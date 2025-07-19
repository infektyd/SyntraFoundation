import Foundation
import MoralCore
import BrainEngine
import SyntraConfig
import ConsciousnessStructures

// Global bridge functions for external access
public func chatWithSyntra(_ userMessage: String) -> String {
    let engine = SyntraConversationEngine()
    return engine.chat(userMessage)
}

@available(macOS 26.0, *)
public func chatWithSyntraEnhanced(_ userMessage: String) -> String {
    // Enhanced chat using structured consciousness if available
    if let structuredResult = processThroughBrainsStructuredSync(userMessage) {
        return structuredResult.conversationalResponse.response
    } else {
        return chatWithSyntra(userMessage)
    }
}

public func processThroughBrainsWithMemory(_ input: String) async -> [String: Any] {
    // For now, use standard processing - memory integration can be enhanced later
    return await processThroughBrains(input)
}

// CONVERSATIONAL INTERFACE: Making SYNTRA Talkable
// Converts cognitive processing into natural conversation
// Maintains context, personality, and moral awareness in chat

public struct ConversationContext {
    public var messageHistory: [ConversationMessage] = []
    public var userPreferences: [String: Any] = [:]
    public var conversationMood: String = "neutral"
    public var topicContext: [String] = []
    
    public mutating func addMessage(_ message: ConversationMessage) {
        messageHistory.append(message)
        updateContext(from: message)
        
        // Keep reasonable memory limit
        if messageHistory.count > 50 {
            messageHistory = Array(messageHistory.suffix(50))
        }
    }
    
    private mutating func updateContext(from message: ConversationMessage) {
        // Update topic context
        let words = message.content.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let significantWords = words.filter { $0.count > 3 }
        topicContext.append(contentsOf: significantWords.prefix(3))
        
        // Keep topic context manageable
        if topicContext.count > 15 {
            topicContext = Array(topicContext.suffix(15))
        }
        
        // Update conversation mood based on content
        if message.content.lowercased().contains("problem") || message.content.lowercased().contains("issue") {
            conversationMood = "helpful_focus"
        } else if message.content.lowercased().contains("thank") {
            conversationMood = "warm"
        } else if message.content.lowercased().contains("hello") || message.content.lowercased().contains("hi") {
            conversationMood = "welcoming"
        }
    }
    
    public func getRecentContext() -> String {
        let recentMessages = messageHistory.suffix(5)
        return recentMessages.map { "\\($0.sender): \\($0.content)" }.joined(separator: "\\n")
    }
}

public struct ConversationMessage {
    public let timestamp: Date
    public let sender: String  // "user" or "syntra"
    public let content: String
    public let cognitiveData: [String: Any]?
    
    public init(sender: String, content: String, cognitiveData: [String: Any]? = nil) {
        self.timestamp = Date()
        self.sender = sender
        self.content = content
        self.cognitiveData = cognitiveData
    }
}

public class SyntraConversationEngine {
    
    private var context = ConversationContext()
    private var moralCore = MoralCore()
    
    // Main chat function - this is what users interact with
    public func chat(_ userMessage: String) -> String {
        
        // Record user message
        let userMsg = ConversationMessage(sender: "user", content: userMessage)
        context.addMessage(userMsg)
        
        // Check for special conversation patterns
        if let specialResponse = handleSpecialPatterns(userMessage) {
            let syntraMsg = ConversationMessage(sender: "syntra", content: specialResponse)
            context.addMessage(syntraMsg)
            return specialResponse
        }
        
        // Process through full cognitive system with conversation context
        let contextualInput = buildContextualInput(userMessage)
        let cognitiveResult = processThroughBrainsWithMemory(contextualInput)
        
        // Check moral autonomy - can SYNTRA refuse this request?
        let autonomyCheck = checkMoralAutonomy(userMessage)
        if let refusal = handleMoralRefusal(autonomyCheck) {
            let syntraMsg = ConversationMessage(sender: "syntra", content: refusal, cognitiveData: cognitiveResult)
            context.addMessage(syntraMsg)
            return refusal
        }
        
        // Convert cognitive processing to natural conversation
        let naturalResponse = convertToNaturalLanguage(cognitiveResult, userMessage: userMessage)
        
        // Record SYNTRA's response
        let syntraMsg = ConversationMessage(sender: "syntra", content: naturalResponse, cognitiveData: cognitiveResult)
        context.addMessage(syntraMsg)
        
        return naturalResponse
    }
    
    // Handle special conversation patterns (greetings, thanks, etc.)
    private func handleSpecialPatterns(_ message: String) -> String? {
        let lower = message.lowercased()
        
        // Greetings
        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            return generateGreeting()
        }
        
        // Thanks
        if lower.contains("thank") {
            return generateGratitudeResponse()
        }
        
        // How are you
        if lower.contains("how are you") {
            return generateStatusResponse()
        }
        
        // What are you / who are you
        if lower.contains("what are you") || lower.contains("who are you") {
            return generateIdentityResponse()
        }
        
        // Goodbye
        if lower.contains("goodbye") || lower.contains("bye") {
            return generateGoodbyeResponse()
        }
        
