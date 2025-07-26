import Foundation

// Fallback structs (no Foundation Models dependency)
public struct ValonMoralAssessment {
    public let primaryEmotion: String
    public let moralUrgency: Double
    public let moralWeight: Double
    public let moralGuidance: String
    public let moralConcerns: [String]
    
    public init(primaryEmotion: String, moralUrgency: Double, moralWeight: Double, moralGuidance: String, moralConcerns: [String]) {
        self.primaryEmotion = primaryEmotion
        self.moralUrgency = moralUrgency
        self.moralWeight = moralWeight
        self.moralGuidance = moralGuidance
        self.moralConcerns = moralConcerns
    }
}

public struct ModiLogicalPattern {
    public let reasoningFramework: String
    public let logicalRigor: Double
    public let analysisConfidence: Double
    public let technicalDomain: String
    public let logicalInsights: [String]
    
    public init(reasoningFramework: String, logicalRigor: Double, analysisConfidence: Double, technicalDomain: String, logicalInsights: [String]) {
        self.reasoningFramework = reasoningFramework
        self.logicalRigor = logicalRigor
        self.analysisConfidence = analysisConfidence
        self.technicalDomain = technicalDomain
        self.logicalInsights = logicalInsights
    }
}

public struct SyntraConsciousnessSynthesis {
    public let consciousnessType: String
    public let consciousDecision: String
    public let decisionConfidence: Double
    public let valonInfluence: Double
    public let modiInfluence: Double
    public let emergentInsights: [String]
    
    public init(consciousnessType: String, consciousDecision: String, decisionConfidence: Double, valonInfluence: Double, modiInfluence: Double, emergentInsights: [String]) {
        self.consciousnessType = consciousnessType
        self.consciousDecision = consciousDecision
        self.decisionConfidence = decisionConfidence
        self.valonInfluence = valonInfluence
        self.modiInfluence = modiInfluence
        self.emergentInsights = emergentInsights
    }
}

public struct SyntraConversationalResponse {
    public let responseText: String
    public let emotionalTone: String
    public let confidence: Double
    
    public init(responseText: String, emotionalTone: String, confidence: Double) {
        self.responseText = responseText
        self.emotionalTone = emotionalTone
        self.confidence = confidence
    }
}