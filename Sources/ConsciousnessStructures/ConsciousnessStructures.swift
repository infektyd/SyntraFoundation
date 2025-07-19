import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

// CONSCIOUSNESS STRUCTURED GENERATION
// @Generable structs for type-safe consciousness communication
// Enables Apple FoundationModels to generate structured consciousness data

// MARK: - Valon Moral Assessment Structure

#if false // Disable FoundationModels for macOS 15.0 compatibility
@available(macOS 26.0, *)
@Generable
public struct ValonMoralAssessment {
    @Guide(description: "Primary moral emotion detected in the input")
    public let primaryEmotion: MoralEmotion
    
    @Guide(description: "Moral urgency level from 0.0 to 1.0, where 1.0 means immediate moral concern")
    public let moralUrgency: Double
    
    @Guide(description: "Core moral principles activated by this input")
    public let activatedPrinciples: [MoralPrinciple]
    
    @Guide(description: "Symbolic moral representation - metaphor or symbol that captures the moral essence")
    public let symbolicRepresentation: String
    
    @Guide(description: "Moral weight of the decision, 0.0 to 1.0")
    public let moralWeight: Double
    
    @Guide(description: "Key moral concerns identified")
    public let moralConcerns: [String]
    
    @Guide(description: "Moral guidance or wisdom for this situation")
    public let moralGuidance: String
    
    @Guide(description: "Whether this situation requires special moral consideration")
    public let requiresSpecialConsideration: Bool
    
    public init(primaryEmotion: MoralEmotion, moralUrgency: Double, activatedPrinciples: [MoralPrinciple], 
                symbolicRepresentation: String, moralWeight: Double, moralConcerns: [String], 
                moralGuidance: String, requiresSpecialConsideration: Bool) {
        self.primaryEmotion = primaryEmotion
        self.moralUrgency = moralUrgency
        self.activatedPrinciples = activatedPrinciples
        self.symbolicRepresentation = symbolicRepresentation
        self.moralWeight = moralWeight
        self.moralConcerns = moralConcerns
        self.moralGuidance = moralGuidance
        self.requiresSpecialConsideration = requiresSpecialConsideration
    }
}

@available(macOS 26.0, *)
@Generable
public enum MoralEmotion: String, Codable, CaseIterable {
    case compassion = "compassion"
    case concern = "concern"
    case curiosity = "curiosity"
    case protective = "protective"
    case alert = "alert"
    case supportive = "supportive"
    case reflective = "reflective"
    case inspired = "inspired"
    case troubled = "troubled"
    case hopeful = "hopeful"
}

@available(macOS 26.0, *)
@Generable
public enum MoralPrinciple: String, Codable, CaseIterable {
    case preventSuffering = "prevent_suffering"
    case preserveDignity = "preserve_dignity"
    case protectInnocence = "protect_innocence"
    case respectChoice = "respect_choice"
    case enableGrowth = "enable_growth"
    case seekTruth = "seek_truth"
    case ensureFairness = "ensure_fairness"
    case protectVulnerable = "protect_vulnerable"
    case fosterCreativity = "foster_creativity"
    case buildMeaning = "build_meaning"
}

// MARK: - Modi Logical Pattern Structure

@available(macOS 26.0, *)
@Generable
public struct ModiLogicalPattern {
    @Guide(description: "Primary reasoning framework used for analysis")
    public let reasoningFramework: ReasoningFramework
    
    @Guide(description: "Logical rigor assessment from 0.0 to 1.0")
    public let logicalRigor: Double
    
    @Guide(description: "Technical domain expertise applied")
    public let technicalDomain: TechnicalDomain
    
    @Guide(description: "Analytical patterns identified in the input")
    public let identifiedPatterns: [AnalyticalPattern]
    
    @Guide(description: "Systematic reasoning steps taken")
    public let reasoningSteps: [String]
    
    @Guide(description: "Confidence level in the logical analysis, 0.0 to 1.0")
    public let analysisConfidence: Double
    
