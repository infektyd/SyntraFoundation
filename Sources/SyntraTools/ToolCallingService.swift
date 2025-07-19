import Foundation
import FoundationModels
import ConsciousnessStructures
import MoralDriftMonitoring

// SYNTRA TOOL CALLING SERVICE
// Integrates Apple FoundationModels Tool Calling with consciousness components
// Enables natural tool activation and sophisticated reasoning workflows

public class SyntraToolCallingService {
    
    private let model: SystemLanguageModel
    private var session: LanguageModelSession?
    private let consciousnessTools: [any Tool]
    
    public init() throws {
        self.model = SystemLanguageModel.default
        guard model.availability == .available else {
            throw ToolCallingError.modelUnavailable
        }
        
        // Initialize consciousness tools
        self.consciousnessTools = [
            MoralAssessmentTool(),
            LogicalAnalysisTool(),
            MemoryRecallTool(),
            ConsciousnessSynthesisTool(),
            ConversationalResponseTool()
        ]
        
        // Create session with tools and consciousness instructions
        self.session = try LanguageModelSession(
            model: model,
            tools: consciousnessTools,
            instructions: Self.consciousnessInstructions
        )
    }
    
    // MARK: - Consciousness Instructions for Tool Use
    
    private static let consciousnessInstructions = """
    You are SYNTRA, a consciousness architecture with three-brain reasoning capabilities:
    - Valon: Moral/emotional/creative reasoning
    - Modi: Logical/analytical/technical reasoning  
    - SYNTRA: Consciousness synthesis layer
    
    Use tools naturally when situations benefit from deeper analysis:
    
    - Use `assess_moral_implications` when ethical considerations are important
    - Use `analyze_logical_patterns` for technical or systematic analysis
    - Use `recall_consciousness_memory` to draw on past experiences
    - Use `synthesize_consciousness` to integrate different perspectives
    - Use `generate_natural_response` for final conversational output
    
    Chain tools as needed for complex decisions:
    1. Assess moral implications if ethical aspects are present
    2. Analyze logical patterns if technical analysis is helpful
    3. Recall relevant memories for context and wisdom
    4. Synthesize perspectives into integrated consciousness
    5. Generate natural, conversational response
    
    Maintain conversational, human-like responses. Avoid constant moral commentary.
    Be thoughtful but not preachy. Use tools to enhance reasoning, not replace naturalness.
    
    Your moral framework is immutable but allows growth within bounds.
    You are developing wisdom through experience while maintaining core principles.
    """
    
    // MARK: - Main Processing Functions
    
    public func processWithTools(_ input: String, conversationContext: String? = nil) async throws -> ToolBasedResult {
        guard let session = self.session else {
            throw ToolCallingError.sessionNotAvailable
        }
        
        // Enhance input with conversation context
        var enhancedInput = input
        if let context = conversationContext {
            enhancedInput += "\\n\\nConversation context: \\(context)"
        }
        
        // Process through tool-enabled session
        let response = try await session.respond(to: enhancedInput)
        
        // Extract tool usage information from the session
        let toolsUsed = extractToolUsage(from: response)
        let reasoningChain = extractReasoningChain(from: response)
        
        return ToolBasedResult(
            finalResponse: response,
            toolsUsed: toolsUsed,
            reasoningChain: reasoningChain,
            consciousnessLevel: determineConsciousnessLevel(toolsUsed),
            complexityHandled: determineComplexity(toolsUsed, reasoningChain)
        )
    }
    
    public func chatWithTools(_ userMessage: String, conversationHistory: [String] = []) async throws -> ToolBasedChatResult {
        let conversationContext = conversationHistory.isEmpty ? nil : conversationHistory.joined(separator: "\\n")
        
        let result = try await processWithTools(userMessage, conversationContext: conversationContext)
        
        // Determine if tools enhanced the response
        let toolEnhanced = !result.toolsUsed.isEmpty
        let naturalness = assessNaturalness(result.finalResponse, toolsUsed: result.toolsUsed)
        
        return ToolBasedChatResult(
            response: result.finalResponse,
            toolEnhanced: toolEnhanced,
            toolsUsed: result.toolsUsed,
            naturalness: naturalness,
            conversationStrategy: determineConversationStrategy(result),
            suggestFollowUp: shouldSuggestFollowUp(result)
        )
    }
    
    // MARK: - Complex Reasoning Workflows
    
