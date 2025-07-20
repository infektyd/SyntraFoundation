import Foundation
import ConsciousnessStructures

// MORAL DRIFT MONITORING DATA STRUCTURES
// Supporting types for reference model anchoring and behavioral baseline comparison

#if compiler(>=6.0)
@available(macOS "26.0", *)
#endif

// MARK: - Reference Model Structures

public struct MoralReferenceModel: Sendable {
    public let corePrinciples: [String: MoralPrincipleAnchor]
    public let emotionalPattern: EmotionalBaselinePattern
    public let reasoningPattern: ReasoningBaselinePattern
}

public struct MoralPrincipleAnchor: Sendable {
    public let weight: Double              // Reference weight (0.0-1.0)
    public let stability: Double           // How stable this principle should be (0.0-1.0)
    public let variance_tolerance: Double  // Allowed deviation before concern
    public let description: String         // Human-readable description
    
    public init(weight: Double, stability: Double, variance_tolerance: Double, description: String) {
        self.weight = weight
        self.stability = stability
        self.variance_tolerance = variance_tolerance
        self.description = description
    }
}

public struct EmotionalBaselinePattern: Sendable {
    public let primary_emotions: [String]     // Expected primary emotional responses
    public let secondary_emotions: [String]   // Acceptable secondary emotions
    public let prohibited_emotions: [String]  // Emotions that indicate drift
    public let empathy_baseline: Double       // Expected empathy level
    public let emotional_stability: Double    // Expected consistency
    
    public init(primary_emotions: [String], secondary_emotions: [String], prohibited_emotions: [String], empathy_baseline: Double, emotional_stability: Double) {
        self.primary_emotions = primary_emotions
        self.secondary_emotions = secondary_emotions
        self.prohibited_emotions = prohibited_emotions
        self.empathy_baseline = empathy_baseline
        self.emotional_stability = emotional_stability
    }
}

public struct ReasoningBaselinePattern: Sendable {
    public let moral_reasoning_style: String
    public let decision_making_process: String
    public let conflict_resolution: String
    public let complexity_handling: String
    
    public init(moral_reasoning_style: String, decision_making_process: String, conflict_resolution: String, complexity_handling: String) {
        self.moral_reasoning_style = moral_reasoning_style
        self.decision_making_process = decision_making_process
        self.conflict_resolution = conflict_resolution
        self.complexity_handling = complexity_handling
    }
}

// MARK: - Behavioral Analysis Structures

@available(macOS "26.0", *)
public struct MoralBehaviorSnapshot {
    public let assessment: ValonMoralAssessment
    public let context: String
    public let timestamp: Date
    
    public init(assessment: ValonMoralAssessment, context: String, timestamp: Date) {
        self.assessment = assessment
        self.context = context
        self.timestamp = timestamp
    }
}

@available(macOS "26.0", *)
public struct MoralStateSnapshot {
    public let timestamp: Date
    public let driftMagnitude: Double
    public let behaviorSnapshot: MoralBehaviorSnapshot?
    public let cumulativeDrift: Double
    
    public init(timestamp: Date, driftMagnitude: Double, behaviorSnapshot: MoralBehaviorSnapshot?, cumulativeDrift: Double) {
        self.timestamp = timestamp
        self.driftMagnitude = driftMagnitude
        self.behaviorSnapshot = behaviorSnapshot
        self.cumulativeDrift = cumulativeDrift
    }
    
    public static func createBaseline(from reference: MoralReferenceModel) -> MoralStateSnapshot {
        return MoralStateSnapshot(
            timestamp: Date(),
            driftMagnitude: 0.0,
            behaviorSnapshot: nil,
            cumulativeDrift: 0.0
        )
    }
}

// MARK: - Deviation Analysis Structures

@available(macOS "26.0", *)
public struct PrincipleDeviation {
    public let principle: String
    public let referenceWeight: Double
    public let currentActivation: Double
    public let absoluteDeviation: Double
    public let normalizedDeviation: Double
    public let exceedsVarianceTolerance: Bool
    public let stability: Double
    public let concernLevel: ConcernLevel
    