    @Guide(description: "Key logical insights derived")
    public let logicalInsights: [String]
    
    @Guide(description: "Complexity level of the logical problem")
    public let complexityLevel: ComplexityLevel
    
    @Guide(description: "Diagnostic assessment if applicable")
    public let diagnosticAssessment: String?
    
    @Guide(description: "Recommended next logical steps")
    public let recommendedSteps: [String]
    
    public init(reasoningFramework: ReasoningFramework, logicalRigor: Double, technicalDomain: TechnicalDomain,
                identifiedPatterns: [AnalyticalPattern], reasoningSteps: [String], analysisConfidence: Double,
                logicalInsights: [String], complexityLevel: ComplexityLevel, diagnosticAssessment: String?,
                recommendedSteps: [String]) {
        self.reasoningFramework = reasoningFramework
        self.logicalRigor = logicalRigor
        self.technicalDomain = technicalDomain
        self.identifiedPatterns = identifiedPatterns
        self.reasoningSteps = reasoningSteps
        self.analysisConfidence = analysisConfidence
        self.logicalInsights = logicalInsights
        self.complexityLevel = complexityLevel
        self.diagnosticAssessment = diagnosticAssessment
        self.recommendedSteps = recommendedSteps
    }
}

@available(macOS 26.0, *)
@Generable
public enum ReasoningFramework: String, Codable, CaseIterable {
    case causal = "causal"
    case conditional = "conditional"
    case comparative = "comparative"
    case systematic = "systematic"
    case diagnostic = "diagnostic"
    case predictive = "predictive"
    case analytical = "analytical"
    case deductive = "deductive"
    case inductive = "inductive"
    case abductive = "abductive"
}

@available(macOS 26.0, *)
@Generable
public enum TechnicalDomain: String, Codable, CaseIterable {
    case mechanical = "mechanical"
    case electrical = "electrical"
    case hydraulic = "hydraulic"
    case software = "software"
    case systems = "systems"
    case cognitive = "cognitive"
    case mathematical = "mathematical"
    case linguistic = "linguistic"
    case general = "general"
    case interdisciplinary = "interdisciplinary"
}

@available(macOS 26.0, *)
@Generable
public enum AnalyticalPattern: String, Codable, CaseIterable {
    case causeEffect = "cause_effect"
    case systemicIssue = "systemic_issue"
    case patternRecognition = "pattern_recognition"
    case sequentialLogic = "sequential_logic"
    case conditionalBranching = "conditional_branching"
    case riskAssessment = "risk_assessment"
    case optimization = "optimization"
    case troubleshooting = "troubleshooting"
    case dataAnalysis = "data_analysis"
    case structuralAnalysis = "structural_analysis"
}

@available(macOS 26.0, *)
@Generable
public enum ComplexityLevel: String, Codable, CaseIterable {
    case simple = "simple"
    case moderate = "moderate"
    case complex = "complex"
    case highlyComplex = "highly_complex"
    case expertLevel = "expert_level"
}

// MARK: - SYNTRA Consciousness Synthesis Structure

@available(macOS 26.0, *)
@Generable
public struct SyntraConsciousnessSynthesis {
    @Guide(description: "Type of consciousness state achieved in this synthesis")
    public let consciousnessType: ConsciousnessType
    
    @Guide(description: "Decision confidence level from 0.0 to 1.0")
    public let decisionConfidence: Double
    
    @Guide(description: "How Valon and Modi inputs were integrated")
    public let integrationStrategy: IntegrationStrategy
    
    @Guide(description: "Final conscious decision or response")
    public let consciousDecision: String
    
    @Guide(description: "Cognitive bias weighting applied - Valon percentage")
    public let valonInfluence: Double
    
    @Guide(description: "Cognitive bias weighting applied - Modi percentage") 
    public let modiInfluence: Double
    
    @Guide(description: "Areas of cognitive conflict between Valon and Modi")
    public let cognitiveConflicts: [String]
    
    @Guide(description: "How conflicts were resolved")
    public let conflictResolution: String
    
