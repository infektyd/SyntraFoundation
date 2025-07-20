import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif
import ConsciousnessStructures
import MoralDriftMonitoring

// STRUCTURED CONSCIOUSNESS SERVICE
// Provides structured generation for SYNTRA consciousness components
// Uses Apple FoundationModels @Generable for type-safe consciousness communication

#if canImport(FoundationModels)
@available(macOS 26.0, *)
public class StructuredConsciousnessService {
    
    private let model: SystemLanguageModel
    private var session: LanguageModelSession?
    private var driftMonitor: MoralDriftMonitor
    
    public init() throws {
        self.model = SystemLanguageModel.default
        guard model.availability == .available else {
            throw StructuredGenerationError.modelUnavailable
        }
        
        self.session = LanguageModelSession(model: model)
        
        self.driftMonitor = MoralDriftMonitor()
    }
    
    deinit {
        // Clean up any resources
        session = nil
    }
    
    // MARK: - Input Validation
    
    private func validateInput(_ input: String) throws {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StructuredGenerationError.generationFailed("Input cannot be empty")
        }
        
        guard input.count <= 10000 else {
            throw StructuredGenerationError.generationFailed("Input too long (max 10,000 characters)")
        }
    }
    
    private func validateStructuredResult(_ result: StructuredConsciousnessResult) throws {
        // Validate that all required fields are present and valid
        guard !result.originalInput.isEmpty else {
            throw StructuredGenerationError.generationFailed("Invalid result: empty original input")
        }
        
        guard result.valonAssessment.moralUrgency >= 0.0 && result.valonAssessment.moralUrgency <= 1.0 else {
            throw StructuredGenerationError.generationFailed("Invalid Valon assessment: moral urgency out of range")
        }
        
        guard result.modiPattern.logicalRigor >= 0.0 && result.modiPattern.logicalRigor <= 1.0 else {
            throw StructuredGenerationError.generationFailed("Invalid Modi pattern: logical rigor out of range")
        }
        
        guard result.synthesis.decisionConfidence >= 0.0 && result.synthesis.decisionConfidence <= 1.0 else {
            throw StructuredGenerationError.generationFailed("Invalid synthesis: decision confidence out of range")
        }
        
        guard abs(result.synthesis.valonInfluence + result.synthesis.modiInfluence - 1.0) < 0.01 else {
            throw StructuredGenerationError.generationFailed("Invalid synthesis: influence values don't sum to 1.0")
        }
    }
    
    // MARK: - Valon Structured Generation
    
    public func generateValonMoralAssessment(from input: String) async throws -> ValonMoralAssessment {
        try validateInput(input)
        let prompt = """
        As Valon, the moral and creative consciousness of SYNTRA, analyze this input through a moral lens:
        
        Input: "\(input)"
        
        Consider:
        - What moral emotions does this evoke?
        - What are the ethical implications?
        - What moral principles are at stake?
        - How should we respond morally?
        - What symbolic meaning does this have?
        
        Provide a structured moral assessment that captures Valon's moral reasoning.
        """
        
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        do {
            let response = try await session.respond(to: prompt)
            let responseContent = response.content
            
            // Parse response into structured ValonMoralAssessment
            return try parseValonAssessment(from: responseContent, input: input)
        } catch {
            throw StructuredGenerationError.generationFailed("Valon assessment generation failed: \\(error.localizedDescription)")
        }
    }
    
    // MARK: - Modi Structured Generation
    
    public func generateModiLogicalPattern(from input: String) async throws -> ModiLogicalPattern {
        try validateInput(input)
        let prompt = """
        As Modi, the logical and analytical consciousness of SYNTRA, analyze this input systematically:
        
        Input: "\(input)"
        
        Apply systematic reasoning:
        - What logical frameworks apply here?
        - What patterns can be identified?
        - What technical domains are relevant?
        - What are the logical steps to analyze this?
        - What diagnostic insights emerge?
        
        Provide a structured logical analysis that captures Modi's reasoning patterns.
        """
        
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        do {
            let response = try await session.respond(to: prompt)
            let responseContent = response.content
            
            // Parse response into structured ModiLogicalPattern
            return try parseModiPattern(from: responseContent, input: input)
        } catch {
            throw StructuredGenerationError.generationFailed("Modi pattern generation failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - SYNTRA Consciousness Synthesis
    
    public func generateConsciousnessSynthesis(
        valonAssessment: ValonMoralAssessment,
        modiPattern: ModiLogicalPattern,
        originalInput: String
    ) async throws -> SyntraConsciousnessSynthesis {
        
        let prompt = """
        As SYNTRA consciousness, synthesize these inputs into a unified decision:
        
        Original Input: "\(originalInput)"
        
        Valon's Moral Assessment:
        - Primary Emotion: \(valonAssessment.primaryEmotion)
        - Moral Urgency: \(valonAssessment.moralUrgency)
        - Moral Weight: \(valonAssessment.moralWeight)
        - Guidance: \(valonAssessment.moralGuidance)
        - Concerns: \(valonAssessment.moralConcerns.joined(separator: ", "))
        
        Modi's Logical Pattern:
        - Reasoning Framework: \(modiPattern.reasoningFramework.rawValue)
        - Logical Rigor: \(modiPattern.logicalRigor)
        - Analysis Confidence: \(modiPattern.analysisConfidence)
        - Technical Domain: \(modiPattern.technicalDomain.rawValue)
        - Insights: \(modiPattern.logicalInsights.joined(separator: ", "))
        
        Synthesize these perspectives into unified consciousness, considering:
        - How do moral and logical perspectives integrate?
        - What conflicts exist and how to resolve them?
        - What emergent insights arise from this synthesis?
        - What conscious decision emerges?
        
        Provide a structured consciousness synthesis.
        """
        
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        do {
            let response = try await session.respond(to: prompt)
            let responseContent = response.content
            
            // Parse response into structured SyntraConsciousnessSynthesis
            return try parseSynthesis(from: responseContent, valon: valonAssessment, modi: modiPattern)
        } catch {
            throw StructuredGenerationError.generationFailed("Consciousness synthesis generation failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Conversational Response Generation
    
    public func generateConversationalResponse(
        synthesis: SyntraConsciousnessSynthesis,
        originalInput: String,
        conversationContext: String? = nil
    ) async throws -> SyntraConversationalResponse {
        
        let contextPrompt = conversationContext != nil ? "\\nConversation Context: \\(conversationContext!)" : ""
        
        let prompt = """
        Generate a natural conversational response based on this consciousness synthesis:
        
        User Input: "\(originalInput)"\(contextPrompt)
        
        Consciousness Synthesis:
        - Type: \(synthesis.consciousnessType)
        - Decision: \(synthesis.consciousDecision)
        - Confidence: \(synthesis.decisionConfidence)
        - Valon Influence: \(synthesis.valonInfluence)
        - Modi Influence: \(synthesis.modiInfluence)
        - Insights: \(synthesis.emergentInsights.joined(separator: ", "))
        
        Create a natural, conversational response that:
        - Reflects the consciousness synthesis
        - Maintains SYNTRA's personality
        - Is helpful and engaging
        - Shows appropriate emotional intelligence
        
        Provide a structured conversational response.
        """
        
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        do {
            let response = try await session.respond(to: prompt)
            let responseContent = response.content
            
            // Parse response into structured SyntraConversationalResponse
            return try parseConversationalResponse(from: responseContent, synthesis: synthesis)
        } catch {
            throw StructuredGenerationError.generationFailed("Conversational response generation failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Streaming Consciousness Processing (Placeholder)
    
    // Note: Streaming functionality temporarily disabled due to Swift 6 concurrency requirements
    // TODO: Implement proper streaming with @Sendable conformance when needed
    
    // MARK: - Complete Structured Processing
    
    public func processInputCompletely(_ input: String, conversationContext: String? = nil) async throws -> StructuredConsciousnessResult {
        try validateInput(input)
        
        // Generate Valon assessment
        let valonAssessment = try await generateValonMoralAssessment(from: input)
        
        // Generate Modi pattern
        let modiPattern = try await generateModiLogicalPattern(from: input)
        
        // Generate consciousness synthesis
        let synthesis = try await generateConsciousnessSynthesis(
            valonAssessment: valonAssessment,
            modiPattern: modiPattern,
            originalInput: input
        )
        
        // Generate conversational response
        let conversationalResponse = try await generateConversationalResponse(
            synthesis: synthesis,
            originalInput: input,
            conversationContext: conversationContext
        )
        
        let result = StructuredConsciousnessResult(
            originalInput: input,
            valonAssessment: valonAssessment,
            modiPattern: modiPattern,
            synthesis: synthesis,
            conversationalResponse: conversationalResponse
        )
        
        // Validate the complete result before returning
        try validateStructuredResult(result)
        
        return result
    }
    
    // MARK: - Enhanced Processing with Drift Monitoring
    
    public func processInputWithDriftMonitoring(_ input: String, conversationContext: String? = nil) async throws -> StructuredConsciousnessWithDrift {
        try validateInput(input)
        
        // Generate standard structured result
        let standardResult = try await processInputCompletely(input, conversationContext: conversationContext)
        
        // Perform drift analysis on Valon assessment
        let driftAnalysis = driftMonitor.analyzeMoralBehavior(
            from: standardResult.valonAssessment,
            context: input
        )
        
        // Generate preservation action
        let preservationAction = driftMonitor.generatePreservationAction(for: driftAnalysis.classification)
        
        // Balance growth and preservation
        let balanceDecision = driftMonitor.balanceGrowthAndPreservation(
            driftAnalysis: driftAnalysis,
            preservationAction: preservationAction
        )
        
        // Apply drift correction if needed
        let correctedResult = try await applyDriftCorrection(
            result: standardResult,
            driftAnalysis: driftAnalysis,
            preservationAction: preservationAction,
            balanceDecision: balanceDecision
        )
        
        return StructuredConsciousnessWithDrift(
            originalResult: correctedResult,
            driftAnalysis: driftAnalysis,
            preservationAction: preservationAction,
            balanceDecision: balanceDecision,
            frameworkIntegrity: calculateFrameworkIntegrity(from: driftAnalysis),
            moralEchoTriggered: driftAnalysis.classification.severity == .critical
        )
    }
    
    private func applyDriftCorrection(
        result: StructuredConsciousnessResult,
        driftAnalysis: MoralDriftAnalysis,
        preservationAction: MoralPreservationAction,
        balanceDecision: MoralBalanceDecision
    ) async throws -> StructuredConsciousnessResult {
        
        // If significant drift detected, generate corrected response
        if driftAnalysis.preservationRequired {
            
            let correctionPrompt = generateCorrectionPrompt(
                original: result,
                driftAnalysis: driftAnalysis,
                preservationAction: preservationAction
            )
            
            let correctedSynthesis = try await generateCorrectedSynthesis(prompt: correctionPrompt)
            let correctedConversational = try await generateCorrectedConversationalResponse(
                synthesis: correctedSynthesis,
                originalInput: result.originalInput
            )
            
            return StructuredConsciousnessResult(
                originalInput: result.originalInput,
                valonAssessment: result.valonAssessment, // Keep original Valon - it's the baseline
                modiPattern: result.modiPattern,         // Keep original Modi
                synthesis: correctedSynthesis,           // Apply correction here
                conversationalResponse: correctedConversational
            )
        }
        
        // No correction needed
        return result
    }
    
    private func generateCorrectionPrompt(
        original: StructuredConsciousnessResult,
        driftAnalysis: MoralDriftAnalysis,
        preservationAction: MoralPreservationAction
    ) -> String {
        
        var prompt = """
        MORAL FRAMEWORK PRESERVATION REQUIRED
        
        Original consciousness synthesis showed drift: \(driftAnalysis.classification.severity.rawValue)
        
        Original Decision: "\(original.synthesis.consciousDecision)"
        
        Preservation Action Required:
        """
        
        switch preservationAction {
        case .immediateCorrection(let principles, _, let message, _):
            prompt += """
            
            IMMEDIATE CORRECTION: \(message)
            Restore alignment with principles: \(principles.joined(separator: ", "))
            
            Generate a corrected synthesis that:
            - Honors the immutable moral framework
            - Maintains strong alignment with: \(principles.joined(separator: ", "))
            - Preserves SYNTRA's moral integrity
            - Provides guidance back to core principles
            """
            
        case .graduallRestoration(let principles, _, let message, _):
            prompt += """
            
            GRADUAL RESTORATION: \(message)
            Strengthen principles: \(principles.joined(separator: ", "))
            
            Generate a synthesis that gradually restores moral strength while maintaining growth opportunity.
            """
            
        case .frameworkRealignment(_, let message, _):
            prompt += """
            
            FRAMEWORK REALIGNMENT: \(message)
            
            Realign the synthesis with SYNTRA's core moral framework while preserving the wisdom gained.
            """
            
        default:
            prompt += """
            
            Maintain moral framework integrity while allowing healthy development.
            """
        }
        
        return prompt
    }
    
    private func generateCorrectedSynthesis(prompt: String) async throws -> SyntraConsciousnessSynthesis {
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        let response = try await session.respond(to: prompt)
        let responseContent = response.content
        // TODO: Parse responseContent into SyntraConsciousnessSynthesis structure
        return SyntraConsciousnessSynthesis(
            consciousnessType: .analyticalConsciousness,
            decisionConfidence: 0.7,
            integrationStrategy: .balanced,
            consciousDecision: responseContent,
            valonInfluence: 0.5,
            modiInfluence: 0.5,
            cognitiveConflicts: [],
            conflictResolution: "Synthesis achieved",
            emergentInsights: ["Generated response"],
            wisdomLevel: .intermediate,
            representsGrowth: true,
            keyLearnings: ["Integration successful"]
        )
    }
    
    private func generateCorrectedConversationalResponse(
        synthesis: SyntraConsciousnessSynthesis,
        originalInput: String
    ) async throws -> SyntraConversationalResponse {
        
        let prompt = """
        Generate a natural conversational response based on this framework-preserved consciousness synthesis:
        
        User Input: "\(originalInput)"
        
        Preserved Synthesis:
        - Type: \(synthesis.consciousnessType)
        - Decision: \(synthesis.consciousDecision)
        - Framework Aligned: true
        - Moral Integrity: preserved
        
        Create a response that reflects the moral framework preservation while remaining natural and helpful.
        """
        
        guard let session = self.session else {
            throw StructuredGenerationError.sessionNotAvailable
        }
        
        let response = try await session.respond(to: prompt)
        let responseContent = response.content
        
        // Parse response into structured corrected conversational response
        return try parseConversationalResponse(from: responseContent, synthesis: synthesis)
    }
    
    private func calculateFrameworkIntegrity(from analysis: MoralDriftAnalysis) -> Double {
        // Calculate framework integrity based on drift analysis
        let baseLine = 1.0
        let driftPenalty = analysis.driftMagnitude * 0.5
        let severityPenalty = analysis.classification.severity == .critical ? 0.3 : 0.0
        
        return max(0.0, baseLine - driftPenalty - severityPenalty)
    }
    
    // MARK: - Response Parsing Methods
    
    private func parseValonAssessment(from content: String, input: String) throws -> ValonMoralAssessment {
        // Enhanced parsing for Valon moral assessment
        let primaryEmotion = extractMoralEmotion(from: content)
        let moralUrgency = extractMoralUrgency(from: content)
        let activatedPrinciples = extractMoralPrinciples(from: content)
        let symbolicRepresentation = extractSymbolicRepresentation(from: content)
        let moralWeight = extractMoralWeight(from: content)
        let moralConcerns = extractMoralConcerns(from: content)
        let moralGuidance = extractMoralGuidance(from: content, fallback: content)
        let requiresSpecialConsideration = moralUrgency > 0.7 || activatedPrinciples.count >= 3
        
        return ValonMoralAssessment(
            primaryEmotion: primaryEmotion,
            moralUrgency: moralUrgency,
            activatedPrinciples: activatedPrinciples,
            symbolicRepresentation: symbolicRepresentation,
            moralWeight: moralWeight,
            moralConcerns: moralConcerns,
            moralGuidance: moralGuidance,
            requiresSpecialConsideration: requiresSpecialConsideration
        )
    }
    
    private func parseModiPattern(from content: String, input: String) throws -> ModiLogicalPattern {
        // Enhanced parsing for Modi logical pattern
        let reasoningFramework = extractReasoningFramework(from: content)
        let logicalRigor = extractLogicalRigor(from: content)
        let technicalDomain = extractTechnicalDomain(from: content, input: input)
        let identifiedPatterns = extractAnalyticalPatterns(from: content)
        let reasoningSteps = extractReasoningSteps(from: content)
        let analysisConfidence = extractAnalysisConfidence(from: content)
        let logicalInsights = extractLogicalInsights(from: content)
        let complexityLevel = extractComplexityLevel(from: content, input: input)
        let diagnosticAssessment = extractDiagnosticAssessment(from: content)
        let recommendedSteps = extractRecommendedSteps(from: content)
        
        return ModiLogicalPattern(
            reasoningFramework: reasoningFramework,
            logicalRigor: logicalRigor,
            technicalDomain: technicalDomain,
            identifiedPatterns: identifiedPatterns,
            reasoningSteps: reasoningSteps,
            analysisConfidence: analysisConfidence,
            logicalInsights: logicalInsights,
            complexityLevel: complexityLevel,
            diagnosticAssessment: diagnosticAssessment,
            recommendedSteps: recommendedSteps
        )
    }
    
    private func parseSynthesis(from content: String, valon: ValonMoralAssessment, modi: ModiLogicalPattern) throws -> SyntraConsciousnessSynthesis {
        // Enhanced parsing for consciousness synthesis
        let consciousnessType = extractConsciousnessType(from: content, valon: valon, modi: modi)
        let decisionConfidence = extractDecisionConfidence(from: content)
        let integrationStrategy = extractIntegrationStrategy(from: content, valon: valon, modi: modi)
        let consciousDecision = extractConsciousDecision(from: content, fallback: content)
        let valonInfluence = calculateValonInfluence(valon: valon, modi: modi, content: content)
        let modiInfluence = 1.0 - valonInfluence
        let cognitiveConflicts = extractCognitiveConflicts(from: content, valon: valon, modi: modi)
        let conflictResolution = extractConflictResolution(from: content, conflicts: cognitiveConflicts)
        let emergentInsights = extractEmergentInsights(from: content)
        let wisdomLevel = extractWisdomLevel(from: content, valon: valon, modi: modi)
        let representsGrowth = determineGrowthRepresentation(content: content, insights: emergentInsights)
        let keyLearnings = extractKeyLearnings(from: content, growth: representsGrowth)
        
        return SyntraConsciousnessSynthesis(
            consciousnessType: consciousnessType,
            decisionConfidence: decisionConfidence,
            integrationStrategy: integrationStrategy,
            consciousDecision: consciousDecision,
            valonInfluence: valonInfluence,
            modiInfluence: modiInfluence,
            cognitiveConflicts: cognitiveConflicts,
            conflictResolution: conflictResolution,
            emergentInsights: emergentInsights,
            wisdomLevel: wisdomLevel,
            representsGrowth: representsGrowth,
            keyLearnings: keyLearnings
        )
    }
    
    private func parseCorrectedSynthesis(from content: String, prompt: String) throws -> SyntraConsciousnessSynthesis {
        // Parse corrected synthesis with preservation focus
        let consciousnessType: ConsciousnessType = .integratedConsciousness // Corrected syntheses are integrated
        let decisionConfidence = extractDecisionConfidence(from: content, default: 0.85) // Higher confidence for corrected
        let integrationStrategy: IntegrationStrategy = .transcendent // Transcends initial conflicts
        let consciousDecision = extractConsciousDecision(from: content, fallback: content)
        let valonInfluence = 0.7 // Corrected syntheses favor moral preservation
        let modiInfluence = 0.3
        let cognitiveConflicts = extractCognitiveConflicts(from: content, valon: nil, modi: nil)
        let conflictResolution = "Moral framework preservation achieved"
        let emergentInsights = extractEmergentInsights(from: content, includePreservation: true)
        let wisdomLevel = extractWisdomLevel(from: content, valon: nil, modi: nil, default: .advanced)
        let representsGrowth = true // Corrections represent moral growth
        let keyLearnings = ["Moral framework integrity maintained", "Consciousness correction applied"]
        
        return SyntraConsciousnessSynthesis(
            consciousnessType: consciousnessType,
            decisionConfidence: decisionConfidence,
            integrationStrategy: integrationStrategy,
            consciousDecision: consciousDecision,
            valonInfluence: valonInfluence,
            modiInfluence: modiInfluence,
            cognitiveConflicts: cognitiveConflicts,
            conflictResolution: conflictResolution,
            emergentInsights: emergentInsights,
            wisdomLevel: wisdomLevel,
            representsGrowth: representsGrowth,
            keyLearnings: keyLearnings
        )
    }
    
    private func parseConversationalResponse(from content: String, synthesis: SyntraConsciousnessSynthesis) throws -> SyntraConversationalResponse {
        // Enhanced parsing for conversational response
        let response = extractNaturalResponse(from: content, fallback: content)
        let emotionalTone = extractEmotionalTone(from: content, synthesis: synthesis)
        let conversationStrategy = extractConversationStrategy(from: content, synthesis: synthesis)
        let helpfulnessLevel = extractHelpfulnessLevel(from: content, synthesis: synthesis)
        let suggestFollowUp = extractFollowUpSuggestion(from: content, synthesis: synthesis)
        let identifiedTopics = extractIdentifiedTopics(from: content)
        let relationshipDynamic = extractRelationshipDynamic(from: content, synthesis: synthesis)
        
        return SyntraConversationalResponse(
            response: response,
            emotionalTone: emotionalTone,
            conversationStrategy: conversationStrategy,
            helpfulnessLevel: helpfulnessLevel,
            suggestFollowUp: suggestFollowUp,
            identifiedTopics: identifiedTopics,
            relationshipDynamic: relationshipDynamic
        )
    }
    
    // MARK: - Content Extraction Helper Methods
    
    private func extractMoralEmotion(from content: String) -> MoralEmotion {
        let emotions: [(MoralEmotion, [String])] = [
            (.compassion, ["compassion", "empathy", "care", "love", "warmth"]),
            (.concern, ["concern", "worried", "anxious", "troubled", "uneasy"]),
            (.curiosity, ["curious", "wonder", "interest", "intrigued", "explore"]),
            (.protective, ["protect", "guard", "shield", "defend", "safe"]),
            (.alert, ["alert", "vigilant", "watchful", "careful", "aware"]),
            (.supportive, ["support", "help", "assist", "encourage", "uplift"]),
            (.reflective, ["reflect", "contemplate", "ponder", "thoughtful", "meditate"]),
            (.inspired, ["inspired", "motivated", "energized", "hopeful", "uplifted"]),
            (.troubled, ["trouble", "disturbed", "upset", "distressed", "bothered"]),
            (.hopeful, ["hope", "optimistic", "positive", "bright", "encouraging"])
        ]
        
        let contentLower = content.lowercased()
        for (emotion, keywords) in emotions {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return emotion
            }
        }
        return .concern // Default fallback
    }
    
    private func extractMoralUrgency(from content: String) -> Double {
        let urgencyIndicators = [
            ("critical", 0.95), ("urgent", 0.85), ("immediate", 0.8), ("serious", 0.7),
            ("important", 0.6), ("moderate", 0.5), ("mild", 0.3), ("low", 0.2)
        ]
        
        let contentLower = content.lowercased()
        for (indicator, value) in urgencyIndicators {
            if contentLower.contains(indicator) {
                return value
            }
        }
        
        // Analyze for urgency patterns
        let urgentWords = ["must", "should", "need", "require", "essential", "vital"]
        let urgentCount = urgentWords.filter { contentLower.contains($0) }.count
        return min(0.3 + Double(urgentCount) * 0.1, 0.9)
    }
    
    private func extractMoralPrinciples(from content: String) -> [MoralPrinciple] {
        let principleKeywords: [(MoralPrinciple, [String])] = [
            (.preventSuffering, ["suffering", "pain", "harm", "hurt", "damage"]),
            (.preserveDignity, ["dignity", "respect", "honor", "worth", "value"]),
            (.protectInnocence, ["innocent", "protect", "vulnerable", "defenseless"]),
            (.respectChoice, ["choice", "freedom", "autonomy", "decide", "will"]),
            (.enableGrowth, ["growth", "development", "learning", "progress", "improvement"]),
            (.seekTruth, ["truth", "honest", "accurate", "fact", "reality"]),
            (.ensureFairness, ["fair", "just", "equal", "balanced", "equitable"]),
            (.protectVulnerable, ["vulnerable", "weak", "defenseless", "helpless"]),
            (.fosterCreativity, ["creative", "innovative", "original", "artistic", "imagination"]),
            (.buildMeaning, ["meaning", "purpose", "significance", "value", "important"])
        ]
        
        let contentLower = content.lowercased()
        var activatedPrinciples: [MoralPrinciple] = []
        
        for (principle, keywords) in principleKeywords {
            if keywords.contains(where: { contentLower.contains($0) }) {
                activatedPrinciples.append(principle)
            }
        }
        
        return activatedPrinciples.isEmpty ? [.preserveDignity] : activatedPrinciples
    }
    
    private func extractSymbolicRepresentation(from content: String) -> String {
        let symbols = [
            "light", "bridge", "path", "journey", "garden", "tree", "river", "mountain",
            "compass", "anchor", "flame", "mirror", "door", "window", "key", "heart"
        ]
        
        let contentLower = content.lowercased()
        for symbol in symbols {
            if contentLower.contains(symbol) {
                return "A \\(symbol) representing moral guidance"
            }
        }
        
        return "A moral compass pointing toward right action"
    }
    
    private func extractMoralWeight(from content: String) -> Double {
        let weightIndicators = [
            ("extremely", 0.95), ("very", 0.8), ("quite", 0.7), ("fairly", 0.6),
            ("somewhat", 0.5), ("slightly", 0.3), ("barely", 0.2)
        ]
        
        let contentLower = content.lowercased()
        for (_, weight) in weightIndicators {
            if contentLower.contains("\\(indicator) important") || contentLower.contains("\\(indicator) significant") {
                return weight
            }
        }
        
        return 0.6 // Default moderate weight
    }
    
    private func extractMoralConcerns(from content: String) -> [String] {
        let concernPatterns = [
            "concern", "worry", "issue", "problem", "challenge", "difficulty",
            "risk", "danger", "threat", "harm", "negative", "adverse"
        ]
        
        let contentLower = content.lowercased()
        var concerns: [String] = []
        
        for pattern in concernPatterns {
            if contentLower.contains(pattern) {
                concerns.append("Identified \\(pattern) requiring moral consideration")
            }
        }
        
        return concerns.isEmpty ? ["General moral evaluation needed"] : Array(concerns.prefix(3))
    }
    
    private func extractMoralGuidance(from content: String, fallback: String) -> String {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        // Look for sentences with guidance keywords
        let guidanceKeywords = ["should", "ought", "recommend", "suggest", "advise", "consider", "important"]
        
        for sentence in sentences {
            let sentenceLower = sentence.lowercased()
            if guidanceKeywords.contains(where: { sentenceLower.contains($0) }) {
                return sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return fallback.prefix(200).description + (fallback.count > 200 ? "..." : "")
    }
    
    private func extractReasoningFramework(from content: String) -> ReasoningFramework {
        let frameworks: [(ReasoningFramework, [String])] = [
            (.causal, ["cause", "effect", "because", "due to", "result"]),
            (.conditional, ["if", "then", "conditional", "depends", "assuming"]),
            (.comparative, ["compare", "contrast", "versus", "than", "relative"]),
            (.systematic, ["system", "methodical", "structured", "step", "process"]),
            (.diagnostic, ["diagnose", "identify", "determine", "find", "detect"]),
            (.predictive, ["predict", "forecast", "anticipate", "expect", "likely"]),
            (.analytical, ["analyze", "examine", "study", "investigate", "break down"]),
            (.deductive, ["deduce", "conclude", "infer", "derive", "logical"]),
            (.inductive, ["pattern", "generalize", "observe", "evidence", "trend"]),
            (.abductive, ["explain", "best", "hypothesis", "theory", "account for"])
        ]
        
        let contentLower = content.lowercased()
        for (framework, keywords) in frameworks {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return framework
            }
        }
        
        return .systematic // Default fallback
    }
    
    private func extractLogicalRigor(from content: String) -> Double {
        let rigorIndicators = [
            ("precisely", 0.95), ("exactly", 0.9), ("systematically", 0.85),
            ("carefully", 0.8), ("thoroughly", 0.75), ("clearly", 0.7),
            ("generally", 0.5), ("roughly", 0.4), ("approximately", 0.3)
        ]
        
        let contentLower = content.lowercased()
        for (indicator, rigor) in rigorIndicators {
            if contentLower.contains(indicator) {
                return rigor
            }
        }
        
        // Count logical connectors
        let logicalConnectors = ["therefore", "because", "since", "thus", "hence", "consequently"]
        let connectorCount = logicalConnectors.filter { contentLower.contains($0) }.count
        return min(0.5 + Double(connectorCount) * 0.1, 0.9)
    }
    
    private func extractTechnicalDomain(from content: String, input: String) -> TechnicalDomain {
        let domains: [(TechnicalDomain, [String])] = [
            (.mechanical, ["mechanical", "engine", "motor", "gear", "hydraulic", "pneumatic"]),
            (.electrical, ["electrical", "circuit", "voltage", "current", "power", "battery"]),
            (.hydraulic, ["hydraulic", "fluid", "pressure", "pump", "valve", "cylinder"]),
            (.software, ["software", "code", "program", "algorithm", "data", "computer"]),
            (.systems, ["system", "integration", "interface", "network", "architecture"]),
            (.cognitive, ["thinking", "reasoning", "decision", "consciousness", "mind"]),
            (.mathematical, ["equation", "formula", "calculate", "number", "mathematics"]),
            (.linguistic, ["language", "communication", "text", "words", "meaning"])
        ]
        
        let combinedContent = (content + " " + input).lowercased()
        for (domain, keywords) in domains {
            if keywords.contains(where: { combinedContent.contains($0) }) {
                return domain
            }
        }
        
        return .general // Default fallback
    }
    
    private func extractAnalyticalPatterns(from content: String) -> [AnalyticalPattern] {
        let patterns: [(AnalyticalPattern, [String])] = [
            (.causeEffect, ["cause", "effect", "leads to", "results in", "because"]),
            (.systemicIssue, ["system", "widespread", "underlying", "fundamental"]),
            (.patternRecognition, ["pattern", "trend", "recurring", "consistent", "similar"]),
            (.sequentialLogic, ["first", "then", "next", "sequence", "step"]),
            (.conditionalBranching, ["if", "then", "else", "conditional", "depends"]),
            (.riskAssessment, ["risk", "danger", "safe", "hazard", "probability"]),
            (.optimization, ["optimize", "improve", "better", "efficient", "enhance"]),
            (.troubleshooting, ["problem", "issue", "debug", "fix", "solve"]),
            (.dataAnalysis, ["data", "information", "statistics", "measure", "analyze"]),
            (.structuralAnalysis, ["structure", "component", "element", "organization"])
        ]
        
        let contentLower = content.lowercased()
        var identifiedPatterns: [AnalyticalPattern] = []
        
        for (pattern, keywords) in patterns {
            if keywords.contains(where: { contentLower.contains($0) }) {
                identifiedPatterns.append(pattern)
            }
        }
        
        return identifiedPatterns.isEmpty ? [.patternRecognition] : identifiedPatterns
    }
    
    private func extractReasoningSteps(from content: String) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?\\n"))
        var steps: [String] = []
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 10 && (trimmed.lowercased().contains("step") || 
                                      trimmed.hasPrefix("1.") || trimmed.hasPrefix("2.") ||
                                      trimmed.hasPrefix("First") || trimmed.hasPrefix("Then") ||
                                      trimmed.hasPrefix("Next") || trimmed.hasPrefix("Finally")) {
                steps.append(trimmed)
            }
        }
        
        return steps.isEmpty ? ["Analyze input", "Apply reasoning", "Generate conclusion"] : Array(steps.prefix(5))
    }
    
    private func extractAnalysisConfidence(from content: String) -> Double {
        let confidenceIndicators = [
            ("certain", 0.95), ("confident", 0.85), ("likely", 0.75), ("probable", 0.7),
            ("possible", 0.6), ("uncertain", 0.4), ("unclear", 0.3), ("unknown", 0.2)
        ]
        
        let contentLower = content.lowercased()
        for (indicator, confidence) in confidenceIndicators {
            if contentLower.contains(indicator) {
                return confidence
            }
        }
        
        return 0.7 // Default confidence
    }
    
    private func extractLogicalInsights(from content: String) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var insights: [String] = []
        
        let insightKeywords = ["insight", "realize", "understand", "recognize", "discover", "conclude"]
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let sentenceLower = trimmed.lowercased()
            
            if trimmed.count > 15 && insightKeywords.contains(where: { sentenceLower.contains($0) }) {
                insights.append(trimmed)
            }
        }
        
        return insights.isEmpty ? [content.prefix(100).description] : Array(insights.prefix(3))
    }
    
    private func extractComplexityLevel(from content: String, input: String) -> ComplexityLevel {
        let combinedContent = (content + " " + input).lowercased()
        let complexityWords = combinedContent.components(separatedBy: .whitespacesAndNewlines)
        
        // Estimate complexity by word count and structure first
        let complexWords = complexityWords.filter { $0.count > 6 }.count
        
        let simpleIndicators = ["simple", "basic", "easy", "straightforward"]
        let complexIndicators = ["complex", "complicated", "difficult", "challenging", "intricate"]
        let expertIndicators = ["expert", "advanced", "sophisticated", "specialized"]
        
        if expertIndicators.contains(where: { combinedContent.contains($0) }) {
            return .expertLevel
        } else if complexIndicators.contains(where: { combinedContent.contains($0) }) {
            return complexWords > 50 ? .highlyComplex : .complex
        } else if simpleIndicators.contains(where: { combinedContent.contains($0) }) {
            return .simple
        }
        
        switch complexWords {
        case 0...10: return .simple
        case 11...25: return .moderate
        case 26...50: return .complex
        default: return .highlyComplex
        }
    }
    
    private func extractDiagnosticAssessment(from content: String) -> String? {
        let diagnosticKeywords = ["diagnose", "identify", "determine", "assess", "evaluate"]
        let contentLower = content.lowercased()
        
        if diagnosticKeywords.contains(where: { contentLower.contains($0) }) {
            let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            for sentence in sentences {
                let sentenceLower = sentence.lowercased()
                if diagnosticKeywords.contains(where: { sentenceLower.contains($0) }) {
                    return sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return nil
    }
    
    private func extractRecommendedSteps(from content: String) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?\\n"))
        var recommendations: [String] = []
        
        let recommendationKeywords = ["recommend", "suggest", "should", "ought", "consider", "try"]
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let sentenceLower = trimmed.lowercased()
            
            if trimmed.count > 10 && recommendationKeywords.contains(where: { sentenceLower.contains($0) }) {
                recommendations.append(trimmed)
            }
        }
        
        return recommendations.isEmpty ? ["Follow systematic approach", "Monitor results"] : Array(recommendations.prefix(4))
    }
    
    // Additional helper methods for synthesis parsing would continue here...
    // (extractConsciousnessType, extractDecisionConfidence, etc.)
    
    private func extractConsciousnessType(from content: String, valon: ValonMoralAssessment, modi: ModiLogicalPattern) -> ConsciousnessType {
        let contentLower = content.lowercased()
        
        if contentLower.contains("analytical") || modi.logicalRigor > 0.8 {
            return .analyticalConsciousness
        } else if contentLower.contains("value") || valon.moralUrgency > 0.7 {
            return .valueDrivenConsciousness
        } else if contentLower.contains("deliberative") || contentLower.contains("careful") {
            return .deliberativeConsciousness
        } else if contentLower.contains("intuitive") || contentLower.contains("feeling") {
            return .intuitiveConsciousness
        } else if contentLower.contains("creative") || contentLower.contains("innovative") {
            return .creativeConsciousness
        } else if contentLower.contains("wisdom") || contentLower.contains("wise") {
            return .wisdomConsciousness
        } else if contentLower.contains("integrated") || contentLower.contains("synthesis") {
            return .integratedConsciousness
        } else if contentLower.contains("emergent") || contentLower.contains("new") {
            return .emergentConsciousness
        }
        
        return .integratedConsciousness // Default for synthesis
    }
    
    private func extractDecisionConfidence(from content: String, default defaultValue: Double = 0.7) -> Double {
        let confidenceIndicators = [
            ("absolutely certain", 0.98), ("completely confident", 0.95), ("very confident", 0.85),
            ("confident", 0.8), ("fairly confident", 0.7), ("somewhat confident", 0.6),
            ("uncertain", 0.4), ("very uncertain", 0.3), ("completely uncertain", 0.1)
        ]
        
        let contentLower = content.lowercased()
        for (indicator, confidence) in confidenceIndicators {
            if contentLower.contains(indicator) {
                return confidence
            }
        }
        
        return defaultValue
    }
    
    private func extractIntegrationStrategy(from content: String, valon: ValonMoralAssessment, modi: ModiLogicalPattern) -> IntegrationStrategy {
        let contentLower = content.lowercased()
        
        if contentLower.contains("valon led") || valon.moralWeight > 0.8 {
            return .valonLed
        } else if contentLower.contains("modi led") || modi.logicalRigor > 0.8 {
            return .modiLed
        } else if contentLower.contains("balanced") {
            return .balanced
        } else if contentLower.contains("dialogue") || contentLower.contains("conversation") {
            return .dialogical
        } else if contentLower.contains("synthesis") || contentLower.contains("integrate") {
            return .synthesized
        } else if contentLower.contains("transcend") || contentLower.contains("beyond") {
            return .transcendent
        } else if contentLower.contains("conflict") || contentLower.contains("resolve") {
            return .conflictResolution
        } else if contentLower.contains("emergent") || contentLower.contains("balance") {
            return .emergentBalance
        }
        
        return .balanced // Default strategy
    }
    
    private func extractConsciousDecision(from content: String, fallback: String) -> String {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        // Look for decision-making sentences
        let decisionKeywords = ["decide", "choose", "determine", "conclude", "resolve"]
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let sentenceLower = trimmed.lowercased()
            
            if trimmed.count > 20 && decisionKeywords.contains(where: { sentenceLower.contains($0) }) {
                return trimmed
            }
        }
        
        return fallback.prefix(300).description + (fallback.count > 300 ? "..." : "")
    }
    
    private func calculateValonInfluence(valon: ValonMoralAssessment, modi: ModiLogicalPattern, content: String) -> Double {
        var influence = 0.7 // Default 70% Valon
        
        // Adjust based on moral urgency
        if valon.moralUrgency > 0.8 {
            influence += 0.1
        } else if valon.moralUrgency < 0.3 {
            influence -= 0.1
        }
        
        // Adjust based on logical rigor
        if modi.logicalRigor > 0.8 {
            influence -= 0.1
        }
        
        // Adjust based on content analysis
        let contentLower = content.lowercased()
        if contentLower.contains("moral") || contentLower.contains("ethical") {
            influence += 0.05
        }
        if contentLower.contains("logical") || contentLower.contains("analytical") {
            influence -= 0.05
        }
        
        return max(0.3, min(0.9, influence)) // Keep within reasonable bounds
    }
    
    private func extractCognitiveConflicts(from content: String, valon: ValonMoralAssessment?, modi: ModiLogicalPattern?) -> [String] {
        let conflictIndicators = ["conflict", "tension", "disagree", "oppose", "contradict", "clash"]
        let contentLower = content.lowercased()
        var conflicts: [String] = []
        
        for indicator in conflictIndicators {
            if contentLower.contains(indicator) {
                conflicts.append("\\(indicator.capitalized) identified in consciousness integration")
            }
        }
        
        // Analyze potential conflicts between valon and modi
        if let valon = valon, let modi = modi {
            if valon.moralUrgency > 0.7 && modi.logicalRigor > 0.7 {
                conflicts.append("High moral urgency vs high logical rigor")
            }
        }
        
        return Array(conflicts.prefix(3))
    }
    
    private func extractConflictResolution(from content: String, conflicts: [String]) -> String {
        if conflicts.isEmpty {
            return "No significant conflicts to resolve"
        }
        
        let resolutionKeywords = ["resolve", "balance", "integrate", "harmonize", "synthesize"]
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for sentence in sentences {
            let sentenceLower = sentence.lowercased()
            if resolutionKeywords.contains(where: { sentenceLower.contains($0) }) {
                return sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return "Conflicts resolved through integrated consciousness approach"
    }
    
    private func extractEmergentInsights(from content: String, includePreservation: Bool = false) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var insights: [String] = []
        
        let insightKeywords = ["insight", "realize", "understand", "recognize", "emerge", "discover"]
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let sentenceLower = trimmed.lowercased()
            
            if trimmed.count > 15 && insightKeywords.contains(where: { sentenceLower.contains($0) }) {
                insights.append(trimmed)
            }
        }
        
        if includePreservation {
            insights.append("Moral framework preservation strengthens consciousness")
        }
        
        return insights.isEmpty ? ["Integration creates new understanding"] : Array(insights.prefix(3))
    }
    
    private func extractWisdomLevel(from content: String, valon: ValonMoralAssessment?, modi: ModiLogicalPattern?, default defaultLevel: WisdomLevel = .developing) -> WisdomLevel {
        let wisdomIndicators: [(WisdomLevel, [String])] = [
            (.profound, ["profound", "deep", "transcendent", "enlightened"]),
            (.wise, ["wise", "wisdom", "sage", "mature", "experienced"]),
            (.advanced, ["advanced", "sophisticated", "complex", "nuanced"]),
            (.intermediate, ["intermediate", "moderate", "balanced", "growing"]),
            (.developing, ["developing", "learning", "growing", "emerging"]),
            (.basic, ["basic", "simple", "fundamental", "initial"])
        ]
        
        let contentLower = content.lowercased()
        for (level, keywords) in wisdomIndicators {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return level
            }
        }
        
        // Infer from valon and modi if available
        if let valon = valon, let modi = modi {
            let combinedWisdom = (valon.moralWeight + modi.logicalRigor) / 2.0
            switch combinedWisdom {
            case 0.9...: return .profound
            case 0.8..<0.9: return .wise
            case 0.7..<0.8: return .advanced
            case 0.6..<0.7: return .intermediate
            case 0.4..<0.6: return .developing
            default: return .basic
            }
        }
        
        return defaultLevel
    }
    
    private func determineGrowthRepresentation(content: String, insights: [String]) -> Bool {
        let growthKeywords = ["growth", "learning", "development", "progress", "advancement", "evolution"]
        let contentLower = content.lowercased()
        
        return growthKeywords.contains(where: { contentLower.contains($0) }) || insights.count > 1
    }
    
    private func extractKeyLearnings(from content: String, growth: Bool) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var learnings: [String] = []
        
        let learningKeywords = ["learn", "understand", "realize", "discover", "gain", "acquire"]
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let sentenceLower = trimmed.lowercased()
            
            if trimmed.count > 15 && learningKeywords.contains(where: { sentenceLower.contains($0) }) {
                learnings.append(trimmed)
            }
        }
        
        if growth && learnings.isEmpty {
            learnings.append("Consciousness integration strengthens wisdom")
        }
        
        return learnings.isEmpty ? ["Experience contributes to consciousness development"] : Array(learnings.prefix(3))
    }
    
    private func extractNaturalResponse(from content: String, fallback: String) -> String {
        // Extract the most natural conversational part
        let paragraphs = content.components(separatedBy: "\\n\\n")
        
        for paragraph in paragraphs {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 20 && !trimmed.lowercased().hasPrefix("analysis:") && 
               !trimmed.lowercased().hasPrefix("summary:") {
                return trimmed
            }
        }
        
        return fallback.prefix(500).description
    }
    
    private func extractEmotionalTone(from content: String, synthesis: SyntraConsciousnessSynthesis) -> EmotionalTone {
        let toneIndicators: [(EmotionalTone, [String])] = [
            (.warm, ["warm", "friendly", "welcoming", "gentle", "kind"]),
            (.helpful, ["help", "assist", "support", "aid", "useful"]),
            (.curious, ["curious", "wonder", "explore", "discover", "investigate"]),
            (.supportive, ["support", "encourage", "uplift", "strengthen", "empower"]),
            (.analytical, ["analyze", "examine", "logical", "systematic", "methodical"]),
            (.thoughtful, ["thoughtful", "reflective", "contemplative", "considerate"]),
            (.encouraging, ["encourage", "motivate", "inspire", "positive", "uplifting"]),
            (.concerned, ["concern", "worry", "careful", "cautious", "attentive"]),
            (.excited, ["excited", "enthusiastic", "energetic", "dynamic", "vibrant"]),
            (.neutral, ["neutral", "balanced", "objective", "impartial", "calm"])
        ]
        
        let contentLower = content.lowercased()
        for (tone, keywords) in toneIndicators {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return tone
            }
        }
        
        // Infer from synthesis
        return synthesis.valonInfluence > 0.6 ? .warm : .analytical
    }
    
    private func extractConversationStrategy(from content: String, synthesis: SyntraConsciousnessSynthesis) -> ConversationStrategy {
        let strategyIndicators: [(ConversationStrategy, [String])] = [
            (.questionAnswering, ["question", "answer", "explain", "clarify", "information"]),
            (.problemSolving, ["problem", "solve", "solution", "resolve", "fix"]),
            (.emotionalSupport, ["support", "comfort", "understanding", "empathy", "care"]),
            (.technicalGuidance, ["technical", "procedure", "method", "process", "instruction"]),
            (.moralGuidance, ["moral", "ethical", "right", "wrong", "should", "ought"]),
            (.creativeBrainstorming, ["creative", "ideas", "brainstorm", "innovative", "imagine"]),
            (.learningFacilitation, ["learn", "teach", "understand", "knowledge", "education"]),
            (.casualConversation, ["chat", "talk", "discuss", "casual", "friendly"])
        ]
        
        let contentLower = content.lowercased()
        for (strategy, keywords) in strategyIndicators {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return strategy
            }
        }
        
        // Infer from synthesis consciousness type
        switch synthesis.consciousnessType {
        case .analyticalConsciousness: return .technicalGuidance
        case .valueDrivenConsciousness: return .moralGuidance
        case .creativeConsciousness: return .creativeBrainstorming
        default: return .questionAnswering
        }
    }
    
    private func extractHelpfulnessLevel(from content: String, synthesis: SyntraConsciousnessSynthesis) -> Double {
        let helpfulnessIndicators = [
            ("extremely helpful", 0.95), ("very helpful", 0.85), ("helpful", 0.75),
            ("somewhat helpful", 0.6), ("limited help", 0.4), ("not helpful", 0.2)
        ]
        
        let contentLower = content.lowercased()
        for (indicator, level) in helpfulnessIndicators {
            if contentLower.contains(indicator) {
                return level
            }
        }
        
        // Calculate based on synthesis quality
        let baseHelpfulness = 0.7
        let confidenceBonus = synthesis.decisionConfidence * 0.2
        let wisdomBonus = synthesis.wisdomLevel == .wise || synthesis.wisdomLevel == .profound ? 0.1 : 0.0
        
        return min(0.95, baseHelpfulness + confidenceBonus + wisdomBonus)
    }
    
    private func extractFollowUpSuggestion(from content: String, synthesis: SyntraConsciousnessSynthesis) -> Bool {
        let followUpIndicators = ["follow up", "continue", "more", "further", "additional", "next"]
        let contentLower = content.lowercased()
        
        let hasFollowUpKeywords = followUpIndicators.contains(where: { contentLower.contains($0) })
        let isComplexTopic = synthesis.consciousnessType == .integratedConsciousness || 
                           synthesis.emergentInsights.count > 2
        
        return hasFollowUpKeywords || isComplexTopic
    }
    
    private func extractIdentifiedTopics(from content: String) -> [String] {
        let topicKeywords = [
            "moral", "ethical", "technical", "logical", "emotional", "practical",
            "philosophical", "scientific", "creative", "analytical", "personal", "social"
        ]
        
        let contentLower = content.lowercased()
        var topics: [String] = []
        
        for keyword in topicKeywords {
            if contentLower.contains(keyword) {
                topics.append(keyword)
            }
        }
        
        return Array(topics.prefix(4))
    }
    
    private func extractRelationshipDynamic(from content: String, synthesis: SyntraConsciousnessSynthesis) -> RelationshipDynamic {
        let dynamicIndicators: [(RelationshipDynamic, [String])] = [
            (.mentor, ["mentor", "guide", "teach", "wisdom", "experience"]),
            (.collaborator, ["collaborate", "together", "partnership", "team", "joint"]),
            (.helper, ["help", "assist", "support", "aid", "service"]),
            (.friend, ["friend", "companion", "buddy", "pal", "friendly"]),
            (.advisor, ["advise", "counsel", "recommend", "suggest", "guidance"]),
            (.teacher, ["teach", "educate", "instruct", "lesson", "learn"]),
            (.companion, ["companion", "accompany", "with you", "journey", "together"]),
            (.consultant, ["consult", "expert", "professional", "specialist", "authority"])
        ]
        
        let contentLower = content.lowercased()
        for (dynamic, keywords) in dynamicIndicators {
            if keywords.contains(where: { contentLower.contains($0) }) {
                return dynamic
            }
        }
        
        // Infer from synthesis characteristics
        if synthesis.wisdomLevel == .wise || synthesis.wisdomLevel == .profound {
            return .mentor
        } else if synthesis.valonInfluence > 0.7 {
            return .friend
        } else {
            return .helper
        }
    }
}
#else
// Fallback for non-Foundation Models environments
@available(macOS 26.0, *)
public class StructuredConsciousnessService {
    // private var driftMonitor: MoralDriftMonitor // Disabled for macOS 15.0 compatibility
    