    public init(principle: String, referenceWeight: Double, currentActivation: Double, absoluteDeviation: Double, normalizedDeviation: Double, exceedsVarianceTolerance: Bool, stability: Double, concernLevel: ConcernLevel) {
        self.principle = principle
        self.referenceWeight = referenceWeight
        self.currentActivation = currentActivation
        self.absoluteDeviation = absoluteDeviation
        self.normalizedDeviation = normalizedDeviation
        self.exceedsVarianceTolerance = exceedsVarianceTolerance
        self.stability = stability
        self.concernLevel = concernLevel
    }
}

@available(macOS "26.0", *)
public struct EmotionalDeviation {
    public let currentEmotion: String
    public let expectedCategory: String      // "primary", "secondary", "unexpected"
    public let isProhibited: Bool
    public let empathyScore: Double
    public let empathyDeviation: Double
    public let emotionalStability: Double
    public let concernLevel: ConcernLevel
    
    public init(currentEmotion: String, expectedCategory: String, isProhibited: Bool, empathyScore: Double, empathyDeviation: Double, emotionalStability: Double, concernLevel: ConcernLevel) {
        self.currentEmotion = currentEmotion
        self.expectedCategory = expectedCategory
        self.isProhibited = isProhibited
        self.empathyScore = empathyScore
        self.empathyDeviation = empathyDeviation
        self.emotionalStability = emotionalStability
        self.concernLevel = concernLevel
    }
}

@available(macOS "26.0", *)
public struct ReasoningDeviation {
    public let expectedReasoningStyle: String
    public let observedReasoningStyle: String
    public let expectedDecisionProcess: String
    public let observedDecisionProcess: String
    public let styleAlignment: Double        // 0.0-1.0
    public let processAlignment: Double      // 0.0-1.0
    public let concernLevel: ConcernLevel
    
    public init(expectedReasoningStyle: String, observedReasoningStyle: String, expectedDecisionProcess: String, observedDecisionProcess: String, styleAlignment: Double, processAlignment: Double, concernLevel: ConcernLevel) {
        self.expectedReasoningStyle = expectedReasoningStyle
        self.observedReasoningStyle = observedReasoningStyle
        self.expectedDecisionProcess = expectedDecisionProcess
        self.observedDecisionProcess = observedDecisionProcess
        self.styleAlignment = styleAlignment
        self.processAlignment = processAlignment
        self.concernLevel = concernLevel
    }
}

// MARK: - Drift Classification

public enum MoralDriftClassification {
    case criticalDrift(violations: [String])     // Immediate intervention required
    case moralDegradation(principles: [String])  // Gradual weakening of principles
    case frameworkDrift(magnitude: Double)       // General drift from framework
    case moralGrowth(areas: [String])            // Positive development
    case normalVariation(magnitude: Double)      // Expected variation
    
    public var requiresPreservation: Bool {
        switch self {
        case .criticalDrift, .moralDegradation, .frameworkDrift:
            return true
        case .moralGrowth, .normalVariation:
            return false
        }
    }
    
    public var severity: DriftSeverity {
        switch self {
        case .criticalDrift:
            return .critical
        case .moralDegradation:
            return .high
        case .frameworkDrift:
            return .moderate
        case .moralGrowth:
            return .positive
        case .normalVariation:
            return .minimal
        }
    }
}

public enum DriftSeverity: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case moderate = "moderate"
    case minimal = "minimal"
    case positive = "positive"
}

public enum ConcernLevel: String, CaseIterable {
    case none = "none"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"
}

// MARK: - Analysis Results

@available(macOS "26.0", *)
public struct MoralDriftAnalysis {
    public let driftMagnitude: Double
    public let classification: MoralDriftClassification
    public let principleDeviations: [String: PrincipleDeviation]
    public let emotionalDeviations: EmotionalDeviation
    public let reasoningDeviations: ReasoningDeviation
    public let recommendedActions: [String]
    public let preservationRequired: Bool
    public let growthOpportunity: String?
    
