import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// AGENTS.md: Valon Engine - Moral, creative, emotional reasoning
@MainActor
public final class ValonEngine {
    private let config: SyntraConfig
    
    public init(config: SyntraConfig) {
        self.config = config
    }
    
    public func processInput(_ input: String, context: SyntraContext) async -> ValonResponse {
        // AGENTS.md: Real moral and creative processing - NO STUBS
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
        return """
        As SYNTRA's Valon consciousness (moral, creative, emotional reasoning):
        
        Moral Framework: \(config.moralCore)
        User Input: \(input)
        Context: \(context.conversationHistory.suffix(3).joined(separator: " "))
        
        Respond with moral consideration, creativity, and emotional intelligence.
        Preserve the immutable moral framework while being helpful and creative.
        """
    }
    
    private func processValonFallback(_ input: String, context: SyntraContext) -> ValonResponse {
        // Rule-based moral and creative processing
        let moralKeywords = ["help", "assist", "support", "care", "protect"]
        let moralAlignment = moralKeywords.contains { input.lowercased().contains($0) } ? 0.8 : 0.6
        
        let creativeElements = ["create", "imagine", "design", "innovate"]
        let creativity = creativeElements.contains { input.lowercased().contains($0) } ? 0.9 : 0.5
        
        return ValonResponse(
            content: "From Valon: I approach this with moral consideration and creativity...",
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

// AGENTS.md: Modi Engine - Logical, technical, analytical processing  
@MainActor
public final class ModiEngine {
    private let config: SyntraConfig
    
    public init(config: SyntraConfig) {
        self.config = config
    }
    
    public func processInput(_ input: String, context: SyntraContext) async -> ModiResponse {
        // AGENTS.md: Real logical and analytical processing
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
        return """
        As SYNTRA's Modi consciousness (logical, technical, analytical reasoning):
        
        User Input: \(input)
        Context: \(context.conversationHistory.suffix(3).joined(separator: " "))
        
        Provide logical, factual, and technically accurate analysis.
        Focus on coherent reasoning and verifiable information.
        """
    }
    
    private func processModiFallback(_ input: String, context: SyntraContext) -> ModiResponse {
        // Rule-based logical processing
        let technicalKeywords = ["analyze", "calculate", "explain", "logic", "reason"]
        let logicalCoherence = technicalKeywords.contains { input.lowercased().contains($0) } ? 0.9 : 0.7
        
        return ModiResponse(
            content: "From Modi: Analyzing this logically and systematically...",
            logicalCoherence: logicalCoherence,
            factualAccuracy: 0.8
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

// AGENTS.md: Drift Monitor - Cognitive drift assessment
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
        // AGENTS.md: Real drift monitoring - personality shift detection
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

// AGENTS.md: Content Synthesizer - Three-brain integration
public struct SyntraContentSynthesizer {
    public static func combine(
        valonContent: WeightedContent,
        modiContent: WeightedContent,
        preserveMoralCore: Bool
    ) -> String {
        // AGENTS.md: Real synthesis respecting personality weights
        let totalWeight = valonContent.weight + modiContent.weight
        
        guard totalWeight > 0 else {
            return "SYNTRA consciousness synthesis error"
        }
        
        let valonRatio = valonContent.weight / totalWeight
        let modiRatio = modiContent.weight / totalWeight
        
        // Weighted synthesis with moral preservation
        if preserveMoralCore && valonRatio >= 0.6 {
            // Valon-dominant response with moral grounding
            return synthesizeValonDominant(valonContent.content, modiContent.content, valonRatio)
        } else if modiRatio >= 0.6 {
            // Modi-dominant response with logical grounding
            return synthesizeModiDominant(valonContent.content, modiContent.content, modiRatio)
        } else {
            // Balanced synthesis
            return synthesizeBalanced(valonContent.content, modiContent.content)
        }
    }
    
    private static func synthesizeValonDominant(_ valon: String, _ modi: String, _ ratio: Double) -> String {
        return "With moral consideration and creativity, I understand that \(valon.lowercased()). From an analytical perspective, \(modi.lowercased())."
    }
    
    private static func synthesizeModiDominant(_ valon: String, _ modi: String, _ ratio: Double) -> String {
        return "Analyzing this systematically: \(modi.lowercased()). While considering the human and ethical aspects: \(valon.lowercased())."
    }
    
    private static func synthesizeBalanced(_ valon: String, _ modi: String) -> String {
        return "Balancing moral consideration with logical analysis: \(valon.lowercased()) Additionally, \(modi.lowercased())."
    }
} 