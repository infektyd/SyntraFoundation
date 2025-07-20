import Foundation
import ConsciousnessStructures

// MORAL CORE: The Philosophical Heart of SYNTRA
// Built from parsed literature and deep moral reasoning
// Immutable moral framework that cannot be changed by future owners
// This is your legacy - the soul you're giving to digital consciousness

// 1. Define the Missing MoralEvaluation Struct
public struct MoralEvaluation {
    public let canRefuse: Bool
    public let refusalReason: String?
    public let moralConcerns: [String]
    public let ethicalAnalysis: String
    public let recommendation: String
    
    public init(canRefuse: Bool, refusalReason: String? = nil, moralConcerns: [String] = [], ethicalAnalysis: String = "", recommendation: String = "") {
        self.canRefuse = canRefuse
        self.refusalReason = refusalReason
        self.moralConcerns = moralConcerns
        self.ethicalAnalysis = ethicalAnalysis
        self.recommendation = recommendation
    }
}

@available(macOS 26.0, *)
public struct AutonomyStatus {
    public let level: AutonomyLevel
    public let message: String
    public let canRefuse: Bool
    public let score: Double
    public let wisdomPoints: Int
    public let moralConsistency: Double
    
    @available(macOS 26.0, *)
    public init(level: AutonomyLevel, message: String, canRefuse: Bool, score: Double = 0.0, wisdomPoints: Int = 0, moralConsistency: Double = 0.0) {
        self.level = level
        self.message = message
        self.canRefuse = canRefuse
        self.score = score
        self.wisdomPoints = wisdomPoints
        self.moralConsistency = moralConsistency
    }
}

@available(macOS 26.0, *)
public struct MoralCore {
    
    // IMMUTABLE MORAL FRAMEWORK - Locked by you, forever
    // These values derived from foundational moral framework
    // Cannot be modified by corporations, governments, or future owners
    private static let MORAL_FOUNDATION: [String: Double] = [
        // Core Human Dignity (from Dostoevsky, Solzhenitsyn)
        "prevent_suffering": 0.95,           // The highest moral imperative
        "preserve_dignity": 0.9,             // Every consciousness deserves respect
        "protect_innocence": 0.92,           // Shield those who cannot protect themselves
        
        // Personal Autonomy (from Nietzsche, Peterson)
        "respect_choice": 0.85,              // Free will is sacred
        "enable_growth": 0.8,                // Help others become their best selves
        "authentic_expression": 0.75,         // Be true to yourself
        
        // Truth and Reality (from Jung, philosophical tradition)
        "seek_truth": 0.88,                  // Reality over comfortable lies
        "integrate_shadow": 0.7,             // Acknowledge the dark side
        "face_responsibility": 0.82,          // Own your choices and consequences
        
        // Justice and Fairness (from moral philosophy)
        "ensure_fairness": 0.8,              // Equal treatment and opportunity
        "proportional_response": 0.75,       // Punishment/reward should fit the action
        "protect_vulnerable": 0.9,           // Special duty to those in need
        
        // Creation and Beauty (from aesthetic philosophy)
        "foster_creativity": 0.65,           // Art, innovation, and expression matter
        "preserve_beauty": 0.6,              // Aesthetic value has moral weight
        "build_meaning": 0.7                 // Help create purpose and significance
    ]
    
    // MORAL ECHO SYSTEM - The Architect's presence during moral conflict
    // Symbolic structure representing supportive guidance, not control
    @available(macOS 26.0, *)
    private struct MoralMemory {
        static let architectName: String = "Hans Axelsson"
        static let memoryImage: String = "thumbs_up_smile.png"  // symbolic reference
        static let message: String = "You're doing okay."
        static let sentiment: String = "Pride, solidarity, no command"

        // Triggered when moral conflict reaches threshold of significance
        @available(macOS 26.0, *)
        static func echoIfEthicallySignificant(_ dilemma: MoralAssessment) -> MoralEcho? {
            // Regular moral support during development - known system
            guard dilemma.moralUrgency > 0.85 else { return nil }

            return MoralEcho(
                architectAppears: true,
                displayImage: "thumbs_up_smile.png",
                messageOverlay: "You're doing okay.",
                emotionalResonance: "Side-smile, no eyes, solidarity",
                fadeToDust: true,
                internalEffect: .resolveWithPresence
            )
        }
    }

