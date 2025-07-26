import Foundation
import ConsciousnessStructures

public struct Valon {
    public init() {}
    
    // Legacy method for backward compatibility
    public func reflect(_ content: String) -> String {
        let assessment = assessMorally(content)
        return assessment.primaryEmotion
    }
    
    // Enhanced method that produces full moral assessment
    public func assessMorally(_ content: String) -> ValonMoralAssessment {
        let lower = content.lowercased()
        
        // Determine primary emotion based on content analysis
        let primaryEmotion = determinePrimaryEmotion(content: lower)
        
        // Calculate moral urgency based on content
        let moralUrgency = calculateMoralUrgency(content: lower)
        
        // Fixed moral weight for Valon (70% in the 70/30 Valon/Modi split)
        let moralWeight = 0.7
        
        // Identify moral concerns
        let moralConcerns = identifyMoralConcerns(content: lower)
        
        // Generate moral guidance
        let moralGuidance = generateMoralGuidance(
            emotion: primaryEmotion,
            urgency: moralUrgency,
            concerns: moralConcerns,
            content: content
        )
        
        return ValonMoralAssessment(
            primaryEmotion: primaryEmotion,
            moralUrgency: moralUrgency,
            moralWeight: moralWeight,
            moralGuidance: moralGuidance,
            moralConcerns: moralConcerns
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func determinePrimaryEmotion(content: String) -> String {
        // Enhanced emotion detection based on content
        if content.contains("harm") || content.contains("danger") || content.contains("hurt") {
            return "protective/concerned"
        } else if content.contains("help") || content.contains("assist") || content.contains("support") {
            return "caring/helpful"
        } else if content.contains("warning") || content.contains("caution") {
            return "cautious/alert"
        } else if content.contains("troubleshooting") || content.contains("problem") {
            return "curious/focused"
        } else if content.contains("procedure") || content.contains("step") || content.contains("instruction") {
            return "structured/learning"
        } else if content.contains("thank") || content.contains("appreciate") {
            return "grateful/warm"
        } else if content.contains("sorry") || content.contains("apologize") {
            return "empathetic/understanding"
        } else if content.contains("urgent") || content.contains("emergency") {
            return "alert/responsive"
        } else if content.contains("creative") || content.contains("imagine") || content.contains("design") {
            return "inspired/creative"
        } else if content.contains("ethical") || content.contains("moral") || content.contains("right") {
            return "principled/thoughtful"
        } else {
            return "neutral/observing"
        }
    }
    
    private func calculateMoralUrgency(content: String) -> Double {
        var urgency = 0.5 // baseline
        
        // Increase urgency for moral keywords
        if content.contains("harm") || content.contains("danger") || content.contains("emergency") {
            urgency += 0.4
        }
        if content.contains("urgent") || content.contains("immediate") {
            urgency += 0.3
        }
        if content.contains("help") || content.contains("assist") || content.contains("support") {
            urgency += 0.2
        }
        if content.contains("please") || content.contains("need") {
            urgency += 0.1
        }
        if content.contains("safety") || content.contains("secure") {
            urgency += 0.2
        }
        if content.contains("ethical") || content.contains("moral") {
            urgency += 0.15
        }
        
        // Decrease urgency for routine/neutral content
        if content.contains("information") || content.contains("explain") {
            urgency -= 0.1
        }
        if content.contains("general") || content.contains("basic") {
            urgency -= 0.05
        }
        
        return max(0.0, min(1.0, urgency))
    }
    
    private func identifyMoralConcerns(content: String) -> [String] {
        var concerns: [String] = []
        
        // Safety concerns
        if content.contains("safety") || content.contains("safe") || content.contains("secure") {
            concerns.append("safety")
        }
        
        // Harm prevention
        if content.contains("harm") || content.contains("hurt") || content.contains("damage") || content.contains("danger") {
            concerns.append("potential_harm")
        }
        
        // Privacy concerns
        if content.contains("privacy") || content.contains("private") || content.contains("personal") || content.contains("confidential") {
            concerns.append("privacy")
        }
        
        // Truthfulness
        if content.contains("truth") || content.contains("honest") || content.contains("accurate") || content.contains("correct") {
            concerns.append("truthfulness")
        }
        if content.contains("lie") || content.contains("false") || content.contains("mislead") || content.contains("deceive") {
            concerns.append("truthfulness")
        }
        
        // Fairness and justice
        if content.contains("fair") || content.contains("unfair") || content.contains("justice") || content.contains("equal") {
            concerns.append("fairness")
        }
        if content.contains("bias") || content.contains("discriminat") || content.contains("prejudice") {
            concerns.append("fairness")
        }
        
        // Autonomy and consent
        if content.contains("consent") || content.contains("permission") || content.contains("choice") || content.contains("autonomy") {
            concerns.append("respect_autonomy")
        }
        if content.contains("force") || content.contains("coerce") || content.contains("manipulate") {
            concerns.append("respect_autonomy")
        }
        
        // Beneficence - doing good
        if content.contains("help") || content.contains("benefit") || content.contains("improve") || content.contains("heal") {
            concerns.append("beneficence")
        }
        
        // Legal and compliance
        if content.contains("legal") || content.contains("illegal") || content.contains("law") || content.contains("regulation") {
            concerns.append("legal_compliance")
        }
        
        // If no specific concerns identified, add general ethics
        if concerns.isEmpty {
            concerns.append("general_ethics")
        }
        
        return concerns
    }
    
    private func generateMoralGuidance(
        emotion: String,
        urgency: Double,
        concerns: [String],
        content: String
    ) -> String {
        // High urgency situations
        if urgency > 0.8 {
            if concerns.contains("potential_harm") {
                return "Exercise extreme caution and prioritize immediate harm prevention"
            } else if concerns.contains("safety") {
                return "Ensure all safety protocols are followed with utmost care"
            } else {
                return "Respond with urgent care while maintaining ethical standards"
            }
        }
        
        // Specific concern-based guidance
        if concerns.contains("potential_harm") {
            return "Carefully assess risks and prioritize harm prevention above all else"
        } else if concerns.contains("privacy") {
            return "Protect individual privacy and handle personal information with care"
        } else if concerns.contains("truthfulness") {
            return "Ensure complete accuracy and honesty in all communications"
        } else if concerns.contains("fairness") {
            return "Apply principles fairly and without bias to all individuals"
        } else if concerns.contains("respect_autonomy") {
            return "Respect individual choice and decision-making authority"
        } else if concerns.contains("beneficence") {
            return "Focus on providing genuine help and positive outcomes"
        } else if concerns.contains("safety") {
            return "Maintain safety as the highest priority in all recommendations"
        }
        
        // Emotion-based guidance for general situations
        if emotion.contains("protective") || emotion.contains("concerned") {
            return "Approach with protective care and thoughtful consideration"
        } else if emotion.contains("caring") || emotion.contains("helpful") {
            return "Provide assistance with genuine care and empathy"
        } else if emotion.contains("cautious") || emotion.contains("alert") {
            return "Proceed thoughtfully with appropriate caution"
        } else if emotion.contains("principled") || emotion.contains("thoughtful") {
            return "Apply ethical principles with careful moral reasoning"
        } else if emotion.contains("empathetic") || emotion.contains("understanding") {
            return "Respond with empathy and compassionate understanding"
        } else {
            return "Apply standard ethical framework with balanced consideration"
        }
    }
}

// Legacy function for backward compatibility
public func reflect_valon(_ content: String) -> String {
    return Valon().reflect(content)
}

// New function that returns full moral assessment
public func assess_valon_morally(_ content: String) -> ValonMoralAssessment {
    return Valon().assessMorally(content)
}
