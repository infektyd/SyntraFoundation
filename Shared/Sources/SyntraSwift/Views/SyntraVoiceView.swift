/*
 * SyntraVoiceView.swift - DEPRECATED
 * 
 * This voice view component has been deprecated as part of the migration to Apple's
 * native dictation support. Voice input is now integrated directly into standard
 * text input fields through the native iOS keyboard dictation button.
 * 
 * Migration date: Based on os changes.md plan
 * Replacement: Standard text input with built-in dictation
 */

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
            
            // Voice Input Button
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
                    
                    Text("SYNTRA Consciousness Response")
                        .font(.headline)
                    
                    Spacer()
                }
                
                ScrollView {
                    Text(voiceBridge.consciousnessResponse)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.purple.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.purple.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    @ViewBuilder
    private var textInputFallback: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Text Input Alternative")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Type your message...", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    Task {
                        await processTextInput()
                    }
                }
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    // MARK: - Error Display
    @ViewBuilder
    private var errorDisplay: some View {
        if let errorMessage = voiceBridge.errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Button("Dismiss") {
                    voiceBridge.errorMessage = nil
                }
                .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.orange.opacity(0.1))
            )
        }
    }
    
    // MARK: - Helper Properties
    private var statusText: String {
        if voiceBridge.isProcessing {
            return "Processing voice input..."
        } else if !voiceBridge.lastTranscript.isEmpty {
            return "Ready for voice input"
        } else {
            return "Hold button to talk"
        }
    }
    
    // MARK: - Helper Methods
    private func setupConsciousnessProcessor() {
        // For now, use mock processor
        // TODO: Connect to real SYNTRA consciousness system
        let mockProcessor = MockConsciousnessProcessor()
        voiceBridge.setConsciousnessProcessor(mockProcessor)
    }
    
    private func processTextInput() async {
        guard !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let input = textInput
        textInput = ""
        
        // Process text through the same consciousness pipeline
        // This simulates what voice input would do
        voiceBridge.lastTranscript = input
        
        // TODO: Process through consciousness system
    }
}

#if DEBUG
#Preview {
    SyntraVoiceView()
}
#endif 