/*
 * SyntraVoiceView.swift - TEMPORARILY DISABLED
 * 
 * This voice view component has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when custom voice UI may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 */

/*
import SwiftUI
import Combine

@MainActor
public struct SyntraVoiceView: View {
    @StateObject private var voiceBridge = SyntraVoiceBridge()
    @State private var showingTranscript = false
    @State private var textInput = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Voice Status Header
                voiceStatusHeader
                
                // Main Voice Interface
                mainVoiceInterface
                
                // Response Display
                responseDisplay
                
                // Text Input Fallback
                textInputFallback
                
                Spacer()
            }
            .padding()
            .navigationTitle("SYNTRA Voice")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                setupConsciousnessProcessor()
            }
        }
    }
    
    @ViewBuilder
    private var voiceStatusHeader: some View {
        HStack {
            Image(systemName: voiceBridge.isProcessing ? "waveform" : "mic")
                .font(.title2)
                .foregroundColor(voiceBridge.isProcessing ? .red : .accentColor)
                .symbolEffect(.pulse, isActive: voiceBridge.isProcessing)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("SYNTRA Voice Interface")
                    .font(.headline)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if voiceBridge.isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder
    private var mainVoiceInterface: some View {
        VStack(spacing: 16) {
            
            // Voice Input Button - TEMPORARILY DISABLED (using native voice input)
            /*
            PTTButton(
                isEnabled: !voiceBridge.isProcessing,
                onStart: {
                    Task {
                        await voiceBridge.startVoiceInput()
                    }
                },
                onStop: {
                    Task {
                        await voiceBridge.stopVoiceInput()
                    }
                }
            )
            */
            
            // Native voice input placeholder
            Text("Voice input is now handled through native iOS keyboard dictation")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            // Transcript Preview
            if !voiceBridge.lastTranscript.isEmpty {
                transcriptPreview
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder
    private var transcriptPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Last Transcript:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("View Details") {
                    showingTranscript = true
                }
                .font(.caption)
            }
            
            Text(voiceBridge.lastTranscript)
                .font(.body)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.background)
                )
                .lineLimit(3)
        }
        .sheet(isPresented: $showingTranscript) {
            transcriptDetailView
        }
    }
    
    @ViewBuilder
    private var transcriptDetailView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Voice Transcript")
                        .font(.headline)
                    
                    Text(voiceBridge.lastTranscript)
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.background)
                        )
                        .textSelection(.enabled)
                    
                    if !voiceBridge.consciousnessResponse.isEmpty {
                        Text("SYNTRA Response")
                            .font(.headline)
                        
                        Text(voiceBridge.consciousnessResponse)
                            .font(.body)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.secondary.opacity(0.1))
                            )
                            .textSelection(.enabled)
                    }
                }
                .padding()
            }
            .navigationTitle("Voice Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                showingTranscript = false
            })
            #else
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        showingTranscript = false
                    }
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private var responseDisplay: some View {
        if !voiceBridge.consciousnessResponse.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text("SYNTRA Response")
                        .font(.headline)
                    
                    Spacer()
                }
                
                Text(voiceBridge.consciousnessResponse)
                    .font(.body)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.secondary.opacity(0.1))
                    )
                    .textSelection(.enabled)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    @ViewBuilder
    private var textInputFallback: some View {
        VStack(spacing: 12) {
            Text("Text Input Fallback")
                .font(.headline)
            
            TextField("Type your message...", text: $textInput, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
            
            Button("Send") {
                // Process text input
                Task {
                    await processTextInput(textInput)
                    textInput = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Helper Methods
    private var statusText: String {
        if voiceBridge.isProcessing {
            return "Processing voice input..."
        } else if voiceBridge.isRecording {
            return "Recording voice input..."
        } else if !voiceBridge.errorMessage.isNilOrEmpty {
            return voiceBridge.errorMessage ?? "Error occurred"
        } else {
            return "Ready for voice input"
        }
    }
    
    private func setupConsciousnessProcessor() {
        // For now, use mock processor
        // TODO: Connect to real SYNTRA consciousness system
        let mockProcessor = MockConsciousnessProcessor()
        voiceBridge.setConsciousnessProcessor(mockProcessor)
    }
    
    private func processTextInput(_ input: String) async {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        voiceBridge.lastTranscript = input
        voiceBridge.isProcessing = true
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock response
        voiceBridge.consciousnessResponse = "SYNTRA: I understand you typed '\(input)'. This is a placeholder response while the consciousness system is being integrated."
        
        voiceBridge.isProcessing = false
    }
}

// MARK: - String Extension
extension String {
    var isNilOrEmpty: Bool {
        return self.isEmpty
    }
}

#Preview {
    SyntraVoiceView()
} 
*/ 