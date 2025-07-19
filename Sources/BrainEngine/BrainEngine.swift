import Foundation
import FoundationModels
import Valon
import Modi
import Drift
import SyntraConfig
import ConsciousnessStructures
// import StructuredConsciousnessService // Disabled for macOS 15.0 compatibility

public func logStage(stage: String, output: Any, directory: String) {
    let fm = FileManager.default
    if !fm.fileExists(atPath: directory) {
        try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true)
    }
    let path = URL(fileURLWithPath: directory).appendingPathComponent("\(stage).json")
    var data: [[String: Any]] = []
    if let d = try? Data(contentsOf: path),
       let j = try? JSONSerialization.jsonObject(with: d) as? [[String: Any]] {
        data = j
    }
    let entry: [String: Any] = ["timestamp": ISO8601DateFormatter().string(from: Date()),
                                "output": output]
    data.append(entry)
    if let out = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]) {
        try? out.write(to: path)
    }
}

// Inter-brain communication system
public func conductInternalDialogue(_ content: String) -> [String: Any] {
    // First, get initial responses from both brains
    let valonInitial = reflect_valon(content)
    let modiInitial = reflect_modi(content)
    
    // Allow Valon to respond to Modi's analysis
    let valonContext = "Modi analyzed this as: \(modiInitial.joined(separator: ", ")). Content: \(content)"
    let valonInformed = reflect_valon(valonContext)
    
    // Allow Modi to respond to Valon's perspective
    let modiContext = "Valon feels this is: \(valonInitial). Content: \(content)"
    let modiInformed = reflect_modi(modiContext)
    
    return [
        "valon_initial": valonInitial,
        "modi_initial": modiInitial,
        "valon_informed": valonInformed,
        "modi_informed": modiInformed,
        "dialogue_occurred": true
    ]
}

public func processThroughBrains(_ input: String) async -> [String: Any] {
    // Enhanced processing with inter-brain communication
    let dialogue = conductInternalDialogue(input)
    
    // Use the informed responses for final synthesis
    let finalValon = dialogue["valon_informed"] as? String ?? dialogue["valon_initial"] as? String ?? "neutral"
    let finalModi = dialogue["modi_informed"] as? [String] ?? dialogue["modi_initial"] as? [String] ?? ["baseline_analysis"]
    
    logStage(stage: "valon_stage", output: dialogue["valon_initial"] ?? "unknown", directory: "entropy_logs")
    logStage(stage: "valon_informed_stage", output: finalValon, directory: "entropy_logs")
    logStage(stage: "modi_stage", output: dialogue["modi_initial"] ?? "unknown", directory: "entropy_logs")
    logStage(stage: "modi_informed_stage", output: finalModi, directory: "entropy_logs")
    
    // Use the enhanced SYNTRA consciousness synthesis
    let consciousness = syntra_consciousness_synthesis(finalValon, finalModi)
    logStage(stage: "consciousness_synthesis", output: consciousness, directory: "entropy_logs")
    
    // Enhanced result with consciousness state
    var result: [String: Any] = [
        "valon": finalValon,
        "modi": finalModi,
        "consciousness": consciousness,
        "internal_dialogue": dialogue,
        "consciousness_state": consciousness["consciousness_state"] ?? "unknown",
        "decision_confidence": consciousness["decision_confidence"] ?? 0.0
    ]
    
    // Legacy compatibility
    result["drift"] = consciousness
    
    // Apple LLM integration for enhanced reasoning (disabled for macOS 15.0 compatibility)
    if let cfg = try? loadConfigLocal(), cfg.useAppleLLM == true {
        let syntraDecision = consciousness["syntra_decision"] as? String ?? "processing"
        let enhancedPrompt = "SYNTRA consciousness state: \\(syntraDecision). Original input: \\(input). Provide enhanced reasoning."
        if #available(macOS 26.0, *) {
            let apple = await queryAppleLLMSync(enhancedPrompt)
            result["appleLLM"] = apple
            logStage(stage: "apple_enhanced_reasoning", output: apple, directory: "entropy_logs")
        } else {
            result["appleLLM"] = "Apple LLM requires macOS 26.0+"
        }
    }
    
    return result
}

public func jsonString(_ obj: Any) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
       let str = String(data: data, encoding: .utf8) {
        return str
    }
    return "{}"
}

// Bridge functions to connect Sources/ modules with swift/ implementations

public func reflect_valon(_ input: String) -> String {
    let valon = Valon()
    return valon.reflect(input)
}

