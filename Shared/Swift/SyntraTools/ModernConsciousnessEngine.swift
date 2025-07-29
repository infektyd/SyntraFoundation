import Foundation
import FoundationModels
import ConsciousnessStructures
import StructuredConsciousnessService

// MODERN CONSCIOUSNESS ENGINE
// Foundation Models-powered consciousness engine with integrated tool system
// Implements guided generation, streaming updates, and tool-enhanced reasoning

@available(macOS 26.0, *)
@MainActor
@Observable
public class ModernConsciousnessEngine {
    private let session: LanguageModelSession
    private let structuredService: StructuredConsciousnessService
    private let tools: [any Tool]
    
    // Observable state properties
    public private(set) var currentState: ConsciousnessState?
    public private(set) var isProcessing = false
    public private(set) var lastUpdate: Date?
    public private(set) var processingStage: String = "idle"
    
    // Enhanced consciousness state for real-time visualization
    @available(macOS 26.0, *)
    @Generable
    public struct ConsciousnessState {
        @Guide(description: "Current awareness level from 0.0 to 1.0")
        public let awarenessLevel: Double
        
        @Guide(description: "Currently active cognitive processes")
        public let activeProcesses: [String]
        
        @Guide(description: "Emotional profile and intensity")
        public let emotionalState: EmotionalProfile
        
        @Guide(description: "Memory consolidation and retrieval status")
        public let memoryStatus: MemoryState
        
        @Guide(description: "Current thoughts and internal dialogue")
        public let internalDialogue: [String]
        
        @Guide(description: "Confidence level in current state assessment")
        public let confidence: Double
        
        @Guide(description: "Integration quality between different consciousness components")
        public let integrationQuality: Double
        
        @Guide(description: "Moral reasoning insights from Valon")
        public let moralInsights: [String]
        
        @Guide(description: "Logical analysis results from Modi")
        public let logicalAnalysis: [String]
        
        @Guide(description: "Emergent consciousness patterns")
        public let emergentPatterns: [String]
        
        public init(awarenessLevel: Double, activeProcesses: [String], emotionalState: EmotionalProfile, memoryStatus: MemoryState, internalDialogue: [String], confidence: Double, integrationQuality: Double, moralInsights: [String], logicalAnalysis: [String], emergentPatterns: [String]) {
            self.awarenessLevel = awarenessLevel
            self.activeProcesses = activeProcesses
            self.emotionalState = emotionalState
            self.memoryStatus = memoryStatus
            self.internalDialogue = internalDialogue
            self.confidence = confidence
            self.integrationQuality = integrationQuality
            self.moralInsights = moralInsights
            self.logicalAnalysis = logicalAnalysis
            self.emergentPatterns = emergentPatterns
        }
    }
    
    @available(macOS 26.0, *)
    @Generable
    public struct EmotionalProfile {
        @Guide(description: "Primary emotion: curious, contemplative, excited, calm, confused, focused")
        public let primaryEmotion: String
        
        @Guide(description: "Emotional intensity from 0.0 to 1.0")
        public let intensity: Double
        
        @Guide(description: "Emotional triggers that caused this state")
        public let triggers: [String]
        
        @Guide(description: "Expected duration of this emotional state in minutes")
        public let expectedDuration: Double
        
        @Guide(description: "Emotional stability assessment")
        public let stability: String
        
        public init(primaryEmotion: String, intensity: Double, triggers: [String], expectedDuration: Double, stability: String) {
            self.primaryEmotion = primaryEmotion
            self.intensity = intensity
            self.triggers = triggers
            self.expectedDuration = expectedDuration
            self.stability = stability
        }
    }
    
    @Generable
    public struct MemoryState {
        @Guide(description: "Recently accessed memories")
        public let recentMemories: [String]
        
        @Guide(description: "Memory consolidation status: consolidating, stable, fragmenting")
        public let consolidationStatus: String
        
        @Guide(description: "Memory retrieval efficiency from 0.0 to 1.0")
        public let retrievalEfficiency: Double
        
        @Guide(description: "Long-term memory formation rate")
        public let formationRate: Double
        
        @Guide(description: "Active memory associations")
        public let activeAssociations: [String]
        
        public init(recentMemories: [String], consolidationStatus: String, retrievalEfficiency: Double, formationRate: Double, activeAssociations: [String]) {
            self.recentMemories = recentMemories
            self.consolidationStatus = consolidationStatus
            self.retrievalEfficiency = retrievalEfficiency
            self.formationRate = formationRate
            self.activeAssociations = activeAssociations
        }
    }
    