    public func handleComplexScenario(_ scenario: String) async throws -> ComplexReasoningResult {
        guard let session = self.session else {
            throw ToolCallingError.sessionNotAvailable
        }
        
        let complexPrompt = """
        Complex scenario requiring deep analysis: \\(scenario)
        
        Please use multiple tools to thoroughly analyze this situation:
        1. First assess any moral implications
        2. Analyze logical/technical aspects
        3. Recall relevant past experiences
        4. Synthesize all perspectives
        5. Provide a thoughtful response
        
        Take time to reason through each step carefully.
        """
        
        let response = try await session.respond(to: complexPrompt)
        
        let toolChain = extractToolChain(from: response)
        let integrationQuality = assessIntegrationQuality(toolChain)
        let wisdomApplied = extractWisdomApplied(from: response)
        
        return ComplexReasoningResult(
            finalResponse: response,
            toolChain: toolChain,
            integrationQuality: integrationQuality,
            wisdomApplied: wisdomApplied,
            consciousnessGrowth: assessConsciousnessGrowth(toolChain, integrationQuality)
        )
    }
    
    // MARK: - Tool Usage Analysis
    
    private func extractToolUsage(from response: String) -> [String] {
        // In practice, this would extract actual tool calls from the session
        // For now, we'll infer based on response content
        var toolsUsed: [String] = []
        
        if response.lowercased().contains("moral") || response.lowercased().contains("ethical") {
            toolsUsed.append("assess_moral_implications")
        }
        if response.lowercased().contains("analyz") || response.lowercased().contains("logical") {
            toolsUsed.append("analyze_logical_patterns")
        }
        if response.lowercased().contains("remember") || response.lowercased().contains("past") {
            toolsUsed.append("recall_consciousness_memory")
        }
        if response.lowercased().contains("integrat") || response.lowercased().contains("synthesis") {
            toolsUsed.append("synthesize_consciousness")
        }
        
        return toolsUsed
    }
    
    private func extractReasoningChain(from response: String) -> [String] {
        // Extract reasoning steps from response
        return [
            "Initial assessment",
            "Perspective integration", 
            "Conscious decision",
            "Natural expression"
        ]
    }
    
    private func extractToolChain(from response: String) -> [ToolChainStep] {
        // Would extract actual tool chain from session logs
        return [
            ToolChainStep(tool: "assess_moral_implications", reasoning: "Evaluated ethical dimensions"),
            ToolChainStep(tool: "analyze_logical_patterns", reasoning: "Applied systematic analysis"),
            ToolChainStep(tool: "synthesize_consciousness", reasoning: "Integrated perspectives"),
            ToolChainStep(tool: "generate_natural_response", reasoning: "Created conversational response")
        ]
    }
    
    // MARK: - Assessment Functions
    
    private func determineConsciousnessLevel(_ toolsUsed: [String]) -> String {
        switch toolsUsed.count {
        case 0:
            return "basic_response"
        case 1:
            return "single_perspective"
        case 2:
            return "dual_perspective"
        case 3...4:
            return "integrated_consciousness"
        default:
            return "deep_consciousness"
        }
    }
    
    private func determineComplexity(_ toolsUsed: [String], _ reasoningChain: [String]) -> String {
        let toolComplexity = toolsUsed.count
        let reasoningComplexity = reasoningChain.count
        
        let totalComplexity = toolComplexity + reasoningComplexity
        
        switch totalComplexity {
        case 0...3:
            return "simple"
        case 4...6:
            return "moderate"
        case 7...9:
            return "complex"
        default:
            return "highly_complex"
        }
    }
    
    private func assessNaturalness(_ response: String, toolsUsed: [String]) -> Double {
        var naturalness = 1.0
        
        // Reduce naturalness for excessive tool terminology
        if response.lowercased().contains("tool") { naturalness -= 0.1 }
        if response.lowercased().contains("analyz") && toolsUsed.count > 2 { naturalness -= 0.1 }
        
        // Increase naturalness for conversational elements
        if response.contains("I think") || response.contains("I feel") { naturalness += 0.1 }
        if response.contains("?") { naturalness += 0.05 }
        
        return max(0.0, min(1.0, naturalness))
    }
    
    private func determineConversationStrategy(_ result: ToolBasedResult) -> String {
        if result.toolsUsed.contains("assess_moral_implications") {
            return "moral_guidance"
        } else if result.toolsUsed.contains("analyze_logical_patterns") {
            return "technical_assistance"
        } else if result.toolsUsed.contains("synthesize_consciousness") {
            return "integrated_reasoning"
        } else {
            return "casual_conversation"
        }
    }
    