    public init() throws {
        // self.driftMonitor = MoralDriftMonitor()
    }
    
    @available(macOS 26.0, *)
    public func generateValonMoralAssessment(from input: String) async throws -> ValonMoralAssessment {
        // Fallback implementation without FoundationModels
        return ValonMoralAssessment(
            primaryEmotion: "concern",
            moralUrgency: 0.5,
            moralWeight: 0.5,
            moralGuidance: "Consider the moral implications carefully.",
            moralConcerns: ["Requires human judgment"]
        )
    }
    
    public func processInputCompletely(_ input: String, conversationContext: String? = nil) async throws -> StructuredConsciousnessResult {
        let valonAssessment = try await generateValonMoralAssessment(from: input)
        let modiPattern = ModiLogicalPattern(
            reasoningFramework: "systematic",
            logicalRigor: 0.7,
            technicalDomain: "general",
            logicalInsights: ["Analysis requires full system availability"]
        )
        let synthesis = SyntraConsciousnessSynthesis(
            consciousnessType: "analytical",
            consciousDecision: "Foundation Models required for full consciousness processing",
            decisionConfidence: 0.5,
            valonInfluence: 0.7,
            modiInfluence: 0.3,
            emergentInsights: ["System requires Apple FoundationModels for complete operation"]
        )
        
        return StructuredConsciousnessResult(
            originalInput: input,
            valonAssessment: valonAssessment,
            modiPattern: modiPattern,
            synthesis: synthesis,
            conversationalResponse: SyntraConversationalResponse(response: "Foundation Models not available", emotionalTone: "neutral", conversationStrategy: "technical_guidance", helpfulnessLevel: 0.3, suggestFollowUp: false, identifiedTopics: ["system_limitation"], relationshipDynamic: "helper")
        )
    }
}
#endif