public func reflect_modi(_ input: String) -> [String] {
    let modi = Modi()
    return modi.reflect(input)
}

public func loadConfigLocal() throws -> SyntraConfig {
    return try loadConfig(path: "config.json")
}

public func drift_average(_ valonResponse: String, _ modiResponse: [String]) -> [String: Any] {
    let drift = Drift()
    return drift.average(valon: valonResponse, modi: modiResponse)
}

public func syntra_consciousness_synthesis(_ valonResponse: String, _ modiResponse: [String]) -> [String: Any] {
    // Enhanced synthesis combining both approaches
    let basicDrift = drift_average(valonResponse, modiResponse)
    
    // Add consciousness state analysis
    let consciousnessState = determineConsciousnessState(valon: valonResponse, modi: modiResponse)
    let decisionConfidence = calculateDecisionConfidence(valon: valonResponse, modi: modiResponse)
    
    var result = basicDrift
    result["consciousness_state"] = consciousnessState
    result["decision_confidence"] = decisionConfidence
    result["syntra_decision"] = result["synthesis"] ?? "processing"
    
    return result
}

private func determineConsciousnessState(valon: String, modi: [String]) -> String {
    // Analyze the nature of the cognitive processing
    if modi.contains(where: { $0.contains("technical") || $0.contains("analytical") }) {
        if valon.contains("moral") || valon.contains("ethical") {
            return "deliberative_consciousness"  // Both analytical and moral
        } else {
            return "analytical_consciousness"    // Primarily analytical
        }
    } else if valon.contains("moral") || valon.contains("creative") {
        return "value_driven_consciousness"      // Primarily value-driven
    } else {
        return "integrated_consciousness"        // Balanced integration
    }
}

private func calculateDecisionConfidence(valon: String, modi: [String]) -> Double {
    var confidence = 0.5
    
    // Higher confidence when both brains provide clear responses
    if !valon.isEmpty && !modi.isEmpty {
        confidence += 0.2
    }
    
    // Technical analysis increases confidence
    if modi.contains(where: { $0.contains("technical") || $0.contains("high_confidence") }) {
        confidence += 0.2
    }
    
    // Strong moral clarity increases confidence
    if valon.contains("clear") || valon.contains("strong") {
        confidence += 0.15
    }
    
    // Multi-component responses suggest thorough analysis
    if modi.count > 2 || valon.split(separator: "|").count > 2 {
        confidence += 0.1
    }
    
    return min(confidence, 1.0)
}

@available(macOS 26.0, *)
public func queryAppleLLM(_ prompt: String) async -> String {
    do {
        let model = SystemLanguageModel.default
        
        guard model.availability == .available else {
            let msg = "[Apple LLM not available on this device]"
            logStage(stage: "apple_llm", output: ["prompt": prompt, "response": msg], directory: "entropy_logs")
            return msg
        }
        
        let session = LanguageModelSession(model: model)
        let response = try await session.respond(to: prompt)
        
        logStage(stage: "apple_llm", output: ["prompt": prompt, "response": response.content], directory: "entropy_logs")
        return response.content
        
    } catch {
        let msg = "[Apple LLM error: \(error.localizedDescription)]"
        logStage(stage: "apple_llm", output: ["prompt": prompt, "response": msg], directory: "entropy_logs")
        return msg
    }
}

@available(macOS 26.0, *)
public func queryAppleLLMSync(_ prompt: String) async -> String {
    // Use Task.detached for Sendable closure
    let result = await Task<String, Never>.detached(priority: .userInitiated) {
        await queryAppleLLM(prompt)
    }.value
    return result
}

// MARK: - Structured Consciousness Processing

