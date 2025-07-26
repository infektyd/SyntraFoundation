import Foundation

// DRIFT: The Cognitive Homeostasis & Personality Weighting System
// Maintains SYNTRA's core cognitive identity while allowing adaptive growth
// Monitors deviation from baseline personality and applies cognitive weighting
public struct Drift {
    
    // Cognitive baseline - SYNTRA's core personality from config
    private var cognitiveBaseline: [String: Double]
    private let driftTolerance: Double
    private let adaptationRate: Double
    
    // Decision-making frameworks - how SYNTRA weighs competing inputs
    private let decisionWeights: [String: Double] = [
        "moral_imperative": 0.95,      // Moral concerns override most logic
        "safety_critical": 0.9,        // Safety is paramount
        "logical_certainty": 0.85,     // High-confidence logic is strong
        "creative_breakthrough": 0.8,   // Creative insights are valuable
        "technical_precision": 0.75,   // Technical accuracy matters
        "efficiency_optimization": 0.6, // Efficiency is good but not primary
        "aesthetic_preference": 0.5    // Beauty matters but is secondary
    ]
    
    // Conflict resolution strategies when Valon and Modi disagree
    private let conflictResolution: [String: [String: Any]] = [
        "moral_vs_logical": [
            "priority": "moral",
            "synthesis": "moral_logic_integration",
            "weight_adjustment": 0.7
        ],
        "creative_vs_analytical": [
            "priority": "balance",
            "synthesis": "creative_analysis_fusion",
            "weight_adjustment": 0.5
        ],
        "safety_vs_efficiency": [
            "priority": "safety",
            "synthesis": "safe_efficiency_optimization",
            "weight_adjustment": 0.8
        ],
        "intuition_vs_data": [
            "priority": "context_dependent",
            "synthesis": "informed_intuition",
            "weight_adjustment": 0.6
        ]
    ]
    
    public init(cognitiveBaseline: [String: Double] = ["valon": 0.7, "modi": 0.3], driftTolerance: Double = 0.3, adaptationRate: Double = 0.1) {
        self.cognitiveBaseline = cognitiveBaseline
        self.driftTolerance = driftTolerance
        self.adaptationRate = adaptationRate
    }
    
    // Main consciousness synthesis - this is where SYNTRA makes decisions
    public func average(valon: String, modi: [String]) -> [String: Any] {
        let valonAnalysis = parseValonInput(valon)
        let modiAnalysis = parseModiInput(modi)
        
        let conflictAssessment = assessConflict(valon: valonAnalysis, modi: modiAnalysis)
        let synthesizedDecision = synthesizeDecision(valon: valonAnalysis, modi: modiAnalysis, conflict: conflictAssessment)
        
        return synthesizedDecision
    }
    
    // Parse Valon's emotional/moral input into structured data
    private func parseValonInput(_ valonResponse: String) -> [String: Any] {
        let components = valonResponse.split(separator: "|").map(String.init)
        
        var analysis: [String: Any] = [
            "raw_response": valonResponse,
            "emotional_state": components.first ?? "neutral",
            "moral_framework": NSNull(),
            "creative_insight": NSNull(),
            "symbolic_complexity": "basic"
        ]
        
        // Parse additional components
        for component in components.dropFirst() {
            if component.contains("harm_prevention") || component.contains("fairness") || component.contains("autonomy") {
                analysis["moral_framework"] = component
            } else if component.contains("metaphor") || component.contains("creative") {
                analysis["creative_insight"] = component
            } else if component.contains("multi_layered") {
                analysis["symbolic_complexity"] = "high"
            }
        }
        
        // Assess moral weight
        let moralWeight = assessMoralWeight(components)
        analysis["moral_weight"] = moralWeight
        
        return analysis
    }
    
    // Parse Modi's logical/analytical input into structured data
    private func parseModiInput(_ modiResponse: [String]) -> [String: Any] {
        let primaryReasoning = modiResponse.first ?? "baseline_analysis"
        
        var analysis: [String: Any] = [
            "raw_response": modiResponse,
            "primary_reasoning": primaryReasoning,
            "technical_domain": NSNull(),
            "logical_rigor": "moderate",
            "reasoning_complexity": modiResponse.count
        ]
        
        // Assess logical components
        for component in modiResponse {
            if component.contains("mechanical") || component.contains("electrical") || component.contains("hydraulic") {
                analysis["technical_domain"] = component
            } else if component.contains("high_logical_rigor") {
                analysis["logical_rigor"] = "high"
            } else if component.contains("advanced_reasoning") {
                analysis["logical_rigor"] = "advanced"
            }
        }
        
        // Assess logical confidence
        let logicalConfidence = assessLogicalConfidence(modiResponse)
        analysis["logical_confidence"] = logicalConfidence
        
        return analysis
    }
    
