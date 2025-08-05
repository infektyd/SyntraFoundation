/*
 * SyntraVoiceManager.swift - TEMPORARILY DISABLED
 * 
 * This voice manager component has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when custom voice functionality may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 */

/*
import Foundation
import OSLog
import Speech
import AVFoundation

#if os(iOS)
import UIKit
#endif

@MainActor
public final class SyntraVoiceManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = SyntraVoiceManager()
    
    // MARK: - Published Properties
    @Published public var isRecording = false
    @Published public var isProcessing = false
    @Published public var transcribedText = ""
    @Published public var errorMessage: String?
    @Published public var isAuthorized = false
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let logger = Logger(subsystem: "SyntraFoundation", category: "VoiceManager")
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupSpeechRecognition()
    }
    
    // MARK: - Public Interface
    public func requestPermissions() async {
        #if os(iOS)
        let authStatus = await SFSpeechRecognizer.authorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            let granted = await SFSpeechRecognizer.requestAuthorization()
            isAuthorized = granted == .authorized
        case .authorized:
            isAuthorized = true
        case .denied, .restricted:
            isAuthorized = false
            errorMessage = "Speech recognition permission denied"
        @unknown default:
            isAuthorized = false
            errorMessage = "Unknown authorization status"
        }
        
        // Also request microphone permission
        let audioAuthStatus = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        if !audioAuthStatus {
            errorMessage = "Microphone permission denied"
        }
        #else
        isAuthorized = false
        errorMessage = "Speech recognition not available on this platform"
        #endif
    }
    
    public func startRecording() async {
        guard isAuthorized else {
            errorMessage = "Speech recognition not authorized"
            return
        }
        
        guard !isRecording else { return }
        
        do {
            try await startSpeechRecognition()
            isRecording = true
            transcribedText = ""
            errorMessage = nil
            logger.info("🎤 Started voice recording")
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
        logger.info("🔇 Stopped voice recording")
    }
    
    public func clearTranscription() {
        transcribedText = ""
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
        #endif
    }
    
    private func startSpeechRecognition() async throws {
        #if os(iOS)
        guard let speechRecognizer = speechRecognizer else {
            throw VoiceError.speechRecognizerNotAvailable
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
            throw VoiceError.recognitionRequestFailed
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
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
        }
        #else
        throw VoiceError.platformNotSupported
        #endif
    }
}

// MARK: - Voice Errors
public enum VoiceError: Error, LocalizedError {
    case speechRecognizerNotAvailable
    case recognitionRequestFailed
    case platformNotSupported
    case microphonePermissionDenied
    case speechRecognizerUnavailable
    case localeNotSupported
    case audioEngineFailure
    
    public var errorDescription: String? {
        switch self {
        case .speechRecognizerNotAvailable:
            return "Speech recognition not available"
        case .recognitionRequestFailed:
            return "Failed to create recognition request"
        case .platformNotSupported:
            return "Voice recognition not supported on this platform"
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

// MARK: - SFSpeechRecognizerDelegate
#if os(iOS)
extension SyntraVoiceManager: SFSpeechRecognizerDelegate {
    @MainActor
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            errorMessage = "Speech recognition became unavailable"
        }
    }
}
#endif

// MARK: - Configuration Integration
extension SyntraVoiceManager {
    public func configure(with voiceConfig: [String: Any]?) {
        guard let voiceConfig = voiceConfig else {
            logger.info("📝 No voice configuration provided")
            return
        }
        
        // Apply voice configuration
        if let locale = voiceConfig["locale"] as? String {
            // Could reconfigure speech recognizer with new locale
            logger.info("⚙️ Voice configured with locale: \(locale)")
        }
        
        logger.info("⚙️ Voice manager configured")
    }
} 
*/ 