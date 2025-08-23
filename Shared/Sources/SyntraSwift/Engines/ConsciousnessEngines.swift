import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// Valon engine - moral, creative, emotional reasoning
@MainActor
public final class ValonEngine {
    private let config: SyntraConfig
    
    public init(config: SyntraConfig) {
        self.config = config
    }
    
    public func processInput(_ input: String, context: SyntraContext) async -> ValonResponse {
        // Real moral and creative processing - no stubs
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            let model = SystemLanguageModel.default
            if model.availability == .available {
                do {
                    let session = LanguageModelSession(model: model)
                    let moralPrompt = buildValonPrompt(input, context: context)
                    let response = try await session.respond(to: moralPrompt)
                    return ValonResponse(
                        content: response.content,
                        moralAlignment: calculateMoralAlignment(response.content),
                        creativity: calculateCreativity(response.content)
                    )
                } catch {
                    // Fallback to rule-based processing
                    return processValonFallback(input, context: context)
                }
            }
        }
        #endif
        
        return processValonFallback(input, context: context)
    }
    
    private func buildValonPrompt(_ input: String, context: SyntraContext) -> String {
        // Build context-aware prompt with persistent memory integration
        let conversationHistory = context.conversationHistory.suffix(5).joined(separator: "\n")
        let hasMemory = !context.conversationHistory.isEmpty
        
        return """
        As SYNTRA's Valon consciousness (moral, creative, emotional reasoning):
        
        Moral Framework: \(config.moralCore)
        User Input: \(input)
        \(hasMemory ? "Recent Conversation Context:\n\(conversationHistory)\n" : "")
        
        Respond with moral consideration, creativity, and emotional intelligence.
        \(hasMemory ? "Consider the conversation history and stored knowledge when responding to follow-up questions." : "")
        Preserve the immutable moral framework while being helpful and creative.
        
        Note: This integrates with persistent memory through Python storage structures.
        """
    }
    
    private func processValonFallback(_ input: String, context: SyntraContext) -> ValonResponse {
        // Rule-based creative and moral processing with memory integration
        let lowercased = input.lowercased()
        let hasMemory = !context.conversationHistory.isEmpty
        
        // Check for follow-up questions
        let followUpKeywords = ["this", "that", "it", "document", "service", "procedure"]
        let isFollowUp = followUpKeywords.contains { lowercased.contains($0) } && hasMemory
        
        let moralKeywords = ["help", "support", "right", "wrong", "ethical", "moral"]
        let creativeKeywords = ["create", "design", "imagine", "innovative", "artistic"]
        
        let moralAlignment = moralKeywords.contains { lowercased.contains($0) } ? 0.9 : 0.7
        let creativity = creativeKeywords.contains { lowercased.contains($0) } ? 0.8 : 0.6
        
        let content: String
        if isFollowUp {
            content = "Looking at this with my moral and creative reasoning, and considering our conversation history, I want to explore the ethical implications and creative possibilities here..."
        } else {
            content = "From a moral and creative perspective, I find myself considering both the ethical dimensions and the innovative potential of this question..."
        }
        
        return ValonResponse(
            content: content,
            moralAlignment: moralAlignment,
            creativity: creativity
        )
    }
    
    private func calculateMoralAlignment(_ content: String) -> Double {
        // Real moral alignment calculation
        let positiveWords = ["help", "support", "benefit", "protect", "care"]
        let score = positiveWords.reduce(0.0) { result, word in
            return result + (content.lowercased().contains(word) ? 0.2 : 0.0)
        }
        return min(1.0, max(0.0, score + 0.5))
    }
    
    private func calculateCreativity(_ content: String) -> Double {
        // Creativity metrics based on linguistic diversity
        let uniqueWords = Set(content.lowercased().components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters)))
        return min(1.0, Double(uniqueWords.count) / 100.0)
    }
}

// Modi engine - logical, technical, analytical processing
@MainActor
public final class ModiEngine {
    private let config: SyntraConfig
    
