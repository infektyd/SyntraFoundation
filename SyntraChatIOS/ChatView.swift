import SwiftUI

struct ChatView: View {
    @StateObject private var brain = SyntraBrain()
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with status
            HStack {
                Circle()
                    .fill(brain.isAvailable ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(brain.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Settings") {
                    showingSettings = true
                }
                .font(.caption)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            // Messages area
            if messages.isEmpty {
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("SYNTRA Chat")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(brain.isAvailable ? "Ready to chat!" : "Device requirements not met")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Messages list
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            HStack {
                                if message.sender == .user {
                                    Spacer()
                                }
                                
                                Text(message.text)
                                    .padding()
                                    .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(message.sender == .user ? .white : .primary)
                                    .cornerRadius(12)
                                    .frame(maxWidth: 280, alignment: message.sender == .user ? .trailing : .leading)
                                
                                if message.sender == .syntra {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            // Input area
            HStack {
                TextField("Message SYNTRA...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!brain.isAvailable)
                
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !brain.isAvailable)
            }
            .padding()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        if messages.isEmpty {
            addWelcomeMessage()
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeText: String
        
        if brain.isAvailable {
            welcomeText = "Hello! I am SYNTRA, ready to assist you."
        } else {
            welcomeText = "⚠️ SYNTRA requires a more powerful device. Current: \(ProcessInfo.processInfo.processorCount) cores"
        }
        
        messages.append(.syntra(welcomeText))
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !userMessage.isEmpty else { return }
        guard brain.isAvailable else {
            messages.append(.error("SYNTRA consciousness is not available on this device."))
            return
        }
        
        // Add user message
        let userMsg = Message.user(userMessage)
        messages.append(userMsg)
        inputText = ""
        
        // Create a snapshot of the history to send to the brain
        let historySnapshot = messages
        
        // Get SYNTRA response
        Task {
            let response = await brain.processMessage(userMessage, withHistory: historySnapshot)
            
            await MainActor.run {
                messages.append(.syntra(response))
            }
        }
    }
}

// MARK: - Preview

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .preferredColorScheme(.light)
        
        ChatView()
            .preferredColorScheme(.dark)
    }
} 