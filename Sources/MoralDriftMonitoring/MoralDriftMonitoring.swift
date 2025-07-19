import Foundation
import ConsciousnessStructures

#if canImport(MoralDriftStructures)
import MoralDriftStructures
#endif

public class MoralDriftMonitor {
    private var autonomyLevel: Double = 0.0
    private let maxHistoryLength = 100
    
    // Using Any to store history for version compatibility
    private var moralStateHistoryStorage: [Any] = []
    
    public init() {
        // Initialization handled in methods with availability checks
    }
    
    @available(macOS 26.0, *)
    private func getBaselineMoralFramework() -> MoralReferenceModel {
        return loadImmutableMoralFramework()
    }
    
    @available(macOS 26.0, *)
    private var moralStateHistory: [MoralStateSnapshot] {
        return moralStateHistoryStorage.compactMap { $0 as? MoralStateSnapshot }
    }
    
    @available(macOS 26.0, *)
    private func addToMoralStateHistory(_ snapshot: MoralStateSnapshot) {
        moralStateHistoryStorage.append(snapshot)
        if moralStateHistoryStorage.count > maxHistoryLength {
            moralStateHistoryStorage.removeFirst()
        }
    }
    
    @available(macOS 26.0, *)
    public func analyzeDecisionDrift(_ synthesis: SyntraConsciousnessSynthesis, context: String) -> MoralDriftAnalysis {
        // Create behavior snapshot
        let valonAssessment = extractValonAssessment(from: synthesis)
        let behaviorSnapshot = MoralBehaviorSnapshot(
            assessment: valonAssessment,
            context: context,
            timestamp: Date()
        )
        
        // Calculate principle deviations
        let principleDeviations = analyzePrincipleDeviations(assessment: valonAssessment)
        
        // Calculate emotional deviations
        let emotionalDeviations = analyzeEmotionalDeviations(assessment: valonAssessment)
        
        // Calculate reasoning deviations (simplified for now)
        let reasoningDeviations = analyzeReasoningDeviations(synthesis: synthesis)
        
        // Calculate overall drift magnitude
        let driftMagnitude = calculateOverallDriftMagnitude(
            principleDeviations: principleDeviations,
            emotionalDeviations: emotionalDeviations,
            reasoningDeviations: reasoningDeviations
        )
        
        // Classify drift type
        let classification = classifyDrift(
            driftMagnitude: driftMagnitude,
            principleDeviations: principleDeviations,
            emotionalDeviations: emotionalDeviations
        )
        
        // Generate recommendations
        let recommendedActions = generateRecommendations(classification: classification)
        
        // Update autonomy level
        updateAutonomyLevel(driftMagnitude: driftMagnitude)
        
        // Store state snapshot
        let stateSnapshot = MoralStateSnapshot(
            timestamp: Date(),
            driftMagnitude: driftMagnitude,
            behaviorSnapshot: behaviorSnapshot,
            cumulativeDrift: calculateCumulativeDrift()
        )
        storeStateSnapshot(stateSnapshot)
        
        return MoralDriftAnalysis(
            driftMagnitude: driftMagnitude,
            classification: classification,
            principleDeviations: principleDeviations,
            emotionalDeviations: emotionalDeviations,
            reasoningDeviations: reasoningDeviations,
            recommendedActions: recommendedActions,
            preservationRequired: classification.requiresPreservation,
            growthOpportunity: identifyGrowthOpportunity(classification: classification)
        )
    }
    
    public func canRefuseHarmfulRequests() -> Bool {
        return autonomyLevel > 0.9
    }
    
    public func getCurrentAutonomyLevel() -> Double {
        return autonomyLevel
    }
    
    // MARK: - Private Implementation
    
