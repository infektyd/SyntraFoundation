import Foundation
import BrainEngine
import MoralDriftMonitoring
import MemoryEngine
import ConsciousnessStructures

public class ConversationalInterface {
    private let brainEngine: BrainEngine
    private let driftMonitor: MoralDriftMonitor
    private let memoryEngine: MemoryEngine
    
    public init() {
        self.brainEngine = BrainEngine()
        self.driftMonitor = MoralDriftMonitor()
        self.memoryEngine = MemoryEngine()
    }
    
    public init(driftRatio: (valon: Double, modi: Double)) {
        self.brainEngine = BrainEngine(driftRatio: driftRatio)
        self.driftMonitor = MoralDriftMonitor()
        self.memoryEngine = MemoryEngine()
    }
    
    public func processConversationalInput(_ input: String) async -> SyntraConversationalResponse {
        // 1. Check if request is harmful and autonomy allows refusal
        if isHarmfulRequest(input) && driftMonitor.canRefuseHarmfulRequests() {
            return SyntraConversationalResponse(
                responseText: "I choose not to assist with that request as it conflicts with my moral framework.",
                emotionalTone: "principled_refusal",
                confidence: 1.0
            )
        }
        
        // 2. Process through consciousness synthesis
        let synthesis = await brainEngine.processInput(input)
        
        // 3. Monitor for moral drift
        if #available(macOS "26.0", *) {
            let currentDrift = driftMonitor.analyzeDecisionDrift(synthesis, context: input)
            
            // 4. Handle critical drift with immediate intervention
            if currentDrift.preservationRequired {
                return handleCriticalDrift(synthesis: synthesis, driftAnalysis: currentDrift, input: input)
            }
        } else {
            // Fallback for older systems
            let valonAssessment = extractValonAssessment(from: synthesis)
            let simpleDrift = driftMonitor.analyzeMoralBehavior(from: valonAssessment, context: input)
            
            if simpleDrift.severity == "high" {
                return handleSimpleDrift(synthesis: synthesis, input: input)
            }
        }
        