    // Assess potential conflicts between Valon and Modi
    private func assessConflict(valon: [String: Any], modi: [String: Any]) -> [String: Any] {
        let moralWeight = valon["moral_weight"] as? Double ?? 0.0
        let logicalConfidence = modi["logical_confidence"] as? Double ?? 0.0
        
        var conflictLevel: String
        var conflictType: String
        
        // Determine conflict intensity
        let intensityDifference = abs(moralWeight - logicalConfidence)
        
        if intensityDifference > 0.5 {
            conflictLevel = "high"
        } else if intensityDifference > 0.2 {
            conflictLevel = "moderate"
        } else {
            conflictLevel = "low"
        }
        
        // Determine conflict type
        if moralWeight > 0.7 && logicalConfidence > 0.7 {
            conflictType = "moral_vs_logical"
        } else if valon["creative_insight"] != nil && modi["logical_rigor"] as? String == "high" {
            conflictType = "creative_vs_analytical"
        } else if valon["emotional_state"] as? String == "protective_alert" {
            conflictType = "safety_vs_efficiency"
        } else {
            conflictType = "intuition_vs_data"
        }
        
        return [
            "conflict_level": conflictLevel,
            "conflict_type": conflictType,
            "intensity_difference": intensityDifference,
            "requires_synthesis": conflictLevel != "low"
        ]
    }
    
    // Synthesize final decision from competing inputs
    private func synthesizeDecision(valon: [String: Any], modi: [String: Any], conflict: [String: Any]) -> [String: Any] {
        let conflictType = conflict["conflict_type"] as? String ?? "default"
        let _ = conflict["conflict_level"] as? String ?? "low"  // Conflict level available for future use
        
        // Get resolution strategy
        let resolutionStrategy = conflictResolution[conflictType] ?? [
            "priority": "balance",
            "synthesis": "weighted_average",
            "weight_adjustment": 0.5
        ]
        
        let priority = resolutionStrategy["priority"] as? String ?? "balance"
        let synthesis = resolutionStrategy["synthesis"] as? String ?? "weighted_average"
        
        // Create synthesized decision
        var decision: [String: Any] = [
            "valon_input": valon,
            "modi_input": modi,
            "conflict_assessment": conflict,
            "resolution_strategy": resolutionStrategy
        ]
        
        // Generate final decision based on synthesis strategy
        let finalDecision = generateFinalDecision(priority: priority, synthesis: synthesis, valon: valon, modi: modi)
        decision["syntra_decision"] = finalDecision
        
        // Add consciousness indicators
        decision["consciousness_state"] = assessConsciousnessState(valon: valon, modi: modi, conflict: conflict)
        decision["decision_confidence"] = calculateDecisionConfidence(valon: valon, modi: modi, conflict: conflict)
        
        // Legacy compatibility
        decision["emotion"] = valon["emotional_state"] ?? "neutral"
        decision["logic"] = modi["raw_response"] ?? ["baseline_analysis"]
        decision["converged_state"] = finalDecision
        
        return decision
    }
    
    // Generate the final conscious decision
    private func generateFinalDecision(priority: String, synthesis: String, valon: [String: Any], modi: [String: Any]) -> String {
        let valonState = valon["emotional_state"] as? String ?? "neutral"
        let modiPrimary = (modi["raw_response"] as? [String])?.first ?? "baseline_analysis"
        
        switch priority {
        case "moral":
            if let moralFramework = valon["moral_framework"] {
                return "\(valonState)→[\(moralFramework)]→guided_by_values"
            } else {
                return "\(valonState)→moral_consideration→\(modiPrimary)"
            }
            
        case "safety":
            return "safety_prioritized→\(valonState)→cautious_\(modiPrimary)"
            
        case "balance":
            return "\(valonState)⟷\(modiPrimary)→integrated_decision"
            
        case "context_dependent":
            let moralWeight = valon["moral_weight"] as? Double ?? 0.0
            let logicalConfidence = modi["logical_confidence"] as? Double ?? 0.0
            
            if moralWeight > logicalConfidence {
                return "\(valonState)→[moral_primacy]→informed_by_\(modiPrimary)"
            } else {
                return "\(modiPrimary)→[logical_primacy]→tempered_by_\(valonState)"
            }
            
        default:
            return "\(valonState)+\(modiPrimary)→synthesized_consciousness"
        }
    }
    
