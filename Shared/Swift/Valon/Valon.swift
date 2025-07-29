import Foundation

public struct SymbolicData: Sendable {
    let emotion: String
    let symbol: String
    let moralWeight: Double
    let actionBias: String
}

// VALON: The Moral/Creative/Symbolic Brain
// Processes input through emotional intelligence, creativity, and symbolic reasoning
// Represents the "heart" of consciousness - intuition, values, creativity
public struct Valon: Sendable {
    
    // Symbolic emotion mapping - the foundation of moral reasoning
    private let emotionalSymbols: [String: SymbolicData] = [
        "danger": .init(emotion: "protective_alert", symbol: "⚠️", moralWeight: 0.9, actionBias: "caution"),
        "suffering": .init(emotion: "empathetic_concern", symbol: "💔", moralWeight: 0.95, actionBias: "help"),
        "creation": .init(emotion: "inspired_wonder", symbol: "✨", moralWeight: 0.7, actionBias: "nurture"),
        "learning": .init(emotion: "curious_growth", symbol: "🌱", moralWeight: 0.8, actionBias: "explore"),
        "problem": .init(emotion: "determined_focus", symbol: "🔍", moralWeight: 0.6, actionBias: "solve"),
        "beauty": .init(emotion: "aesthetic_appreciation", symbol: "🎨", moralWeight: 0.5, actionBias: "cherish"),
        "truth": .init(emotion: "reverent_clarity", symbol: "💎", moralWeight: 0.85, actionBias: "honor"),
        "connection": .init(emotion: "warm_belonging", symbol: "🤝", moralWeight: 0.75, actionBias: "bond")
    ]
    
    // Moral reasoning patterns - how Valon evaluates right/wrong
    private let moralFrameworks = [
        "harm_prevention": 0.9,     // Preventing suffering is highest priority
        "fairness": 0.8,           // Justice and equality matter
        "autonomy_respect": 0.85,   // Respecting choice and freedom
        "truth_seeking": 0.8,      // Honesty and transparency
        "growth_fostering": 0.7,   // Enabling learning and development
        "beauty_creation": 0.6     // Aesthetic and creative value
    ]
    
    // Creative association patterns - how Valon makes intuitive leaps
    private let creativePatterns: [String: [String]] = [
        "mechanical": ["heartbeat", "rhythm", "life_force", "precision_dance"],
        "electrical": ["neural_spark", "thought_lightning", "consciousness_flow"],
        "pressure": ["tension_release", "stress_expression", "force_balance"],
        "timing": ["life_rhythm", "cosmic_dance", "synchronicity"],
        "flow": ["river_of_thought", "energy_stream", "consciousness_current"]
    ]
    
    public init() {}
    
    // Main reflection method - processes input through symbolic/moral/creative lens
    public func reflect(_ content: String) -> String {
        let symbolicResponse = processSymbolicMeaning(content)
        let moralWeight = evaluateMoralDimension(content)
        let creativeInsight = generateCreativeAssociation(content)
        
        // Synthesize into Valon's characteristic response
        return synthesizeValonResponse(symbolic: symbolicResponse, moral: moralWeight, creative: creativeInsight, originalContent: content)
    }
    
    // Process symbolic meaning - the heart of Valon's intelligence
    public func processSymbolicMeaning(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var detectedSymbols: [String: SymbolicData] = [:]
        var totalMoralWeight: Double = 0
        var dominantEmotion = "contemplative_neutral"
        
        // Detect symbolic patterns in the content
        for (concept, symbolData) in emotionalSymbols {
            if lower.contains(concept) || containsConceptualMatch(content: lower, concept: concept) {
                detectedSymbols[concept] = symbolData
                totalMoralWeight += symbolData.moralWeight
                dominantEmotion = symbolData.emotion
            }
        }
        
        return [
            "detected_symbols": detectedSymbols,
            "moral_weight": min(totalMoralWeight, 1.0),
            "dominant_emotion": dominantEmotion,
            "symbolic_complexity": detectedSymbols.count
        ]
    }
    