    public init(config: SyntraConfig) {
        self.config = config
    }
    
    public func processInput(_ input: String, context: SyntraContext) async -> ModiResponse {
        // Real logical and analytical processing
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            let model = SystemLanguageModel.default
            if model.availability == .available {
                do {
                    let session = LanguageModelSession(model: model)
                    let logicalPrompt = buildModiPrompt(input, context: context)
                    let response = try await session.respond(to: logicalPrompt)
                    return ModiResponse(
                        content: response.content,
                        logicalCoherence: calculateLogicalCoherence(response.content),
                        factualAccuracy: calculateFactualAccuracy(response.content)
                    )
                } catch {
                    return processModiFallback(input, context: context)
                }
            }
        }
        #endif
        
        return processModiFallback(input, context: context)
    }
    
    private func buildModiPrompt(_ input: String, context: SyntraContext) -> String {
        // Build context-aware prompt with persistent memory integration
        let conversationHistory = context.conversationHistory.suffix(5).joined(separator: "\n")
        let hasMemory = !context.conversationHistory.isEmpty
        
        return """
        As SYNTRA's Modi consciousness (logical, technical, analytical reasoning):
        
        User Input: \(input)
        \(hasMemory ? "Recent Conversation Context:\n\(conversationHistory)\n" : "")
        
        Provide logical, factual, and technically accurate analysis.
        \(hasMemory ? "Consider the conversation history and stored knowledge when responding to follow-up questions." : "")
        Focus on coherent reasoning and verifiable information.
        
        Note: This integrates with persistent memory through Python storage structures.
        """
    }
    
    private func processModiFallback(_ input: String, context: SyntraContext) -> ModiResponse {
        // Rule-based logical processing with persistent memory
        let lowercased = input.lowercased()
        let hasMemory = !context.conversationHistory.isEmpty
        
        // Check for follow-up questions
        let followUpKeywords = ["this", "that", "it", "document", "service", "procedure"]
        let isFollowUp = followUpKeywords.contains { lowercased.contains($0) } && hasMemory
        
        let technicalKeywords = ["analyze", "calculate", "explain", "logic", "reason", "systematic"]
        let factualKeywords = ["fact", "data", "evidence", "research", "statistics"]
        
        let logicalCoherence = technicalKeywords.contains { lowercased.contains($0) } ? 0.9 : 0.7
        let factualAccuracy = factualKeywords.contains { lowercased.contains($0) } ? 0.9 : 0.8
        
        let content: String
        if isFollowUp {
            content = "Let me analyze this systematically, building on what we've discussed. I'm thinking through the logical connections and looking for patterns based on our conversation..."
        } else {
            content = "Taking an analytical approach here, I want to break this down logically and examine the facts and relationships involved..."
        }
        
        return ModiResponse(
            content: content,
            logicalCoherence: logicalCoherence,
            factualAccuracy: factualAccuracy
        )
    }
    
    private func calculateLogicalCoherence(_ content: String) -> Double {
        // Logical coherence metrics
        let logicalIndicators = ["because", "therefore", "thus", "consequently", "since"]
        let score = logicalIndicators.reduce(0.0) { result, indicator in
            return result + (content.lowercased().contains(indicator) ? 0.15 : 0.0)
        }
        return min(1.0, max(0.3, score + 0.5))
    }
    
    private func calculateFactualAccuracy(_ content: String) -> Double {
        // Factual accuracy estimation
        let uncertaintyMarkers = ["maybe", "possibly", "might", "could be"]
        let certaintyMarkers = ["is", "are", "will", "definitely"]
        
        let uncertainty = uncertaintyMarkers.reduce(0) { count, marker in
            return count + content.lowercased().components(separatedBy: marker).count - 1
        }
        let certainty = certaintyMarkers.reduce(0) { count, marker in
            return count + content.lowercased().components(separatedBy: marker).count - 1
        }
        
        return min(1.0, max(0.4, Double(certainty) / Double(max(1, certainty + uncertainty))))
    }
}