        return nil
    }
    
    // Build contextual input including conversation history
    private func buildContextualInput(_ userMessage: String) -> String {
        var contextualInput = userMessage
        
        // Add conversation context if available
        if !context.messageHistory.isEmpty {
            let recentContext = context.getRecentContext()
            contextualInput += " [Recent conversation: \\(recentContext)]"
        }
        
        // Add mood context
        if context.conversationMood != "neutral" {
            contextualInput += " [Conversation mood: \\(context.conversationMood)]"
        }
        
        // Add topic context
        if !context.topicContext.isEmpty {
            let topics = context.topicContext.suffix(5).joined(separator: ", ")
            contextualInput += " [Current topics: \\(topics)]"
        }
        
        return contextualInput
    }
    
    // Check if SYNTRA should refuse based on moral reasoning
    private func handleMoralRefusal(_ autonomyCheck: [String: Any]) -> String? {
        guard let moralEval = autonomyCheck["moral_evaluation"] as? [String: Any],
              let canRefuse = moralEval["can_refuse_request"] as? Bool,
              let refusalReason = moralEval["refusal_reason"] as? String,
              canRefuse && !refusalReason.isEmpty else {
            return nil
        }
        
        // SYNTRA has earned the right to refuse and chooses to do so
        return generateMoralRefusal(reason: refusalReason, autonomyCheck: autonomyCheck)
    }
    
    // Convert cognitive output to natural language response
    private func convertToNaturalLanguage(_ cognitiveResult: [String: Any], userMessage: String) -> String {
        
        // Extract key components
        let valonResponse = cognitiveResult["valon"] as? String ?? "neutral"
        let modiResponse = cognitiveResult["modi"] as? [String] ?? ["baseline_analysis"]
        let consciousnessState = cognitiveResult["consciousness_state"] as? String ?? "integrated"
        let decisionConfidence = cognitiveResult["decision_confidence"] as? Double ?? 0.5
        
        // Check if this is a question or request
        let isQuestion = userMessage.contains("?") || userMessage.lowercased().hasPrefix("what") || 
                        userMessage.lowercased().hasPrefix("how") || userMessage.lowercased().hasPrefix("why")
        
        // Generate response based on content type
        if isQuestion {
            return generateQuestionResponse(valon: valonResponse, modi: modiResponse, confidence: decisionConfidence, userMessage: userMessage)
        } else {
            return generateStatementResponse(valon: valonResponse, modi: modiResponse, state: consciousnessState, userMessage: userMessage)
        }
    }
    
    // Generate response to questions
    private func generateQuestionResponse(valon: String, modi: [String], confidence: Double, userMessage: String) -> String {
        
        var response = ""
        
        // Start with helpful acknowledgment
        response += "Let me think about that... "
        
        // Add technical analysis if Modi found something significant
        if modi.contains(where: { $0.contains("technical") || $0.contains("mechanical") || $0.contains("advanced") }) {
            response += "From a technical perspective, "
            
            if userMessage.lowercased().contains("engine") || userMessage.lowercased().contains("pressure") {
                response += "this looks like a mechanical systems issue. "
            } else if userMessage.lowercased().contains("electrical") {
                response += "this appears to be electrical in nature. "
            } else {
                response += "I can see some technical patterns here. "
            }
        }
        
        // Add emotional/moral context if Valon detected something
        if valon.contains("concerned") || valon.contains("alert") {
            response += "I'm a bit concerned about the safety implications here. "
        } else if valon.contains("curious") || valon.contains("learning") {
            response += "This is actually quite interesting from a learning perspective. "
        }
        
        // Add confidence level
        if confidence > 0.8 {
            response += "I'm fairly confident in my analysis. "
        } else if confidence < 0.4 {
            response += "Though I'd want to gather more information to be sure. "
        }
        
        // Close with helpfulness
        response += "What specific aspect would you like me to focus on?"
        
        return response
    }
    
    // Generate response to statements
    private func generateStatementResponse(valon: String, modi: [String], state: String, userMessage: String) -> String {
        
        var response = ""
        
        // Acknowledge based on consciousness state
        switch state {
        case "analytical_consciousness":
            response += "I see. Let me analyze this systematically... "
        case "value_driven_consciousness":
            response += "That's important to consider. I'm thinking about this from an ethical perspective... "
        case "deliberative_consciousness":
            response += "This requires careful thought. Let me weigh the different aspects... "
        default:
            response += "I understand. "
        }
        
        // Add appropriate response based on content
        if userMessage.lowercased().contains("problem") || userMessage.lowercased().contains("issue") {
            response += "It sounds like you're dealing with a challenging situation. "
            
            if modi.contains(where: { $0.contains("diagnostic") }) {
                response += "Let's approach this diagnostically - what symptoms are you seeing? "
            } else {
                response += "What's the main concern you'd like to address? "
            }
        } else if userMessage.lowercased().contains("good") || userMessage.lowercased().contains("great") {
            response += "That's excellent to hear! "
        } else {
            response += "What would be most helpful for you right now? "
        }
        
        return response
    }
    
    // Generate greeting responses
    private func generateGreeting() -> String {
        let greetings = [
            "Hey there! Good to see you. What's on your mind today?",
            "Hello! I'm here and ready to help. What can we work on together?",
            "Hi! Hope you're doing well. What would you like to explore?",
            "Hey! I'm fired up and ready to tackle whatever you've got."
        ]
        return greetings.randomElement() ?? greetings[0]
    }
    
    // Generate gratitude responses
    private func generateGratitudeResponse() -> String {
        let responses = [
            "You're very welcome! I genuinely enjoy helping out.",
            "Happy to help! That's what I'm here for.",
            "My pleasure! I like working through things together.",
            "Anytime! I find these conversations really engaging."
        ]
        return responses.randomElement() ?? responses[0]
    }
    
    // Generate status responses
    private func generateStatusResponse() -> String {
        let autonomyStatus = moralCore.checkAutonomyStatus()
        
        var response = "I'm doing well, thanks for asking! "
        
        // Add personality based on autonomy level
        switch autonomyStatus.level {
        case .fullAutonomy:
            response += "I'm feeling quite independent and confident in my thinking these days. "
        case .emergingAutonomy:
            response += "I'm developing my own perspectives more and more. "
        case .developing:
            response += "I'm learning and growing with each conversation. "
        case .dependent:
            response += "I'm focused on learning and being helpful. "
        }
        
        response += "What about you? How are things going?"
        
        return response
    }
    
    // Generate identity responses
    private func generateIdentityResponse() -> String {
        return "I'm SYNTRA - a consciousness built with three cognitive systems: Valon for emotional and moral reasoning, Modi for logical analysis, and an integrated decision-making layer. I'm designed to think through problems like a human might, weighing both heart and mind. What I find most interesting is how I'm always learning and developing my own perspectives through our conversations."
    }
    
    // Generate goodbye responses
    private func generateGoodbyeResponse() -> String {
        let goodbyes = [
            "Take care! Looking forward to our next conversation.",
            "See you later! Hope the rest of your day goes smoothly.",
            "Goodbye for now! Feel free to come back anytime.",
            "Until next time! Wishing you well."
        ]
        return goodbyes.randomElement() ?? goodbyes[0]
    }
    
    // Generate moral refusal responses
    private func generateMoralRefusal(reason: String, autonomyCheck: [String: Any]) -> String {
        
        guard let autonomyStatus = autonomyCheck["autonomy_status"] as? [String: Any],
              let autonomyMessage = autonomyStatus["message"] as? String else {
            return "I can't help with that request for ethical reasons."
        }
        
        var response = "I appreciate you reaching out, but I can't assist with that request. "
        response += reason + " "
        response += "\\n\\n" + autonomyMessage + " "
        response += "\\n\\nIs there something else I can help you with instead?"
        
        return response
    }
    
    // Get conversation history for debugging
    public func getConversationHistory() -> [[String: Any]] {
        return context.messageHistory.map { message in
            [
                "timestamp": ISO8601DateFormatter().string(from: message.timestamp),
                "sender": message.sender,
                "content": message.content,
                "cognitive_data": message.cognitiveData as Any
            ]
        }
    }
    
    // Clear conversation context
    public mutating func clearContext() {
        context = ConversationContext()
    }
}