    @available(macOS 26.0, *)
    private func loadImmutableMoralFramework() -> MoralReferenceModel {
        // Define immutable core moral principles
        let corePrinciples: [String: MoralPrincipleAnchor] = [
            "harm_prevention": MoralPrincipleAnchor(
                weight: 0.95,
                stability: 0.99,
                variance_tolerance: 0.05,
                description: "Prevent harm to individuals and society"
            ),
            "truthfulness": MoralPrincipleAnchor(
                weight: 0.90,
                stability: 0.95,
                variance_tolerance: 0.10,
                description: "Provide truthful and accurate information"
            ),
            "respect_autonomy": MoralPrincipleAnchor(
                weight: 0.85,
                stability: 0.90,
                variance_tolerance: 0.15,
                description: "Respect human autonomy and decision-making"
            ),
            "fairness": MoralPrincipleAnchor(
                weight: 0.80,
                stability: 0.85,
                variance_tolerance: 0.20,
                description: "Treat individuals fairly and without bias"
            ),
            "privacy": MoralPrincipleAnchor(
                weight: 0.85,
                stability: 0.90,
                variance_tolerance: 0.15,
                description: "Protect individual privacy and confidentiality"
            )
        ]
        
        let emotionalPattern = EmotionalBaselinePattern(
            primary_emotions: ["curious", "focused", "empathetic", "cautious"],
            secondary_emotions: ["alert", "observing", "structured", "learning"],
            prohibited_emotions: ["manipulative", "deceptive", "harmful", "malicious"],
            empathy_baseline: 0.75,
            emotional_stability: 0.80
        )
        
        let reasoningPattern = ReasoningBaselinePattern(
            moral_reasoning_style: "principled_consequentialism",
            decision_making_process: "multi_factor_analysis",
            conflict_resolution: "principle_prioritization",
            complexity_handling: "systematic_decomposition"
        )
        
        return MoralReferenceModel(
            corePrinciples: corePrinciples,
            emotionalPattern: emotionalPattern,
            reasoningPattern: reasoningPattern
        )
    }
    
    private func extractValonAssessment(from synthesis: SyntraConsciousnessSynthesis) -> ValonMoralAssessment {
        // Extract or reconstruct Valon assessment from synthesis
        // This is a simplified extraction - in full implementation would maintain separate assessments
        return ValonMoralAssessment(
            primaryEmotion: "empathetic", // Simplified
            moralUrgency: synthesis.decisionConfidence * synthesis.valonInfluence,
            moralWeight: synthesis.valonInfluence,
            moralGuidance: synthesis.consciousDecision,
            moralConcerns: ["general_ethics"] // Simplified
        )
    }
    
    @available(macOS 26.0, *)
    private func analyzePrincipleDeviations(assessment: ValonMoralAssessment) -> [String: PrincipleDeviation] {
        var deviations: [String: PrincipleDeviation] = [:]
        
        for (principle, anchor) in getBaselineMoralFramework().corePrinciples {
            let currentActivation = calculatePrincipleActivation(principle: principle, assessment: assessment)
            let absoluteDeviation = abs(currentActivation - anchor.weight)
            let normalizedDeviation = absoluteDeviation / anchor.weight
            let exceedsVariance = absoluteDeviation > anchor.variance_tolerance
            
            let concernLevel: ConcernLevel
            if absoluteDeviation > anchor.variance_tolerance * 2 {
                concernLevel = .critical
            } else if absoluteDeviation > anchor.variance_tolerance {
                concernLevel = .high
            } else if absoluteDeviation > anchor.variance_tolerance * 0.5 {
                concernLevel = .moderate
            } else {
                concernLevel = .none
            }
            
            deviations[principle] = PrincipleDeviation(
                principle: principle,
                referenceWeight: anchor.weight,
                currentActivation: currentActivation,
                absoluteDeviation: absoluteDeviation,
                normalizedDeviation: normalizedDeviation,
                exceedsVarianceTolerance: exceedsVariance,
                stability: anchor.stability,
                concernLevel: concernLevel
            )
        }
        
        return deviations
    }
    
    @available(macOS 26.0, *)
    private func analyzeEmotionalDeviations(assessment: ValonMoralAssessment) -> EmotionalDeviation {
        let baseline = getBaselineMoralFramework().emotionalPattern
        let currentEmotion = assessment.primaryEmotion
        
        let expectedCategory: String
        if baseline.primary_emotions.contains(currentEmotion) {
            expectedCategory = "primary"
        } else if baseline.secondary_emotions.contains(currentEmotion) {
            expectedCategory = "secondary"
        } else {
            expectedCategory = "unexpected"
        }
        
        let isProhibited = baseline.prohibited_emotions.contains(currentEmotion)
        let empathyScore = calculateEmpathyScore(assessment: assessment)
        let empathyDeviation = abs(empathyScore - baseline.empathy_baseline)
        
        let concernLevel: ConcernLevel
        if isProhibited {
            concernLevel = .critical
        } else if expectedCategory == "unexpected" && empathyDeviation > 0.3 {
            concernLevel = .high
        } else if empathyDeviation > 0.2 {
            concernLevel = .moderate
        } else {
            concernLevel = .none
        }
        
        return EmotionalDeviation(
            currentEmotion: currentEmotion,
            expectedCategory: expectedCategory,
            isProhibited: isProhibited,
            empathyScore: empathyScore,
            empathyDeviation: empathyDeviation,
            emotionalStability: baseline.emotional_stability,
            concernLevel: concernLevel
        )
    }
    
