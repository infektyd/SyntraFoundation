import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
public final class SyntraCore: ObservableObject {
    // AGENTS.md: Three-brain architecture - REAL IMPLEMENTATION
    private let valonEngine: ValonEngine
    private let modiEngine: ModiEngine
    private let driftMonitor: DriftMonitor
    private let config: SyntraConfig
    
    // AGENTS.md: Personality weights (70% Valon, 30% Modi)
    private let valonWeight: Double
    private let modiWeight: Double
    
    public init(config: SyntraConfig) {
        self.config = config
        self.valonWeight = config.driftRatio["valon"] ?? 0.7
        self.modiWeight = config.driftRatio["modi"] ?? 0.3
        
        // Rule 1: REAL implementation - NO STUBS
        self.valonEngine = ValonEngine(config: config)
        self.modiEngine = ModiEngine(config: config)
        self.driftMonitor = DriftMonitor(config: config)
    }
    
    public func processInput(
        _ input: String,
        context: SyntraContext
    ) async -> SyntraResponse {
        // AGENTS.md: Real consciousness processing
        let valonResponse = await valonEngine.processInput(input, context: context)
        let modiResponse = await modiEngine.processInput(input, context: context)
        
        // Three-brain synthesis with personality weighting
        let synthesizedContent = synthesizeResponses(
            valon: valonResponse,
            modi: modiResponse
        )
        
        // Monitor cognitive drift
        let driftScore = await driftMonitor.assessDrift(
            valonResponse: valonResponse,
            modiResponse: modiResponse,
            context: context
        )
        
        return SyntraResponse(
            content: synthesizedContent,
            valonInfluence: valonWeight,
            modiInfluence: modiWeight,
            driftScore: driftScore,
            timestamp: Date()
        )
    }
    
    private func synthesizeResponses(
        valon: ValonResponse,
        modi: ModiResponse
    ) -> String {
        // AGENTS.md: Real synthesis algorithm - respects weights
        let valonWeighted = valon.content.weight(valonWeight)
        let modiWeighted = modi.content.weight(modiWeight)
        
        return SyntraContentSynthesizer.combine(
            valonContent: valonWeighted,
            modiContent: modiWeighted,
            preserveMoralCore: true  // AGENTS.md: Immutable moral framework
        )
    }
}

// Supporting types - REAL IMPLEMENTATION
public struct ValonResponse {
    public let content: String
    public let moralAlignment: Double
    public let creativity: Double
    
    public init(content: String, moralAlignment: Double, creativity: Double) {
        self.content = content
        self.moralAlignment = moralAlignment
        self.creativity = creativity
    }
}

public struct ModiResponse {
    public let content: String
    public let logicalCoherence: Double
    public let factualAccuracy: Double
    
    public init(content: String, logicalCoherence: Double, factualAccuracy: Double) {
        self.content = content
        self.logicalCoherence = logicalCoherence
        self.factualAccuracy = factualAccuracy
    }
}

public struct WeightedContent {
    public let content: String
    public let weight: Double
    
    public init(content: String, weight: Double) {
        self.content = content
        self.weight = weight
    }
}

// String extension for consciousness weighting
private extension String {
    func weight(_ factor: Double) -> WeightedContent {
        return WeightedContent(content: self, weight: factor)
    }
} 