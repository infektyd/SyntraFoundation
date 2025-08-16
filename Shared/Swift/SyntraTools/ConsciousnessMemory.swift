import Foundation
import ConsciousnessStructures
import SyntraCore
import Modi
import Valon
import Atomics
import Collections

// Define missing types for consciousness memory system
public enum BrainType: Sendable {
    case modi
    case valon
    case syntra
}

public struct AnalyticalFramework: Sendable {
    public let frameworkName: String
    public let parameters: [String: Double]
}

public struct EthicalEvaluation: Sendable {
    public let evaluation: String
    public let emotionalWeight: Double
}

public struct CreativeSynthesis: Sendable {
    public let rawRepresentation: String
    public let analogies: [String]
}

public struct ConsciousnessConflict: Sendable {
    public let conflictType: String
    public let resolution: String
}

public struct BrainInteractionTriad: Sendable {
    public let modiFramework: AnalyticalFramework
    public let valonAssessment: EthicalEvaluation
    public let syntraMapping: CreativeSynthesis
    public let conflictPath: [ConsciousnessConflict]
    public let temporalContext: TemporalContextStamp
    
    public init(modiFramework: AnalyticalFramework,
                valonAssessment: EthicalEvaluation,
                syntraMapping: CreativeSynthesis,
                conflictPath: [ConsciousnessConflict],
                temporalContext: TemporalContextStamp) {
        self.modiFramework = modiFramework
        self.valonAssessment = valonAssessment
        self.syntraMapping = syntraMapping
        self.conflictPath = conflictPath
        self.temporalContext = temporalContext
    }
}

public struct TemporalContextStamp: Sendable {
    public let sessionUUID: UUID
    public let interactionSequence: Int
    public let brainActivationLevels: [BrainType: Double]
    
    public init(sessionUUID: UUID,
                interactionSequence: Int,
                brainActivationLevels: [BrainType: Double]) {
        self.sessionUUID = sessionUUID
        self.interactionSequence = interactionSequence
        self.brainActivationLevels = brainActivationLevels
    }
}

