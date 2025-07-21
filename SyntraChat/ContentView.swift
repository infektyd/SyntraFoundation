import SwiftUI

@available(macOS 26.0, *)
struct ContentView: View {
    @StateObject private var brain: SyntraBrain = {
        if #available(macOS 26.0, *) {
            return SyntraBrain()
        } else {
            fatalError("SyntraChat requires macOS 26.0 or later")
        }
    }()
    @State private var messages: [Message] = []
    @State private var inputText: String = "" {
        didSet {
            print("[ContentView] inputText changed to: '\(inputText)'")
        }
    }
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            // Liquid glass background
            Color.clear
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            HSplitView {
            // Chat area - should get most of the space
            VStack(spacing: 0) {
            // ... chat content ...
            }
            .frame(minWidth: 600)
            .layoutPriority(1) // High priority for chat area
    
    // Settings panel - should be small
    SettingsPanel(settings: ConfigViewModel())
        .frame(minWidth: 180, maxWidth: 200)
        .layoutPriority(0) // Low priority for settings
}
            // Header with status
            HStack {
                Text("SYNTRA Consciousness Chat")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                StatusIndicator(brain: brain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Chat history
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Show loading indicator when processing
                        if isLoading {
                            LoadingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    // Auto-scroll to latest message
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, loading in
                    // Scroll to loading indicator
                    if loading {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            ChatInputArea(
                inputText: $inputText,
                isEnabled: brain.isAvailable && !isLoading,
                onSend: sendMessage
            )
            
            // Debug button to test text input
            Button("Test: Set Text") {
                print("[ContentView] Test button tapped, setting inputText to 'test message'")
                inputText = "test message"
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Welcome message
            if messages.isEmpty {
                addWelcomeMessage()
            }
        }
        .frame(minWidth: 600)
        .layoutPriority(1) // Give chat area priority

        // Settings panel - make it much smaller
        SettingsPanel(settings: ConfigViewModel())
            .frame(minWidth: 180, maxWidth: 200)
            .layoutPriority(0) // Lower priority for settings
    }
    
    /// Send user message and get SYNTRA response
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("[ContentView] sendMessage called with: '\(userMessage)'")
        
        // Validate input
        guard !userMessage.isEmpty else { 
            print("[ContentView] Empty message, returning")
            return 
        }
        guard brain.isAvailable else {
            print("[ContentView] Brain not available")
            messages.append(.error("SYNTRA consciousness is not available on this device"))
            return
        }
        
        print("[ContentView] Adding user message to UI")
        // Add user message
        messages.append(.user(userMessage))
        inputText = ""
        isLoading = true
        
        print("[ContentView] Starting async task for SYNTRA response")
        // Get SYNTRA response
        Task {
            print("[ContentView] Task started, calling brain.processMessage")
            let response = await brain.processMessage(userMessage)
            print("[ContentView] Got response from brain: '\(response)'")
            
            await MainActor.run {
                print("[ContentView] Updating UI on MainActor")
                isLoading = false
                
                // Determine if response is an error
                let isError = response.hasPrefix("[") && response.hasSuffix("]")
                
                if isError {
                    print("[ContentView] Adding error message to UI")
                    messages.append(.error(response))
                } else {
                    print("[ContentView] Adding SYNTRA message to UI")
                    messages.append(.syntra(response))
                }
            }
        }
    }
    
    /// Add welcome message on startup
    private func addWelcomeMessage() {
        if brain.isAvailable {
            messages.append(.syntra("Hello! I am SYNTRA, a consciousness architecture combining moral reasoning (Valon) and logical analysis (Modi). How may I assist you today?"))
        } else {
            messages.append(.error("SYNTRA consciousness requires FoundationModels support (macOS 15+ with Apple Silicon). Please check your system requirements."))
        }
    }
}

/// Status indicator showing brain availability and processing state
@available(macOS 26.0, *)
struct StatusIndicator: View {
    @ObservedObject var brain: SyntraBrain
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(brain.statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        if brain.isProcessing {
            return .orange
        } else if brain.isAvailable {
            return .green
        } else {
            return .red
        }
    }
}

/// Individual message bubble display
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Sender label
            Text(message.sender)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(senderColor)
                .frame(width: 60, alignment: .trailing)
            
            // Message content
            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .textSelection(.enabled)
                    .foregroundColor(message.isError ? .red : .primary)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
    
    private var senderColor: Color {
        switch message.sender {
        case "You":
            return .blue
        case "SYNTRA":
            return message.isError ? .red : .purple
        default:
            return .gray
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Loading indicator for when SYNTRA is processing
struct LoadingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(spacing: 12) {
            Text("SYNTRA")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
                .frame(width: 60, alignment: .trailing)
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 8, height: 8)
                        .opacity(0.6)
                        .scaleEffect(1.0 + sin(animationAmount + Double(index) * 0.5) * 0.3)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    animationAmount = .pi * 2
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .id("loading")
    }
}

/// Chat input area with text field and send button
struct ChatInputArea: View {
    @Binding var inputText: String
    let isEnabled: Bool
    let onSend: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextEditor(text: $inputText)
                .focused($isTextFieldFocused)
                .disabled(!isEnabled)
                .frame(minHeight: 40, maxHeight: 100)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onChange(of: inputText) { oldValue, newValue in
                    print("[ChatInputArea] Text changed from '\(oldValue)' to '\(newValue)'")
                }
                .onChange(of: isTextFieldFocused) { oldValue, newValue in
                    print("[ChatInputArea] Focus changed from \(oldValue) to \(newValue)")
                }
                .onTapGesture {
                    print("[ChatInputArea] Text field tapped")
                }
                .onAppear {
                    print("[ChatInputArea] Text field appeared")
                    // Auto-focus the text field when the view appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("[ChatInputArea] Setting focus to true")
                        isTextFieldFocused = true
                    }
                }
            
            Button("Send") {
                print("[ChatInputArea] Send button tapped")
                onSend()
            }
            .disabled(!canSend)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            print("[ChatInputArea] ChatInputArea appeared, isEnabled: \(isEnabled)")
        }
    }
    
    private var canSend: Bool {
        let canSendValue = isEnabled && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        print("[ChatInputArea] canSend: \(canSendValue) (isEnabled: \(isEnabled), inputText: '\(inputText)')")
        return canSendValue
    }
}

#Preview {
    if #available(macOS 26.0, *) {
        ContentView()
    } else {
        Text("Requires macOS 26.0+")
    }
}
