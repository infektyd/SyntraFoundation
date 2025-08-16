import Foundation
import Algorithms

#if compiler(>=6.0)
#if canImport(_NumericsShims)
// _NumericsShims may be available on some toolchains but we avoid importing it
// as an @_implementationOnly dependency. Modi uses its local
// ModiNumericsCompatibility shim which delegates to Darwin/libm functions.
#endif
#endif



public struct ReasoningFrameworkData: Sendable {
    let patterns: [String]
    let strength: Double
    let type: String
    let probabilityDistribution: [String: Double]?
}

public struct TechnicalDomainData: Sendable {
    let keywords: [String]
    let reasoningType: String
    let confidence: Double
    let minConfidence: Double
    let maxConfidence: Double
    let patternCount: Int
}

public struct QuantitativeAnalysisResult: Sendable {
    public let minValue: Double
    public let maxValue: Double
    public let count: Int
    public let average: Double
    public let standardDeviation: Double
    public let entropy: Double
}

public struct ProbabilityDistribution: Sendable {
    public let domain: String
    public let probabilities: [String: Double]
    public let entropy: Double
    public let prior: [String: Double]
    public let posterior: [String: Double]
    public let likelihood: [String: Double]
    
    public init(domain: String, probabilities: [String: Double], entropy: Double, prior: [String: Double], posterior: [String: Double], likelihood: [String: Double]) {
        self.domain = domain
        self.probabilities = probabilities
        self.entropy = entropy
        self.prior = prior
        self.posterior = posterior
        self.likelihood = likelihood
    }
}

// MODI: The Logical/Rational/Analytical Brain
// Processes input through systematic reasoning, logical frameworks, and analytical patterns
// Represents the "mind" of consciousness - logic, analysis, systematic thinking
public struct Modi: Sendable {
    
    // Logical reasoning frameworks - the foundation of rational analysis
    private let reasoningFrameworks: [String: ReasoningFrameworkData] = [
        "causal_analysis": .init(patterns: ["cause", "effect", "because", "therefore", "leads to", "results in"], strength: 0.9, type: "causal_reasoning", probabilityDistribution: nil),
        "conditional_logic": .init(patterns: ["if", "then", "when", "unless", "provided", "assuming"], strength: 0.85, type: "conditional_reasoning", probabilityDistribution: nil),
        "comparative_analysis": .init(patterns: ["compare", "versus", "better", "worse", "more", "less", "than"], strength: 0.8, type: "comparative_reasoning", probabilityDistribution: nil),
        "systematic_decomposition": .init(patterns: ["system", "component", "part", "element", "structure", "hierarchy"], strength: 0.85, type: "systems_thinking", probabilityDistribution: nil),
        "quantitative_analysis": .init(patterns: ["measure", "calculate", "precise", "exact", "percentage", "ratio"], strength: 0.9, type: "quantitative_reasoning", probabilityDistribution: nil),
        "pattern_recognition": .init(patterns: ["pattern", "trend", "cycle", "recurring", "consistent", "anomaly"], strength: 0.8, type: "pattern_analysis", probabilityDistribution: nil)
    ]
    