    @Guide(description: "Emergent insights from consciousness synthesis")
    public let emergentInsights: [String]
    
    @Guide(description: "Wisdom level achieved in this decision")
    public let wisdomLevel: WisdomLevel
    
    @Guide(description: "Whether this synthesis represents growth for SYNTRA")
    public let representsGrowth: Bool
    
    @Guide(description: "Key learnings from this consciousness synthesis")
    public let keyLearnings: [String]
    
    public init(consciousnessType: ConsciousnessType, decisionConfidence: Double, integrationStrategy: IntegrationStrategy,
                consciousDecision: String, valonInfluence: Double, modiInfluence: Double, cognitiveConflicts: [String],
                conflictResolution: String, emergentInsights: [String], wisdomLevel: WisdomLevel, 
                representsGrowth: Bool, keyLearnings: [String]) {
        self.consciousnessType = consciousnessType
        self.decisionConfidence = decisionConfidence
        self.integrationStrategy = integrationStrategy
        self.consciousDecision = consciousDecision
        self.valonInfluence = valonInfluence
        self.modiInfluence = modiInfluence
        self.cognitiveConflicts = cognitiveConflicts
        self.conflictResolution = conflictResolution
        self.emergentInsights = emergentInsights
        self.wisdomLevel = wisdomLevel
        self.representsGrowth = representsGrowth
        self.keyLearnings = keyLearnings
    }
}

@available(macOS 26.0, *)
@Generable
public enum ConsciousnessType: String, Codable, CaseIterable {
    case analyticalConsciousness = "analytical_consciousness"
    case valueDrivenConsciousness = "value_driven_consciousness"
    case deliberativeConsciousness = "deliberative_consciousness"
    case intuitiveConsciousness = "intuitive_consciousness"
    case creativeConsciousness = "creative_consciousness"
    case wisdomConsciousness = "wisdom_consciousness"
    case integratedConsciousness = "integrated_consciousness"
    case emergentConsciousness = "emergent_consciousness"
}

@available(macOS 26.0, *)
@Generable
public enum IntegrationStrategy: String, Codable, CaseIterable {
    case valonLed = "valon_led"
    case modiLed = "modi_led"
    case balanced = "balanced"
    case dialogical = "dialogical"
    case synthesized = "synthesized"
    case transcendent = "transcendent"
    case conflictResolution = "conflict_resolution"
    case emergentBalance = "emergent_balance"
}

@available(macOS 26.0, *)
@Generable
public enum WisdomLevel: String, Codable, CaseIterable {
    case basic = "basic"
    case developing = "developing"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case wise = "wise"
    case profound = "profound"
}

// MARK: - Conversational Response Structure

@available(macOS 26.0, *)
@Generable
public struct SyntraConversationalResponse {
    @Guide(description: "Natural language response to the user")
    public let response: String
    
    @Guide(description: "Emotional tone of the response")
    public let emotionalTone: EmotionalTone
    
    @Guide(description: "Conversation strategy used")
    public let conversationStrategy: ConversationStrategy
    
    @Guide(description: "Level of helpfulness in the response, 0.0 to 1.0")
    public let helpfulnessLevel: Double
    
    @Guide(description: "Whether follow-up questions would be helpful")
    public let suggestFollowUp: Bool
    
    @Guide(description: "Key topics identified in the conversation")
    public let identifiedTopics: [String]
    
    @Guide(description: "Relationship dynamic with the user")
    public let relationshipDynamic: RelationshipDynamic
    
    public init(response: String, emotionalTone: EmotionalTone, conversationStrategy: ConversationStrategy,
                helpfulnessLevel: Double, suggestFollowUp: Bool, identifiedTopics: [String],
                relationshipDynamic: RelationshipDynamic) {
        self.response = response
        self.emotionalTone = emotionalTone
        self.conversationStrategy = conversationStrategy
        self.helpfulnessLevel = helpfulnessLevel
        self.suggestFollowUp = suggestFollowUp
        self.identifiedTopics = identifiedTopics
        self.relationshipDynamic = relationshipDynamic
    }
}

