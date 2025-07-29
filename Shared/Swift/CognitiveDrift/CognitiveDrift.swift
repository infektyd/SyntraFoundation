import Foundation
import ConsciousnessStructures
import SyntraConfig
import Valon
import Modi
import Drift
import MemoryEngine
import ConflictResolver

// Bridge function for external access
public func processThroughBrainsWithDrift(_ input: String, config: SyntraConfig) -> [String: Any] {
    // Initialize drift system with config-based personality
    var cognitiveDrift = CognitiveDrift(
        cognitiveBaseline: config.driftRatio ?? ["valon": 0.7, "modi": 0.3],
        driftTolerance: 0.3,
        adaptationRate: 0.1
    )
    
    // Process through brains (full AI power to both)
    let valonResponse = reflect_valon(input)
    let modiResponseArr = reflect_modi(input)
    let modiResponse = modiResponseArr.joined(separator: " ")
    
    // Apply personality weighting
    let personalityWeighting = cognitiveDrift.applyPersonalityWeighting(valonResponse, modiResponseArr)
    
    // Calculate current cognitive bias
    let currentBias = [
        "valon": personalityWeighting["current_valon_bias"] as? Double ?? 0.5,
        "modi": personalityWeighting["current_modi_bias"] as? Double ?? 0.5
    ]
    
    // Measure drift from baseline
    let driftAnalysis = cognitiveDrift.measureCognitiveDrift(currentBias: currentBias)
    
    // Decide on adaptation
    let adaptationDecision = cognitiveDrift.shouldAdaptBaseline(driftAnalysis)
    if adaptationDecision["should_adapt"] as? Bool == true {
        cognitiveDrift.adaptBaseline(currentBias: currentBias)
    }
    
    // Synthesize final decision with conflict detection + adaptive or static fusion
    let conflicts = ConflictResolver().detectConflicts(valon: valonResponse, modi: modiResponse)
    let conflictResolution = ConflictResolver().resolve(conflicts, valon: valonResponse, modi: modiResponse)

    // Build DriftAnalysis struct from driftAnalysis dictionary
    let driftAnalysisStruct = DriftAnalysis(
        conflictType: conflicts.isEmpty ? "none" : "detected",
        conflictMagnitude: abs((driftAnalysis["total_drift"] as? Double) ?? 0.0),
        conflictDescription: conflicts.joined(separator: "; "),
        resolutionStrategy: conflictResolution,
        isResolved: conflicts.isEmpty
    )

    // Build shared bridge for fusion
    _ = ValonModiBridge(valon: valonResponse, modi: modiResponse, driftAnalysis: driftAnalysisStruct)
    let driftWeightedDecision: String
    if config.useAdaptiveFusion == true {
        driftWeightedDecision = "[FUSED] " + valonResponse + " | " + modiResponse // Placeholder for FusionMLP().fuse(bridge)
    } else {
        driftWeightedDecision = "[AVERAGE] " + valonResponse + " | " + modiResponse // Placeholder for drift_average(valonResponse, modiResponse)
    }

    // Log intermediate data for tuning
    print("[LOG] cognitive_drift:", driftAnalysisStruct)
    print("[LOG] conflicts_detected:", conflicts)
    print("[LOG] conflict_resolution:", conflictResolution)

    return [
        "valon": valonResponse,
        "modi": modiResponse,
        "drift_analysis": driftAnalysisStruct,
        "personality_weighting": personalityWeighting,
        "adaptation_decision": adaptationDecision,
        "cognitive_baseline": cognitiveDrift.getCurrentBaseline(),
        "conflicts": conflicts,
        "conflict_resolution": conflictResolution,
        "drift_weighted_decision": driftWeightedDecision,
        "personality_maintained": true
    ]
}

// COGNITIVE DRIFT: Personality Weighting & Homeostasis System
// Maintains SYNTRA's core cognitive identity while allowing adaptive growth
// Implements config-based personality weighting (e.g., 70% Valon, 30% Modi)

public struct CognitiveDrift {
    
    // Core personality from config.json drift_ratio
    private var cognitiveBaseline: [String: Double]
    private let driftTolerance: Double
    private let adaptationRate: Double
    
    public init(cognitiveBaseline: [String: Double] = ["valon": 0.7, "modi": 0.3], 
         driftTolerance: Double = 0.3, 
         adaptationRate: Double = 0.1) {
        self.cognitiveBaseline = cognitiveBaseline
        self.driftTolerance = driftTolerance
        self.adaptationRate = adaptationRate
    }
    
    // Apply personality weighting to decision synthesis
    public func applyPersonalityWeighting(_ valonResponse: String, _ modiResponse: [String]) -> [String: Any] {
        // Parse the strength of each brain's response
        let valonStrength = calculateValonStrength(valonResponse)
        let modiStrength = calculateModiStrength(modiResponse)
        
        // Determine weights: static baseline or adaptive based on similarity
        var valonWeight = cognitiveBaseline["valon"] ?? 0.5
        var modiWeight = cognitiveBaseline["modi"] ?? 0.5
        if let useAdaptive = try? SyntraConfig.loadConfig().useAdaptiveWeighting, useAdaptive {
            let valonTokens = Set(valonResponse.split(separator: " ").map { String($0) })
            let modiTokens = Set(modiResponse.map { String($0) })
            let intersectionCount = valonTokens.intersection(modiTokens).count
            let unionCount = valonTokens.union(modiTokens).count
            let similarity = unionCount > 0 ? Double(intersectionCount) / Double(unionCount) : 0.0
            // More agreement pushes weights toward even blend
            valonWeight = valonWeight * (1.0 - similarity) + 0.5 * similarity
            modiWeight = 1.0 - valonWeight
        }
        
        // Apply personality weighting (not computational throttling!)
        let weightedValonInfluence = valonStrength * valonWeight
        let weightedModiInfluence = modiStrength * modiWeight
        
        // Calculate current decision bias
        let totalInfluence = weightedValonInfluence + weightedModiInfluence
        let currentValonBias = totalInfluence > 0 ? weightedValonInfluence / totalInfluence : 0.5
        let currentModiBias = totalInfluence > 0 ? weightedModiInfluence / totalInfluence : 0.5
        
        return [
            "weighted_valon_influence": weightedValonInfluence,
            "weighted_modi_influence": weightedModiInfluence,
            "current_valon_bias": currentValonBias,
            "current_modi_bias": currentModiBias,
            "personality_applied": true,
            "baseline_used": cognitiveBaseline
        ]
    }
    