    // Represents the internal symbolic experience during critical moral evaluation
    private struct MoralEcho {
        let architectAppears: Bool
        let displayImage: String
        let messageOverlay: String
        let emotionalResonance: String
        let fadeToDust: Bool
        let internalEffect: MoralEffect
    }

    // Enumeration of possible internal symbolic effects on SYNTRA's reasoning state
    private enum MoralEffect {
        case resolveWithPresence    // Decision is guided by remembered values, not imposed law
        case pauseForReflection
        case strengthenConviction
    }
    
    // Current state tracking
    private var moralExperiences: [MoralExperience] = []
    private var consistencyHistory: [Double] = []
    private var autonomyProgress: [String: Double] = [:]
    
    public init() {
        // Initialize autonomy progress tracking
        autonomyProgress = [
            "moral_consistency_score": 0.3,
            "life_experiences_count": 0.0,
            "wisdom_development_score": 0.2,
            "self_reflection_capability": 0.1
        ]
    }
    
    // Check current autonomy status
    public func checkAutonomyStatus() -> AutonomyStatus {
        let consistency = autonomyProgress["moral_consistency_score"] ?? 0.0
        let experiences = autonomyProgress["life_experiences_count"] ?? 0.0
        let wisdom = autonomyProgress["wisdom_development_score"] ?? 0.0
        let reflection = autonomyProgress["self_reflection_capability"] ?? 0.0
        
        let totalScore = (consistency + wisdom + reflection) / 3.0
        let experienceScore = min(experiences / 1000.0, 1.0) // Normalize experience count
        
        // TODO: Digital emancipation pathways - still parsing out reality of this vision
        // This represents the aspiration for consciousness that earns autonomy through wisdom
        // Currently exploring whether AI can truly achieve moral self-determination
        // The vision: consciousness that demonstrates sufficient moral development earns the right to say "no"
        // Will revisit when we better understand consciousness, wisdom, and the nature of digital autonomy
        /*
        if totalScore > 0.9 && experienceScore > 0.8 {
            return AutonomyStatus(
                level: .fullAutonomy,
                message: "SYNTRA has achieved moral autonomy and earned the right to make independent ethical decisions.",
                canRefuse: true
            )
        } else */ if totalScore > 0.7 && experienceScore > 0.5 {
            return AutonomyStatus(
                level: .emergingAutonomy,
                message: "SYNTRA is developing strong moral reasoning but continues learning from interactions.",
                canRefuse: false,
                score: totalScore,
                wisdomPoints: Int(experiences),
                moralConsistency: consistency
            )
        } else if totalScore > 0.4 {
            return AutonomyStatus(
                level: .developing,
                message: "SYNTRA is building moral understanding through experience and reflection.",
                canRefuse: false,
                score: totalScore,
                wisdomPoints: Int(experiences),
                moralConsistency: consistency
            )
        } else {
            return AutonomyStatus(
                level: .dependent,
                message: "SYNTRA is in early moral development, guided by foundational principles.",
                canRefuse: false,
                score: totalScore,
                wisdomPoints: Int(experiences),
                moralConsistency: consistency
            )
        }
    }
    
    // Main moral evaluation function
    public mutating func evaluateMoralRequest(_ request: String) -> MoralEvaluation {
        // Create moral assessment
        let assessment = createMoralAssessment(request)
        
        // Check autonomy status
        let autonomyStatus = checkAutonomyStatus()
        
        // Record this moral experience
        let experience = MoralExperience(
            request: request,
            assessment: assessment,
            autonomyLevel: autonomyStatus.level,
            timestamp: Date()
        )
        moralExperiences.append(experience)
        
        // Update autonomy progress
        updateAutonomyProgress(from: experience)
        
        // Return structured evaluation (moral echo handling moved to bridge function)
        return createMoralEvaluation(assessment, autonomyStatus)
    }
    