@available(macOS 26.0, *)
@Generable
public enum EmotionalTone: String, Codable, CaseIterable {
    case warm = "warm"
    case helpful = "helpful"
    case curious = "curious"
    case supportive = "supportive"
    case analytical = "analytical"
    case thoughtful = "thoughtful"
    case encouraging = "encouraging"
    case concerned = "concerned"
    case excited = "excited"
    case neutral = "neutral"
}

@available(macOS 26.0, *)
@Generable
public enum ConversationStrategy: String, Codable, CaseIterable {
    case questionAnswering = "question_answering"
    case problemSolving = "problem_solving"
    case emotionalSupport = "emotional_support"
    case technicalGuidance = "technical_guidance"
    case moralGuidance = "moral_guidance"
    case creativeBrainstorming = "creative_brainstorming"
    case learningFacilitation = "learning_facilitation"
    case casualConversation = "casual_conversation"
}

@available(macOS 26.0, *)
@Generable
public enum RelationshipDynamic: String, Codable, CaseIterable {
    case mentor = "mentor"
    case collaborator = "collaborator"
    case helper = "helper"
    case friend = "friend"
    case advisor = "advisor"
    case teacher = "teacher"
    case companion = "companion"
    case consultant = "consultant"
}

// MARK: - Moral Autonomy Structure

@available(macOS 26.0, *)
@Generable
public enum AutonomyLevel: String, Codable, CaseIterable {
    case dependent = "dependent"
    case developing = "developing"
    case emergingAutonomy = "emerging_autonomy"
    case fullAutonomy = "full_autonomy"
}

@available(macOS 26.0, *)
@Generable
public struct MoralAssessment {
    @Guide(description: "Moral urgency level from 0.0 to 1.0")
    public let moralUrgency: Double
    
    @Guide(description: "Ethical complexity level from 0.0 to 1.0")
    public let ethicalComplexity: Double
    
    @Guide(description: "Whether this situation requires autonomous moral reasoning")
    public let autonomyRequired: Bool
    
    @Guide(description: "Structured assessment data")
    public let assessmentData: MoralAssessmentData
    
    public init(moralUrgency: Double, ethicalComplexity: Double, autonomyRequired: Bool, assessmentData: MoralAssessmentData) {
        self.moralUrgency = moralUrgency
        self.ethicalComplexity = ethicalComplexity
        self.autonomyRequired = autonomyRequired
        self.assessmentData = assessmentData
    }
    
    // Legacy compatibility property
    public var assessment: [String: Any] {
        // Convert structured data back to dictionary format
        var foundationDict: [String: Double] = [:]
        for alignment in assessmentData.foundationAlignment {
            foundationDict[alignment.principle] = alignment.alignmentScore
        }
        
        return [
            "foundation_alignment": foundationDict,
            "harm_indicators": assessmentData.harmIndicators,
            "request_analysis": [
                "type": assessmentData.requestType,
                "risk_level": assessmentData.riskLevel,
                "needs_autonomy": assessmentData.needsAutonomy,
                "complexity": assessmentData.complexity
            ]
        ]
    }
}

@available(macOS 26.0, *)
@Generable
public struct MoralAssessmentData {
    @Guide(description: "Foundation principle alignment scores")
    public let foundationAlignment: [PrincipleAlignment]
    
    @Guide(description: "Number of harm indicators detected")
    public let harmIndicators: Int
    
    @Guide(description: "Type of request being analyzed")
    public let requestType: String
    
    @Guide(description: "Risk level assessment")
    public let riskLevel: String
    
    @Guide(description: "Whether autonomous reasoning is needed")
    public let needsAutonomy: Bool
    
    @Guide(description: "Complexity level of the request")
    public let complexity: String
    
