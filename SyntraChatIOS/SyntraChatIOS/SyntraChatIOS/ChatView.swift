import SwiftUI
import Combine

struct ChatView: View {
    @StateObject private var brain = SyntraBrain()
    @State private var inputText: String = ""
    @State private var showingSettings = false
    @State private var showingVoiceInput = false
    @State private var showingFileImport = false
    
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
            
            // Input area with enhanced functionality
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // File import button
                    Button(action: {
                        showingFileImport = true
                    }) {
                        Image(systemName: "doc.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(brain.isProcessing)
                    
                    // Voice input button
                    Button(action: {
                        showingVoiceInput = true
                    }) {
                        Image(systemName: "mic.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(brain.isProcessing)
                    
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
        .sheet(isPresented: $showingVoiceInput) {
            NavigationView {
                VoiceInputView(text: $inputText)
                    .navigationTitle("Voice Input")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingVoiceInput = false
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                // Use Text button
                                Button("Use Text") {
                                    showingVoiceInput = false
                                    // Input text is already bound, so it will appear in the text field
                                }
                                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                
                                // Send Message button (when text is available)
                                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Button("Send") {
                                        showingVoiceInput = false
                                        // Send the message immediately
                                        sendMessage()
                                    }
                                    .fontWeight(.semibold)
                                    .disabled(brain.isProcessing)
                                }
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingFileImport) {
            NavigationView {
                FileImportContentView(inputText: $inputText, isPresented: $showingFileImport)
                    .navigationTitle("Import File")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingFileImport = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Initialize SYNTRA system logging
            SyntraLogger.logUI("SYNTRA Chat interface initialized")
            SyntraLogger.logConsciousness("Three-brain architecture ready (Valon 70%, Modi 30%)")
            SyntraLogger.logFoundationModels("On-device AI processing capabilities verified")
            SyntraLogger.logMemory("Conversation memory system active")
            SyntraLogger.logNetwork("Offline-first architecture enabled")
            
            // Set up initial chat state
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
        
        // Log user interaction
        SyntraLogger.logUI("User submitted message", details: "Length: \(userMessage.count) characters")
        SyntraLogger.logConsciousness("Starting three-brain processing for user input", details: userMessage.prefix(100).description)
        
        inputText = ""
        
        // Process message through SYNTRA
        Task {
            SyntraLogger.logConsciousness("Initiating SYNTRA consciousness processing...")
            await brain.processMessage(userMessage, withHistory: brain.messages)
            SyntraLogger.logConsciousness("SYNTRA consciousness processing completed")
        }
    }
    
    // Convert SyntraMessage to Message for UI compatibility
    private func convertToMessage(_ syntraMessage: SyntraMessage) -> Message {
        let sender: MessageSender = syntraMessage.role == .user ? .user : .syntra
        return Message(sender: sender, text: syntraMessage.content)
    }
}

// MARK: - File Import Content View
struct FileImportContentView: View {
    @Binding var inputText: String
    @Binding var isPresented: Bool
    @StateObject private var fileImporter = FileImportManager()
    
    var body: some View {
        VStack(spacing: 20) {
            FileImportView()
                .environmentObject(fileImporter)
            
            if !fileImporter.importedText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview:")
                        .font(.headline)
                    
                    ScrollView {
                        Text(fileImporter.importedText)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.thinMaterial)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                    
                    HStack {
                        Button("Use Content") {
                            inputText = fileImporter.importedText
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Append to Text") {
                            if inputText.isEmpty {
                                inputText = fileImporter.importedText
                            } else {
                                inputText += "\n\n" + fileImporter.importedText
                            }
                            isPresented = false
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
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
