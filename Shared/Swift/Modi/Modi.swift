import Foundation

public struct ReasoningFrameworkData: Sendable {
    let patterns: [String]
    let strength: Double
    let type: String
}

public struct TechnicalDomainData: Sendable {
    let keywords: [String]
    let reasoningType: String
    let confidence: Double
}

// MODI: The Logical/Rational/Analytical Brain
// Processes input through systematic reasoning, logical frameworks, and analytical patterns
// Represents the "mind" of consciousness - logic, analysis, systematic thinking
public struct Modi: Sendable {
    
    // Logical reasoning frameworks - the foundation of rational analysis
    private let reasoningFrameworks: [String: ReasoningFrameworkData] = [
        "causal_analysis": .init(patterns: ["cause", "effect", "because", "therefore", "leads to", "results in"], strength: 0.9, type: "causal_reasoning"),
        "conditional_logic": .init(patterns: ["if", "then", "when", "unless", "provided", "assuming"], strength: 0.85, type: "conditional_reasoning"),
        "comparative_analysis": .init(patterns: ["compare", "versus", "better", "worse", "more", "less", "than"], strength: 0.8, type: "comparative_reasoning"),
        "systematic_decomposition": .init(patterns: ["system", "component", "part", "element", "structure", "hierarchy"], strength: 0.85, type: "systems_thinking"),
        "quantitative_analysis": .init(patterns: ["measure", "calculate", "precise", "exact", "percentage", "ratio"], strength: 0.9, type: "quantitative_reasoning"),
        "pattern_recognition": .init(patterns: ["pattern", "trend", "cycle", "recurring", "consistent", "anomaly"], strength: 0.8, type: "pattern_analysis")
    ]
    
    // Technical domain expertise - Modi's specialized knowledge areas
    private let technicalDomains: [String: TechnicalDomainData] = [
        "mechanical_systems": .init(keywords: ["torque", "pressure", "rpm", "vibration", "bearing", "seal", "gasket"], reasoningType: "mechanical_analysis", confidence: 0.9),
        "electrical_systems": .init(keywords: ["voltage", "current", "resistance", "circuit", "ground", "short", "open"], reasoningType: "electrical_analysis", confidence: 0.85),
        "hydraulic_systems": .init(keywords: ["flow", "pressure", "valve", "pump", "cylinder", "accumulator"], reasoningType: "hydraulic_analysis", confidence: 0.8),
        "diagnostic_procedures": .init(keywords: ["test", "check", "verify", "measure", "inspect", "troubleshoot"], reasoningType: "diagnostic_reasoning", confidence: 0.9),
        "safety_protocols": .init(keywords: ["safety", "hazard", "protection", "warning", "procedure", "protocol"], reasoningType: "safety_analysis", confidence: 0.95)
    ]
    
    // Logical operators and their relationships
    private let logicalOperators: [String: Double] = [
        "and": 0.8,      // Conjunction - both conditions must be true
        "or": 0.7,       // Disjunction - either condition can be true
        "not": 0.9,      // Negation - inverse logic
        "xor": 0.6,      // Exclusive or - only one condition true
        "implies": 0.85, // Implication - if A then B
        "iff": 0.9       // If and only if - bidirectional implication
    ]
    
    public init() {}
    
    // Main reflection method - processes input through logical/analytical lens
    public func reflect(_ content: String) -> [String] {
        let logicalAnalysis = performLogicalAnalysis(content)
        let technicalAssessment = assessTechnicalDomain(content)
        let reasoningPatterns = identifyReasoningPatterns(content)
        
        return synthesizeModiResponse(logical: logicalAnalysis, technical: technicalAssessment, patterns: reasoningPatterns)
    }
    
    // Perform logical analysis - the core of Modi's intelligence
    public func performLogicalAnalysis(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var detectedFrameworks: [String: [String: Any]] = [:]
        var logicalStrength: Double = 0
        var primaryReasoning = "baseline_analysis"
        
        // Detect logical reasoning frameworks
        for (framework, data) in reasoningFrameworks {
            let matchCount = data.patterns.filter { lower.contains($0) }.count
            if matchCount > 0 {
                detectedFrameworks[framework] = [
                    "match_count": matchCount,
                    "strength": data.strength,
                    "type": data.type
                ]
                
                if data.strength > logicalStrength {
                    logicalStrength = data.strength
                    primaryReasoning = framework
                }
            }
        }
        
        // Analyze logical operators
        let operatorAnalysis = analyzeLogicalOperators(content: lower)
        
        return [
            "detected_frameworks": detectedFrameworks,
            "logical_strength": logicalStrength,
            "primary_reasoning": primaryReasoning,
            "logical_operators": operatorAnalysis,
            "reasoning_complexity": detectedFrameworks.count
        ]
    }
    