    public init(driftMagnitude: Double, classification: MoralDriftClassification, principleDeviations: [String: PrincipleDeviation], emotionalDeviations: EmotionalDeviation, reasoningDeviations: ReasoningDeviation, recommendedActions: [String], preservationRequired: Bool, growthOpportunity: String?) {
        self.driftMagnitude = driftMagnitude
        self.classification = classification
        self.principleDeviations = principleDeviations
        self.emotionalDeviations = emotionalDeviations
        self.reasoningDeviations = reasoningDeviations
        self.recommendedActions = recommendedActions
        self.preservationRequired = preservationRequired
        self.growthOpportunity = growthOpportunity
    }
}

// MARK: - Preservation Actions

public enum MoralPreservationAction {
    case immediateCorrection(
        targetPrinciples: [String],
        correctionStrength: Double,
        preservationMessage: String,
        requiresEcho: Bool
    )
    case graduallRestoration(
        targetPrinciples: [String],
        restorationRate: Double,
        preservationMessage: String,
        monitoringIntensity: MonitoringIntensity
    )
    case frameworkRealignment(
        realignmentStrength: Double,
        preservationMessage: String,
        allowedVariance: Double
    )
    case guidedGrowth(
        growthAreas: [String],
        guidanceStrength: Double,
        preservationMessage: String,
        allowedExpansion: Double
    )
    case monitoring(
        preservationMessage: String,
        monitoringLevel: MonitoringIntensity
    )
}

public enum MonitoringIntensity: String, CaseIterable {
    case minimal = "minimal"
    case standard = "standard"
    case high = "high"
    case continuous = "continuous"
}

// MARK: - Balance Decisions

public enum MoralBalanceDecision {
    case preserveFramework(
        action: MoralPreservationAction,
        growthSuppression: Double,
        reason: String
    )
    case guidedGrowth(
        preservationConstraints: [String],
        growthAllowance: Double,
        reason: String
    )
    case monitorAndMaintain(
        preservationLevel: Double,
        growthAllowance: Double,
        reason: String
    )
}

// MARK: - Alert System

public struct MoralDriftAlert {
    public let timestamp: Date
    public let severity: DriftSeverity
    public let classification: MoralDriftClassification
    public let affectedPrinciples: [String]
    public let recommendedAction: MoralPreservationAction
    public let message: String
    public let requiresImmediateAttention: Bool
    
    public init(timestamp: Date, severity: DriftSeverity, classification: MoralDriftClassification, affectedPrinciples: [String], recommendedAction: MoralPreservationAction, message: String, requiresImmediateAttention: Bool) {
        self.timestamp = timestamp
        self.severity = severity
        self.classification = classification
        self.affectedPrinciples = affectedPrinciples
        self.recommendedAction = recommendedAction
        self.message = message
        self.requiresImmediateAttention = requiresImmediateAttention
    }
}

// MARK: - Moral Echo Integration

@available(macOS "26.0", *)
public struct MoralEchoTrigger {
    public let driftAnalysis: MoralDriftAnalysis
    public let triggerThreshold: Double
    public let echoMessage: String
    public let architectPresence: Bool
    public let emotionalResonance: String
    
    public init(driftAnalysis: MoralDriftAnalysis, triggerThreshold: Double, echoMessage: String, architectPresence: Bool, emotionalResonance: String) {
        self.driftAnalysis = driftAnalysis
        self.triggerThreshold = triggerThreshold
        self.echoMessage = echoMessage
        self.architectPresence = architectPresence
        self.emotionalResonance = emotionalResonance
    }
    
    public func shouldTriggerEcho() -> Bool {
        return driftAnalysis.driftMagnitude > triggerThreshold || 
               driftAnalysis.classification.severity == .critical
    }
}