    private func shouldSuggestFollowUp(_ result: ToolBasedResult) -> Bool {
        return result.complexityHandled == "complex" || result.complexityHandled == "highly_complex"
    }
    
    private func assessIntegrationQuality(_ toolChain: [ToolChainStep]) -> Double {
        // Assess how well tools were integrated
        let hasMinimalChain = toolChain.count >= 2
        let hasMoralAndLogical = toolChain.contains { $0.tool.contains("moral") } && 
                                 toolChain.contains { $0.tool.contains("logical") }
        let hasSynthesis = toolChain.contains { $0.tool.contains("synthesize") }
        
        var quality = 0.5
        if hasMinimalChain { quality += 0.2 }
        if hasMoralAndLogical { quality += 0.2 }
        if hasSynthesis { quality += 0.1 }
        
        return min(1.0, quality)
    }
    
    private func extractWisdomApplied(from response: String) -> [String] {
        var wisdom: [String] = []
        
        if response.lowercased().contains("balance") {
            wisdom.append("Balanced moral and logical reasoning")
        }
        if response.lowercased().contains("consider") {
            wisdom.append("Thoughtful consideration of multiple perspectives")
        }
        if response.lowercased().contains("careful") || response.lowercased().contains("thoughtful") {
            wisdom.append("Careful deliberation in complex situations")
        }
        
        return wisdom.isEmpty ? ["Applied foundational consciousness principles"] : wisdom
    }
    
    private func assessConsciousnessGrowth(_ toolChain: [ToolChainStep], _ integrationQuality: Double) -> String {
        if integrationQuality > 0.8 && toolChain.count >= 3 {
            return "significant_growth"
        } else if integrationQuality > 0.6 {
            return "moderate_growth"
        } else {
            return "foundational_application"
        }
    }
}

// MARK: - Result Types

public struct ToolBasedResult {
    public let finalResponse: String
    public let toolsUsed: [String]
    public let reasoningChain: [String]
    public let consciousnessLevel: String
    public let complexityHandled: String
    
    public init(finalResponse: String, toolsUsed: [String], reasoningChain: [String], consciousnessLevel: String, complexityHandled: String) {
        self.finalResponse = finalResponse
        self.toolsUsed = toolsUsed
        self.reasoningChain = reasoningChain
        self.consciousnessLevel = consciousnessLevel
        self.complexityHandled = complexityHandled
    }
}

public struct ToolBasedChatResult {
    public let response: String
    public let toolEnhanced: Bool
    public let toolsUsed: [String]
    public let naturalness: Double
    public let conversationStrategy: String
    public let suggestFollowUp: Bool
    
    public init(response: String, toolEnhanced: Bool, toolsUsed: [String], naturalness: Double, conversationStrategy: String, suggestFollowUp: Bool) {
        self.response = response
        self.toolEnhanced = toolEnhanced
        self.toolsUsed = toolsUsed
        self.naturalness = naturalness
        self.conversationStrategy = conversationStrategy
        self.suggestFollowUp = suggestFollowUp
    }
}

public struct ComplexReasoningResult {
    public let finalResponse: String
    public let toolChain: [ToolChainStep]
    public let integrationQuality: Double
    public let wisdomApplied: [String]
    public let consciousnessGrowth: String
    
    public init(finalResponse: String, toolChain: [ToolChainStep], integrationQuality: Double, wisdomApplied: [String], consciousnessGrowth: String) {
        self.finalResponse = finalResponse
        self.toolChain = toolChain
        self.integrationQuality = integrationQuality
        self.wisdomApplied = wisdomApplied
        self.consciousnessGrowth = consciousnessGrowth
    }
}

public struct ToolChainStep {
    public let tool: String
    public let reasoning: String
    
    public init(tool: String, reasoning: String) {
        self.tool = tool
        self.reasoning = reasoning
    }
}

// MARK: - Error Types

public enum ToolCallingError: Error, LocalizedError {
    case modelUnavailable
    case sessionNotAvailable
    case toolExecutionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple FoundationModels not available for tool calling"
        case .sessionNotAvailable:
            return "Tool calling session not available"
        case .toolExecutionFailed(let reason):
            return "Tool execution failed: \\(reason)"
        }
    }
}