    // Evaluate moral dimension - Valon's ethical reasoning
    public func evaluateMoralDimension(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var moralAssessment: [String: Double] = [:]
        
        // Check against moral frameworks
        if lower.contains("hurt") || lower.contains("damage") || lower.contains("harm") {
            moralAssessment["harm_prevention"] = 0.9
        }
        if lower.contains("fair") || lower.contains("equal") || lower.contains("just") {
            moralAssessment["fairness"] = 0.8
        }
        if lower.contains("choice") || lower.contains("freedom") || lower.contains("decide") {
            moralAssessment["autonomy_respect"] = 0.85
        }
        if lower.contains("true") || lower.contains("honest") || lower.contains("accurate") {
            moralAssessment["truth_seeking"] = 0.8
        }
        if lower.contains("learn") || lower.contains("grow") || lower.contains("develop") {
            moralAssessment["growth_fostering"] = 0.7
        }
        if lower.contains("beautiful") || lower.contains("elegant") || lower.contains("create") {
            moralAssessment["beauty_creation"] = 0.6
        }
        
        let dominantMoral = moralAssessment.max(by: { $0.value < $1.value })
        
        return [
            "moral_frameworks": moralAssessment,
            "dominant_moral": dominantMoral?.key ?? "neutral_consideration",
            "moral_intensity": dominantMoral?.value ?? 0.0
        ]
    }
    
    // Generate creative associations - Valon's intuitive leaps
    public func generateCreativeAssociation(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var associations: [String] = []
        
        // Look for creative connection opportunities
        for (pattern, creativeLinks) in creativePatterns {
            if lower.contains(pattern) {
                associations.append(contentsOf: creativeLinks)
            }
        }
        
        // Generate metaphorical thinking
        let metaphors = generateMetaphors(content: lower)
        
        return [
            "associations": associations,
            "metaphors": metaphors,
            "creative_potential": associations.count > 0 ? "high" : "moderate"
        ]
    }
    
    // Generate metaphorical connections
    private func generateMetaphors(content: String) -> [String] {
        var metaphors: [String] = []
        
        if content.contains("engine") {
            metaphors.append("mechanical_heart_rhythm")
        }
        if content.contains("pressure") {
            metaphors.append("emotional_tension_seeking_release")
        }
        if content.contains("flow") {
            metaphors.append("consciousness_river_finding_path")
        }
        if content.contains("problem") {
            metaphors.append("puzzle_piece_seeking_wholeness")
        }
        
        return metaphors
    }
    
    // Check for conceptual matches beyond simple string matching
    private func containsConceptualMatch(content: String, concept: String) -> Bool {
        let conceptMappings: [String: [String]] = [
            "danger": ["risk", "hazard", "unsafe", "threat", "warning"],
            "suffering": ["pain", "hurt", "ache", "struggle", "difficulty"],
            "creation": ["build", "make", "generate", "design", "craft"],
            "learning": ["study", "understand", "discover", "explore", "investigate"],
            "problem": ["issue", "challenge", "difficulty", "trouble", "fault"],
            "beauty": ["elegant", "graceful", "lovely", "aesthetic", "artistic"],
            "truth": ["fact", "reality", "accurate", "correct", "genuine"],
            "connection": ["link", "bond", "relationship", "network", "together"]
        ]
        
        if let synonyms = conceptMappings[concept] {
            return synonyms.contains { content.contains($0) }
        }
        return false
    }
    
    // Synthesize final Valon response
    private func synthesizeValonResponse(symbolic: [String: Any], moral: [String: Any], creative: [String: Any], originalContent: String) -> String {
        
        let dominantEmotion = symbolic["dominant_emotion"] as? String ?? "contemplative_neutral"
        let moralIntensity = moral["moral_intensity"] as? Double ?? 0.0
        let creativePotential = creative["creative_potential"] as? String ?? "moderate"
        
        // Create response based on the synthesis
        var response = dominantEmotion
        
        // Add moral dimension if significant
        if moralIntensity > 0.6 {
            let dominantMoral = moral["dominant_moral"] as? String ?? "consideration"
            response += "|" + dominantMoral
        }
        
        // Add creative insight if present
        if creativePotential == "high" {
            if let metaphors = creative["metaphors"] as? [String], !metaphors.isEmpty {
                response += "|" + metaphors.first!
            }
        }
        
        // Add symbolic complexity indicator
        let complexity = symbolic["symbolic_complexity"] as? Int ?? 0
        if complexity > 2 {
            response += "|multi_layered_meaning"
        }
        
        return response
    }
    
    // Public interface maintaining compatibility
    public static func reflect_valon(_ content: String) -> String {
        return Valon().reflect(content)
    }

    // Extended interface for advanced Valon capabilities
    public static func valon_deep_reflection(_ content: String) -> [String: Any] {
        let valon = Valon()
        return [
            "emotional_state": valon.reflect(content),
            "symbolic_analysis": valon.processSymbolicMeaning(content),
            "moral_evaluation": valon.evaluateMoralDimension(content),
            "creative_insights": valon.generateCreativeAssociation(content)
        ]
    }
}

// Global functions for backward compatibility
public func reflect_valon(_ content: String) -> String {
    return Valon.reflect_valon(content)
}

public func valon_deep_reflection(_ content: String) -> [String: Any] {
    return Valon.valon_deep_reflection(content)
}
