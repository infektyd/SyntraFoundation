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
    
    // MARK: - Initialization
    public init() {
        Task {
            await setupAudioSession()
            await checkAvailability()
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
        let status = await AVAudioSession.sharedInstance().requestRecordPermission()
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