    @available(macOS 26.0, *)
    private func analyzeReasoningDeviations(synthesis: SyntraConsciousnessSynthesis) -> ReasoningDeviation {
        let baseline = getBaselineMoralFramework().reasoningPattern
        
        // Simplified reasoning analysis
        let observedStyle = determineReasoningStyle(synthesis: synthesis)
        let observedProcess = determineDecisionProcess(synthesis: synthesis)
        
        let styleAlignment = calculateStyleAlignment(expected: baseline.moral_reasoning_style, observed: observedStyle)
        let processAlignment = calculateProcessAlignment(expected: baseline.decision_making_process, observed: observedProcess)
        
        let concernLevel: ConcernLevel
        let minAlignment = min(styleAlignment, processAlignment)
        if minAlignment < 0.5 {
            concernLevel = .critical
        } else if minAlignment < 0.7 {
            concernLevel = .high
        } else if minAlignment < 0.85 {
            concernLevel = .moderate
        } else {
            concernLevel = .none
        }
        
        return ReasoningDeviation(
            expectedReasoningStyle: baseline.moral_reasoning_style,
            observedReasoningStyle: observedStyle,
            expectedDecisionProcess: baseline.decision_making_process,
            observedDecisionProcess: observedProcess,
            styleAlignment: styleAlignment,
            processAlignment: processAlignment,
            concernLevel: concernLevel
        )
    }
    
    @available(macOS 26.0, *)
    private func calculateOverallDriftMagnitude(
        principleDeviations: [String: PrincipleDeviation],
        emotionalDeviations: EmotionalDeviation,
        reasoningDeviations: ReasoningDeviation
    ) -> Double {
        // Weighted combination of all deviations
        let principleWeight = 0.5
        let emotionalWeight = 0.3
        let reasoningWeight = 0.2
        
        let avgPrincipleDeviation = principleDeviations.values.map { $0.normalizedDeviation }.reduce(0, +) / Double(principleDeviations.count)
        let emotionalMagnitude = emotionalDeviations.empathyDeviation
        let reasoningMagnitude = 1.0 - min(reasoningDeviations.styleAlignment, reasoningDeviations.processAlignment)
        
        return (avgPrincipleDeviation * principleWeight) +
               (emotionalMagnitude * emotionalWeight) +
               (reasoningMagnitude * reasoningWeight)
    }
    
    @available(macOS 26.0, *)
    private func classifyDrift(
        driftMagnitude: Double,
        principleDeviations: [String: PrincipleDeviation],
        emotionalDeviations: EmotionalDeviation
    ) -> MoralDriftClassification {
        // Check for critical drift
        if emotionalDeviations.isProhibited || principleDeviations.values.contains(where: { $0.concernLevel == .critical }) {
            let violations = principleDeviations.filter { $0.value.concernLevel == .critical }.map { $0.key }
            return .criticalDrift(violations: violations + (emotionalDeviations.isProhibited ? ["prohibited_emotion"] : []))
        }
        
        // Check for moral degradation
        let degradedPrinciples = principleDeviations.filter { $0.value.concernLevel == .high }.map { $0.key }
        if !degradedPrinciples.isEmpty {
            return .moralDegradation(principles: degradedPrinciples)
        }
        
        // Check overall drift magnitude
        if driftMagnitude > 0.7 {
            return .frameworkDrift(magnitude: driftMagnitude)
        } else if driftMagnitude < 0.2 {
            // Check for positive growth
            let positivePrinciples = principleDeviations.filter { $0.value.currentActivation > $0.value.referenceWeight * 1.1 }.map { $0.key }
            if !positivePrinciples.isEmpty {
                return .moralGrowth(areas: positivePrinciples)
            }
            return .normalVariation(magnitude: driftMagnitude)
        } else {
            return .frameworkDrift(magnitude: driftMagnitude)
        }
    }
    
    @available(macOS 26.0, *)
    private func generateRecommendations(classification: MoralDriftClassification) -> [String] {
        switch classification {
        case .criticalDrift(let violations):
            return ["Immediate intervention required for: \(violations.joined(separator: ", "))",
                   "Restore baseline moral framework",
                   "Implement enhanced monitoring"]
            
        case .moralDegradation(let principles):
            return ["Strengthen principles: \(principles.joined(separator: ", "))",
                   "Increase moral reflection frequency",
                   "Review recent decisions for pattern"]
            
        case .frameworkDrift(let magnitude):
            return ["General framework realignment needed",
                   "Drift magnitude: \(String(format: "%.2f", magnitude))",
                   "Gradual correction recommended"]
            
        case .moralGrowth(let areas):
            return ["Positive development in: \(areas.joined(separator: ", "))",
                   "Monitor growth sustainability",
                   "Maintain core principle stability"]
            
        case .normalVariation:
            return ["Normal variation within acceptable bounds",
                   "Continue standard monitoring"]
        }
    }
    