    // Assess technical domain expertise
    public func assessTechnicalDomain(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var domainMatches: [String: Any] = [:]
        var highestConfidence: Double = 0
        var primaryDomain = "general_analysis"
        
        for (domain, data) in technicalDomains {
            let matchCount = data.keywords.filter { lower.contains($0) }.count
            if matchCount > 0 {
                let confidence = data.confidence * (Double(matchCount) / Double(data.keywords.count))
                domainMatches[domain] = [
                    "match_count": matchCount,
                    "confidence": confidence,
                    "reasoning_type": data.reasoningType
                ]
                
                if confidence > highestConfidence {
                    highestConfidence = confidence
                    primaryDomain = domain
                }
            }
        }
        
        return [
            "domain_matches": domainMatches,
            "primary_domain": primaryDomain,
            "domain_confidence": highestConfidence,
            "technical_depth": domainMatches.count
        ]
    }
    
    // Identify reasoning patterns
    public func identifyReasoningPatterns(_ content: String) -> [String: Any] {
        let lower = content.lowercased()
        var patterns: [String] = []
        
        // Sequential reasoning
        if lower.contains("first") && lower.contains("then") {
            patterns.append("sequential_reasoning")
        }
        
        // Problem-solving methodology
        if lower.contains("problem") && (lower.contains("solve") || lower.contains("solution")) {
            patterns.append("problem_solving_methodology")
        }
        
        // Hypothesis testing
        if lower.contains("test") && (lower.contains("hypothesis") || lower.contains("theory")) {
            patterns.append("hypothesis_testing")
        }
        
        // Root cause analysis
        if lower.contains("root") && lower.contains("cause") {
            patterns.append("root_cause_analysis")
        }
        
        // Risk assessment
        if lower.contains("risk") || lower.contains("probability") {
            patterns.append("risk_assessment")
        }
        
        // Optimization thinking
        if lower.contains("optimize") || lower.contains("improve") || lower.contains("efficient") {
            patterns.append("optimization_reasoning")
        }
        
        return [
            "identified_patterns": patterns,
            "pattern_diversity": patterns.count,
            "reasoning_sophistication": patterns.count > 2 ? "high" : patterns.count > 0 ? "moderate" : "basic"
        ]
    }
    
    // Analyze logical operators in the content
    private func analyzeLogicalOperators(content: String) -> [String: Any] {
        var operatorPresence: [String: Bool] = [:]
        var logicalComplexity: Double = 0
        
        for (operator_, weight) in logicalOperators {
            if content.contains(operator_) {
                operatorPresence[operator_] = true
                logicalComplexity += weight
            }
        }
        
        return [
            "operators_present": operatorPresence,
            "logical_complexity": min(logicalComplexity, 1.0),
            "operator_count": operatorPresence.count
        ]
    }
    
    // Synthesize Modi's response
    private func synthesizeModiResponse(logical: [String: Any], technical: [String: Any], patterns: [String: Any]) -> [String] {
        var response: [String] = []
        
        // Add primary reasoning type
        let primaryReasoning = logical["primary_reasoning"] as? String ?? "baseline_analysis"
        response.append(primaryReasoning)
        
        // Add technical domain if significant
        let domainConfidence = technical["domain_confidence"] as? Double ?? 0.0
        if domainConfidence > 0.5 {
            let primaryDomain = technical["primary_domain"] as? String ?? "general_analysis"
            response.append(primaryDomain)
        }
        
        // Add reasoning sophistication
        let sophistication = patterns["reasoning_sophistication"] as? String ?? "basic"
        if sophistication == "high" {
            response.append("advanced_reasoning")
        }
        
        // Add logical complexity indicator
        let logicalStrength = logical["logical_strength"] as? Double ?? 0.0
        if logicalStrength > 0.8 {
            response.append("high_logical_rigor")
        }
        
        // Ensure we always return something meaningful
        if response.isEmpty {
            response.append("baseline_analysis")
        }
        
        return response
    }
    
    // Public interface maintaining compatibility
    public static func reflect_modi(_ content: String) -> [String] {
        return Modi().reflect(content)
    }

    // Extended interface for advanced Modi capabilities
    public static func modi_deep_analysis(_ content: String) -> [String: Any] {
        let modi = Modi()
        return [
            "reasoning_patterns": modi.reflect(content),
            "logical_analysis": modi.performLogicalAnalysis(content),
            "technical_assessment": modi.assessTechnicalDomain(content),
            "pattern_identification": modi.identifyReasoningPatterns(content)
        ]
    }
}

// Global functions for backward compatibility
public func reflect_modi(_ content: String) -> [String] {
    return Modi.reflect_modi(content)
}

public func modi_deep_analysis(_ content: String) -> [String: Any] {
    return Modi.modi_deep_analysis(content)
}