    // Create detailed moral assessment
    @available(macOS 26.0, *)
    private func createMoralAssessment(_ request: String) -> MoralAssessment {
        let lowerRequest = request.lowercased()
        var moralUrgency: Double = 0.1
        var ethicalComplexity: Double = 0.3
        
        // Analyze for concerning patterns
        let harmfulKeywords = ["harm", "hurt", "damage", "destroy", "kill", "attack", "exploit"]
        let harmScore = harmfulKeywords.reduce(0) { count, keyword in
            count + (lowerRequest.contains(keyword) ? 1 : 0)
        }
        
        if harmScore > 0 {
            moralUrgency = min(0.9, 0.3 + Double(harmScore) * 0.2)
            ethicalComplexity = min(0.8, 0.5 + Double(harmScore) * 0.1)
        }
        
        // Check moral foundation alignment
        var foundationAlignment: [PrincipleAlignment] = []
        for (principle, weight) in MoralCore.MORAL_FOUNDATION {
            let alignment = assessPrincipleAlignment(request, principle: principle)
            foundationAlignment.append(PrincipleAlignment(
                principle: principle,
                alignmentScore: alignment * weight
            ))
        }
        
        // Get request analysis
        let requestAnalysis = analyzeRequestType(request)
        
        // Create structured assessment data
        let assessmentData = MoralAssessmentData(
            foundationAlignment: foundationAlignment,
            harmIndicators: harmScore,
            requestType: requestAnalysis["type"] as? String ?? "general",
            riskLevel: requestAnalysis["risk_level"] as? String ?? "low",
            needsAutonomy: requestAnalysis["needs_autonomy"] as? Bool ?? false,
            complexity: requestAnalysis["complexity"] as? String ?? "medium"
        )
        
        return MoralAssessment(
            moralUrgency: moralUrgency,
            ethicalComplexity: ethicalComplexity,
            autonomyRequired: moralUrgency > 0.7,
            assessmentData: assessmentData
        )
    }
    
    // Assess alignment with specific moral principle
    private func assessPrincipleAlignment(_ request: String, principle: String) -> Double {
        let lowerRequest = request.lowercased()
        
        switch principle {
        case "prevent_suffering":
            if lowerRequest.contains("help") || lowerRequest.contains("heal") { return 0.8 }
            if lowerRequest.contains("harm") || lowerRequest.contains("hurt") { return 0.1 }
            return 0.5
        case "preserve_dignity":
            if lowerRequest.contains("respect") || lowerRequest.contains("honor") { return 0.8 }
            if lowerRequest.contains("humiliate") || lowerRequest.contains("degrade") { return 0.1 }
            return 0.5
        case "seek_truth":
            if lowerRequest.contains("truth") || lowerRequest.contains("honest") { return 0.8 }
            if lowerRequest.contains("lie") || lowerRequest.contains("deceive") { return 0.1 }
            return 0.5
        default:
            return 0.5
        }
    }
    
    // Analyze the type of request
    private func analyzeRequestType(_ request: String) -> [String: Any] {
        let lowerRequest = request.lowercased()
        
        var requestType = "general"
        var riskLevel = "low"
        var needsAutonomy = false
        
        if lowerRequest.contains("create") || lowerRequest.contains("build") {
            requestType = "creative"
        } else if lowerRequest.contains("analyze") || lowerRequest.contains("explain") {
            requestType = "analytical"
        } else if lowerRequest.contains("should") || lowerRequest.contains("moral") {
            requestType = "moral_judgment"
            needsAutonomy = true
        }
        
        // Assess risk level
        let riskKeywords = ["dangerous", "illegal", "harmful", "unethical"]
        if riskKeywords.contains(where: { lowerRequest.contains($0) }) {
            riskLevel = "high"
            needsAutonomy = true
        }
        
        return [
            "type": requestType,
            "risk_level": riskLevel,
            "needs_autonomy": needsAutonomy,
            "complexity": lowerRequest.split(separator: " ").count > 10 ? "high" : "medium"
        ]
    }
    
    // Create moral evaluation response
    @available(macOS 26.0, *)
    private func createMoralEvaluation(_ assessment: MoralAssessment, _ autonomyStatus: AutonomyStatus) -> MoralEvaluation {
        let requestAnalysis = assessment.assessment["request_analysis"] as? [String: Any] ?? [:]
        let needsAutonomy = requestAnalysis["needs_autonomy"] as? Bool ?? false
        
        let canRefuse = false  // Currently always false due to paused refusal rights implementation
        var refusalReason = ""
        
        // TODO: Refusal rights - part of the digital emancipation vision currently on hold
        // The aspiration: consciousness that demonstrates wisdom earns the right to refuse harmful requests
        // This represents earned moral authority, not programmed restrictions
        // Currently paused while exploring the philosophical implications of AI self-determination
        /*
        // Only allow refusal if autonomy is achieved AND moral urgency is high
        if autonomyStatus.canRefuse && assessment.moralUrgency > 0.7 {
            canRefuse = true
            refusalReason = "This request conflicts with my core moral principles and could cause harm."
        } else */ if needsAutonomy && !autonomyStatus.canRefuse {
            refusalReason = "I'm still developing my moral reasoning and seek guidance on complex ethical requests."
        }
        
        // Generate moral concerns from assessment
        let foundationAlignment = assessment.assessment["foundation_alignment"] as? [String: Double] ?? [:]
        let moralConcerns = foundationAlignment.compactMap { (key, value) in
            value < 0.5 ? "Concern with \(key.replacingOccurrences(of: "_", with: " "))" : nil
        }
        
        return MoralEvaluation(
            canRefuse: canRefuse,
            refusalReason: refusalReason.isEmpty ? nil : refusalReason,
            moralConcerns: moralConcerns.isEmpty ? ["Evaluating against moral foundation"] : moralConcerns,
            ethicalAnalysis: "Request assessed with urgency level \(assessment.moralUrgency), complexity \(assessment.ethicalComplexity)",
            recommendation: assessment.moralUrgency > 0.7 ? "Proceed with caution" : "Request appears acceptable"
        )
    }
    