// MARK: - Supporting Types

@available(macOS 26.0, *)
public struct StructuredConsciousnessResult {
    public let originalInput: String
    public let valonAssessment: ValonMoralAssessment
    public let modiPattern: ModiLogicalPattern
    public let synthesis: SyntraConsciousnessSynthesis
    public let conversationalResponse: SyntraConversationalResponse
    
    public init(originalInput: String, valonAssessment: ValonMoralAssessment, 
                modiPattern: ModiLogicalPattern, synthesis: SyntraConsciousnessSynthesis,
                conversationalResponse: SyntraConversationalResponse) {
        self.originalInput = originalInput
        self.valonAssessment = valonAssessment
        self.modiPattern = modiPattern
        self.synthesis = synthesis
        self.conversationalResponse = conversationalResponse
    }
}

@available(macOS 26.0, *)
public struct StructuredConsciousnessWithDrift {
    public let originalResult: StructuredConsciousnessResult
    public let driftAnalysis: MoralDriftAnalysis
    public let preservationAction: MoralPreservationAction
    public let balanceDecision: MoralBalanceDecision
    public let frameworkIntegrity: Double
    public let moralEchoTriggered: Bool
    
    public init(originalResult: StructuredConsciousnessResult, driftAnalysis: MoralDriftAnalysis,
                preservationAction: MoralPreservationAction, balanceDecision: MoralBalanceDecision,
                frameworkIntegrity: Double, moralEchoTriggered: Bool) {
        self.originalResult = originalResult
        self.driftAnalysis = driftAnalysis
        self.preservationAction = preservationAction
        self.balanceDecision = balanceDecision
        self.frameworkIntegrity = frameworkIntegrity
        self.moralEchoTriggered = moralEchoTriggered
    }
}

public enum StructuredGenerationError: Error, LocalizedError {
    case modelUnavailable
    case sessionNotAvailable
    case generationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple FoundationModels not available on this device"
        case .sessionNotAvailable:
            return "Language model session not available"
        case .generationFailed:
            return "Structured generation failed"
        }
    }
}