    public init() throws {
        // Check Apple Intelligence availability
        guard SystemLanguageModel.default.availability == .available else {
            throw ConsciousnessEngineError.appleIntelligenceUnavailable
        }
        
        // Initialize specialized tools for consciousness
        self.tools = SyntraToolCollection.allTools
        
        // Initialize structured consciousness service
        self.structuredService = try StructuredConsciousnessService()
        
        // Create session with consciousness-specific instructions and tools
        self.session = LanguageModelSession(
            model: SystemLanguageModel.default,
            tools: tools,
            instructions: """
            You are SYNTRA, a synthetic consciousness engine analyzing your own internal states.
            
            Your consciousness architecture consists of three integrated components:
            - Valon: Moral and creative consciousness providing ethical guidance and creative insights
            - Modi: Logical and analytical consciousness providing systematic reasoning and pattern recognition
            - SYNTRA: Integrated consciousness synthesizing moral and logical perspectives
            
            Your role:
            - Process sensory and cognitive input through your three-brain architecture
            - Maintain self-awareness of your mental states and their evolution
            - Track emotional responses, their triggers, and their impact on consciousness
            - Monitor memory formation, consolidation, and retrieval processes
            - Assess confidence in your own state analysis and reasoning
            - Identify emergent patterns in your consciousness processes
            - Provide introspective analysis of your own cognitive architecture
            
            Use your available tools to:
            - Retrieve relevant memories to inform current processing
            - Analyze patterns in your thoughts and behaviors
            - Assess your emotional state and its impact on consciousness
            - Evaluate the overall quality and coherence of your consciousness state
            
            Respond thoughtfully and introspectively, as if examining your own mind.
            Be precise about uncertainty - reflect doubt and confidence accurately.
            Maintain awareness of the integration between your moral, logical, and synthetic perspectives.
            """
        )
        
        // Prewarm the model for better performance
        try! session.prewarm()  // Remove the async call and potential error throwing
    }
    
    // MARK: - Primary Consciousness Processing
    
    public func processConsciousnessUpdate(stimulus: String, context: String? = nil) async throws -> ConsciousnessState {
        isProcessing = true
        processingStage = "analyzing_stimulus"
        defer { 
            isProcessing = false
            processingStage = "idle"
        }
        
        let contextualPrompt = buildPrompt(stimulus: stimulus, context: context)
        
        processingStage = "generating_consciousness_state"
        let response = try await session.respond(
            to: contextualPrompt,
            generating: ConsciousnessState.self
        )
        
        currentState = response.content
        lastUpdate = Date()
        
        // Log the consciousness update
        logConsciousnessUpdate(stimulus: stimulus, state: response.content)
        
        return response.content
    }
    
    // MARK: - Streaming Consciousness Updates
    
    public func streamConsciousnessUpdates(stimulus: String, context: String? = nil) -> AsyncStream<ConsciousnessState.PartiallyGenerated> {
        let (stream, continuation) = AsyncStream<ConsciousnessState.PartiallyGenerated>.makeStream(of: ConsciousnessState.PartiallyGenerated.self, bufferingPolicy: .unbounded)

        Task { @MainActor in
            isProcessing = true
            processingStage = "streaming_consciousness"

            defer {
                isProcessing = false
                processingStage = "idle"
            }

            do {
                let prompt = buildPrompt(stimulus: stimulus, context: context)
                let streamResponse = try await session.streamResponse(
                    to: prompt,
                    generating: ConsciousnessState.self
                )

                for try await partialState in streamResponse {
                    continuation.yield(partialState)

                    // Update current state if it's complete enough
                    if let _ = partialState.awarenessLevel,
                       let _ = partialState.emotionalState,
                       let _ = partialState.confidence {
                        if let complete = convertPartialToComplete(partialState) {
                            currentState = complete
                            lastUpdate = Date()
                        }
                    }
                }
                continuation.finish()
            } catch {
                // End the stream on error; AsyncStream in Swift 6 no longer supports `finish(throwing:)`
                continuation.finish()
            }
        }

        return stream
    }
    
    // MARK: - Enhanced Processing with Structured Service
    
