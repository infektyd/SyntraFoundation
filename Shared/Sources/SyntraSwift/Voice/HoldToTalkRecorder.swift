/*
 * HoldToTalkRecorder.swift - DEPRECATED
 * 
 * This custom voice recording implementation has been deprecated as part of the migration
 * to Apple's native dictation support. Voice input is now provided automatically through
 * native UITextView components with built-in dictation functionality.
 * 
 * Migration date: Based on os changes.md plan
 * Replacement: Native iOS dictation through keyboard mic button
 */

import Foundation
import AVFoundation
import Speech
import OSLog

// iOS 26+ SpeechAnalyzer - falls back to SFSpeechRecognizer on older versions
#if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
import SpeechAnalyzer
#endif

@MainActor
public final class HoldToTalkRecorder: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isRecording = false
    @Published public var transcriptionText = ""
    @Published public var isAvailable = false
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    private let audioEngine = AVAudioEngine()
    
    #if os(iOS)
    private var audioSession: AVAudioSession?
    #endif
    
    // iOS 26+ SpeechAnalyzer integration
    #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
    @available(iOS 26.0, macOS 26.0, *)
    private var analyzer: SpeechAnalyzer?
    @available(iOS 26.0, macOS 26.0, *)
    private var transcriber: SpeechTranscriber?
    @available(iOS 26.0, macOS 26.0, *)
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?
    @available(iOS 26.0, macOS 26.0, *)
    private var analyzerFormat: AVAudioFormat?
    #endif
    
    // Fallback to SFSpeechRecognizer for iOS < 26
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var transcriptionTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "SyntraFoundation", category: "VoiceInput")
    
    // MARK: - Audio File Storage
    private var isStoringAudio = true // Enable audio file storage
    private var currentRecordingURL: URL?
    private var audioFileWriter: AVAudioFile?
    
    // MARK: - Recording History
    public struct RecordingSession: Identifiable, Codable {
        public let id = UUID()
        public let timestamp: Date
        public let duration: TimeInterval
        public let transcript: String
        public let audioFileURL: URL
        public let fileSize: Int64
        
        public init(timestamp: Date, duration: TimeInterval, transcript: String, audioFileURL: URL, fileSize: Int64) {
            self.timestamp = timestamp
            self.duration = duration
            self.transcript = transcript
            self.audioFileURL = audioFileURL
            self.fileSize = fileSize
        }
    }

    @Published public var recordingSessions: [RecordingSession] = []
    
    // MARK: - Initialization
    public init() {
        Task {
            await setupAudioSession()
            await checkAvailability()
            loadRecordingSessions()
        }
    }
    
    deinit {
        // Cannot call async methods during deinit in Swift 6 concurrency mode
        // Cleanup will happen when recording stops or app lifecycle events occur
        transcriptionTask?.cancel()
    }
    
    // MARK: - Public Interface
    public func startRecording() async {
        guard !isRecording else { return }
        
        do {
            try await requestMicrophonePermission()
            try await prepareAudioEngine()
            
            // Setup audio file writer for recording storage
            try setupAudioFileWriter()
            
            #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
            if #available(iOS 26.0, macOS 26.0, *) {
                try await startSpeechAnalyzer()
            } else {
                try await startSFSpeechRecognizer()
            }
            #else
            try await startSFSpeechRecognizer()
            #endif
            
            try audioEngine.start()
            isRecording = true
            errorMessage = nil
            
            logger.info("🎙️ Voice recording started")
            
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            logger.error("❌ Recording start failed: \(error.localizedDescription)")
        }
    }
    
    public func stopRecording() async {
        guard isRecording else { return }
        
        let recordingDuration = Date().timeIntervalSince(Date()) // Will calculate properly
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
        if #available(iOS 26.0, macOS 26.0, *) {
            inputContinuation?.finish()
            try? await analyzer?.finalizeAndFinishThroughEndOfInput()
        }
        #endif
        
        // Fallback cleanup
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
        recognitionTask = nil
        recognitionRequest = nil
        
        // Finalize audio recording with transcript
        finalizeRecording(transcript: transcriptionText, duration: recordingDuration)
        
        transcriptionTask?.cancel()
        transcriptionTask = nil
        
        isRecording = false
        logger.info("🛑 Voice recording stopped")
    }
    
    // MARK: - iOS 26+ SpeechAnalyzer Implementation
    #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
    @available(iOS 26.0, macOS 26.0, *)
    private func startSpeechAnalyzer() async throws {
        let locale = Locale.current
        
        // Ensure model availability
        guard await SpeechTranscriber.supportedLocales.contains(where: { 
            $0.identifier(.bcp47) == locale.identifier(.bcp47) 
        }) else {
            throw VoiceError.localeNotSupported
        }
        
        // Download model if needed
        transcriber = SpeechTranscriber(locale: locale, preset: .progressiveLiveTranscription)
        
        let isModelInstalled = await SpeechTranscriber.installedLocales.contains { installedLocale in
            installedLocale.identifier(.bcp47) == locale.identifier(.bcp47)
        }
        
        if !isModelInstalled {
            try await downloadModelIfNeeded()
        }
        
        // Setup analyzer
        analyzer = SpeechAnalyzer(modules: [transcriber!])
        analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber!])
        
        // Create input stream
        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        inputContinuation = inputBuilder
        
        try await analyzer?.start(inputSequence: inputSequence)
        
        // Start collecting results
        transcriptionTask = Task { [weak self] in
            guard let transcriber = self?.transcriber else { return }
            
            for try await result in transcriber.results {
                await MainActor.run {
                    if result.isFinal {
                        self?.transcriptionText = result.text
                        self?.logger.info("📝 Final transcript: \(result.text)")
                    } else {
                        // Show volatile results for immediate feedback
                        self?.transcriptionText = result.text
                    }
                }
            }
        }
        
        logger.info("🧠 SpeechAnalyzer initialized successfully")
    }
    
    @available(iOS 26.0, macOS 26.0, *)
    private func downloadModelIfNeeded() async throws {
        guard let transcriber = transcriber else { return }
        
        if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            logger.info("📥 Downloading speech model...")
            try await downloader.downloadAndInstall()
            logger.info("✅ Speech model downloaded successfully")
        }
    }
    #endif
    
    // MARK: - Fallback SFSpeechRecognizer Implementation
    private func startSFSpeechRecognizer() async throws {
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale.current) else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        guard speechRecognizer.isAvailable else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        self.speechRecognizer = speechRecognizer
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.transcriptionText = result.bestTranscription.formattedString
                    if result.isFinal {
                        self?.logger.info("📝 Final transcript (SFSpeechRecognizer): \(result.bestTranscription.formattedString)")
                    }
                }
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.logger.error("❌ SFSpeechRecognizer error: \(error.localizedDescription)")
                }
            }
        }
        
        logger.info("🧠 SFSpeechRecognizer initialized successfully")
    }
    
    // MARK: - Audio Engine Setup
    private func prepareAudioEngine() async throws {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // Install audio tap for processing
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, time in
            Task { [weak self] in
                await self?.processAudioBuffer(buffer)
            }
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) async {
        // Write audio buffer to file if recording
        writeAudioBuffer(buffer)
        
        #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
        if #available(iOS 26.0, macOS 26.0, *), let continuation = inputContinuation, let analyzerFormat = analyzerFormat {
            // Convert buffer format if needed
            if buffer.format == analyzerFormat {
                continuation.yield(AnalyzerInput(buffer: buffer))
            } else {
                // Format conversion would go here if needed
                continuation.yield(AnalyzerInput(buffer: buffer))
            }
        } else {
            // Fallback to SFSpeechRecognizer
            recognitionRequest?.append(buffer)
        }
        #else
        // Fallback to SFSpeechRecognizer
        recognitionRequest?.append(buffer)
        #endif
    }
    
    // MARK: - Audio Session Management
    private func setupAudioSession() async {
        #if os(iOS)
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers])
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("❌ Audio session setup failed: \(error.localizedDescription)")
            errorMessage = "Audio session setup failed"
        }
        #endif
    }
    
    private func requestMicrophonePermission() async throws {
        #if os(iOS)
        // FIX: MUST explicitly run permission request on main queue to prevent threading crashes
        let status = await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        #else
        // For macOS, we don't need to request audio session permission
        let status = true // macOS handles this differently
        #endif
        guard status else {
            throw VoiceError.microphonePermissionDenied
        }
    }
    
    // MARK: - Availability Checking
    private func checkAvailability() async {
        // Check speech recognition permission
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    guard status == .authorized else {
                        self.errorMessage = "Speech recognition permission denied"
                        self.isAvailable = false
                        continuation.resume()
                        return
                    }
                    
                    // Check if any speech recognizer is available
                    #if canImport(SpeechAnalyzer) && (os(iOS) || os(macOS))
                    if #available(iOS 26.0, macOS 26.0, *) {
                        self.isAvailable = await !SpeechTranscriber.supportedLocales.isEmpty
                    } else {
                        self.isAvailable = SFSpeechRecognizer(locale: Locale.current)?.isAvailable ?? false
                    }
                    #else
                    self.isAvailable = SFSpeechRecognizer(locale: Locale.current)?.isAvailable ?? false
                    #endif
                    
                    self.logger.info("🔍 Voice input availability: \(self.isAvailable)")
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Audio File Management
    private func createRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingsPath = documentsPath.appendingPathComponent("VoiceRecordings", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
        
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        return recordingsPath.appendingPathComponent("recording_\(timestamp).m4a")
    }

    private func setupAudioFileWriter() throws {
        guard isStoringAudio else { return }
        
        currentRecordingURL = createRecordingURL()
        
        guard let recordingURL = currentRecordingURL else {
            throw RecordingError.audioFileCreationFailed
        }
        
        // Setup audio format for recording (AAC in m4a container)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        let audioFormat = AVAudioFormat(settings: settings)!
        audioFileWriter = try AVAudioFile(forWriting: recordingURL, settings: audioFormat.settings)
        
        logger.info("📁 Audio file writer created: \(recordingURL.lastPathComponent)")
    }

    private func writeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let writer = audioFileWriter else { return }
        
        do {
            try writer.write(from: buffer)
        } catch {
            logger.error("❌ Failed to write audio buffer: \(error.localizedDescription)")
        }
    }

    private func finalizeRecording(transcript: String, duration: TimeInterval) {
        guard let recordingURL = currentRecordingURL else { return }
        
        // Get file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: recordingURL.path)[.size] as? Int64) ?? 0
        
        // Create recording session
        let session = RecordingSession(
            timestamp: Date(),
            duration: duration,
            transcript: transcript,
            audioFileURL: recordingURL,
            fileSize: fileSize
        )
        
        // Add to sessions and save to disk
        recordingSessions.append(session)
        saveRecordingSessions()
        
        logger.info("💾 Recording saved: \(recordingURL.lastPathComponent) (\(fileSize) bytes)")
        
        // Clean up
        audioFileWriter = nil
        currentRecordingURL = nil
    }
    
    // MARK: - Recording Session Persistence
    private func saveRecordingSessions() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionsURL = documentsPath.appendingPathComponent("recordingSessions.json")
        
        do {
            let data = try JSONEncoder().encode(recordingSessions)
            try data.write(to: sessionsURL)
            logger.info("💾 Recording sessions saved")
        } catch {
            logger.error("❌ Failed to save recording sessions: \(error.localizedDescription)")
        }
    }
    
    private func loadRecordingSessions() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionsURL = documentsPath.appendingPathComponent("recordingSessions.json")
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            recordingSessions = try JSONDecoder().decode([RecordingSession].self, from: data)
            logger.info("📁 Loaded \(recordingSessions.count) recording sessions")
        } catch {
            logger.info("📁 No previous recording sessions found")
            recordingSessions = []
        }
    }
    
    // MARK: - Public Recording Management
    public func deleteRecording(_ session: RecordingSession) {
        // Remove file
        try? FileManager.default.removeItem(at: session.audioFileURL)
        
        // Remove from array
        recordingSessions.removeAll { $0.id == session.id }
        saveRecordingSessions()
        
        logger.info("🗑️ Recording deleted: \(session.audioFileURL.lastPathComponent)")
    }
    
    public func getRecordingDuration(_ session: RecordingSession) async -> TimeInterval? {
        do {
            let audioFile = try AVAudioFile(forReading: session.audioFileURL)
            let frameCount = AVAudioFrameCount(audioFile.length)
            let sampleRate = audioFile.fileFormat.sampleRate
            return Double(frameCount) / sampleRate
        } catch {
            logger.error("❌ Failed to get duration for \(session.audioFileURL.lastPathComponent): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() async {
        if isRecording {
            await stopRecording()
        }
        
        #if os(iOS)
        try? audioSession?.setActive(false)
        #endif
    }
}

// MARK: - Error Types
public enum VoiceError: LocalizedError {
    case microphonePermissionDenied
    case speechRecognizerUnavailable
    case localeNotSupported
    case audioEngineFailure
    
    public var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission is required for voice input"
        case .speechRecognizerUnavailable:
            return "Speech recognition is not available on this device"
        case .localeNotSupported:
            return "Current locale is not supported for speech recognition"
        case .audioEngineFailure:
            return "Audio engine failed to start"
        }
    }
} 

// MARK: - Error Types
public enum RecordingError: Error, LocalizedError {
    case permissionDenied
    case audioEngineStartFailed
    case speechRecognitionUnavailable
    case audioFileCreationFailed
    case microphoneUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission denied"
        case .audioEngineStartFailed:
            return "Failed to start audio engine"
        case .speechRecognitionUnavailable:
            return "Speech recognition not available"
        case .audioFileCreationFailed:
            return "Failed to create audio file"
        case .microphoneUnavailable:
            return "Microphone not available"
        }
    }
} 