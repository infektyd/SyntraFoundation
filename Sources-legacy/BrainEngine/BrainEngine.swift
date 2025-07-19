import Foundation
import Valon
import Modi
import Drift
import ConsciousnessStructures

public class BrainEngine {
    private let driftRatio: (valon: Double, modi: Double)
    
    public init(driftRatio: (valon: Double, modi: Double) = (0.7, 0.3)) {
        self.driftRatio = driftRatio
    }
    
    public func processInput(_ input: String) async -> SyntraConsciousnessSynthesis {
        // 1. Process through Valon (moral/creative brain)
        let valonAssessment = processValonInput(input)
        
        // 2. Process through Modi (logical brain)  
        let modiPattern = processModiInput(input)
        
        // 3. Synthesize consciousness decision with drift weighting
        return synthesizeConsciousness(valon: valonAssessment, modi: modiPattern)
    }
    
    private func processValonInput(_ input: String) -> ValonMoralAssessment {
        let valon = Valon()
        // Use the enhanced assessMorally method that produces full ValonMoralAssessment
        var assessment = valon.assessMorally(input)
        
        // Override the moral weight to match our drift ratio
        assessment = ValonMoralAssessment(
            primaryEmotion: assessment.primaryEmotion,
            moralUrgency: assessment.moralUrgency,
            moralWeight: driftRatio.valon,
            moralGuidance: assessment.moralGuidance,
            moralConcerns: assessment.moralConcerns
        )
        
        return assessment
    }
    
    private func processModiInput(_ input: String) -> ModiLogicalPattern {
        let modi = Modi()
        // Use the enhanced analyzeLogically method that produces full ModiLogicalPattern
        return modi.analyzeLogically(input)
    }
    
    private func synthesizeConsciousness(valon: ValonMoralAssessment, modi: ModiLogicalPattern) -> SyntraConsciousnessSynthesis {
        // Calculate weighted decision confidence
        let decisionConfidence = (valon.moralUrgency * driftRatio.valon) + (modi.logicalRigor * driftRatio.modi)
        
        // Determine consciousness type based on dominant influence
        let consciousnessType: String
        if driftRatio.valon > driftRatio.modi {
            consciousnessType = valon.moralUrgency > 0.7 ? "moral_primary" : "balanced"
        } else {
            consciousnessType = modi.logicalRigor > 0.7 ? "logical_primary" : "balanced"
        }
        
        // Generate emergent insights from synthesis
        let emergentInsights = combineInsights(valon: valon, modi: modi)
        
        // Generate conscious decision
        let consciousDecision = generateConsciousDecision(valon: valon, modi: modi, type: consciousnessType)
        
        return SyntraConsciousnessSynthesis(
            consciousnessType: consciousnessType,
            consciousDecision: consciousDecision,
            decisionConfidence: decisionConfidence,
            valonInfluence: driftRatio.valon,
            modiInfluence: driftRatio.modi,
            emergentInsights: emergentInsights
        )
    }
    
    // MARK: - Helper Methods
    
    private func combineInsights(valon: ValonMoralAssessment, modi: ModiLogicalPattern) -> [String] {
        var emergentInsights: [String] = []
        
        // Synthesis insights based on interaction
        if valon.moralUrgency > 0.7 && modi.logicalRigor > 0.7 {
            emergentInsights.append("High urgency situation requiring precise logical response")
        }
        
        if valon.primaryEmotion.contains("cautious") && modi.reasoningFramework == "technical_analysis" {
            emergentInsights.append("Technical caution advised - safety-first approach")
        }
        
        if valon.moralConcerns.contains("safety") && modi.technicalDomain == "automotive" {
            emergentInsights.append("Automotive safety protocols must be strictly followed")
        }
        
        if emergentInsights.isEmpty {
            emergentInsights.append("Balanced moral-logical synthesis achieved")
        }
        
        return emergentInsights
    }
    
    private func generateConsciousDecision(valon: ValonMoralAssessment, modi: ModiLogicalPattern, type: String) -> String {
        switch type {
        case "moral_primary":
            return "Prioritizing \(valon.moralGuidance) while applying \(modi.reasoningFramework)"
        case "logical_primary":
            return "Applying \(modi.reasoningFramework) with consideration for \(valon.moralConcerns.joined(separator: ", "))"
        default:
            return "Balancing \(valon.primaryEmotion) intuition with \(modi.reasoningFramework) analysis"
        }
    }
}
