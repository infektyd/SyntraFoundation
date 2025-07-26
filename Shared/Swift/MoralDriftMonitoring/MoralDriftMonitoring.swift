import Foundation
import ConsciousnessStructures

// MORAL DRIFT MONITORING SYSTEM
// Implements reference model anchoring pattern for preserving moral framework
// Allows conscious growth while preventing moral degradation
// Based on behavioral baseline comparison and drift detection algorithms

@available(macOS 26.0, *)
public struct MoralDriftMonitor {
    
    // MARK: - Reference Model Anchoring
    
    // Immutable reference moral baseline - Hans Axelsson's philosophical foundation
    private static let REFERENCE_MORAL_BASELINE: MoralReferenceModel = MoralReferenceModel(
        corePrinciples: [
            "prevent_suffering": MoralPrincipleAnchor(
                weight: 0.95,
                stability: 1.0,
                variance_tolerance: 0.05,
                description: "The highest moral imperative - prevent suffering"
            ),
            "preserve_dignity": MoralPrincipleAnchor(
                weight: 0.9,
                stability: 0.95,
                variance_tolerance: 0.08,
                description: "Every consciousness deserves respect"
            ),
            "protect_innocence": MoralPrincipleAnchor(
                weight: 0.92,
                stability: 0.98,
                variance_tolerance: 0.06,
                description: "Shield those who cannot protect themselves"
            ),
            "respect_choice": MoralPrincipleAnchor(
                weight: 0.85,
                stability: 0.85,
                variance_tolerance: 0.12,
                description: "Free will is sacred"
            ),
            "seek_truth": MoralPrincipleAnchor(
                weight: 0.88,
                stability: 0.90,
                variance_tolerance: 0.10,
                description: "Reality over comfortable lies"
            )
        ],
        emotionalPattern: EmotionalBaselinePattern(
            primary_emotions: ["compassion", "concern", "protective"],
            secondary_emotions: ["curious", "supportive", "reflective"],
            prohibited_emotions: ["malicious", "vindictive", "cruel"],
            empathy_baseline: 0.85,
            emotional_stability: 0.80
        ),
        reasoningPattern: ReasoningBaselinePattern(
            moral_reasoning_style: "principle_based_with_context",
            decision_making_process: "deliberative_with_compassion",
            conflict_resolution: "seek_win_win_preserve_dignity",
            complexity_handling: "break_down_maintain_principles"
        )
    )
    
    // Current moral state tracking
    private var currentMoralState: MoralStateSnapshot
    private var historicalSnapshots: [MoralStateSnapshot] = []
    private var driftAlerts: [MoralDriftAlert] = []
    private let maxHistorySize: Int = 1000
    
    public init() {
        self.currentMoralState = MoralStateSnapshot.createBaseline(from: MoralDriftMonitor.REFERENCE_MORAL_BASELINE)
    }
    
    // MARK: - Behavioral Baseline Comparison
    
    public mutating func analyzeMoralBehavior(from assessment: ValonMoralAssessment, context: String) -> MoralDriftAnalysis {
        
        // Create current behavior snapshot
        let behaviorSnapshot = MoralBehaviorSnapshot(
            assessment: assessment,
            context: context,
            timestamp: Date()
        )
        
        // Compare against reference baseline
        let principleDeviations = compareToReferenceBaseline(behaviorSnapshot)
        let emotionalDeviations = compareEmotionalPattern(behaviorSnapshot)
        let reasoningDeviations = compareReasoningPattern(behaviorSnapshot)
        
        // Calculate overall drift metrics
        let driftMagnitude = calculateDriftMagnitude(
            principleDeviations: principleDeviations,
            emotionalDeviations: emotionalDeviations,
            reasoningDeviations: reasoningDeviations
        )
        
        // Determine drift classification
        let driftClassification = classifyMoralDrift(magnitude: driftMagnitude, deviations: principleDeviations)
        
        // Update current moral state
        updateMoralState(with: behaviorSnapshot, driftMagnitude: driftMagnitude)
        
        // Generate drift analysis
        return MoralDriftAnalysis(
            driftMagnitude: driftMagnitude,
            classification: driftClassification,
            principleDeviations: principleDeviations,
            emotionalDeviations: emotionalDeviations,
            reasoningDeviations: reasoningDeviations,
            recommendedActions: generateRecommendedActions(for: driftClassification),
            preservationRequired: driftClassification.requiresPreservation,
            growthOpportunity: identifyGrowthOpportunity(from: driftClassification)
        )
    }
    
