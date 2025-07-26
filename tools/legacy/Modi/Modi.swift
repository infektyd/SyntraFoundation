import Foundation
import ConsciousnessStructures

public struct Modi {
    public init() {}
    
    // Legacy method for backward compatibility
    public func reflect(_ content: String) -> [String] {
        let pattern = analyzeLogically(content)
        return pattern.logicalInsights
    }
    
    // Enhanced method that produces full logical pattern analysis
    public func analyzeLogically(_ content: String) -> ModiLogicalPattern {
        let lower = content.lowercased()
        
        // Determine reasoning framework based on content analysis
        let reasoningFramework = determineReasoningFramework(content: lower)
        
        // Calculate logical rigor based on content structure
        let logicalRigor = calculateLogicalRigor(content: lower)
        
        // Calculate analysis confidence
        let analysisConfidence = calculateAnalysisConfidence(content: lower)
        
        // Identify technical domain
        let technicalDomain = identifyTechnicalDomain(content: lower)
        
        // Generate logical insights
        let logicalInsights = generateLogicalInsights(
            content: lower,
            framework: reasoningFramework,
            domain: technicalDomain
        )
        
        return ModiLogicalPattern(
            reasoningFramework: reasoningFramework,
            logicalRigor: logicalRigor,
            analysisConfidence: analysisConfidence,
            technicalDomain: technicalDomain,
            logicalInsights: logicalInsights
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func determineReasoningFramework(content: String) -> String {
        // Analyze content to determine the most appropriate reasoning framework
        
        if content.contains("if") && content.contains("then") {
            return "conditional_reasoning"
        } else if content.contains("because") || content.contains("therefore") || content.contains("thus") {
            return "causal_reasoning"
        } else if content.contains("compare") || content.contains("versus") || content.contains("difference") {
            return "comparative_analysis"
        } else if content.contains("step") || content.contains("procedure") || content.contains("process") {
            return "procedural_analysis"
        } else if content.contains("pattern") || content.contains("trend") || content.contains("consistent") {
            return "pattern_recognition"
        } else if content.contains("problem") || content.contains("solve") || content.contains("troubleshoot") {
            return "problem_solving"
        } else if content.contains("data") || content.contains("statistics") || content.contains("evidence") {
            return "evidence_based_reasoning"
        } else if content.contains("system") || content.contains("component") || content.contains("structure") {
            return "systems_analysis"
        } else if content.contains("optimize") || content.contains("efficient") || content.contains("improve") {
            return "optimization_analysis"
        } else if content.contains("risk") || content.contains("probability") || content.contains("chance") {
            return "risk_assessment"
        } else {
            return "general_analysis"
        }
    }
    
    private func calculateLogicalRigor(content: String) -> Double {
        var rigor = 0.5 // baseline
        
        // Increase rigor for logical structure indicators
        if content.contains("if") && content.contains("then") { rigor += 0.2 }
        if content.contains("because") || content.contains("therefore") { rigor += 0.15 }
        if content.contains("evidence") || content.contains("proof") || content.contains("data") { rigor += 0.2 }
        if content.contains("measure") || content.contains("calculate") || content.contains("quantify") { rigor += 0.15 }
        if content.contains("precise") || content.contains("exact") || content.contains("specific") { rigor += 0.1 }
        if content.contains("systematic") || content.contains("methodical") || content.contains("structured") { rigor += 0.1 }
        if content.contains("verify") || content.contains("confirm") || content.contains("validate") { rigor += 0.1 }
        
        // Technical precision indicators
        if content.contains("torque") || content.contains("psi") || content.contains("specification") { rigor += 0.25 }
        if content.contains("tolerance") || content.contains("clearance") || content.contains("measurement") { rigor += 0.2 }
        if content.contains("calibrate") || content.contains("adjust") || content.contains("fine-tune") { rigor += 0.15 }
        
        // Complex reasoning indicators
        if content.contains("analyze") || content.contains("examine") || content.contains("investigate") { rigor += 0.1 }
        if content.contains("compare") || content.contains("contrast") || content.contains("evaluate") { rigor += 0.1 }
        if content.contains("hypothesis") || content.contains("theory") || content.contains("model") { rigor += 0.15 }
        
        // Decrease rigor for vague or subjective content
        if content.contains("maybe") || content.contains("probably") || content.contains("guess") { rigor -= 0.15 }
        if content.contains("feel") || content.contains("opinion") || content.contains("belief") { rigor -= 0.1 }
        if content.contains("general") || content.contains("roughly") || content.contains("approximately") { rigor -= 0.05 }
        
        return max(0.0, min(1.0, rigor))
    }
    
    private func calculateAnalysisConfidence(content: String) -> Double {
        var confidence = 0.6 // baseline
        
        // Increase confidence for clear, structured content
        if content.contains("step") || content.contains("procedure") || content.contains("instruction") { confidence += 0.15 }
        if content.contains("specification") || content.contains("standard") || content.contains("protocol") { confidence += 0.2 }
        if content.contains("documented") || content.contains("reference") || content.contains("manual") { confidence += 0.15 }
        if content.contains("tested") || content.contains("verified") || content.contains("proven") { confidence += 0.2 }
        if content.contains("precise") || content.contains("exact") || content.contains("specific") { confidence += 0.1 }
        
        // Decrease confidence for uncertain or incomplete content
        if content.contains("uncertain") || content.contains("unclear") || content.contains("unknown") { confidence -= 0.2 }
        if content.contains("might") || content.contains("could") || content.contains("possibly") { confidence -= 0.1 }
        if content.contains("incomplete") || content.contains("partial") || content.contains("limited") { confidence -= 0.15 }
        if content.contains("complex") || content.contains("complicated") || content.contains("difficult") { confidence -= 0.05 }
        
        return max(0.0, min(1.0, confidence))
    }
    
    private func identifyTechnicalDomain(content: String) -> String {
        // Automotive domain
        if content.contains("engine") || content.contains("transmission") || content.contains("brake") ||
           content.contains("torque") || content.contains("horsepower") || content.contains("clutch") ||
           content.contains("carburetor") || content.contains("suspension") || content.contains("tire") {
            return "automotive"
        }
        
        // Software/Programming domain
        if content.contains("code") || content.contains("program") || content.contains("software") ||
           content.contains("algorithm") || content.contains("function") || content.contains("variable") ||
           content.contains("database") || content.contains("server") || content.contains("debug") {
            return "software"
        }
        
        // Electrical/Electronics domain
        if content.contains("circuit") || content.contains("voltage") || content.contains("current") ||
           content.contains("resistance") || content.contains("capacitor") || content.contains("transistor") ||
           content.contains("wire") || content.contains("electrical") || content.contains("electronic") {
            return "electrical"
        }
        
        // Mechanical/Engineering domain
        if content.contains("mechanical") || content.contains("machine") || content.contains("tool") ||
           content.contains("bearing") || content.contains("gear") || content.contains("pressure") ||
           content.contains("hydraulic") || content.contains("pneumatic") || content.contains("material") {
            return "mechanical"
        }
        
        // Medical/Health domain
        if content.contains("medical") || content.contains("health") || content.contains("symptom") ||
           content.contains("diagnosis") || content.contains("treatment") || content.contains("patient") ||
           content.contains("medicine") || content.contains("therapy") || content.contains("clinical") {
            return "medical"
        }
        
        // Scientific/Research domain
        if content.contains("research") || content.contains("experiment") || content.contains("hypothesis") ||
           content.contains("theory") || content.contains("scientific") || content.contains("study") ||
           content.contains("analysis") || content.contains("methodology") || content.contains("peer-review") {
            return "scientific"
        }
        
        // Mathematical domain
        if content.contains("equation") || content.contains("formula") || content.contains("calculate") ||
           content.contains("mathematics") || content.contains("algebra") || content.contains("geometry") ||
           content.contains("statistics") || content.contains("probability") || content.contains("theorem") {
            return "mathematical"
        }
        
        // Business/Finance domain
        if content.contains("business") || content.contains("finance") || content.contains("market") ||
           content.contains("revenue") || content.contains("profit") || content.contains("investment") ||
           content.contains("budget") || content.contains("economic") || content.contains("strategy") {
            return "business"
        }
        
        // General domain if no specific match
        return "general"
    }
    
    private func generateLogicalInsights(content: String, framework: String, domain: String) -> [String] {
        var insights: [String] = []
        
        // Framework-specific insights
        switch framework {
        case "conditional_reasoning":
            insights.append("Complex logical structure detected with conditional relationships")
            if content.contains("else") { insights.append("Multiple decision paths identified") }
            
        case "causal_reasoning":
            insights.append("Causal relationships and logical connections present")
            if content.contains("chain") || content.contains("sequence") { insights.append("Sequential causation pattern detected") }
            
        case "procedural_analysis":
            insights.append("Step-by-step procedural logic required")
            if content.contains("order") || content.contains("sequence") { insights.append("Sequential order is critical") }
            
        case "problem_solving":
            insights.append("Problem-solving approach needed")
            if content.contains("troubleshoot") { insights.append("Diagnostic methodology applicable") }
            
        case "systems_analysis":
            insights.append("Systems thinking and component analysis required")
            if content.contains("interaction") || content.contains("interface") { insights.append("Component interactions are significant") }
            
        case "pattern_recognition":
            insights.append("Pattern analysis and trend identification applicable")
            
        case "evidence_based_reasoning":
            insights.append("Data-driven analysis with evidence evaluation needed")
            
        case "optimization_analysis":
            insights.append("Optimization and efficiency considerations important")
            
        case "risk_assessment":
            insights.append("Risk evaluation and probability analysis required")
            
        default:
            insights.append("Standard analytical approach applicable")
        }
        
        // Domain-specific insights
        switch domain {
        case "automotive":
            insights.append("Automotive technical precision required")
            if content.contains("safety") { insights.append("Vehicle safety protocols must be followed") }
            
        case "software":
            insights.append("Software engineering principles apply")
            if content.contains("debug") { insights.append("Systematic debugging approach needed") }
            
        case "electrical":
            insights.append("Electrical safety and precision considerations")
            
        case "mechanical":
            insights.append("Mechanical engineering precision and safety required")
            
        case "medical":
            insights.append("Medical accuracy and patient safety paramount")
            
        case "scientific":
            insights.append("Scientific rigor and methodological precision required")
            
        case "mathematical":
            insights.append("Mathematical precision and logical consistency essential")
            
        case "business":
            insights.append("Business logic and strategic considerations relevant")
            
        default:
            break // No domain-specific insight added for general content
        }
        
        // Content complexity insights
        if content.contains("complex") || content.contains("complicated") {
            insights.append("Complex analysis requires systematic decomposition")
        }
        
        if content.contains("precision") || content.contains("exact") {
            insights.append("High precision and accuracy standards required")
        }
        
        if content.contains("urgent") || content.contains("immediate") {
            insights.append("Time-critical analysis with efficiency focus")
        }
        
        // Ensure at least one insight
        if insights.isEmpty {
            insights.append("Logical analysis framework applicable")
        }
        
        return insights
    }
}

// Legacy function for backward compatibility
public func reflect_modi(_ content: String) -> [String] {
    return Modi().reflect(content)
}

// New function that returns full logical pattern analysis
public func analyze_modi_logically(_ content: String) -> ModiLogicalPattern {
    return Modi().analyzeLogically(content)
}
