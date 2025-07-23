import SwiftUI

struct ChatView: View {
    @StateObject private var brain = SyntraBrain()
    @State private var inputText: String = ""
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with status
            HStack {
                Circle()
                    .fill(brain.isProcessing ? .orange : .green)
                    .frame(width: 12, height: 12)
                
                Text(brain.isProcessing ? "SYNTRA thinking..." : "SYNTRA ready")
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
            if brain.messages.isEmpty {
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                        .padding()
                    
                    Text("SYNTRA Chat")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Ready to chat!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(brain.messages) { message in
                                MessageBubble(message: convertToMessage(message))
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: brain.messages.count) { _ in
                        if let lastMessage = brain.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    TextField("Message SYNTRA...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(brain.isProcessing)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || brain.isProcessing ? .gray : .blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || brain.isProcessing)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(UIColor.separator)),
                    alignment: .top
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialState() {
        if brain.messages.isEmpty {
            addWelcomeMessage()
        }
    }
    
    private func addWelcomeMessage() {
        Task {
            await brain.processMessage("Hello", withHistory: [])
        }
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !userMessage.isEmpty else { return }
        guard !brain.isProcessing else { return }
        
        inputText = ""
        
        // Process message through SYNTRA
        Task {
            await brain.processMessage(userMessage, withHistory: brain.messages)
        }
    }
    
    // Convert SyntraMessage to Message for UI compatibility
    private func convertToMessage(_ syntraMessage: SyntraMessage) -> Message {
        let sender: MessageSender = syntraMessage.role == .user ? .user : .syntra
        return Message(sender: sender, text: syntraMessage.content)
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
