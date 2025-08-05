/*
 * HoldToTalkRecorder.swift - TEMPORARILY DISABLED
 * 
 * This Hold-to-Talk recorder component has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when custom voice recording functionality may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 */

/*
import Foundation
import OSLog
import Speech
import AVFoundation
import Combine

#if os(iOS)
import UIKit
#endif

@MainActor
public final class HoldToTalkRecorder: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isRecording = false
    @Published public var isProcessing = false
    @Published public var transcriptionText = ""
    @Published public var errorMessage: String?
    @Published public var isAvailable = false
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let logger = Logger(subsystem: "SyntraFoundation", category: "HoldToTalkRecorder")
    
    #if os(iOS)
    private var audioSession: AVAudioSession?
    #endif
    
    // MARK: - Recording History
    public struct RecordingSession: Identifiable, Codable {
        public let id = UUID()
        public let timestamp: Date
        public let duration: TimeInterval
        public let audioFileURL: URL
        public let transcriptionText: String?
        
        public init(timestamp: Date, duration: TimeInterval, audioFileURL: URL, transcriptionText: String? = nil) {
            self.timestamp = timestamp
            self.duration = duration
            self.audioFileURL = audioFileURL
            self.transcriptionText = transcriptionText
        }
    }
    
    @Published public var recordingSessions: [RecordingSession] = []
    
    // MARK: - Initialization
    public init() {
        setupSpeechRecognition()
        loadRecordingSessions()
    }
    
    // MARK: - Public Interface
    public func startRecording() async {
        guard isAvailable else {
            errorMessage = "Voice recording is not available"
            return
        }
        
        guard !isRecording else { return }
        
        do {
            try await requestPermissions()
            try await startSFSpeechRecognizer()
            
            isRecording = true
            transcriptionText = ""
            errorMessage = nil
            
            logger.info("🎤 Started hold-to-talk recording")
            
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            logger.error("❌ Recording start failed: \(error.localizedDescription)")
        }
    }
    
    public func stopRecording() async {
        guard isRecording else { return }
        
        isRecording = false
        isProcessing = true
        
        // Stop audio engine
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        // Wait for final transcription
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        isProcessing = false
        logger.info("🔇 Stopped hold-to-talk recording")
    }
    
    public func clearTranscription() {
        transcriptionText = ""
        errorMessage = nil
    }
    
    // MARK: - Private Implementation
    private func setupSpeechRecognition() {
        #if os(iOS)
        guard let speechRecognizer = speechRecognizer else {
            errorMessage = "Speech recognition not available"
            return
        }
        
        speechRecognizer.delegate = self
        
        // Configure for continuous recognition
        speechRecognizer.defaultTaskHint = .dictation
        
        // Check availability
        isAvailable = speechRecognizer.isAvailable
        #else
        isAvailable = false
        errorMessage = "Speech recognition not available on this platform"
        #endif
    }
    
    private func startSFSpeechRecognizer() async throws {
        #if os(iOS)
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale.current) else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        guard speechRecognizer.isAvailable else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceError.speechRecognizerUnavailable
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Recognition error: \(error.localizedDescription)"
                    self.logger.error("❌ Recognition error: \(error.localizedDescription)")
                }
                return
            }
            
            if let result = result {
                Task { @MainActor in
                    self.transcriptionText = result.bestTranscription.formattedString
                }
            }
        }
        #else
        throw VoiceError.platformNotSupported
        #endif
    }
    
    private func requestPermissions() async throws {
        #if os(iOS)
        // Request speech recognition permission
        let speechStatus = await SFSpeechRecognizer.authorizationStatus()
        
        switch speechStatus {
        case .notDetermined:
            let granted = await SFSpeechRecognizer.requestAuthorization()
            guard granted == .authorized else {
                throw VoiceError.microphonePermissionDenied
            }
        case .authorized:
            break
        case .denied, .restricted:
            throw VoiceError.microphonePermissionDenied
        @unknown default:
            throw VoiceError.microphonePermissionDenied
        }
        
        // Request microphone permission
        let status = await AVAudioSession.sharedInstance().requestRecordPermission()
        guard status else {
            throw VoiceError.microphonePermissionDenied
        }
        #else
        let status = true // macOS handles this differently
        #endif
        guard status else {
            throw VoiceError.microphonePermissionDenied
        }
    }
    
    // MARK: - Recording Session Management
    private func saveRecordingSessions() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionsURL = documentsPath.appendingPathComponent("recordingSessions.json")
        
        do {
            let data = try JSONEncoder().encode(recordingSessions)
            try data.write(to: sessionsURL)
            logger.info("💾 Saved \(recordingSessions.count) recording sessions")
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
            logger.info("📁 Loaded \(self.recordingSessions.count) recording sessions")
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

// Use the VoiceError from SyntraVoiceManager instead of duplicating 

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
*/
