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
            // Main chat area with proper layout
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
                
                // Messages list - takes up available space
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
                
                // Input area - FIXED at bottom with proper spacing
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        // Use native NSTextField with improved copy/paste support
                        NativeTextField(
                            text: $inputText,
                            placeholder: "Type your message to SYNTRA...",
                            isEnabled: brain.isAvailable && !isLoading,
                            onSubmit: sendMessage
                        )
                        .frame(minHeight: 36)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        }
                        .disabled(!canSendMessage)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
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

/// Native NSTextField wrapper with improved copy/paste support
struct NativeTextField: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isEnabled: Bool
    let onSubmit: () -> Void
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.stringValue = text
        textField.placeholderString = placeholder
        textField.isEnabled = isEnabled
        textField.delegate = context.coordinator
        
        // Style the text field
        textField.isBordered = true
        textField.bezelStyle = .roundedBezel
        textField.font = NSFont.systemFont(ofSize: 14)
        
        // Enable copy/paste and all standard text editing features
        textField.allowsEditingTextAttributes = false
        textField.cell?.wraps = false
        textField.cell?.isScrollable = true
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        nsView.isEnabled = isEnabled
        nsView.placeholderString = placeholder
        
        // Update the coordinator's callback reference
        context.coordinator.updateCallback(onSubmit)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        private var onSubmitCallback: (() -> Void)?
        
        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            self._text = text
            self.onSubmitCallback = onSubmit
        }
        
        func updateCallback(_ callback: @escaping () -> Void) {
            self.onSubmitCallback = callback
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                // Pre-fetch the value to avoid main actor issues
                let newValue = textField.stringValue
                DispatchQueue.main.async { [weak self] in
                    self?.text = newValue
                }
            }
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // Call the callback on main actor
                DispatchQueue.main.async { [weak self] in
                    self?.onSubmitCallback?()
                }
                return true
            }
            return false
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