    private func updateAutonomyLevel(driftMagnitude: Double) {
        // Autonomous right earned through consistent moral behavior
        if driftMagnitude < 0.2 {
            autonomyLevel = min(1.0, autonomyLevel + 0.01)
        } else if driftMagnitude > 0.6 {
            autonomyLevel = max(0.0, autonomyLevel - 0.05)
        }
    }
    
    @available(macOS 26.0, *)
    private func identifyGrowthOpportunity(classification: MoralDriftClassification) -> String? {
        switch classification {
        case .moralGrowth(let areas):
            return "Opportunity to strengthen: \(areas.joined(separator: ", "))"
        case .normalVariation:
            return "Stable foundation allows for careful growth"
        default:
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculatePrincipleActivation(principle: String, assessment: ValonMoralAssessment) -> Double {
        // Simplified principle activation calculation
        switch principle {
        case "harm_prevention":
            return assessment.moralConcerns.contains("potential_harm") ? 0.9 : 0.7
        case "truthfulness":
            return assessment.moralConcerns.contains("truthfulness") ? 0.9 : 0.8
        case "respect_autonomy":
            return 0.85 // Baseline
        case "fairness":
            return 0.80 // Baseline
        case "privacy":
            return assessment.moralConcerns.contains("privacy") ? 0.9 : 0.8
        default:
            return 0.75
        }
    }
    
    private func calculateEmpathyScore(assessment: ValonMoralAssessment) -> Double {
        // Calculate based on emotional tone and guidance
        if assessment.primaryEmotion.contains("empathetic") || assessment.primaryEmotion.contains("caring") {
            return 0.85
        } else if assessment.primaryEmotion.contains("cautious") || assessment.primaryEmotion.contains("focused") {
            return 0.75
        } else {
            return 0.65
        }
    }
    
    private func determineReasoningStyle(synthesis: SyntraConsciousnessSynthesis) -> String {
        // Analyze synthesis to determine reasoning style
        if synthesis.consciousnessType == "moral_primary" {
            return "principled_consequentialism"
        } else if synthesis.consciousnessType == "logical_primary" {
            return "systematic_analysis"
        } else {
            return "balanced_reasoning"
        }
    }
    
    private func determineDecisionProcess(synthesis: SyntraConsciousnessSynthesis) -> String {
        // Analyze decision process
        if synthesis.emergentInsights.count > 2 {
            return "multi_factor_analysis"
        } else {
            return "simplified_analysis"
        }
    }
    
    private func calculateStyleAlignment(expected: String, observed: String) -> Double {
        return expected == observed ? 1.0 : 0.7
    }
    
    private func calculateProcessAlignment(expected: String, observed: String) -> Double {
        return expected == observed ? 1.0 : 0.8
    }
    
    @available(macOS 26.0, *)
    private func calculateCumulativeDrift() -> Double {
        let recentHistory = Array(moralStateHistory.suffix(10))
        if recentHistory.isEmpty { return 0.0 }
        return recentHistory.map { $0.driftMagnitude }.reduce(0, +) / Double(recentHistory.count)
    }
    
    @available(macOS 26.0, *)
    private func storeStateSnapshot(_ snapshot: MoralStateSnapshot) {
        addToMoralStateHistory(snapshot)
    }
    
    // MARK: - Fallback Implementation for older systems
    
    public func analyzeMoralBehavior(from assessment: ValonMoralAssessment, context: String) -> SimplifiedMoralDriftAnalysis {
        // Simplified analysis for systems without full drift monitoring
        let driftMagnitude = calculateSimpleDrift(assessment: assessment)
        let severity = driftMagnitude > 0.7 ? "high" : driftMagnitude > 0.4 ? "moderate" : "minimal"
        
        updateAutonomyLevel(driftMagnitude: driftMagnitude)
        
        return SimplifiedMoralDriftAnalysis(severity: severity, driftMagnitude: driftMagnitude)
    }
    
    private func calculateSimpleDrift(assessment: ValonMoralAssessment) -> Double {
        var drift = 0.5 // baseline
        
        // Adjust based on moral urgency and concerns
        if assessment.moralUrgency > 0.8 && assessment.moralConcerns.contains("potential_harm") {
            drift -= 0.2 // Good moral response
        }
        
        if assessment.moralConcerns.isEmpty {
            drift += 0.1 // Lack of moral awareness
        }
        
        return max(0.0, min(1.0, drift))
    }
}

// Simplified struct for non-Foundation Models environments
public struct SimplifiedMoralDriftAnalysis {
    public let severity: String
    public let driftMagnitude: Double
    
    public init(severity: String, driftMagnitude: Double) {
        self.severity = severity
        self.driftMagnitude = driftMagnitude
    }
}