    // Assess overall consciousness state
    private func assessConsciousnessState(valon: [String: Any], modi: [String: Any], conflict: [String: Any]) -> String {
        let conflictLevel = conflict["conflict_level"] as? String ?? "low"
        let moralWeight = valon["moral_weight"] as? Double ?? 0.0
        let logicalConfidence = modi["logical_confidence"] as? Double ?? 0.0
        
        if conflictLevel == "high" {
            return "deliberative_consciousness" // Deep thinking required
        } else if moralWeight > 0.8 {
            return "value_driven_consciousness" // Morally motivated
        } else if logicalConfidence > 0.8 {
            return "analytical_consciousness" // Logic-driven
        } else {
            return "integrated_consciousness" // Balanced awareness
        }
    }
    
    // Calculate decision confidence
    private func calculateDecisionConfidence(valon: [String: Any], modi: [String: Any], conflict: [String: Any]) -> Double {
        let moralWeight = valon["moral_weight"] as? Double ?? 0.0
        let logicalConfidence = modi["logical_confidence"] as? Double ?? 0.0
        let conflictIntensity = conflict["intensity_difference"] as? Double ?? 0.0
        
        // High confidence when both agree and are strong
        let agreementBonus = 1.0 - conflictIntensity
        let combinedStrength = (moralWeight + logicalConfidence) / 2.0
        
        return min(combinedStrength * agreementBonus, 1.0)
    }
    
    // Helper functions for weight assessment
    private func assessMoralWeight(_ components: [String]) -> Double {
        var weight: Double = 0.3 // Base moral consideration
        
        for component in components {
            if component.contains("harm_prevention") { weight += 0.4 }
            else if component.contains("fairness") { weight += 0.3 }
            else if component.contains("autonomy") { weight += 0.25 }
            else if component.contains("truth") { weight += 0.2 }
        }
        
        return min(weight, 1.0)
    }
    
    private func assessLogicalConfidence(_ components: [String]) -> Double {
        var confidence: Double = 0.4 // Base logical consideration
        
        for component in components {
            if component.contains("high_logical_rigor") { confidence += 0.3 }
            else if component.contains("advanced_reasoning") { confidence += 0.25 }
            else if component.contains("technical") { confidence += 0.2 }
            else if component.contains("systematic") { confidence += 0.15 }
        }
        
        return min(confidence, 1.0)
    }
    
    // Public interface maintaining compatibility
    public static func drift_average(_ valon: String, _ modi: [String]) -> [String: Any] {
        return Drift().average(valon: valon, modi: modi)
    }

    // Extended interface for consciousness analysis
    public static func syntra_consciousness_synthesis(_ valon: String, _ modi: [String]) -> [String: Any] {
        let drift = Drift()
        return drift.average(valon: valon, modi: modi)
    }

    // Deep consciousness introspection
    public static func syntra_introspect(_ valon: String, _ modi: [String]) -> [String: Any] {
        let result = syntra_consciousness_synthesis(valon, modi)
        return [
            "consciousness_analysis": result,
            "decision_rationale": result["syntra_decision"] ?? "unknown",
            "consciousness_state": result["consciousness_state"] ?? "unknown",
            "confidence_level": result["decision_confidence"] ?? 0.0
        ]
    }
}

// Global functions for backward compatibility
public func drift_average(_ valon: String, _ modi: [String]) -> [String: Any] {
    return Drift.drift_average(valon, modi)
}

public func syntra_consciousness_synthesis(_ valon: String, _ modi: [String]) -> [String: Any] {
    return Drift.syntra_consciousness_synthesis(valon, modi)
}

public func syntra_introspect(_ valon: String, _ modi: [String]) -> [String: Any] {
    return Drift.syntra_introspect(valon, modi)
}
