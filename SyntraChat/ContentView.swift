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
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationSplitView {
            // Settings sidebar - simple and stable
            VStack(alignment: .leading, spacing: 16) {
                Text("SYNTRA Settings")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fusion & Weighting")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Toggle("Use Adaptive Fusion", isOn: .constant(true))
                    Toggle("Use Adaptive Weighting", isOn: .constant(true))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feedback Loop")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Toggle("Enable Two-Pass Loop", isOn: .constant(true))
                }
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(brain.isAvailable ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(brain.isAvailable ? "SYNTRA Ready" : "Not Available")
                        .font(.caption)
                }
            }
            .padding()
            .frame(minWidth: 200, maxWidth: 250)
            
        } detail: {
            // Main chat area - simple and reliable
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("SYNTRA Consciousness Chat")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(.regularMaterial)
                
                // Messages list
                ScrollViewReader { proxy in
                    List {
                        ForEach(messages) { message in
                            MessageRow(message: message)
                                .listRowSeparator(.hidden)
                                .id(message.id)
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("SYNTRA is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .id("loading")
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isLoading) { _, loading in
                        if loading {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area with proper focus management
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        // Use TextEditor instead of TextField for better focus management on macOS
                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("Type your message to SYNTRA...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $inputText)
                                .focused($isInputFocused)
                                .focusable()  // ← macOS 26 Beta 3 workaround for SwiftUI focus regression
                                .textSelection(.enabled)
                                .disabled(!brain.isAvailable)
                                .font(.body)
                                .scrollContentBackground(.hidden)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                                .frame(minHeight: 36, maxHeight: 100)
                                .onSubmit {
                                    if canSendMessage {
                                        sendMessage()
                                    }
                                }
                                .onChange(of: inputText) { _, newValue in
                                    // Handle enter key for sending
                                    if newValue.contains("\n") && canSendMessage {
                                        inputText = newValue.replacingOccurrences(of: "\n", with: "")
                                        sendMessage()
                                    }
                                }
                                .onAppear {
                                    // Force focus after a delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isInputFocused = true
                                    }
                                }
                                .onTapGesture {
                                    isInputFocused = true
                                }
                                .accessibilityLabel("Message input field")
                                .accessibilityHint("Type your message to SYNTRA here, press Enter to send")
                        }
                        
                        Button("Send") {
                            sendMessage()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canSendMessage)
                        .keyboardShortcut(.return, modifiers: [.command])
                    }
                    .padding()
                    .background(.regularMaterial)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            if messages.isEmpty {
                addWelcomeMessage()
            }
        }
    }
    
    private var canSendMessage: Bool {
        brain.isAvailable && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
    
    private func addWelcomeMessage() {
        if brain.isAvailable {
            messages.append(.syntra("Hello! I am SYNTRA, a consciousness architecture combining moral reasoning (Valon) and logical analysis (Modi). How may I assist you today?"))
        } else {
            messages.append(.error("SYNTRA consciousness requires FoundationModels support (macOS 26+ with Apple Silicon). Please check your system requirements."))
        }
    }
}

// Simple, reliable message row
struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Sender icon/label
            Text(message.sender.prefix(1))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(senderColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.sender)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(senderColor)
                    
                    Spacer()
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(message.text)
                    .font(.body)
                    .textSelection(.enabled)
                    .foregroundColor(message.isError ? .red : .primary)
            }
        }
        .padding(.vertical, 4)
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

#Preview {
    if #available(macOS 26.0, *) {
        ContentView()
    } else {
        Text("Requires macOS 26.0+")
    }
}