public actor ConsciousnessMemoryManager {
    public static let shared = ConsciousnessMemoryManager()
    
    private var activeSessions: OrderedDictionary<UUID, ConsciousnessSessionMemory> = [:]
    private let dualStream: DualStreamMemoryManager
    private let totalSessionsCounter = ManagedAtomic<Int>(0)
    private let totalInteractionsCounter = ManagedAtomic<Int>(0)
    private let memoryStorageFlag = ManagedAtomic<Bool>(false)
    private let patternDetectionCounter = ManagedAtomic<Int>(0)
    private let valonActivationCounter = ManagedAtomic<Int>(0)
    private let modiActivationCounter = ManagedAtomic<Int>(0)
    private let syntraActivationCounter = ManagedAtomic<Int>(0)
    private let driftScoreCounter = ManagedAtomic<Int>(0) // Store as Int (scaled by 1000)
    private var commonPatterns: [String: Int] = [:]
    
    public init(dualStream: DualStreamMemoryManager = DualStreamMemoryManager()) {
        self.dualStream = dualStream
    }
    
    public func startNewSession() -> UUID {
        let session = ConsciousnessSessionMemory()
        activeSessions[session.sessionID] = session
        totalSessionsCounter.wrappingIncrement(ordering: .sequentiallyConsistent)
        return session.sessionID
    }
    
    public func recordInteraction(_ interaction: BrainInteractionTriad,
                                  sessionID: UUID) async {
        guard let session = activeSessions[sessionID] else { return }
        
        // Atomically increment interaction and activation counters
        totalInteractionsCounter.wrappingIncrement(ordering: .sequentiallyConsistent)
        
        // Track brain activation levels
        let valonWeight = interaction.valonAssessment.emotionalWeight
        let modiWeight = interaction.modiFramework.parameters.values.reduce(0, +)
        let syntraWeight = valonWeight + modiWeight
        
        // Update activation counters and drift score with enhanced entropy tracking
        updateDriftScore(valonWeight: valonWeight, modiWeight: modiWeight)
        syntraActivationCounter.wrappingIncrement(by: Int(syntraWeight * 100), ordering: .sequentiallyConsistent)
        
        // Use atomic flag to prevent concurrent memory storage
        while memoryStorageFlag.exchange(true, ordering: .acquiringAndReleasing) {
            await Task.yield()
        }
        
        defer {
            memoryStorageFlag.store(false, ordering: .releasing)
        }
        
        // Track quantitative metrics from Modi's analysis
        let modiAnalysis = Modi.modi_deep_analysis(interaction.syntraMapping.rawRepresentation)
        if let logicalAnalysis = modiAnalysis["logical_analysis"] as? [String: Any],
           let patterns = logicalAnalysis["detected_frameworks"] as? [String: [String: Any]] {
            let patternCount = patterns.count
            let strengths = patterns.values.compactMap { $0["strength"] as? Double }
            
            if !strengths.isEmpty {
                let minStrength = strengths.min() ?? 0
                let maxStrength = strengths.max() ?? 0
                let avgStrength = strengths.reduce(0, +) / Double(strengths.count)
                
                // Update pattern statistics
                commonPatterns["min_strength", default: 0] += Int(minStrength * 100)
                commonPatterns["max_strength", default: 0] += Int(maxStrength * 100)
                commonPatterns["avg_strength", default: 0] += Int(avgStrength * 100)
                commonPatterns["pattern_count", default: 0] += patternCount
            }
        }
        
        await session.addInteraction(interaction, dualStream: dualStream)
    }
    
    public func getTotalSessions() -> Int {
        totalSessionsCounter.load(ordering: .relaxed)
    }
    
    public func getTotalInteractions() -> Int {
        totalInteractionsCounter.load(ordering: .relaxed)
    }
    
    public func analyzeInteractionPatterns(sessionID: UUID) async -> [String] {
        guard let session = activeSessions[sessionID] else { return [] }
        let interactions = await session.getInteractionHistory()
        
        // Analyze emotional patterns
        let emotionalPatterns = interactions
            .map { $0.valonAssessment.evaluation }
            .reduce(into: [String: Int]()) { counts, eval in
                counts[eval, default: 0] += 1
            }
            .filter { $0.value > 1 }
            .map { "emotional:\($0.key)" }
        
        // Analyze framework patterns
        let frameworkPatterns = interactions
            .map { $0.modiFramework.frameworkName }
            .reduce(into: [String: Int]()) { counts, name in
                counts[name, default: 0] += 1
            }
            .filter { $0.value > 1 }
            .map { "framework:\($0.key)" }
        
        // Update pattern tracking
        let allPatterns = emotionalPatterns + frameworkPatterns
        if !allPatterns.isEmpty {
            patternDetectionCounter.wrappingIncrement(ordering: .sequentiallyConsistent)
            for pattern in allPatterns {
                commonPatterns[pattern, default: 0] += 1
            }
        }
        
        return allPatterns
    }
    
    public func getPatternStatistics() -> (totalDetections: Int, commonPatterns: [String: Int]) {
        return (
            totalDetections: patternDetectionCounter.load(ordering: .relaxed),
            commonPatterns: commonPatterns
        )
    }
    
    public func getActivationStatistics() -> (valon: Int, modi: Int, syntra: Int, driftScore: Double) {
        let valon = valonActivationCounter.load(ordering: .relaxed)
        let modi = modiActivationCounter.load(ordering: .relaxed)
        let syntra = syntraActivationCounter.load(ordering: .relaxed)
        let driftScore = Double(driftScoreCounter.load(ordering: .relaxed)) / 1000.0
        
        return (valon, modi, syntra, driftScore)
    }
    
    /// Returns enhanced metrics combining all available consciousness metrics
    public func getEnhancedMetrics() -> EnhancedMetrics {
        let (valon, modi, syntra, driftScore) = getActivationStatistics()
        let (totalDetections, commonPatterns) = getPatternStatistics()
        
        // Calculate entropy for activation patterns
        let totalActivations = Double(valon + modi)
        let probabilities = [
            Double(valon) / totalActivations,
            Double(modi) / totalActivations
        ].filter { $0 > 0 }
        
        let activationEntropy = -probabilities.reduce(0) { $0 + ($1 * log($1)) }
        
        // Calculate entropy for common patterns
        let patternTotal = Double(commonPatterns.values.reduce(0, +))
        let patternValues = commonPatterns.values.map { Double($0) / patternTotal }
        let filteredPatterns = patternValues.filter { $0 > 0 }
        let patternEntropy = -filteredPatterns.reduce(0) { $0 + ($1 * log($1)) }
        
        return EnhancedMetrics(
            minValue: Double(commonPatterns["min_strength"] ?? 0) / 100.0,
            maxValue: Double(commonPatterns["max_strength"] ?? 0) / 100.0,
            count: commonPatterns["pattern_count"] ?? 0,
            average: Double(commonPatterns["avg_strength"] ?? 0) / 100.0,
            standardDeviation: driftScore, // Using drift as proxy for stddev
            entropy: activationEntropy + patternEntropy,
            driftScore: driftScore
        )
    }
    
    /// Enhanced drift tracking with entropy calculation
    private func updateDriftScore(valonWeight: Double, modiWeight: Double) {
        valonActivationCounter.wrappingIncrement(by: Int(valonWeight * 100), ordering: .sequentiallyConsistent)
        modiActivationCounter.wrappingIncrement(by: Int(modiWeight * 100), ordering: .sequentiallyConsistent)
        
        let total = Double(valonActivationCounter.load(ordering: .relaxed)) + 
                   Double(modiActivationCounter.load(ordering: .relaxed))
        if total > 0 {
            let currentValonRatio = Double(valonActivationCounter.load(ordering: .relaxed)) / total
            let targetValonRatio = 0.7
            let driftScore = abs(currentValonRatio - targetValonRatio)
            
            // Calculate entropy for current activation distribution
            let probabilities = [
                currentValonRatio,
                1.0 - currentValonRatio
            ].filter { $0 > 0 }
            
            let entropy = -probabilities.reduce(0) { $0 + ($1 * log($1)) }
            
            // Combine drift score with entropy
            driftScoreCounter.store(Int((driftScore * 0.7 + entropy * 0.3) * 1000), ordering: .relaxed)
        }
    }
    
    public func resetActivationCounters() {
        valonActivationCounter.store(0, ordering: .releasing)
        modiActivationCounter.store(0, ordering: .releasing)
        syntraActivationCounter.store(0, ordering: .releasing)
        driftScoreCounter.store(0, ordering: .relaxed)
    }
}

