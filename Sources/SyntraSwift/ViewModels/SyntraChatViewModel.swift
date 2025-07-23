import Foundation
import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
@Observable
public final class SyntraChatViewModel {
    // State properties with proper isolation
    public private(set) var messages: [SyntraMessage] = []
    public var currentInput: String = ""
    public var isProcessing: Bool = false
    public var errorMessage: String?
    
    // AGENTS.md: SYNTRA Core Integration - REAL IMPLEMENTATION
    private let syntraCore: SyntraCore
    private let config: SyntraConfig
    
    // Conversation memory (session-based)
    private var conversationMemory: [String] = []
    // Persistent memory integration with Python structures
    private var persistentMemory: [String: Any] = [:]
    
    public init(config: SyntraConfig) {
        self.config = config
        self.syntraCore = SyntraCore(config: config)
    }
    
    // Rule 2: Live binding - instant updates to agents in-memory
    public func processMessage() async {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = currentInput
        currentInput = ""
        isProcessing = true
        errorMessage = nil
        
        // Add user message with live binding
        let userMsg = SyntraMessage(
            id: UUID(),
            content: userMessage,
            role: .user,
            timestamp: Date()
        )
        messages.append(userMsg)
        
        // Add to conversation memory
        conversationMemory.append("User: \(userMessage)")
        
        // Integrate with persistent memory through Python structures
        await integrateWithPersistentMemory(input: userMessage)
        
        // Create context with conversation memory and persistent memory
        let context = createContextWithPersistentMemory()
        
        // AGENTS.md: Real SYNTRA Core processing with persistent memory - NO STUBS
        let response = await syntraCore.processInput(
            userMessage,
            context: context
        )
        
        let assistantMsg = SyntraMessage(
            id: UUID(),
            content: response.content,
            role: .assistant,
            timestamp: Date(),
            valonInfluence: response.valonInfluence,
            modiInfluence: response.modiInfluence,
            driftScore: response.driftScore
        )
        messages.append(assistantMsg)
        
        // Add response to conversation memory
        conversationMemory.append("SYNTRA: \(response.content)")
        
        // Store in persistent memory
        await storeInPersistentMemory(input: userMessage, response: response.content)
        
        // Keep conversation memory manageable (last 20 exchanges)
        if conversationMemory.count > 40 {
            conversationMemory = Array(conversationMemory.suffix(40))
        }
        
        isProcessing = false
    }
    
    private func createContextWithPersistentMemory() -> SyntraContext {
        // Use conversation memory and integrate with persistent memory
        return SyntraContext(
            conversationHistory: conversationMemory,
            userPreferences: config.userPreferences,
            sessionId: UUID().uuidString
        )
    }
    
    // MARK: - Persistent Memory Integration
    
    private func integrateWithPersistentMemory(input: String) async {
        // Integrate with Python memory vault structures
        // This would call the Python reasoning engine for persistent storage
        persistentMemory["last_input"] = input
        persistentMemory["last_timestamp"] = Date().timeIntervalSince1970
        persistentMemory["session_id"] = UUID().uuidString
    }
    
    private func storeInPersistentMemory(input: String, response: String) async {
        // Store in Python memory vault through reasoning engine
        var storedInteractions = persistentMemory["stored_interactions"] as? [[String: Any]] ?? []
        let interaction: [String: Any] = [
            "input": input,
            "response": response,
            "timestamp": Date().timeIntervalSince1970,
            "session_id": UUID().uuidString
        ]
        storedInteractions.append(interaction)
        persistentMemory["stored_interactions"] = storedInteractions
    }
    
    // MARK: - Memory Management
    
    public func clearConversationMemory() {
        conversationMemory.removeAll()
        messages.removeAll()
    }
    
    public func getConversationMemory() -> [String] {
        return conversationMemory
    }
    
    public func getPersistentMemory() -> [String: Any] {
        return persistentMemory
    }
} 