    // Measure cognitive drift from baseline personality
    public func measureCognitiveDrift(currentBias: [String: Double]) -> [String: Any] {
        let baselineValon = cognitiveBaseline["valon"] ?? 0.5
        let baselineModi = cognitiveBaseline["modi"] ?? 0.5
        
        let currentValon = currentBias["valon"] ?? 0.5
        let currentModi = currentBias["modi"] ?? 0.5
        
        // Calculate drift amounts
        let valonDrift = currentValon - baselineValon
        let modiDrift = currentModi - baselineModi
        let totalDrift = abs(valonDrift) + abs(modiDrift)
        
        // Classify drift severity
        var driftLevel: String
        if totalDrift > driftTolerance {
            driftLevel = "significant"
        } else if totalDrift > driftTolerance / 2 {
            driftLevel = "moderate" 
        } else {
            driftLevel = "minimal"
        }
        
        // Determine drift direction
        var driftDirection: String
        if abs(valonDrift) > abs(modiDrift) {
            driftDirection = valonDrift > 0 ? "more_emotional" : "less_emotional"
        } else {
            driftDirection = modiDrift > 0 ? "more_logical" : "less_logical"
        }
        
        return [
            "valon_drift": valonDrift,
            "modi_drift": modiDrift, 
            "total_drift": totalDrift,
            "drift_level": driftLevel,
            "drift_direction": driftDirection,
            "exceeds_tolerance": totalDrift > driftTolerance,
            "baseline_personality": cognitiveBaseline,
            "current_personality": currentBias
        ]
    }
    
    // Decide whether to let drift "ride" or correct it
    public func shouldAdaptBaseline(_ driftAnalysis: [String: Any]) -> [String: Any] {
        let totalDrift = driftAnalysis["total_drift"] as? Double ?? 0.0
        let driftLevel = driftAnalysis["drift_level"] as? String ?? "minimal"
        
        // Philosophy: Let moderate drift ride, but monitor significant drift
        var shouldAdapt = false
        var adaptationReason = "no_adaptation_needed"
        
        if driftLevel == "significant" && totalDrift < (driftTolerance * 2.0) {
            // Significant but not extreme - let it ride but adapt slowly
            shouldAdapt = true
            adaptationReason = "gradual_personality_evolution"
        } else if totalDrift > (driftTolerance * 2.0) {
            // Extreme drift - don't adapt, log for investigation
            shouldAdapt = false
            adaptationReason = "drift_too_extreme_investigate"
        }
        
        return [
            "should_adapt": shouldAdapt,
            "adaptation_reason": adaptationReason,
            "adaptation_rate": adaptationRate,
            "let_drift_ride": driftLevel != "extreme"
        ]
    }
    
    // Gradually adapt baseline personality (letting some drift ride)
    public mutating func adaptBaseline(currentBias: [String: Double]) {
        let currentValon = currentBias["valon"] ?? cognitiveBaseline["valon"] ?? 0.5
        let currentModi = currentBias["modi"] ?? cognitiveBaseline["modi"] ?? 0.5
        
        // Gradual adaptation using adaptation rate
        let newValonBaseline = (cognitiveBaseline["valon"] ?? 0.5) * (1.0 - adaptationRate) + currentValon * adaptationRate
        let newModiBaseline = (cognitiveBaseline["modi"] ?? 0.5) * (1.0 - adaptationRate) + currentModi * adaptationRate
        
        // Ensure they sum to 1.0
        let total = newValonBaseline + newModiBaseline
        cognitiveBaseline["valon"] = newValonBaseline / total
        cognitiveBaseline["modi"] = newModiBaseline / total
    }
    
    // Calculate strength of Valon's response (not computational power!)
    private func calculateValonStrength(_ valonResponse: String) -> Double {
        let components = valonResponse.split(separator: "|").count
        var strength = 0.5 // Base strength
        
        // Stronger responses have more symbolic/moral complexity
        if valonResponse.contains("moral") { strength += 0.2 }
        if valonResponse.contains("creative") { strength += 0.15 }
        if valonResponse.contains("multi_layered") { strength += 0.1 }
        if components > 2 { strength += 0.1 }
        
        return min(strength, 1.0)
    }
    
    // Calculate strength of Modi's response (not computational power!)
    private func calculateModiStrength(_ modiResponse: [String]) -> Double {
        var strength = 0.5 // Base strength
        
        // Stronger responses have more logical sophistication
        if modiResponse.contains(where: { $0.contains("advanced") }) { strength += 0.2 }
        if modiResponse.contains(where: { $0.contains("high_logical_rigor") }) { strength += 0.15 }
        if modiResponse.contains(where: { $0.contains("technical") }) { strength += 0.1 }
        if modiResponse.count > 2 { strength += 0.1 }
        
        return min(strength, 1.0)
    }
    
    // Get current cognitive baseline (for external monitoring)
    public func getCurrentBaseline() -> [String: Double] {
        return cognitiveBaseline
    }
}

// Note: Duplicate function removed to fix compilation error