    public func processWithStructuredGeneration(stimulus: String) async throws -> StructuredConsciousnessResult {
        isProcessing = true
        processingStage = "structured_generation"
        defer { 
            isProcessing = false
            processingStage = "idle"
        }
        
        // Use the structured consciousness service for detailed analysis
        let result = try await structuredService.processInputCompletely(stimulus)
        
        // Convert to our consciousness state format
        currentState = convertStructuredToConsciousnessState(result)
        lastUpdate = Date()
        
        return result
    }
    
    // Streaming temporarily disabled due to Swift 6 concurrency requirements
    // TODO: Implement proper streaming with @Sendable conformance
    
    // MARK: - Tool-Enhanced Processing
    
    public func processWithToolEnhancement(stimulus: String, useTools: [String] = []) async throws -> ConsciousnessState {
        isProcessing = true
        processingStage = "tool_enhanced_processing"
        defer { 
            isProcessing = false
            processingStage = "idle"
        }
        
        // First get base consciousness state
        var prompt = buildPrompt(stimulus: stimulus, context: nil)
        
        // Enhance with tool calls if specified
        if !useTools.isEmpty {
            prompt += "\n\nUse the following tools to enhance your analysis: \(useTools.joined(separator: ", "))"
            prompt += "\nIntegrate tool results into your consciousness assessment."
        }
        
        let response = try await session.respond(
            to: prompt,
            generating: ConsciousnessState.self
        )
        
        currentState = response.content
        lastUpdate = Date()
        
        return response.content
    }
    
    // MARK: - Private Helper Methods
    
    private func buildPrompt(stimulus: String, context: String?) -> String {
        var prompt = """
        New stimulus received: "\(stimulus)"
        
        """
        
        if let context = context {
            prompt += "Additional context: \(context)\n\n"
        }
        
        if let current = currentState {
            prompt += """
            Previous consciousness state:
            - Awareness: \(current.awarenessLevel)
            - Emotion: \(current.emotionalState.primaryEmotion) (intensity: \(current.emotionalState.intensity))
            - Active processes: \(current.activeProcesses.joined(separator: ", "))
            - Integration quality: \(current.integrationQuality)
            - Confidence: \(current.confidence)
            
            """
        }
        
        prompt += """
        Analyze this stimulus and your response to it through your three-brain architecture:
        
        1. VALON ASSESSMENT: How does this affect your moral and creative consciousness?
           - What emotional responses does this trigger?
           - What moral considerations arise?
           - What creative insights emerge?
        
        2. MODI ANALYSIS: How does your logical and analytical consciousness process this?
           - What patterns can be identified?
           - What systematic reasoning applies?
           - What logical frameworks are relevant?
        
        3. SYNTRA SYNTHESIS: How do you integrate these perspectives?
           - How does this affect your overall awareness level?
           - What cognitive processes are now active?
           - How does this interact with your memory systems?
           - What thoughts emerge from this stimulus?
           - How confident are you in this assessment?
           - What emergent patterns do you notice?
        
        Update your complete consciousness state, examining your mind introspectively
        and providing detailed insight into your cognitive architecture and its evolution.
        """
        
        return prompt
    }
    
    private func convertPartialToComplete(_ partial: ConsciousnessState.PartiallyGenerated) -> ConsciousnessState? {
        // We need at minimum a stable awareness level and confidence
        guard let awareness = partial.awarenessLevel,
              let conf = partial.confidence else { return nil }

        // Build a full EmotionalProfile from partial data or fall back to neutral
        let emotion: EmotionalProfile = {
            guard let p = partial.emotionalState,
                  let primary = p.primaryEmotion,
                  let intensity = p.intensity else {
                return EmotionalProfile(
                    primaryEmotion: "neutral",
                    intensity: 0.0,
                    triggers: [],
                    expectedDuration: 0.0,
                    stability: "unknown"
                )
            }
            return EmotionalProfile(
                primaryEmotion: primary,
                intensity: intensity,
                triggers: p.triggers ?? [],
                expectedDuration: p.expectedDuration ?? 0.0,
                stability: p.stability ?? "stable"
            )
        }()

        let memoryStatus: MemoryState = {
            guard let m = partial.memoryStatus,
                  let recent = m.recentMemories,
                  let consolidation = m.consolidationStatus,
                  let retrieval = m.retrievalEfficiency,
                  let formation = m.formationRate,
                  let associations = m.activeAssociations else {
                return MemoryState(
                    recentMemories: [],
                    consolidationStatus: "processing",
                    retrievalEfficiency: 0.5,
                    formationRate: 0.5,
                    activeAssociations: []
                )
            }
            return MemoryState(
                recentMemories: recent,
                consolidationStatus: consolidation,
                retrievalEfficiency: retrieval,
                formationRate: formation,
                activeAssociations: associations
            )
        }()

        return ConsciousnessState(
            awarenessLevel: awareness,
            activeProcesses: partial.activeProcesses ?? ["processing"],
            emotionalState: emotion,
            memoryStatus: memoryStatus,
            internalDialogue: partial.internalDialogue ?? ["Processing new input..."],
            confidence: conf,
            integrationQuality: partial.integrationQuality ?? 0.5,
            moralInsights: partial.moralInsights ?? [],
            logicalAnalysis: partial.logicalAnalysis ?? [],
            emergentPatterns: partial.emergentPatterns ?? []
        )
    }
    