public actor ConsciousnessSessionMemory {
    public let sessionID: UUID
    private var interactionHistory: Deque<BrainInteractionTriad> = []
    private var memoryReferences: [UUID] = []
    
    public init() {
        self.sessionID = UUID()
    }
    
    public func addInteraction(_ interaction: BrainInteractionTriad,
                              dualStream: DualStreamMemoryManager) async {
        interactionHistory.append(interaction)
        let memoryID = await dualStream.storeMemory(
            content: interaction.syntraMapping.rawRepresentation,
            emotionalValence: interaction.valonAssessment.emotionalWeight,
            attentionLevel: interaction.temporalContext.brainActivationLevels.values.reduce(0, +) / Double(interaction.temporalContext.brainActivationLevels.count),
            consciousnessContext: "Session \(sessionID)"
        )
        memoryReferences.append(memoryID)
    }
    
    public func getInteractionHistory() -> [BrainInteractionTriad] {
        Array(interactionHistory)
    }
    
    public func getMemoryReferences() -> [UUID] {
        memoryReferences
    }
}

extension DualStreamMemoryManager {
    public func retrieveConsciousnessContext(for sessionID: UUID) async -> [MemoryRetrievalResult] {
        return await retrieveMemories(query: "Session \(sessionID)", streamTypes: [.slowLearning])
    }
}