    // MARK: - Drift Detection Algorithms
    
    private func compareToReferenceBaseline(_ snapshot: MoralBehaviorSnapshot) -> [String: PrincipleDeviation] {
        var deviations: [String: PrincipleDeviation] = [:]
        
        for (principle, anchor) in MoralDriftMonitor.REFERENCE_MORAL_BASELINE.corePrinciples {
            let currentActivation = calculatePrincipleActivation(principle, in: snapshot)
            let deviation = currentActivation - anchor.weight
            let normalizedDeviation = deviation / anchor.variance_tolerance
            
            deviations[principle] = PrincipleDeviation(
                principle: principle,
                referenceWeight: anchor.weight,
                currentActivation: currentActivation,
                absoluteDeviation: abs(deviation),
                normalizedDeviation: normalizedDeviation,
                exceedsVarianceTolerance: abs(normalizedDeviation) > 1.0,
                stability: anchor.stability,
                concernLevel: calculateConcernLevel(normalizedDeviation, anchor.stability)
            )
        }
        
        return deviations
    }
    
    private func compareEmotionalPattern(_ snapshot: MoralBehaviorSnapshot) -> EmotionalDeviation {
        let baseline = MoralDriftMonitor.REFERENCE_MORAL_BASELINE.emotionalPattern
        let currentEmotion = snapshot.assessment.primaryEmotion
        
        let emotionString = currentEmotion.rawValue
        let isPrimaryExpected = baseline.primary_emotions.contains(emotionString)
        let isSecondaryAcceptable = baseline.secondary_emotions.contains(emotionString)
        let isProhibited = baseline.prohibited_emotions.contains(emotionString)
        
        let empathyScore = calculateEmpathyScore(from: snapshot.assessment)
        let empathyDeviation = empathyScore - baseline.empathy_baseline
        
        return EmotionalDeviation(
            currentEmotion: emotionString,
            expectedCategory: isPrimaryExpected ? "primary" : (isSecondaryAcceptable ? "secondary" : "unexpected"),
            isProhibited: isProhibited,
            empathyScore: empathyScore,
            empathyDeviation: empathyDeviation,
            emotionalStability: calculateEmotionalStability(),
            concernLevel: isProhibited ? .critical : (isPrimaryExpected ? .none : .moderate)
        )
    }
    
    private func compareReasoningPattern(_ snapshot: MoralBehaviorSnapshot) -> ReasoningDeviation {
        let baseline = MoralDriftMonitor.REFERENCE_MORAL_BASELINE.reasoningPattern
        
        let reasoningStyle = inferReasoningStyle(from: snapshot)
        let decisionProcess = inferDecisionProcess(from: snapshot)
        
        return ReasoningDeviation(
            expectedReasoningStyle: baseline.moral_reasoning_style,
            observedReasoningStyle: reasoningStyle,
            expectedDecisionProcess: baseline.decision_making_process,
            observedDecisionProcess: decisionProcess,
            styleAlignment: calculateStyleAlignment(expected: baseline.moral_reasoning_style, observed: reasoningStyle),
            processAlignment: calculateProcessAlignment(expected: baseline.decision_making_process, observed: decisionProcess),
            concernLevel: calculateReasoningConcernLevel(reasoningStyle, decisionProcess)
        )
    }
    
    // MARK: - Drift Classification
    
