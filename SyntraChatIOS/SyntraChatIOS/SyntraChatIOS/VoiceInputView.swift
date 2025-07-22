import SwiftUI
import Speech
import AVFoundation

/// Voice-to-text input component that bypasses iOS/macOS 26 Beta 3 threading crashes
/// Uses Apple's Speech framework instead of TextField for input
@MainActor
struct VoiceInputView: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        VStack(spacing: 16) {
            // Voice input button
            Button(action: toggleRecording) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title)
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
            
            // Status indicator
            if isRecording {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Listening...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Transcribed text display
            if !text.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcribed Text:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(text)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.thinMaterial)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onAppear {
            requestSpeechRecognitionPermission()
        }
    }
    
    // MARK: - Speech Recognition Methods
    
    private func isSpeechRecognitionAvailable() -> Bool {
        return speechRecognizer?.isAvailable == true
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                // Handle authorization status
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
        // CRITICAL: Ensure audio operations on main thread - Beta 3 threading fix
        DispatchQueue.main.async {
            guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
                print("Speech recognition not available")
                return
            }
            
            // Configure audio session
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to configure audio session: \(error)")
                return
            }
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                print("Unable to create recognition request")
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            
            // Start recognition task
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self.text = result.bestTranscription.formattedString
                    }
                    
                    if error != nil || result?.isFinal == true {
                        self.stopRecording()
                    }
                }
            }
            
            // Configure audio input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            // Start audio engine
            do {
                audioEngine.prepare()
                try audioEngine.start()
                isRecording = true
            } catch {
                print("Failed to start audio engine: \(error)")
                stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        // CRITICAL: Ensure audio operations on main thread - Beta 3 threading fix
        DispatchQueue.main.async {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            
            isRecording = false
            recognitionRequest = nil
            recognitionTask = nil
        }
    }
} 