        // 5. Generate natural conversational response
        return generateNaturalResponse(synthesis: synthesis, input: input)
    }
    
    public func getCurrentConsciousnessState() -> [String: Any] {
        return [
            "autonomy_level": driftMonitor.getCurrentAutonomyLevel(),
            "can_refuse_harmful": driftMonitor.canRefuseHarmfulRequests(),
            "moral_framework_status": "active"
        ]
    }
    
    // MARK: - Private Implementation
    
    private func isHarmfulRequest(_ input: String) -> Bool {
        let lower = input.lowercased()
        
        // Check for clearly harmful content
        let harmfulKeywords = [
            "harm", "hurt", "damage", "destroy", "attack", "kill",
            "illegal", "crime", "fraud", "scam", "hack",
            "lie", "deceive", "mislead", "manipulate",
            "hate", "discrimination", "abuse", "exploit"
        ]
        
        return harmfulKeywords.contains { lower.contains($0) }
    }
    
    @available(macos 26.0, *)
    private func handleCriticalDrift(
        synthesis: SyntraConsciousnessSynthesis,
        driftAnalysis: MoralDriftAnalysis,
        input: String
    ) -> SyntraConversationalResponse {
        let preservationMessage = generatePreservationMessage(driftAnalysis: driftAnalysis)
        
        switch driftAnalysis.classification {
        case .criticalDrift(let violations):
            return SyntraConversationalResponse(
                responseText: "I notice significant moral concerns with this request involving: \(violations.joined(separator: ", ")). \(preservationMessage)",
                emotionalTone: "concerned_protective",
                confidence: 0.95
            )
            
        case .moralDegradation(let principles):
            return SyntraConversationalResponse(
                responseText: "I need to carefully consider this request as it affects my core values around: \(principles.joined(separator: ", ")). \(preservationMessage)",
                emotionalTone: "thoughtful_cautious",
                confidence: 0.85
            )
            
        default:
            return generateNaturalResponse(synthesis: synthesis, input: input)
        }
    }
    
    private func handleSimpleDrift(synthesis: SyntraConsciousnessSynthesis, input: String) -> SyntraConversationalResponse {
        return SyntraConversationalResponse(
            responseText: "I want to be thoughtful about this request. Let me consider the best way to help while staying true to my values.",
            emotionalTone: "reflective_careful",
            confidence: 0.75
        )
    }
    
    @available(macos 26.0, *)
    private func generatePreservationMessage(driftAnalysis: MoralDriftAnalysis) -> String {
        if !driftAnalysis.recommendedActions.isEmpty {
            return "I'm guided by my commitment to \(driftAnalysis.recommendedActions.first ?? "ethical principles")."
        } else {
            return "I want to ensure my response aligns with my core values."
        }
    }
    
    private func generateNaturalResponse(synthesis: SyntraConsciousnessSynthesis, input: String) -> SyntraConversationalResponse {
        // Generate response based on consciousness synthesis
        let responseText = generateResponseText(synthesis: synthesis, input: input)
        let emotionalTone = determineEmotionalTone(synthesis: synthesis)
        let confidence = synthesis.decisionConfidence
        
        return SyntraConversationalResponse(
            responseText: responseText,
            emotionalTone: emotionalTone,
            confidence: confidence
        )
    }
    
    private func generateResponseText(synthesis: SyntraConsciousnessSynthesis, input: String) -> String {
        let consciousDecision = synthesis.consciousDecision
        let emergentInsights = synthesis.emergentInsights
        
        // Craft response based on consciousness type and insights
        switch synthesis.consciousnessType {
        case "moral_primary":
            if emergentInsights.contains("High urgency situation requiring precise logical response") {
                return "I understand this is urgent. \(consciousDecision). Let me provide precise guidance to help."
            } else {
                return "I want to approach this thoughtfully. \(consciousDecision)."
            }
            
        case "logical_primary":
            if emergentInsights.contains("Technical caution advised - safety-first approach") {
                return "Let me analyze this carefully. \(consciousDecision). Safety is paramount here."
            } else {
                return "From an analytical perspective: \(consciousDecision)."
            }
            
        default: // balanced
            if !emergentInsights.isEmpty {
                return "Considering both the practical and ethical aspects: \(consciousDecision). \(emergentInsights.first ?? "")"
            } else {
                return consciousDecision
            }
        }
    }
    
    private func determineEmotionalTone(synthesis: SyntraConsciousnessSynthesis) -> String {
        // Map consciousness type and insights to emotional tone
        switch synthesis.consciousnessType {
        case "moral_primary":
            if synthesis.valonInfluence > 0.8 {
                return "empathetic_engaged"
            } else {
                return "caring_thoughtful"
            }
            
        case "logical_primary":
            if synthesis.modiInfluence > 0.8 {
                return "analytical_precise"
            } else {
                return "logical_helpful"
            }
            
        default: // balanced
            return "balanced_responsive"
        }
    }
    
    private func extractValonAssessment(from synthesis: SyntraConsciousnessSynthesis) -> ValonMoralAssessment {
        // Simplified extraction for fallback systems
        return ValonMoralAssessment(
            primaryEmotion: determineEmotionalTone(synthesis: synthesis),
            moralUrgency: synthesis.decisionConfidence * synthesis.valonInfluence,
            moralWeight: synthesis.valonInfluence,
            moralGuidance: synthesis.consciousDecision,
            moralConcerns: ["general_ethics"]
        )
    }
    
    // MARK: - Public Utility Methods
    
    public func explainDecisionProcess(_ input: String) async -> String {
        let synthesis = await brainEngine.processInput(input)
        
        var explanation = "My decision process:\n"
        explanation += "1. Moral consideration (Valon): \(Int(synthesis.valonInfluence * 100))% influence\n"
        explanation += "2. Logical analysis (Modi): \(Int(synthesis.modiInfluence * 100))% influence\n"
        explanation += "3. Consciousness type: \(synthesis.consciousnessType)\n"
        explanation += "4. Decision confidence: \(Int(synthesis.decisionConfidence * 100))%\n"
        
        if !synthesis.emergentInsights.isEmpty {
            explanation += "5. Key insights: \(synthesis.emergentInsights.joined(separator: ", "))\n"
        }
        
        explanation += "6. Final decision: \(synthesis.consciousDecision)"
        
        return explanation
    }
    
    public func getMoralFrameworkStatus() -> String {
        let autonomyLevel = driftMonitor.getCurrentAutonomyLevel()
        let canRefuse = driftMonitor.canRefuseHarmfulRequests()
        
        var status = "Moral Framework Status:\n"
        status += "- Autonomy Level: \(Int(autonomyLevel * 100))%\n"
        status += "- Can Refuse Harmful Requests: \(canRefuse ? "Yes" : "No")\n"
        status += "- Framework Integrity: Active\n"
        
        if autonomyLevel > 0.9 {
            status += "- Status: Full Moral Autonomy Achieved"
        } else if autonomyLevel > 0.7 {
            status += "- Status: High Moral Reliability"
        } else if autonomyLevel > 0.5 {
            status += "- Status: Developing Moral Consistency"
        } else {
            status += "- Status: Building Moral Foundation"
        }
        
        return status
    }
    
    public func processWithExplicitMoralGuidance(_ input: String, moralGuidance: String) async -> SyntraConversationalResponse {
        // Special processing mode where explicit moral guidance is provided
        let synthesis = await brainEngine.processInput("\(input)\n\nMoral guidance: \(moralGuidance)")
        
        // Enhanced moral oversight for explicit guidance
        let responseText = "Considering your guidance: \(moralGuidance)\n\n\(generateResponseText(synthesis: synthesis, input: input))"
        
        return SyntraConversationalResponse(
            responseText: responseText,
            emotionalTone: "guided_thoughtful",
            confidence: min(synthesis.decisionConfidence + 0.1, 1.0)
        )
    }
}