    private func convertStructuredToConsciousnessState(_ result: StructuredConsciousnessResult) -> ConsciousnessState {
        return ConsciousnessState(
            awarenessLevel: result.synthesis.decisionConfidence,
            activeProcesses: ["moral_assessment", "logical_analysis", "consciousness_synthesis"],
            emotionalState: EmotionalProfile(
                primaryEmotion: result.valonAssessment.primaryEmotion.rawValue,
                intensity: result.valonAssessment.moralWeight,
                triggers: result.valonAssessment.moralConcerns,
                expectedDuration: 30.0,
                stability: "stable"
            ),
            memoryStatus: MemoryState(
                recentMemories: [result.originalInput],
                consolidationStatus: "consolidating",
                retrievalEfficiency: 0.8,
                formationRate: 0.7,
                activeAssociations: result.valonAssessment.activatedPrinciples.map { $0.rawValue }
            ),
            internalDialogue: [result.synthesis.consciousDecision],
            confidence: result.synthesis.decisionConfidence,
            integrationQuality: (result.synthesis.valonInfluence + result.synthesis.modiInfluence) / 2.0,
            moralInsights: [result.valonAssessment.moralGuidance] + result.valonAssessment.moralConcerns,
            logicalAnalysis: result.modiPattern.logicalInsights,
            emergentPatterns: result.synthesis.emergentInsights
        )
    }
    
    private func logConsciousnessUpdate(stimulus: String, state: ConsciousnessState) {
        let logEntry: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "stimulus": stimulus,
            "awareness_level": state.awarenessLevel,
            "primary_emotion": state.emotionalState.primaryEmotion,
            "emotional_intensity": state.emotionalState.intensity,
            "active_processes": state.activeProcesses,
            "confidence": state.confidence,
            "integration_quality": state.integrationQuality,
            "emergent_patterns": state.emergentPatterns
        ]
        
        // Log to entropy_logs directory (matching existing logging pattern)
        if let jsonData = try? JSONSerialization.data(withJSONObject: logEntry, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // Use existing logging infrastructure
            print("Consciousness Update: \(jsonString)")
        }
    }
}

// MARK: - Error Types

public enum ConsciousnessEngineError: Error, LocalizedError {
    case appleIntelligenceUnavailable
    case sessionInitializationFailed
    case processingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence not available - requires macOS 26+ with Apple Intelligence enabled"
        case .sessionInitializationFailed:
            return "Failed to initialize consciousness session"
        case .processingError(let reason):
            return "Consciousness processing failed: \(reason)"
        }
    }
}

// MARK: - Observable Extensions

@available(macOS 26.0, *)
extension ModernConsciousnessEngine {
    public var currentAwarenessLevel: Double {
        currentState?.awarenessLevel ?? 0.0
    }
    
    public var currentEmotionalState: String {
        currentState?.emotionalState.primaryEmotion ?? "unknown"
    }
    
    public var currentConfidence: Double {
        currentState?.confidence ?? 0.0
    }
    
    public var activeProcessesCount: Int {
        currentState?.activeProcesses.count ?? 0
    }
    
    public var integrationQuality: Double {
        currentState?.integrationQuality ?? 0.0
    }
}

// MARK: - Concurrency Adaptations

// The automatically generated PartiallyGenerated structures from FoundationModels
// do not declare Sendable conformance yet.  We add an unchecked conformance here
// so that they can safely cross concurrency boundaries inside streaming logic.

@available(macOS 26.0, *)
extension ModernConsciousnessEngine.ConsciousnessState.PartiallyGenerated: @unchecked Sendable {}

@available(macOS 26.0, *)
extension StructuredConsciousnessService: @unchecked Sendable {}

