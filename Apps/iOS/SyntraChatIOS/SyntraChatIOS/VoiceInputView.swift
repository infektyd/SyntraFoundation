/*
 * VoiceInputView.swift - TEMPORARILY DISABLED
 * 
 * This custom voice-to-text implementation has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when custom voice functionality may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 * 
 * Previous issues:
 * - Custom Swift voice UI is fragile and prone to threading crashes in iOS betas
 * - Complex permission handling and audio session management
 * - Users now get voice input through the native dictation mic that appears automatically
 * 
 * Migration completed: Voice functionality replaced with native UITextView dictation
 */

/*
import SwiftUI
import Speech
import AVFoundation

// This file has been deprecated - voice functionality now provided by native iOS dictation

struct VoiceInputView: View {
    @StateObject private var voiceRecorder = HoldToTalkRecorder()
    @State private var transcribedText = ""
    @State private var isRecording = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // Voice recording button
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isRecording ? .red : .blue)
                    .scaleEffect(isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
            .disabled(!voiceRecorder.isAvailable)
            
            // Status text
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Transcribed text display
            if !transcribedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcription:")
                        .font(.headline)
                    
                    Text(transcribedText)
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.background)
                        )
                        .textSelection(.enabled)
                }
            }
            
            // Error display
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red.opacity(0.1))
                    )
            }
        }
        .padding()
        .onAppear {
            setupVoiceRecorder()
        }
    }
    
    private var statusText: String {
        if !voiceRecorder.isAvailable {
            return "Voice input not available"
        } else if isRecording {
            return "Recording... Tap to stop"
        } else {
            return "Tap to start recording"
        }
    }
    
    private func setupVoiceRecorder() {
        // Setup voice recorder bindings
        voiceRecorder.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: \.isRecording, on: self)
            .store(in: &voiceRecorder.cancellables)
        
        voiceRecorder.$transcriptionText
            .receive(on: DispatchQueue.main)
            .assign(to: \.transcribedText, on: self)
            .store(in: &voiceRecorder.cancellables)
        
        voiceRecorder.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &voiceRecorder.cancellables)
    }
    
    private func startRecording() {
        Task {
            await voiceRecorder.startRecording()
        }
    }
    
    private func stopRecording() {
        Task {
            await voiceRecorder.stopRecording()
        }
    }
}

#Preview {
    VoiceInputView()
} 
*/ 