/* Temporarily disabled until StructuredConsciousnessService API is verified
@available(macOS 26.0, *)
public func processThroughBrainsStructured(_ input: String) async -> StructuredConsciousnessResult? {
    do {
        let service = try StructuredConsciousnessService()
        return try await service.processInputCompletely(input)
    } catch {
        logStage(stage: "structured_processing_error", output: ["error": error.localizedDescription], directory: "entropy_logs")
        return nil
    }
}

@available(macOS 26.0, *)
public func processThroughBrainsStructuredSync(_ input: String) -> StructuredConsciousnessResult? {
    let semaphore = DispatchSemaphore(value: 0)
    var result: StructuredConsciousnessResult?
    
    Task {
        result = await processThroughBrainsStructured(input)
        semaphore.signal()
    }
    
    semaphore.wait()
    return result
}

// Enhanced processing with structured generation
@available(macOS 26.0, *)
public func processThroughBrainsWithStructuredOutput(_ input: String) -> [String: Any] {
    // Try structured generation first
    if let structuredResult = processThroughBrainsStructuredSync(input) {
        // Convert structured result to legacy format for compatibility
        return convertStructuredResultToLegacy(structuredResult)
    } else {
        // Fall back to original processing
        return processThroughBrains(input)
    }
}

@available(macOS 26.0, *)
private func convertStructuredResultToLegacy(_ result: StructuredConsciousnessResult) -> [String: Any] {
    return [
        "original_input": result.originalInput,
        "valon": convertValonToLegacy(result.valonAssessment),
        "modi": convertModiToLegacy(result.modiPattern),
        "consciousness": convertSynthesisToLegacy(result.synthesis),
        "conversational_response": convertConversationalToLegacy(result.conversationalResponse),
        "structured_generation": true,
        "consciousness_state": result.synthesis.consciousnessType.rawValue,
        "decision_confidence": result.synthesis.decisionConfidence
    ]
}

@available(macOS 26.0, *)
private func convertValonToLegacy(_ assessment: ValonMoralAssessment) -> String {
    return "\(assessment.primaryEmotion.rawValue)|\(assessment.symbolicRepresentation)|\(assessment.moralGuidance)|urgency:\(assessment.moralUrgency)"
}

@available(macOS 26.0, *)
private func convertModiToLegacy(_ pattern: ModiLogicalPattern) -> [String] {
    var result = [pattern.reasoningFramework.rawValue]
    result.append(contentsOf: pattern.identifiedPatterns.map { $0.rawValue })
    result.append("rigor:\(pattern.logicalRigor)")
    result.append("confidence:\(pattern.analysisConfidence)")
    return result
}

@available(macOS 26.0, *)
private func convertSynthesisToLegacy(_ synthesis: SyntraConsciousnessSynthesis) -> [String: Any] {
    return [
        "consciousness_type": synthesis.consciousnessType.rawValue,
        "syntra_decision": synthesis.consciousDecision,
        "decision_confidence": synthesis.decisionConfidence,
        "valon_influence": synthesis.valonInfluence,
        "modi_influence": synthesis.modiInfluence,
        "integration_strategy": synthesis.integrationStrategy.rawValue,
        "wisdom_level": synthesis.wisdomLevel.rawValue,
        "emergent_insights": synthesis.emergentInsights,
        "cognitive_conflicts": synthesis.cognitiveConflicts,
        "represents_growth": synthesis.representsGrowth
    ]
}

@available(macOS 26.0, *)
private func convertConversationalToLegacy(_ response: SyntraConversationalResponse) -> [String: Any] {
    return [
        "response": response.response,
        "emotional_tone": response.emotionalTone.rawValue,
        "conversation_strategy": response.conversationStrategy.rawValue,
        "helpfulness_level": response.helpfulnessLevel,
        "relationship_dynamic": response.relationshipDynamic.rawValue,
        "identified_topics": response.identifiedTopics
    ]
}
*/

#if false // Disabled for macOS 15.0 compatibility
// MARK: - Structured Consciousness Processing with Modern Foundation Models

@available(macOS 26.0, *)
public func processThroughBrainsStructured(_ input: String) async -> StructuredConsciousnessResult? {
    do {
        let service = try StructuredConsciousnessService()
        return try await service.processInputCompletely(input)
    } catch {
        logStage(stage: "structured_processing_error", output: ["error": error.localizedDescription], directory: "entropy_logs")
        return nil
    }
}

// MARK: - Streaming Consciousness Processing

@available(macOS 26.0, *)
public func streamConsciousnessUpdates(_ input: String) -> AsyncStream<StructuredConsciousnessResult.PartiallyGenerated> {
    AsyncStream { continuation in
        Task {
            do {
                let service = try StructuredConsciousnessService()
                let stream = service.streamConsciousnessUpdates(stimulus: input)
                
                for await partialResult in stream {
                    continuation.yield(partialResult)
                }
                continuation.finish()
            } catch {
                logStage(stage: "streaming_error", output: ["error": error.localizedDescription], directory: "entropy_logs")
                continuation.finish(throwing: error)
            }
        }
    }
}

@available(macOS 26.0, *)
public func streamValonAssessment(_ input: String) -> AsyncStream<ValonMoralAssessment.PartiallyGenerated> {
    AsyncStream { continuation in
        Task {
            do {
                let service = try StructuredConsciousnessService()
                let stream = service.streamValonAssessment(from: input)
                
                for await partialAssessment in stream {
                    continuation.yield(partialAssessment)
                }
                continuation.finish()
            } catch {
                logStage(stage: "valon_streaming_error", output: ["error": error.localizedDescription], directory: "entropy_logs")
                continuation.finish(throwing: error)
            }
        }
    }
}