    // Technical domain expertise - Modi's specialized knowledge areas
    private let technicalDomains: [String: TechnicalDomainData] = [
        "mechanical_systems": .init(keywords: ["torque", "pressure", "rpm", "vibration", "bearing", "seal", "gasket"], reasoningType: "mechanical_analysis", confidence: 0.9, minConfidence: 0.7, maxConfidence: 1.0, patternCount: 7),
        "electrical_systems": .init(keywords: ["voltage", "current", "resistance", "circuit", "ground", "short", "open"], reasoningType: "electrical_analysis", confidence: 0.85, minConfidence: 0.6, maxConfidence: 0.95, patternCount: 7),
        "hydraulic_systems": .init(keywords: ["flow", "pressure", "valve", "pump", "cylinder", "accumulator"], reasoningType: "hydraulic_analysis", confidence: 0.8, minConfidence: 0.5, maxConfidence: 0.9, patternCount: 6),
        "diagnostic_procedures": .init(keywords: ["test", "check", "verify", "measure", "inspect", "troubleshoot"], reasoningType: "diagnostic_reasoning", confidence: 0.9, minConfidence: 0.7, maxConfidence: 1.0, patternCount: 6),
        "safety_protocols": .init(keywords: ["safety", "hazard", "protection", "warning", "procedure", "protocol"], reasoningType: "safety_analysis", confidence: 0.95, minConfidence: 0.8, maxConfidence: 1.0, patternCount: 6)
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
    
    // Calculate domain probabilities using Bayesian inference
    public func calculateDomainProbabilities(_ content: String) -> ProbabilityDistribution {
        let lower = content.lowercased()
        var domainProbabilities: [String: Double] = [:]
        var priors: [String: Double] = [:]
        var posteriors: [String: Double] = [:]
        var likelihoods: [String: Double] = [:]
        
        // Calculate priors based on domain frequencies
        let totalDomains = technicalDomains.count
        for (domain, _) in technicalDomains {
            priors[domain] = 1.0 / Double(totalDomains)
        }
        
        // Calculate likelihoods and posteriors
        for (domain, data) in technicalDomains {
            let matchCount = data.keywords.filter { lower.contains($0) }.count
            if matchCount > 0 {
                // Likelihood is probability of seeing these keywords given the domain
                let likelihood = Double(matchCount) / Double(data.keywords.count)
                likelihoods[domain] = likelihood
                
                // Posterior = (Likelihood * Prior) / Evidence
                // For simplicity, we'll use unnormalized posteriors here
                posteriors[domain] = likelihood * (priors[domain] ?? 0)
                domainProbabilities[domain] = posteriors[domain] ?? 0
            }
        }
        
        // Normalize probabilities
        let totalProbability = domainProbabilities.values.reduce(0, +)
        if totalProbability > 0 {
            for (domain, prob) in domainProbabilities {
                domainProbabilities[domain] = prob / totalProbability
                posteriors[domain] = (posteriors[domain] ?? 0) / totalProbability
            }
        }
        
    // Calculate entropy using helper
    let entropy = calculateEntropy(for: domainProbabilities.values)
    
    return ProbabilityDistribution(
            domain: "technical_domains",
            probabilities: domainProbabilities,
            entropy: entropy,
            prior: priors,
            posterior: posteriors,
            likelihood: likelihoods
        )
    }
    
    // Calculate quantitative metrics for patterns using swift-algorithms
    public func calculateQuantitativeMetrics(_ content: String) -> QuantitativeAnalysisResult {
        let domainDist = calculateDomainProbabilities(content)
        let confidenceValues = domainDist.probabilities.values.map { $0 }
        
        guard !confidenceValues.isEmpty else {
            return QuantitativeAnalysisResult(
                minValue: 0,
                maxValue: 0,
                count: 0,
                average: 0,
                standardDeviation: 0,
                entropy: 0
            )
        }
        
        // Use Algorithms package for enhanced calculations
        let minValue = confidenceValues.min() ?? 0
        let maxValue = confidenceValues.max() ?? 0
        let count = confidenceValues.count
        let sum = confidenceValues.reduce(0, +)
        let average = sum / Double(count)
        let variance = confidenceValues.map { pow($0 - average, 2) }.reduce(0, +) / Double(count)
        let standardDeviation = sqrt(variance)
        let entropy = calculateEntropy(for: confidenceValues)
        
        return QuantitativeAnalysisResult(
            minValue: minValue,
            maxValue: maxValue,
            count: count,
            average: average,
            standardDeviation: standardDeviation,
            entropy: entropy
        )
    }
    
    /// Enhanced Bayesian analysis using Swift Algorithms
    public func calculateEnhancedBayesian(_ content: String) -> ProbabilityDistribution {
        let lower = content.lowercased()
        var domainProbabilities: [String: Double] = [:]
        var priors: [String: Double] = [:]
        var posteriors: [String: Double] = [:]
        var likelihoods: [String: Double] = [:]
        
        // Calculate priors using Algorithms package
        let totalDomains = technicalDomains.count
        technicalDomains.keys.forEach { domain in
            priors[domain] = 1.0 / Double(totalDomains)
        }
        
        // Calculate likelihoods using sliding windows for pattern matching
        for (domain, data) in technicalDomains {
            let matchCount = data.keywords.count { keyword in 
                lower.windows(ofCount: keyword.count).contains { $0.elementsEqual(keyword) }
            }
            
            if matchCount > 0 {
                let likelihood = Double(matchCount) / Double(data.keywords.count)
                likelihoods[domain] = likelihood
                posteriors[domain] = likelihood * (priors[domain] ?? 0)
                domainProbabilities[domain] = posteriors[domain] ?? 0
            }
        }
        
        // Normalize using Algorithms package
        let totalProbability = domainProbabilities.values.reduce(0, +)
        if totalProbability > 0 {
            domainProbabilities = Dictionary(uniqueKeysWithValues: 
                domainProbabilities.map { ($0.key, $0.value / totalProbability) }
            )
            posteriors = Dictionary(uniqueKeysWithValues:
                posteriors.map { ($0.key, $0.value / totalProbability) }
            )
        }
        
        return ProbabilityDistribution(
            domain: "technical_domains",
            probabilities: domainProbabilities,
            entropy: calculateEntropy(for: domainProbabilities.values),
            prior: priors,
            posterior: posteriors,
            likelihood: likelihoods
        )
    }
    
    /// Helper to calculate entropy for any probability distribution
    private func calculateEntropy<T: Collection>(for probabilities: T) -> Double where T.Element == Double {
        -probabilities.reduce(0) { $0 + ($1 > 0 ? $1 * safeLog($1) : 0) }
    }
    
    private func safeLog(_ value: Double) -> Double {
        // Use the Modi-local compatibility shim to avoid depending on SyntraTools
        // module linkage from within the Modi target.
        return ModiNumericsCompatibility.log(value)
    }
    
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