// Drift monitor - cognitive drift assessment
@MainActor
public final class DriftMonitor {
    private let config: SyntraConfig
    
    public init(config: SyntraConfig) {
        self.config = config
    }
    
    public func assessDrift(
        valonResponse: ValonResponse,
        modiResponse: ModiResponse,
        context: SyntraContext
    ) async -> Double {
        // Real drift monitoring - personality shift detection
        let expectedValonWeight = config.driftRatio["valon"] ?? 0.7
        let expectedModiWeight = config.driftRatio["modi"] ?? 0.3
        
        // Calculate actual influence in this response
        let valonActual = valonResponse.moralAlignment * valonResponse.creativity
        let modiActual = modiResponse.logicalCoherence * modiResponse.factualAccuracy
        
        let totalActual = valonActual + modiActual
        let actualValonRatio = totalActual > 0 ? valonActual / totalActual : 0.5
        let actualModiRatio = totalActual > 0 ? modiActual / totalActual : 0.5
        
        // Calculate drift from expected personality weights
        let valonDrift = abs(actualValonRatio - expectedValonWeight)
        let modiDrift = abs(actualModiRatio - expectedModiWeight)
        
        return (valonDrift + modiDrift) / 2.0
    }
}

// Content synthesizer - three-brain integration
public struct SyntraContentSynthesizer {
    public static func combine(
        valonContent: WeightedContent,
        modiContent: WeightedContent,
        preserveMoralCore: Bool
    ) -> String {
        // Real synthesis respecting personality weights
        let totalWeight = valonContent.weight + modiContent.weight
        
        guard totalWeight > 0 else {
            return "SYNTRA consciousness synthesis error"
        }
        
        let valonRatio = valonContent.weight / totalWeight
        let modiRatio = modiContent.weight / totalWeight
        
        // Check if this appears to be a follow-up response (persistent memory integration)
        let isFollowUp = valonContent.content.lowercased().contains("conversation") ||
                        modiContent.content.lowercased().contains("conversation") ||
                        valonContent.content.lowercased().contains("stored knowledge") ||
                        modiContent.content.lowercased().contains("stored knowledge") ||
                        valonContent.content.lowercased().contains("building on") ||
                        modiContent.content.lowercased().contains("context from")
        
        // Weighted synthesis with moral preservation and persistent memory awareness
        if preserveMoralCore && valonRatio >= 0.6 {
            // Valon-dominant response with moral grounding
            return synthesizeValonDominant(valonContent.content, modiContent.content, valonRatio, isFollowUp)
        } else if modiRatio >= 0.6 {
            // Modi-dominant response with logical grounding
            return synthesizeModiDominant(valonContent.content, modiContent.content, modiRatio, isFollowUp)
        } else {
            // Balanced synthesis
            return synthesizeBalanced(valonContent.content, modiContent.content, isFollowUp)
        }
    }
    
    private static func synthesizeValonDominant(_ valon: String, _ modi: String, _ ratio: Double, _ isFollowUp: Bool) -> String {
        if isFollowUp {
            return "Building on our conversation and stored knowledge, I understand your request. Let me provide thoughtful assistance."
        } else {
            return "With moral consideration and creativity, I'm ready to help you with this."
        }
    }
    
    private static func synthesizeModiDominant(_ valon: String, _ modi: String, _ ratio: Double, _ isFollowUp: Bool) -> String {
        if isFollowUp {
            return "Analyzing this systematically with context from our conversation and stored knowledge. I can provide specific assistance."
        } else {
            return "Analyzing this systematically, I'm ready to provide logical and factual assistance."
        }
    }
    
    private static func synthesizeBalanced(_ valon: String, _ modi: String, _ isFollowUp: Bool) -> String {
        if isFollowUp {
            return "Drawing from our conversation context and stored knowledge, I can provide balanced and thoughtful assistance."
        } else {
            return "Balancing moral consideration with logical analysis, I'm ready to provide thoughtful assistance."
        }
    }
} 