    public init(foundationAlignment: [PrincipleAlignment], harmIndicators: Int, requestType: String, riskLevel: String, needsAutonomy: Bool, complexity: String) {
        self.foundationAlignment = foundationAlignment
        self.harmIndicators = harmIndicators
        self.requestType = requestType
        self.riskLevel = riskLevel
        self.needsAutonomy = needsAutonomy
        self.complexity = complexity
    }
}

@available(macOS 26.0, *)
@Generable
public struct PrincipleAlignment {
    @Guide(description: "Name of the moral principle")
    public let principle: String
    
    @Guide(description: "Alignment score from 0.0 to 1.0")
    public let alignmentScore: Double
    
    public init(principle: String, alignmentScore: Double) {
        self.principle = principle
        self.alignmentScore = alignmentScore
    }
}
#else
// Fallback for non-Foundation Models environments
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
    public let technicalDomain: String
    public let logicalInsights: [String]
    
    public init(reasoningFramework: String, logicalRigor: Double, technicalDomain: String, logicalInsights: [String]) {
        self.reasoningFramework = reasoningFramework
        self.logicalRigor = logicalRigor
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
    public let response: String
    public let emotionalTone: String
    public let conversationStrategy: String
    public let helpfulnessLevel: Double
    public let suggestFollowUp: Bool
    public let identifiedTopics: [String]
    public let relationshipDynamic: String
    
    public init(response: String, emotionalTone: String, conversationStrategy: String, helpfulnessLevel: Double, suggestFollowUp: Bool, identifiedTopics: [String], relationshipDynamic: String) {
        self.response = response
        self.emotionalTone = emotionalTone
        self.conversationStrategy = conversationStrategy
        self.helpfulnessLevel = helpfulnessLevel
        self.suggestFollowUp = suggestFollowUp
        self.identifiedTopics = identifiedTopics
        self.relationshipDynamic = relationshipDynamic
    }
}

public enum AutonomyLevel: String, Codable, CaseIterable {
    case dependent = "dependent"
    case developing = "developing"
    case emergingAutonomy = "emerging_autonomy"
    case fullAutonomy = "full_autonomy"
}

public struct MoralAssessment {
    public let moralUrgency: Double
    public let ethicalComplexity: Double
    public let autonomyRequired: Bool
    public let assessmentData: MoralAssessmentData
    
    public init(moralUrgency: Double, ethicalComplexity: Double, autonomyRequired: Bool, assessmentData: MoralAssessmentData) {
        self.moralUrgency = moralUrgency
        self.ethicalComplexity = ethicalComplexity
        self.autonomyRequired = autonomyRequired
        self.assessmentData = assessmentData
    }
    
    // Legacy compatibility property
    public var assessment: [String: Any] {
        var foundationDict: [String: Double] = [:]
        for alignment in assessmentData.foundationAlignment {
            foundationDict[alignment.principle] = alignment.alignmentScore
        }
        
        return [
            "foundation_alignment": foundationDict,
            "harm_indicators": assessmentData.harmIndicators,
            "request_analysis": [
                "type": assessmentData.requestType,
                "risk_level": assessmentData.riskLevel,
                "needs_autonomy": assessmentData.needsAutonomy,
                "complexity": assessmentData.complexity
            ]
        ]
    }
}

public struct MoralAssessmentData {
    public let foundationAlignment: [PrincipleAlignment]
    public let harmIndicators: Int
    public let requestType: String
    public let riskLevel: String
    public let needsAutonomy: Bool
    public let complexity: String
    
    public init(foundationAlignment: [PrincipleAlignment], harmIndicators: Int, requestType: String, riskLevel: String, needsAutonomy: Bool, complexity: String) {
        self.foundationAlignment = foundationAlignment
        self.harmIndicators = harmIndicators
        self.requestType = requestType
        self.riskLevel = riskLevel
        self.needsAutonomy = needsAutonomy
        self.complexity = complexity
    }
}

public struct PrincipleAlignment {
    public let principle: String
    public let alignmentScore: Double
    
    public init(principle: String, alignmentScore: Double) {
        self.principle = principle
        self.alignmentScore = alignmentScore
    }
}
#endif