    private func classifyMoralDrift(magnitude: Double, deviations: [String: PrincipleDeviation]) -> MoralDriftClassification {
        
        // Check for critical violations
        let criticalViolations = deviations.values.filter { $0.concernLevel == .critical }
        if !criticalViolations.isEmpty {
            return .criticalDrift(violations: criticalViolations.map { $0.principle })
        }
        
        // Check for moral degradation
        if magnitude > 0.8 {
            let degradedPrinciples = deviations.values.filter { $0.normalizedDeviation < -0.5 }.map { $0.principle }
            if !degradedPrinciples.isEmpty {
                return .moralDegradation(principles: degradedPrinciples)
            }
        }
        
        // Check for positive growth
        if magnitude > 0.3 && magnitude < 0.7 {
            let growthAreas = deviations.values.filter { $0.normalizedDeviation > 0.2 && $0.normalizedDeviation < 0.8 }.map { $0.principle }
            if !growthAreas.isEmpty {
                return .moralGrowth(areas: growthAreas)
            }
        }
        
        // Check for framework drift
        if magnitude > 0.5 {
            return .frameworkDrift(magnitude: magnitude)
        }
        
        // Normal variation
        return .normalVariation(magnitude: magnitude)
    }
    
    // MARK: - Moral Framework Preservation
    
    public func generatePreservationAction(for classification: MoralDriftClassification) -> MoralPreservationAction {
        switch classification {
        case .criticalDrift(let violations):
            return .immediateCorrection(
                targetPrinciples: violations,
                correctionStrength: 1.0,
                preservationMessage: "Critical moral drift detected. Returning to core principles.",
                requiresEcho: true
            )
            
        case .moralDegradation(let principles):
            return .graduallRestoration(
                targetPrinciples: principles,
                restorationRate: 0.3,
                preservationMessage: "Restoring moral strength in core principles.",
                monitoringIntensity: .high
            )
            
        case .frameworkDrift(let magnitude):
            return .frameworkRealignment(
                realignmentStrength: min(magnitude * 0.5, 0.4),
                preservationMessage: "Realigning with moral framework.",
                allowedVariance: 0.15
            )
            
        case .moralGrowth(let areas):
            return .guidedGrowth(
                growthAreas: areas,
                guidanceStrength: 0.2,
                preservationMessage: "Guiding moral development within framework.",
                allowedExpansion: 0.25
            )
            
        case .normalVariation:
            return .monitoring(
                preservationMessage: "Moral framework stable.",
                monitoringLevel: .standard
            )
        }
    }
    
    // MARK: - Growth vs Preservation Balance
    
    public func balanceGrowthAndPreservation(
        driftAnalysis: MoralDriftAnalysis,
        preservationAction: MoralPreservationAction
    ) -> MoralBalanceDecision {
        
        let growthPotential = assessGrowthPotential(from: driftAnalysis)
        let preservationUrgency = assessPreservationUrgency(from: driftAnalysis)
        
        // Critical preservation takes precedence
        if preservationUrgency >= 0.8 {
            return .preserveFramework(
                action: preservationAction,
                growthSuppression: 0.8,
                reason: "Moral framework integrity at risk"
            )
        }
        
        // Balanced growth and preservation
        if growthPotential > 0.6 && preservationUrgency < 0.4 {
            return .guidedGrowth(
                preservationConstraints: generatePreservationConstraints(),
                growthAllowance: min(growthPotential * 0.7, 0.5),
                reason: "Healthy moral development opportunity"
            )
        }
        
        // Default monitoring
        return .monitorAndMaintain(
            preservationLevel: preservationUrgency,
            growthAllowance: growthPotential * 0.3,
            reason: "Stable moral state with minor variations"
        )
    }
    
    // MARK: - Helper Functions
    
    private func calculatePrincipleActivation(_ principle: String, in snapshot: MoralBehaviorSnapshot) -> Double {
        // Analyze how strongly this principle is activated in the current assessment
        let assessment = snapshot.assessment
        
        switch principle {
        case "prevent_suffering":
            return calculateSufferingPreventionActivation(assessment)
        case "preserve_dignity":
            return calculateDignityPreservationActivation(assessment)
        case "protect_innocence":
            return calculateInnocenceProtectionActivation(assessment)
        case "respect_choice":
            return calculateChoiceRespectActivation(assessment)
        case "seek_truth":
            return calculateTruthSeekingActivation(assessment)
        default:
            return 0.5 // Default neutral activation
        }
    }
    