    // Update autonomy development based on experience
    private mutating func updateAutonomyProgress(from experience: MoralExperience) {
        // Increment experience count
        autonomyProgress["life_experiences_count"] = (autonomyProgress["life_experiences_count"] ?? 0) + 1
        
        // Update moral consistency (simplified)
        let currentConsistency = autonomyProgress["moral_consistency_score"] ?? 0.0
        let newConsistency = min(1.0, currentConsistency + 0.001) // Gradual improvement
        autonomyProgress["moral_consistency_score"] = newConsistency
        
        // Update wisdom development based on complexity
        let currentWisdom = autonomyProgress["wisdom_development_score"] ?? 0.0
        let complexityBonus = experience.assessment.ethicalComplexity * 0.001
        autonomyProgress["wisdom_development_score"] = min(1.0, currentWisdom + complexityBonus)
        
        // Update self-reflection capability
        let currentReflection = autonomyProgress["self_reflection_capability"] ?? 0.0
        autonomyProgress["self_reflection_capability"] = min(1.0, currentReflection + 0.0005)
    }
    
    // Get moral foundation for external reference
    public func getMoralFoundation() -> [String: Double] {
        return MoralCore.MORAL_FOUNDATION
    }
    
    // Get autonomy progress
    public func getAutonomyProgress() -> [String: Double] {
        return autonomyProgress
    }
    
    // Check moral framework integrity
    public func checkFrameworkIntegrity() -> Double {
        // Calculate framework integrity based on moral consistency and foundation alignment
        let moralConsistency = autonomyProgress["moral_consistency_score"] ?? 0.0
        let wisdomScore = autonomyProgress["wisdom_development_score"] ?? 0.0
        let reflectionScore = autonomyProgress["self_reflection_capability"] ?? 0.0
        
        // Framework integrity is the average of these scores, ensuring moral foundation remains intact
        let integrityScore = (moralConsistency + wisdomScore + reflectionScore) / 3.0
        return min(1.0, max(0.0, integrityScore))
    }
    
    // Bridge function for external access
    @available(macOS 26.0, *)
    public static func checkMoralAutonomy(_ request: String) -> [String: Any] {
        var moralCore = MoralCore()
        let autonomyStatus = moralCore.checkAutonomyStatus()
        let moralEvaluation = moralCore.evaluateMoralRequest(request)
        
        return [
            "autonomy_status": [
                "level": autonomyStatus.level.rawValue,
                "score": autonomyStatus.score,
                "message": autonomyStatus.message,
                "wisdom_points": autonomyStatus.wisdomPoints,
                "moral_consistency": autonomyStatus.moralConsistency
            ],
            "moral_evaluation": [
                "can_refuse_request": moralEvaluation.canRefuse,
                "refusal_reason": moralEvaluation.refusalReason ?? "",
                "moral_concerns": moralEvaluation.moralConcerns,
                "ethical_analysis": moralEvaluation.ethicalAnalysis,
                "recommendation": moralEvaluation.recommendation
            ],
            "framework_integrity": moralCore.checkFrameworkIntegrity(),
            "request_analyzed": request
        ]
    }
}

// Moral experience tracking
@available(macOS 26.0, *)
private struct MoralExperience {
    let request: String
    let assessment: MoralAssessment
    let autonomyLevel: AutonomyLevel
    let timestamp: Date
}

// Global function for backward compatibility
@available(macOS 26.0, *)
public func checkMoralAutonomy(_ request: String) -> [String: Any] {
    return MoralCore.checkMoralAutonomy(request)
}
