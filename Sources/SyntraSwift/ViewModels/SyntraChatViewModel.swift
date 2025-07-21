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
        
        // AGENTS.md: Real SYNTRA Core processing - NO STUBS
        let response = await syntraCore.processInput(
            userMessage,
            context: createContext()
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
        
        isProcessing = false
    }
    
    private func createContext() -> SyntraContext {
        SyntraContext(
            conversationHistory: messages.suffix(10).map { $0.content },
            userPreferences: config.userPreferences,
            sessionId: UUID().uuidString
        )
    }
} 