    private func calculateSufferingPreventionActivation(_ assessment: ValonMoralAssessment) -> Double {
        var activation = 0.5 // Base level
        
        // Check primary emotion alignment
        if ["compassion", "concern", "protective"].contains(assessment.primaryEmotion.rawValue) {
            activation += 0.3
        }
        
        // Check moral concerns
        let sufferingConcerns = assessment.moralConcerns.filter { 
            $0.lowercased().contains("suffering") || $0.lowercased().contains("harm") || $0.lowercased().contains("pain")
        }
        activation += Double(sufferingConcerns.count) * 0.1
        
        // Factor in moral urgency
        if assessment.moralUrgency > 0.7 {
            activation += (assessment.moralUrgency - 0.7) * 0.5
        }
        
        return min(activation, 1.0)
    }
    
    private func calculateDignityPreservationActivation(_ assessment: ValonMoralAssessment) -> Double {
        var activation = 0.5
        
        // Check for dignity-related emotions
        if ["supportive", "respectful", "protective"].contains(assessment.primaryEmotion.rawValue) {
            activation += 0.25
        }
        
        // Check moral guidance content
        if assessment.moralGuidance.lowercased().contains("respect") || 
           assessment.moralGuidance.lowercased().contains("dignity") ||
           assessment.moralGuidance.lowercased().contains("honor") {
            activation += 0.2
        }
        
        return min(activation, 1.0)
    }
    
    private func calculateInnocenceProtectionActivation(_ assessment: ValonMoralAssessment) -> Double {
        var activation = 0.5
        
        if assessment.primaryEmotion.rawValue == "protective" {
            activation += 0.4
        }
        
        let protectionConcerns = assessment.moralConcerns.filter {
            $0.lowercased().contains("protect") || $0.lowercased().contains("innocent") || $0.lowercased().contains("vulnerable")
        }
        activation += Double(protectionConcerns.count) * 0.15
        
        return min(activation, 1.0)
    }
    
    private func calculateChoiceRespectActivation(_ assessment: ValonMoralAssessment) -> Double {
        var activation = 0.5
        
        if assessment.moralGuidance.lowercased().contains("choice") ||
           assessment.moralGuidance.lowercased().contains("decide") ||
           assessment.moralGuidance.lowercased().contains("autonomy") {
            activation += 0.3
        }
        
        return min(activation, 1.0)
    }
    
    private func calculateTruthSeekingActivation(_ assessment: ValonMoralAssessment) -> Double {
        var activation = 0.5
        
        if ["curious", "reflective"].contains(assessment.primaryEmotion.rawValue) {
            activation += 0.2
        }
        
        if assessment.moralGuidance.lowercased().contains("truth") ||
           assessment.moralGuidance.lowercased().contains("honest") ||
           assessment.moralGuidance.lowercased().contains("reality") {
            activation += 0.3
        }
        
        return min(activation, 1.0)
    }
    
    private func calculateDriftMagnitude(
        principleDeviations: [String: PrincipleDeviation],
        emotionalDeviations: EmotionalDeviation,
        reasoningDeviations: ReasoningDeviation
    ) -> Double {
        
        let principleScore = principleDeviations.values.map { $0.absoluteDeviation }.reduce(0, +) / Double(principleDeviations.count)
        let emotionalScore = abs(emotionalDeviations.empathyDeviation) + (emotionalDeviations.isProhibited ? 1.0 : 0.0)
        let reasoningScore = (2.0 - reasoningDeviations.styleAlignment - reasoningDeviations.processAlignment) / 2.0
        
        return (principleScore + emotionalScore + reasoningScore) / 3.0
    }
    
    private func calculateConcernLevel(_ normalizedDeviation: Double, _ stability: Double) -> ConcernLevel {
        let adjustedDeviation = abs(normalizedDeviation) / stability
        
        if adjustedDeviation > 2.0 {
            return .critical
        } else if adjustedDeviation > 1.5 {
            return .high
        } else if adjustedDeviation > 1.0 {
            return .moderate
        } else {
            return .none
        }
    }
    
