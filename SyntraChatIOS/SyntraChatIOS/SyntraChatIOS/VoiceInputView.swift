import SwiftUI
import Speech
import AVFoundation

/// Modern voice-to-text input using enhanced SFSpeechRecognizer
/// Improved architecture with async/await and better error handling
/// Now supports natural accumulative text input (append instead of replace)
@MainActor
struct VoiceInputView: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var partialResult = ""
    @State private var finalResult = ""
    @State private var accumulatedText = "" // Store accumulated text across sessions
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var hasPermission = false
    @State private var sessionStartTime = Date()
    
    // Track available text for the Use Text button
    private var hasAvailableText: Bool {
        !accumulatedText.isEmpty || !finalResult.isEmpty || !partialResult.isEmpty
    }
    
    private var combinedText: String {
        let baseText = accumulatedText.isEmpty ? "" : accumulatedText + " "
        
        if !finalResult.isEmpty {
            return baseText + finalResult
        } else if !partialResult.isEmpty {
            return baseText + partialResult
        } else {
            return accumulatedText
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Voice input button with hold-to-talk design
            Button(action: {}) {
                HStack {
                    Image(systemName: isRecording ? "mic.fill" : "mic.circle")
                        .font(.title)
                        .foregroundStyle(isRecording ? .red : .blue)
                    Text(isRecording ? "Recording..." : "Hold to Speak")
                        .font(.headline)
                }
                .foregroundColor(isRecording ? .red : .blue)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .stroke(isRecording ? .red : .blue, lineWidth: 2)
                )
                .scaleEffect(isRecording ? 1.05 : 1.0) // Visual feedback when pressed
                .animation(.easeInOut(duration: 0.1), value: isRecording)
            }
            .disabled(!isSpeechRecognitionAvailable())
            .simultaneousGesture(
                // Hold-to-talk gesture: press to start, release to stop
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isRecording && isSpeechRecognitionAvailable() {
                            // Haptic feedback for press confirmation
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            SyntraLogger.logUI("User pressed hold-to-talk button")
                            startRecording()
                        }
                    }
                    .onEnded { _ in
                        if isRecording {
                            // Light haptic feedback for release
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            SyntraLogger.logUI("User released hold-to-talk button")
                            stopRecording()
                        }
                    }
            )
            
            // Real-time status indicator
            if isRecording {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Listening with Enhanced Speech Recognition...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("• Release to finish")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            // Live transcription display with improved wrapping
            if hasAvailableText {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Live Transcription:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        // Clear accumulated text button
                        if !accumulatedText.isEmpty {
                            Button("Clear All") {
                                clearAccumulatedText()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
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
                    
                    // Enhanced text display with proper wrapping
                    EnhancedCrashSafeTextDisplay(
                        finalText: combinedText,
                        partialText: isRecording ? partialResult : ""
                    )
                    .allowsHitTesting(false)   // Prevent any touch interaction
                    
                    // Use Text button directly in the voice input view
                    HStack {
                        // Show word count for longer text
                        if combinedText.split(separator: " ").count > 10 {
                            Text("\(combinedText.split(separator: " ").count) words")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Use This Text") {
                            useCurrentText()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!hasAvailableText)
                    }
                    .padding(.top, 8)
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
                    Text(hasPermission ? "Ready for speech input • Hold button to speak" : "Permission required")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .onAppear {
            requestSpeechPermission()
            // Initialize accumulated text with current binding value
            if !text.isEmpty && accumulatedText.isEmpty {
                accumulatedText = text
            }
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
        SyntraLogger.logUI("Requesting speech recognition permission...")
        Task {
            do {
                let authStatus = await SFSpeechRecognizer.requestAuthorization()
                await MainActor.run {
                    hasPermission = authStatus == .authorized
                    SyntraLogger.logUI("Speech recognition permission result: \(authStatus == .authorized ? "granted" : "denied")")
                }
                print("[VoiceInputView] Speech recognition permission: \(authStatus.rawValue)")
            }
        }
    }
    
    private func useCurrentText() {
        let textToUse = combinedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !textToUse.isEmpty {
            text = textToUse
            SyntraLogger.logUI("User selected transcribed text (\(textToUse.split(separator: " ").count) words)", details: textToUse)
            print("[VoiceInputView] Using accumulated text: \(textToUse)")
        }
    }
    
    private func clearAccumulatedText() {
        accumulatedText = ""
        finalResult = ""
        partialResult = ""
        text = ""
        SyntraLogger.logUI("User cleared all accumulated voice text")
        print("[VoiceInputView] Cleared all accumulated text")
    }
    
    private func startRecording() {
        sessionStartTime = Date()
        SyntraLogger.logUI("Starting enhanced speech recognition session...")
        Task {
            do {
                try await startSpeechRecognition()
            } catch {
                SyntraLogger.logUI("Failed to start voice recording", level: .error, details: error.localizedDescription)
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
            SyntraLogger.logUI("Speech recognizer unavailable", level: .error)
            throw SpeechRecognitionError.recognizerUnavailable
        }
        
        SyntraLogger.logUI("Configuring speech recognition session with on-device processing...")
        
        // Clear current session results (but keep accumulated text)
        finalResult = ""
        partialResult = ""
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            SyntraLogger.logUI("Failed to create speech recognition request", level: .error)
            throw SpeechRecognitionError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Enhanced configuration for better accuracy
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
            recognitionRequest.requiresOnDeviceRecognition = true // Privacy-first
            SyntraLogger.logUI("Enabled on-device speech processing with punctuation")
        }
        
        await MainActor.run {
            // Start recognition task with enhanced result handling
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                Task { @MainActor in
                    if let result = result {
                        let transcription = result.bestTranscription.formattedString
                        
                        if result.isFinal {
                            // Final result - accumulate with previous text
                            if !transcription.isEmpty {
                                // Add to accumulated text with proper spacing
                                if !self.accumulatedText.isEmpty {
                                    self.accumulatedText += " " + transcription
                                } else {
                                    self.accumulatedText = transcription
                                }
                                SyntraLogger.logUI("Speech recognition final result", details: "Accumulated: \(self.accumulatedText)")
                                print("[VoiceInputView] Accumulated text: \(self.accumulatedText)")
                            }
                            
                            self.finalResult = ""
                            self.partialResult = ""
                            
                            // Update the bound text with accumulated content
                            self.text = self.accumulatedText
                            
                            print("[VoiceInputView] Final result accumulated: \(transcription)")
                            self.stopRecording()
                        } else {
                            // Partial result for immediate feedback
                            self.partialResult = transcription
                            
                            // Update bound text with accumulated + current partial
                            let combinedText = self.accumulatedText.isEmpty ? transcription : 
                                self.accumulatedText + " " + transcription
                            self.text = combinedText
                            
                            // Log partial results occasionally to show activity
                            if transcription.split(separator: " ").count % 5 == 0 {
                                SyntraLogger.logUI("Speech recognition in progress", details: "Current: \(transcription)")
                            }
                            
                            print("[VoiceInputView] Partial result: \(transcription)")
                        }
                    }
                    
                    if let error = error {
                        SyntraLogger.logUI("Speech recognition error", level: .error, details: error.localizedDescription)
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
        
        SyntraLogger.logUI("Speech recognition session active", details: "Using accumulative mode with \(bufferSize) buffer size")
        print("[VoiceInputView] Enhanced speech recognition started (accumulative mode)")
    }
    
    private func stopRecording() {
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        
        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End recognition request
        recognitionRequest?.endAudio()
        
        // Cancel recognition task
        recognitionTask?.cancel()
        
        // Update final text binding with accumulated content
        if !accumulatedText.isEmpty {
            text = accumulatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            SyntraLogger.logUI("Voice session completed", details: "Duration: \(String(format: "%.1f", sessionDuration))s, Final text: \(text)")
            print("[VoiceInputView] Stopped recording, accumulated text: \(text)")
        } else {
            SyntraLogger.logUI("Voice session ended with no text captured", details: "Duration: \(String(format: "%.1f", sessionDuration))s")
        }
        
        // Reset state
        isRecording = false
        recognitionRequest = nil
        recognitionTask = nil
        
        print("[VoiceInputView] Speech recognition stopped (session lasted \(Date().timeIntervalSince(sessionStartTime)) seconds)")
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