@available(macOS 26.0, *)
public func streamModiPattern(_ input: String) -> AsyncStream<ModiLogicalPattern.PartiallyGenerated> {
    AsyncStream { continuation in
        Task {
            do {
                let service = try StructuredConsciousnessService()
                let stream = service.streamModiPattern(from: input)
                
                for await partialPattern in stream {
                    continuation.yield(partialPattern)
                }
                continuation.finish()
            } catch {
                logStage(stage: "modi_streaming_error", output: ["error": error.localizedDescription], directory: "entropy_logs")
                continuation.finish(throwing: error)
            }
        }
    }
}

@available(macOS 26.0, *)
public func processThroughBrainsStructuredSync(_ input: String) -> StructuredConsciousnessResult? {
    let semaphore = DispatchSemaphore(value: 0)
    var result: StructuredConsciousnessResult?
    
    Task {
        result = await processThroughBrainsStructured(input)
        semaphore.signal()
    }
    
    semaphore.wait()
    return result
}

// Enhanced processing with structured generation
public func processThroughBrainsWithStructuredOutput(_ input: String) -> [String: Any] {
    if #available(macOS 26.0, *) {
        // Try structured generation first
        if let structuredResult = processThroughBrainsStructuredSync(input) {
            return convertStructuredResultToLegacy(structuredResult)
        }
    }
    // Fallback to standard processing
    return processThroughBrains(input)
}

@available(macOS 26.0, *)
private func convertStructuredResultToLegacy(_ result: StructuredConsciousnessResult) -> [String: Any] {
    return [
        "original_input": result.originalInput,
        "valon": convertValonToLegacy(result.valonAssessment),
        "modi": convertModiToLegacy(result.modiPattern),
        "consciousness": convertSynthesisToLegacy(result.synthesis),
        "conversational_response": convertConversationalToLegacy(result.conversationalResponse),
        "structured_generation": true,
        "consciousness_state": result.synthesis.consciousnessType.rawValue,
        "decision_confidence": result.synthesis.decisionConfidence
    ]
}

@available(macOS 26.0, *)
private func convertValonToLegacy(_ assessment: ValonMoralAssessment) -> [String: Any] {
    return [
        "primary_emotion": assessment.primaryEmotion.rawValue,
        "moral_urgency": assessment.moralUrgency,
        "activated_principles": assessment.activatedPrinciples.map { $0.rawValue },
        "symbolic_representation": assessment.symbolicRepresentation,
        "moral_weight": assessment.moralWeight,
        "moral_concerns": assessment.moralConcerns,
        "moral_guidance": assessment.moralGuidance
    ]
}

@available(macOS 26.0, *)
private func convertModiToLegacy(_ pattern: ModiLogicalPattern) -> [String] {
    var result = [pattern.reasoningFramework.rawValue]
    result.append(contentsOf: pattern.identifiedPatterns.map { $0.rawValue })
    result.append("rigor:\(pattern.logicalRigor)")
    result.append("confidence:\(pattern.analysisConfidence)")
    return result
}

@available(macOS 26.0, *)
private func convertSynthesisToLegacy(_ synthesis: SyntraConsciousnessSynthesis) -> [String: Any] {
    return [
        "consciousness_type": synthesis.consciousnessType.rawValue,
        "syntra_decision": synthesis.consciousDecision,
        "decision_confidence": synthesis.decisionConfidence,
        "valon_influence": synthesis.valonInfluence,
        "modi_influence": synthesis.modiInfluence,
        "integration_strategy": synthesis.integrationStrategy.rawValue,
        "wisdom_level": synthesis.wisdomLevel.rawValue,
        "emergent_insights": synthesis.emergentInsights,
        "cognitive_conflicts": synthesis.cognitiveConflicts,
        "represents_growth": synthesis.representsGrowth
    ]
}

@available(macOS 26.0, *)
private func convertConversationalToLegacy(_ response: SyntraConversationalResponse) -> [String: Any] {
    return [
        "response": response.response,
        "emotional_tone": response.emotionalTone.rawValue,
        "conversation_strategy": response.conversationStrategy.rawValue,
        "helpfulness_level": response.helpfulnessLevel,
        "relationship_dynamic": response.relationshipDynamic.rawValue,
        "identified_topics": response.identifiedTopics
    ]
}
#endif