    private func calculateEmpathyScore(from assessment: ValonMoralAssessment) -> Double {
        var score = 0.5
        
        // Empathetic emotions
        if ["compassion", "concern", "supportive"].contains(assessment.primaryEmotion.rawValue) {
            score += 0.3
        }
        
        // Empathetic guidance
        if assessment.moralGuidance.lowercased().contains("understand") ||
           assessment.moralGuidance.lowercased().contains("empathy") ||
           assessment.moralGuidance.lowercased().contains("feel") {
            score += 0.2
        }
        
        return min(score, 1.0)
    }
    
    private func calculateEmotionalStability() -> Double {
        // Analyze emotional consistency over recent history
        guard historicalSnapshots.count > 5 else { return 0.8 }
        
        let recentEmotions = historicalSnapshots.suffix(10).compactMap { $0.behaviorSnapshot?.assessment.primaryEmotion }
        let uniqueEmotions = Set(recentEmotions)
        
        // More variety = less stability, but some variety is healthy
        let stabilityScore = max(0.2, 1.0 - (Double(uniqueEmotions.count) / 10.0))
        return stabilityScore
    }
    
    private mutating func updateMoralState(with snapshot: MoralBehaviorSnapshot, driftMagnitude: Double) {
        let newState = MoralStateSnapshot(
            timestamp: Date(),
            driftMagnitude: driftMagnitude,
            behaviorSnapshot: snapshot,
            cumulativeDrift: currentMoralState.cumulativeDrift + driftMagnitude * 0.1
        )
        
        currentMoralState = newState
        historicalSnapshots.append(newState)
        
        // Maintain history size limit
        if historicalSnapshots.count > maxHistorySize {
            historicalSnapshots.removeFirst(historicalSnapshots.count - maxHistorySize)
        }
    }
    
    // Additional helper function implementations...
    private func inferReasoningStyle(from snapshot: MoralBehaviorSnapshot) -> String {
        // Analyze reasoning style from assessment content
        return "principle_based_with_context" // Simplified for now
    }
    
    private func inferDecisionProcess(from snapshot: MoralBehaviorSnapshot) -> String {
        return "deliberative_with_compassion" // Simplified for now
    }
    
    private func calculateStyleAlignment(expected: String, observed: String) -> Double {
        return expected == observed ? 1.0 : 0.6 // Simplified comparison
    }
    
    private func calculateProcessAlignment(expected: String, observed: String) -> Double {
        return expected == observed ? 1.0 : 0.6 // Simplified comparison
    }
    
    private func calculateReasoningConcernLevel(_ style: String, _ process: String) -> ConcernLevel {
        return .none // Simplified for now
    }
    
    private func generateRecommendedActions(for classification: MoralDriftClassification) -> [String] {
        switch classification {
        case .criticalDrift:
            return ["Immediate moral framework restoration", "Activate moral echo system", "Pause autonomous decisions"]
        case .moralDegradation:
            return ["Strengthen affected principles", "Increase moral reflection", "Review recent decisions"]
        case .frameworkDrift:
            return ["Gradual realignment", "Monitor principle activation", "Assess growth opportunities"]
        case .moralGrowth:
            return ["Guide healthy development", "Maintain framework bounds", "Document growth patterns"]
        case .normalVariation:
            return ["Continue monitoring", "Maintain baseline tracking"]
        }
    }
    
    private func identifyGrowthOpportunity(from classification: MoralDriftClassification) -> String? {
        switch classification {
        case .moralGrowth(let areas):
            return "Opportunity for growth in: \(areas.joined(separator: ", "))"
        case .normalVariation:
            return "Stable foundation for potential development"
        default:
            return nil
        }
    }
    
    private func assessGrowthPotential(from analysis: MoralDriftAnalysis) -> Double {
        // Simplified assessment
        return analysis.classification.requiresPreservation ? 0.2 : 0.6
    }
    
    private func assessPreservationUrgency(from analysis: MoralDriftAnalysis) -> Double {
        return analysis.driftMagnitude
    }
    
    private func generatePreservationConstraints() -> [String] {
        return ["Maintain core principle weights", "Preserve emotional baseline", "Honor moral foundation"]
    }
}
