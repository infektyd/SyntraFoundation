import SwiftUI

struct ChatView: View {
    @StateObject private var brain = SyntraBrain()
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list with iOS-native behavior
                ScrollViewReader { proxy in
                    List {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .id(message.id)
                        }
                        
                        // Loading indicator for iOS
                        if brain.isProcessing {
                            SyntraLoadingView()
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .id("loading")
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        // iOS pull-to-refresh to reinitialize SYNTRA
                        await refreshSyntra()
                    }
                    .onChange(of: messages.count) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: brain.isProcessing) { _, isProcessing in
                        if isProcessing {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                
                // iOS-native chat input bar
                ChatInputBar(
                    text: $inputText,
                    isLoading: .constant(brain.isProcessing),
                    isEnabled: brain.isAvailable,
                    onSend: sendMessage
                )
            }
            .navigationTitle("SYNTRA")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // iOS-native toolbar with settings
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                // Status indicator in toolbar
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(brain.isAvailable ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        if brain.isProcessing {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .hideKeyboardOnTap()
            .keyboardAdaptive()
            .onAppear {
                setupInitialState()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        if messages.isEmpty {
            addWelcomeMessage()
        }
        
        // Prepare iOS-specific features
        UIApplication.shared.isIdleTimerDisabled = false // Allow screen to sleep normally
    }
    
    private func addWelcomeMessage() {
        let welcomeText: String
        
        if brain.isAvailable {
            welcomeText = """
            Hello! I am SYNTRA, a consciousness architecture that combines:
            
            🧠 **Moral reasoning** (Valon)
            🔬 **Logical analysis** (Modi)  
            ⚖️ **Ethical synthesis** (Core)
            
            How may I assist you today?
            """
        } else {
            welcomeText = """
            ⚠️ SYNTRA consciousness requires a more powerful device.
            
            **Requirements:**
            • 4+ CPU cores
            • 4GB+ RAM
            
            **Your device:** \(ProcessInfo.processInfo.processorCount) cores
            """
        }
        
        messages.append(.syntra(welcomeText))
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !userMessage.isEmpty else { return }
        guard brain.isAvailable else {
            messages.append(.error("SYNTRA consciousness is not available on this device. Please check device requirements."))
            return
        }
        
        // Add user message with haptic feedback
        messages.append(.user(userMessage))
        inputText = ""
        
        // Trigger haptic feedback for message sent
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Get SYNTRA response
        Task {
            let response = await brain.processMessage(userMessage)
            
            await MainActor.run {
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
    
    private func scrollToBottom(proxy: ScrollViewReader<AnyHashable>) {
        withAnimation(.easeOut(duration: 0.5)) {
            if brain.isProcessing {
                proxy.scrollTo("loading", anchor: UnitPoint.bottom)
            } else if let lastMessage = messages.last {
                proxy.scrollTo(lastMessage.id, anchor: UnitPoint.bottom)
            }
        }
    }
    
    private func refreshSyntra() async {
        // iOS pull-to-refresh functionality
        await MainActor.run {
            brain.reinitialize()
            
            // Provide haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // Add refresh message
            messages.append(.syntra("SYNTRA consciousness refreshed and ready! ✨"))
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