import Foundation
import SyntraTools

/// Handles SYNTRA consciousness integration for UI interactions
@available(macOS 26.0, *)
@MainActor
class SyntraBrain: ObservableObject {
    @Published var isAvailable: Bool = false
    @Published var isProcessing: Bool = false
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var lastResponse: String = ""
    
    private let syntraCore = SyntraCore()
    
    init() {
        // SyntraCore handles all initialization internally
        isAvailable = true
    }
    
    /// Process user input through unified SYNTRA consciousness
    @available(macOS 26.0, *)
    func processMessage(_ input: String) async -> String {
        print("[SyntraBrain] Processing message: '\(input)'")
        
        // Guard against empty/whitespace input
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            print("[SyntraBrain] Empty input, returning error")
            return "[Please provide a message for SYNTRA to process]"
        }
        
        print("[SyntraBrain] Calling SyntraCore.processInput...")
        
        // Process through unified SyntraCore
        let response = await syntraCore.processInput(trimmedInput)
        
        print("[SyntraBrain] Got response: '\(response)'")
        
        // Update published state
        consciousnessState = syntraCore.consciousnessState
        lastResponse = response
        isProcessing = syntraCore.isProcessing
        
        return response
    }
    
    /// Get status message for debugging/display
    var statusMessage: String {
        if !isAvailable {
            return "SYNTRA consciousness unavailable"
        } else if isProcessing {
            return "SYNTRA processing..."
        } else {
            return "SYNTRA consciousness ready"
        }
    }
    
    /// Reinitialize if needed (for error recovery)
    func reinitialize() {
        // SyntraCore handles its own initialization
        isAvailable = true
    }
}