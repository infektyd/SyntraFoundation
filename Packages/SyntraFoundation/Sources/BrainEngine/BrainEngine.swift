import Foundation
import FoundationModels
import Valon
import Modi
import Drift
import SyntraConfig
import ConsciousnessStructures
// import StructuredConsciousnessService // Disabled for macOS "26.0" compatibility

/// BrainEngine for SYNTRA consciousness architecture
/// Refactored July 2025 to eliminate top-level functions and ensure SwiftPM compliance
public struct BrainEngine {
    public init() {}
    
    /// Log processing stage to entropy/drift logs
    public static func logStage(stage: String, output: Any, directory: String) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: directory) {
            try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true)
        }
        let path = URL(fileURLWithPath: directory).appendingPathComponent("\(stage).json")
        var data: [[String: Any]] = []
        // FIXED: Use newer Data(contentsOf:options:) API for iOS 18 compatibility
        if let d = try? Data(contentsOf: path, options: []),
           let j = try? JSONSerialization.jsonObject(with: d) as? [[String: Any]] {
            data = j
        }
        let entry: [String: Any] = ["timestamp": ISO8601DateFormatter().string(from: Date()),
                                    "output": output]
        data.append(entry)
        if let out = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]) {
            try? out.write(to: path)
        }
    }

    /// Inter-brain communication system
    public static func conductInternalDialogue(_ content: String) -> [String: Any] {
        // First, get initial responses from both brains
        let valonInitial = Self.reflect_valon(content)
        let modiInitial = Self.reflect_modi(content)
        
        // Allow Valon to respond to Modi's analysis
        let valonContext = "Modi analyzed this as: \(modiInitial.joined(separator: ", ")). Content: \(content)"
        let valonInformed = Self.reflect_valon(valonContext)
        
        // Allow Modi to respond to Valon's perspective
        let modiContext = "Valon feels this is: \(valonInitial). Content: \(content)"
        let modiInformed = Self.reflect_modi(modiContext)
        
        return [
            "valon_initial": valonInitial,
            "modi_initial": modiInitial,
            "valon_informed": valonInformed,
            "modi_informed": modiInformed,
            "dialogue_occurred": true
        ]
    }

    public static func processThroughBrains(_ input: String) async -> [String: Any] {
        // Enhanced processing with inter-brain communication
        let dialogue = Self.conductInternalDialogue(input)
        
        // Use the informed responses for final synthesis
        let finalValon = dialogue["valon_informed"] as? String ?? dialogue["valon_initial"] as? String ?? "neutral"
        let finalModi = dialogue["modi_informed"] as? [String] ?? dialogue["modi_initial"] as? [String] ?? ["baseline_analysis"]
        
        Self.logStage(stage: "valon_stage", output: dialogue["valon_initial"] ?? "unknown", directory: "entropy_logs")
        Self.logStage(stage: "valon_informed_stage", output: finalValon, directory: "entropy_logs")
        Self.logStage(stage: "modi_stage", output: dialogue["modi_initial"] ?? "unknown", directory: "entropy_logs")
        Self.logStage(stage: "modi_informed_stage", output: finalModi, directory: "entropy_logs")
        
        // Use the enhanced SYNTRA consciousness synthesis
        let consciousness = Self.syntra_consciousness_synthesis(finalValon, finalModi)
        Self.logStage(stage: "consciousness_synthesis", output: consciousness, directory: "entropy_logs")
        
        // Enhanced result with consciousness state
        var result: [String: Any] = [
            "valon": finalValon,
            "modi": finalModi,
            "consciousness": consciousness,
            "internal_dialogue": dialogue,
            "consciousness_state": consciousness["consciousness_state"] ?? "unknown",
            "decision_confidence": consciousness["decision_confidence"] ?? 0.0
        ]
        
        // Legacy compatibility
        result["drift"] = consciousness
        
        // Apple LLM integration for enhanced reasoning (disabled for macOS "26.0" compatibility)
        if let cfg = try? Self.loadConfigLocal(), cfg.useAppleLLM == true {
            let syntraDecision = consciousness["syntra_decision"] as? String ?? "processing"
            let enhancedPrompt = "SYNTRA consciousness state: \(syntraDecision). Original input: \(input). Provide enhanced reasoning."
            if #available(macOS 26.0, *) {
                let apple = await Self.queryAppleLLMSync(enhancedPrompt)
                result["appleLLM"] = apple
                Self.logStage(stage: "apple_enhanced_reasoning", output: apple, directory: "entropy_logs")
            } else {
                result["appleLLM"] = "Apple LLM requires macOS 26.0+"
            }
        }
        
        return result
    }

    public static func jsonString(_ obj: Any) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    // Bridge functions to connect Sources/ modules with swift/ implementations

    public static func reflect_valon(_ input: String) -> String {
        let valon = Valon()
        return valon.reflect(input)
    }

    public static func reflect_modi(_ input: String) -> [String] {
        let modi = Modi()
        return modi.reflect(input)
    }

    public static func loadConfigLocal() throws -> SyntraConfig {
        return try loadConfig(path: "config.json")
    }

    public static func drift_average(_ valonResponse: String, _ modiResponse: [String]) -> [String: Any] {
        let drift = Drift()
        return drift.average(valon: valonResponse, modi: modiResponse)
    }

    public static func syntra_consciousness_synthesis(_ valonResponse: String, _ modiResponse: [String]) -> [String: Any] {
        // Enhanced synthesis combining both approaches
        let basicDrift = Self.drift_average(valonResponse, modiResponse)
        
        // Add consciousness state analysis
        let consciousnessState = Self.determineConsciousnessState(valon: valonResponse, modi: modiResponse)
        let decisionConfidence = Self.calculateDecisionConfidence(valon: valonResponse, modi: modiResponse)
        
        var result = basicDrift
        result["consciousness_state"] = consciousnessState
        result["decision_confidence"] = decisionConfidence
        result["syntra_decision"] = result["synthesis"] ?? "processing"
        
        return result
    }

    private static func determineConsciousnessState(valon: String, modi: [String]) -> String {
        // Analyze the nature of the cognitive processing
        if modi.contains(where: { $0.contains("technical") || $0.contains("analytical") }) {
            if valon.contains("moral") || valon.contains("ethical") {
                return "deliberative_consciousness"  // Both analytical and moral
            } else {
                return "analytical_consciousness"    // Primarily analytical
            }
        } else if valon.contains("moral") || valon.contains("creative") {
            return "value_driven_consciousness"      // Primarily value-driven
        } else {
            return "integrated_consciousness"        // Balanced integration
        }
    }

    private static func calculateDecisionConfidence(valon: String, modi: [String]) -> Double {
        var confidence = 0.5
        
        // Higher confidence when both brains provide clear responses
        if !valon.isEmpty && !modi.isEmpty {
            confidence += 0.2
        }
        
        // Technical analysis increases confidence
        if modi.contains(where: { $0.contains("technical") || $0.contains("high_confidence") }) {
            confidence += 0.2
        }
        
        // Strong moral clarity increases confidence
        if valon.contains("clear") || valon.contains("strong") {
            confidence += 0.15
        }
        
        // Multi-component responses suggest thorough analysis
        if modi.count > 2 || valon.split(separator: "|").count > 2 {
            confidence += 0.1
        }
        
        return min(confidence, 1.0)
    }

    @available(macOS 26.0, *)
    public static func queryAppleLLM(_ prompt: String) async -> String {
        do {
            let model = SystemLanguageModel.default
            
            guard model.availability == .available else {
                let msg = "[Apple LLM not available on this device]"
                Self.logStage(stage: "apple_llm", output: ["prompt": prompt, "response": msg], directory: "entropy_logs")
                return msg
            }
            
            let session = LanguageModelSession(model: model)
            let response = try await session.respond(to: prompt)
            
            Self.logStage(stage: "apple_llm", output: ["prompt": prompt, "response": response.content], directory: "entropy_logs")
            return response.content
            
        } catch {
            let msg = "[Apple LLM error: \(error.localizedDescription)]"
            Self.logStage(stage: "apple_llm", output: ["prompt": prompt, "response": msg], directory: "entropy_logs")
            return msg
        }
    }

    @available(macOS 26.0, *)
    public static func queryAppleLLMSync(_ prompt: String) async -> String {
        // Use Task.detached for Sendable closure
        let result = await Task<String, Never>.detached(priority: .userInitiated) {
            await Self.queryAppleLLM(prompt)
        }.value
        return result
    }
}