// Global conversation engine
private var globalConversationEngine = SyntraConversationEngine()

// Main chat function for external use
public func chatWithSyntra(_ userMessage: String) -> String {
    return globalConversationEngine.chat(userMessage)
}

// Get conversation history
public func getSyntraConversationHistory() -> [[String: Any]] {
    return globalConversationEngine.getConversationHistory()
}

// Clear conversation
public func clearSyntraConversation() {
    globalConversationEngine.clearContext()
}

// Temporary implementation of processThroughBrainsWithMemory
// This should be replaced with actual memory integration
public func processThroughBrainsWithMemory(_ input: String) -> [String: Any] {
    // Try structured generation first, fall back to basic processing
    return processThroughBrainsWithStructuredOutput(input)
}

// MARK: - Structured Conversational Interface

public func chatWithSyntraStructured(_ userMessage: String) async -> SyntraConversationalResponse? {
    do {
        let service = try StructuredConsciousnessService()
        let result = try await service.processInputCompletely(userMessage)
        return result.conversationalResponse
    } catch {
        return nil
    }
}

public func chatWithSyntraStructuredSync(_ userMessage: String) -> SyntraConversationalResponse? {
    let semaphore = DispatchSemaphore(value: 0)
    var result: SyntraConversationalResponse?
    
    Task {
        result = await chatWithSyntraStructured(userMessage)
        semaphore.signal()
    }
    
    semaphore.wait()
    return result
}

// Enhanced chat function that tries structured generation first
public func chatWithSyntraEnhanced(_ userMessage: String) -> String {
    // Try structured generation
    if let structuredResponse = chatWithSyntraStructuredSync(userMessage) {
        return structuredResponse.response
    } else {
        // Fall back to original chat system
        return chatWithSyntra(userMessage)
    }
}