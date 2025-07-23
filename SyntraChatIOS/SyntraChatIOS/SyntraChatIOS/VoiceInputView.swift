import SwiftUI
import Speech
import AVFoundation

/// Modern voice-to-text input using enhanced SFSpeechRecognizer
/// Improved architecture with async/await and better error handling
@MainActor
struct VoiceInputView: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var partialResult = ""
    @State private var finalResult = ""
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var hasPermission = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Voice input button with modern design
            Button(action: toggleRecording) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title)
                        .foregroundStyle(isRecording ? .red : .blue)
                    Text(isRecording ? "Stop Recording" : "Start Voice Input")
                        .font(.headline)
                }
                .foregroundColor(isRecording ? .red : .blue)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .stroke(isRecording ? .red : .blue, lineWidth: 2)
                )
            }
            .disabled(!isSpeechRecognitionAvailable())
            
            // Real-time status indicator
            if isRecording {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Listening with Enhanced Speech Recognition...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Live transcription display with COMPLETE crash prevention
            if !partialResult.isEmpty || !finalResult.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Live Transcription:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        // Enhanced crash prevention indicator
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("Beta 3 Protected")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // ULTIMATE crash prevention: Use character-by-character display
                    // This completely bypasses all SwiftUI text input mechanisms
                    EnhancedCrashSafeTextDisplay(
                        finalText: finalResult,
                        partialText: partialResult
                    )
                    .allowsHitTesting(false)   // Prevent any touch interaction
                }
            }
            
            // Speech recognition status
            VStack(alignment: .leading, spacing: 8) {
                Text("Speech Recognition Status:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: hasPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(hasPermission ? .green : .orange)
                    Text(hasPermission ? "Ready for speech input" : "Permission required")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            requestSpeechPermission()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    // MARK: - Modern Speech Recognition Methods
    
    private func isSpeechRecognitionAvailable() -> Bool {
        guard let recognizer = speechRecognizer else { return false }
        return recognizer.isAvailable && hasPermission
    }
    
    private func requestSpeechPermission() {
        Task {
            do {
                let authStatus = await SFSpeechRecognizer.requestAuthorization()
                await MainActor.run {
                    hasPermission = authStatus == .authorized
                }
                print("[VoiceInputView] Speech recognition permission: \(authStatus.rawValue)")
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        Task {
            do {
                try await startSpeechRecognition()
            } catch {
                print("[VoiceInputView] Failed to start recording: \(error)")
                await MainActor.run {
                    isRecording = false
                }
            }
        }
    }
    
    private func startSpeechRecognition() async throws {
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerUnavailable
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Enhanced configuration for better accuracy
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
            recognitionRequest.requiresOnDeviceRecognition = true // Privacy-first
        }
        
                 await MainActor.run {
             // Start recognition task with enhanced result handling
             recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                 Task { @MainActor in
                     if let result = result {
                         let transcription = result.bestTranscription.formattedString
                         
                         if result.isFinal {
                             // Final result - stable and accurate
                             self.finalResult = transcription
                             self.partialResult = ""
                             
                             // Update the bound text with final result
                             self.text = transcription
                             
                             print("[VoiceInputView] Final result: \(transcription)")
                             self.stopRecording()
                         } else {
                             // Partial result for immediate feedback
                             self.partialResult = transcription
                             print("[VoiceInputView] Partial result: \(transcription)")
                         }
                     }
                     
                     if let error = error {
                         print("[VoiceInputView] Recognition error: \(error)")
                         self.stopRecording()
                     }
                 }
             }
         }
        
        // Setup audio engine with optimized configuration
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Enhanced buffer size for better performance
        let bufferSize: AVAudioFrameCount = 1024
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        await MainActor.run {
            isRecording = true
        }
        
        print("[VoiceInputView] Enhanced speech recognition started")
    }
    
    private func stopRecording() {
        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        
        // Cancel recognition task
        recognitionTask?.cancel()
        
        // Update final text binding
        let combinedText = finalResult + partialResult
        if !combinedText.isEmpty {
            text = combinedText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Reset state
        isRecording = false
        recognitionRequest = nil
        recognitionTask = nil
        
        print("[VoiceInputView] Speech recognition stopped")
    }
}

// MARK: - Speech Recognition Error Types
enum SpeechRecognitionError: Error, LocalizedError {
    case recognizerUnavailable
    case requestCreationFailed
    case permissionDenied
    case audioEngineError
    
    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available"
        case .requestCreationFailed:
            return "Failed to create recognition request"
        case .permissionDenied:
            return "Speech recognition permission denied"
        case .audioEngineError:
            return "Audio engine configuration failed"
        }
    }
}

// MARK: - SFSpeechRecognizer Authorization Extension
extension SFSpeechRecognizer {
    static func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
} 