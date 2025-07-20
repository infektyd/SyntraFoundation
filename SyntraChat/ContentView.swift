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
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            // Liquid glass background
            Color.clear
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            HSplitView {
                VStack(spacing: 0) {
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
        }
            .onAppear {
                // Welcome message
                if messages.isEmpty {
                    addWelcomeMessage()
                }
                }
                .frame(minWidth: 400)

                // Settings panel
                SettingsPanel(settings: ConfigViewModel())
            }
        }
    }
    
    /// Send user message and get SYNTRA response
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate input
        guard !userMessage.isEmpty else { return }
        guard brain.isAvailable else {
            messages.append(.error("SYNTRA consciousness is not available on this device"))
            return
        }
        
        // Add user message
        messages.append(.user(userMessage))
        inputText = ""
        isLoading = true
        
        // Get SYNTRA response
        Task {
            let response = await brain.processMessage(userMessage)
            
            await MainActor.run {
                isLoading = false
                
                // Determine if response is an error
                let isError = response.hasPrefix("[") && response.hasSuffix("]")
                
                if isError {
                    messages.append(.error(response))
                } else {
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
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type your message to SYNTRA...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .disabled(!isEnabled)
                .onSubmit {
                    if canSend {
                        onSend()
                    }
                }
            
            Button("Send") {
                onSend()
            }
            .disabled(!canSend)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var canSend: Bool {
        isEnabled && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    if #available(macOS 26.0, *) {
        ContentView()
    } else {
        Text("Requires macOS 26.0+")
    }
}
