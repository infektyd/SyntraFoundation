import SwiftUI
import Speech
import AVFoundation

/// Modern voice-to-text input using enhanced SFSpeechRecognizer
/// Improved architecture with async/await and better error handling
/// Now supports natural accumulative text input (append instead of replace)
/// ROBUST: Added debouncing and comprehensive error handling to prevent crashes
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
    
    // ROBUST: Debouncing and state management
    @State private var isProcessingRequest = false
    @State private var debounceTimer: Timer?
    @State private var lastButtonPressTime = Date()
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var recordingStartTime: Date?
    @State private var minimumRecordingDuration: Double = 0.5 // Minimum recording time
    @State private var speechDetectionTimeout: Double = 10.0 // Max recording time
    @State private var speechDetectionTimer: Timer?
    
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
            .disabled(!isSpeechRecognitionAvailable() || isProcessingRequest)
            .simultaneousGesture(
                // Hold-to-talk gesture: press to start, release to stop
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        handleButtonPress()
                    }
                    .onEnded { _ in
                        handleButtonRelease()
                    }
            )
            
            // Real-time status indicator with enhanced feedback
            if isRecording {
                VStack(spacing: 8) {
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
                    
                    // Recording duration indicator
                    if let startTime = recordingStartTime {
                        RecordingDurationView(startTime: startTime, minimumDuration: minimumRecordingDuration)
                    }
                }
            }
            
            // ROBUST: Error display
            if showError, let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.orange.opacity(0.1))
                )
            }
            
            // Use Text button for accumulated content
            if hasAvailableText {
                Button("Use Text") {
                    text = combinedText
                    // Clear accumulated text after use
                    accumulatedText = ""
                    finalResult = ""
                    partialResult = ""
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
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
            Task {
                await checkSpeechRecognitionPermission()
            }
            // Initialize accumulated text with current binding value
            if !text.isEmpty && accumulatedText.isEmpty {
                accumulatedText = text
            }
        }
        .onDisappear {
            // Clean up all timers
            speechDetectionTimer?.invalidate()
            debounceTimer?.invalidate()
            
            Task {
                await stopRecordingSafely()
            }
        }
    }
    
    // MARK: - Modern Speech Recognition Methods
    
    private func isSpeechRecognitionAvailable() -> Bool {
        guard let recognizer = speechRecognizer else { return false }
        return recognizer.isAvailable && hasPermission
    }
    
    private func checkSpeechRecognitionPermission() async {
        SyntraLogger.logUI("Requesting speech recognition permission...")
        do {
            let authStatus = await SFSpeechRecognizer.requestAuthorization()
            await MainActor.run {
                hasPermission = authStatus == .authorized
                SyntraLogger.logUI("Speech recognition permission result: \(authStatus == .authorized ? "granted" : "denied")")
            }
            print("[VoiceInputView] Speech recognition permission: \(authStatus.rawValue)")
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
    
    // ROBUST: Improved button press handling with reduced debouncing
    private func handleButtonPress() {
        let now = Date()
        let timeSinceLastPress = now.timeIntervalSince(lastButtonPressTime)
        
        // Reduced debounce: ignore presses within 200ms (was 500ms - too aggressive)
        guard timeSinceLastPress > 0.2 else {
            SyntraLogger.logUI("Button press debounced", details: "Time since last: \(String(format: "%.2f", timeSinceLastPress))s")
            return
        }
        
        lastButtonPressTime = now
        
        // Cancel any existing debounce timer
        debounceTimer?.invalidate()
        
        // Immediate response - no additional debounce timer
        if !isRecording && isSpeechRecognitionAvailable() && !isProcessingRequest {
            // Haptic feedback for press confirmation
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            SyntraLogger.logUI("User pressed hold-to-talk button (improved)")
            
            // Start recording immediately
            Task { @MainActor in
                await startRecordingSafely()
            }
        }
    }
    
    // ROBUST: Enhanced button release handling with minimum recording time
    private func handleButtonRelease() {
        debounceTimer?.invalidate()
        speechDetectionTimer?.invalidate()
        
        if isRecording && !isProcessingRequest {
            // Check minimum recording duration
            let recordingDuration = recordingStartTime.map { Date().timeIntervalSince($0) } ?? 0
            
            if recordingDuration < minimumRecordingDuration {
                SyntraLogger.logUI("Recording too short, extending to minimum duration", details: "Duration: \(String(format: "%.2f", recordingDuration))s")
                
                // Extend recording to minimum duration
                DispatchQueue.main.asyncAfter(deadline: .now() + (minimumRecordingDuration - recordingDuration)) {
                    Task { @MainActor in
                        await self.stopRecordingSafely()
                    }
                }
            } else {
                // Light haptic feedback for release
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                SyntraLogger.logUI("User released hold-to-talk button", details: "Duration: \(String(format: "%.2f", recordingDuration))s")
                Task { @MainActor in
                    await stopRecordingSafely()
                }
            }
        }
    }
    
    // ROBUST: Safe recording start with comprehensive error handling
    private func startRecordingSafely() async {
        guard !isProcessingRequest else {
            SyntraLogger.logUI("Recording request ignored - already processing", level: .warning)
            return
        }
        
        isProcessingRequest = true
        showError = false
        errorMessage = nil
        
        do {
            // Check audio session
            try await configureAudioSession()
            
            // Check speech recognition availability
            guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
                throw SpeechRecognitionError.recognizerUnavailable
            }
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                throw SpeechRecognitionError.requestCreationFailed
            }
            
            // Configure request
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false
            
            // ROBUST: Ensure audio engine is in clean state
            if audioEngine.isRunning {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            // Reset audio engine
            audioEngine = AVAudioEngine()
            
            // Setup audio engine with proper error handling
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Enhanced buffer size for better performance
            let bufferSize: AVAudioFrameCount = 1024
            
            // ROBUST: Install tap with proper error handling
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            // Prepare and start audio engine
            audioEngine.prepare()
            try audioEngine.start()
            
            // Start recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                Task { @MainActor in
                    await handleRecognitionResult(result: result, error: error)
                }
            }
            
            // Update UI state
            isRecording = true
            sessionStartTime = Date()
            recordingStartTime = Date()
            
            // Set up speech detection timeout to prevent indefinite recording
            speechDetectionTimer = Timer.scheduledTimer(withTimeInterval: speechDetectionTimeout, repeats: false) { _ in
                Task { @MainActor in
                    SyntraLogger.logUI("Speech detection timeout reached", details: "Max duration: \(self.speechDetectionTimeout)s")
                    await self.stopRecordingSafely()
                }
            }
            
            SyntraLogger.logUI("Speech recognition session active", details: "Using accumulative mode with \(bufferSize) buffer size, timeout: \(speechDetectionTimeout)s")
            print("[VoiceInputView] Enhanced speech recognition started (accumulative mode)")
            
        } catch {
            await handleRecordingError(error)
        }
        
        isProcessingRequest = false
    }
    
    // ROBUST: Safe recording stop with enhanced cleanup
    private func stopRecordingSafely() async {
        guard !isProcessingRequest else {
            SyntraLogger.logUI("Stop request ignored - already processing", level: .warning)
            return
        }
        
        isProcessingRequest = true
        
        // Clean up timers
        speechDetectionTimer?.invalidate()
        speechDetectionTimer = nil
        
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        let recordingDuration = recordingStartTime.map { Date().timeIntervalSince($0) } ?? 0
        
        // Stop audio engine safely
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
            SyntraLogger.logUI("Voice session completed successfully", details: "Recording: \(String(format: "%.1f", recordingDuration))s, Total: \(String(format: "%.1f", sessionDuration))s, Words: \(text.split(separator: " ").count)")
            print("[VoiceInputView] Stopped recording, accumulated text: \(text)")
        } else if recordingDuration < minimumRecordingDuration {
            SyntraLogger.logUI("Voice session too short for reliable detection", details: "Recording: \(String(format: "%.1f", recordingDuration))s (minimum: \(minimumRecordingDuration)s)")
        } else {
            SyntraLogger.logUI("Voice session ended with no text captured", details: "Recording: \(String(format: "%.1f", recordingDuration))s, may need to speak louder or closer to device")
        }
        
        // Reset state
        isRecording = false
        recordingStartTime = nil
        recognitionRequest = nil
        recognitionTask = nil
        
        print("[VoiceInputView] Speech recognition stopped (session lasted \(Date().timeIntervalSince(sessionStartTime)) seconds)")
        
        isProcessingRequest = false
    }
    
    // ROBUST: Audio session configuration
    private func configureAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw SpeechRecognitionError.audioEngineError
        }
    }
    
    // ROBUST: Enhanced error handling with complete cleanup
    private func handleRecordingError(_ error: Error) async {
        SyntraLogger.logUI("Speech recognition error", level: .error, details: error.localizedDescription)
        print("[VoiceInputView] Recording error: \(error)")
        
        // Clean up all timers
        speechDetectionTimer?.invalidate()
        speechDetectionTimer = nil
        debounceTimer?.invalidate()
        
        // Reset audio engine state
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Update UI with error
        errorMessage = "Speech recognition failed: \(error.localizedDescription)"
        showError = true
        isRecording = false
        recordingStartTime = nil
        isProcessingRequest = false
        
        // Auto-hide error after 7 seconds (increased for better readability)
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            showError = false
            errorMessage = nil
        }
    }
    
    // ROBUST: Enhanced recognition result handling
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) async {
        if let result = result {
            let transcription = result.bestTranscription.formattedString
            
            if result.isFinal {
                // Final result - accumulate and stop
                if !transcription.isEmpty {
                    if accumulatedText.isEmpty {
                        accumulatedText = transcription
                    } else {
                        accumulatedText += " " + transcription
                    }
                }
                
                finalResult = transcription
                SyntraLogger.logUI("Speech recognition final result", details: "Transcription: \(transcription)")
                print("[VoiceInputView] Final result accumulated: \(transcription)")
                await stopRecordingSafely()
            } else {
                // Partial result for immediate feedback
                partialResult = transcription
                
                // Update bound text with accumulated + current partial
                let combinedText = accumulatedText.isEmpty ? transcription : 
                    accumulatedText + " " + transcription
                text = combinedText
                
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
            await stopRecordingSafely()
        }
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

// MARK: - Recording Duration View
struct RecordingDurationView: View {
    let startTime: Date
    let minimumDuration: Double
    @State private var currentDuration: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 8) {
            // Duration indicator
            Text(String(format: "%.1fs", currentDuration))
                .font(.caption)
                .foregroundColor(currentDuration >= minimumDuration ? .green : .orange)
                .bold()
            
            // Progress bar for minimum duration
            ProgressView(value: min(currentDuration / minimumDuration, 1.0))
                .frame(width: 60)
                .progressViewStyle(.linear)
                .tint(currentDuration >= minimumDuration ? .green : .orange)
            
            // Status text
            Text(currentDuration >= minimumDuration ? "Ready" : "Keep talking...")
                .font(.caption2)
                .foregroundColor(currentDuration >= minimumDuration ? .green : .orange)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentDuration = Date().timeIntervalSince(startTime)
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