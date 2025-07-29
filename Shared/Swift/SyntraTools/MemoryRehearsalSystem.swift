import Foundation
import FoundationModels
import OSLog
import ConsciousnessStructures

// MEMORY REHEARSAL AND REPLAY SYSTEM
// Implements biological rehearsal strategies for AI consciousness
// Prevents forgetting through strategic memory reactivation and pattern replay

// MARK: - Rehearsal Strategy Types

@available(macOS 26.0, *)
@Generable
public enum RehearsalStrategy: String, Codable, CaseIterable {
    case distributedPractice = "distributed_practice"     // Spaced repetition over time
    case massedPractice = "massed_practice"               // Intensive rehearsal in short period
    case elaborativeRehearsal = "elaborative_rehearsal"   // Deep processing with associations
    case maintenanceRehearsal = "maintenance_rehearsal"   // Simple repetition for retention
    case interleaving = "interleaving"                    // Mixed practice of different concepts
    case variableEncoding = "variable_encoding"           // Multiple encoding contexts
    case generativeReplay = "generative_replay"           // AI generates new examples
    case contrastiveReplay = "contrastive_replay"         // Highlighting differences
}

@available(macOS 26.0, *)
@Generable
public struct RehearsalSession {
    @Guide(description: "Unique identifier for this rehearsal session")
    public let sessionId: UUID
    
    @Guide(description: "Strategy used for this rehearsal")
    public let strategy: RehearsalStrategy
    
    @Guide(description: "Memory traces rehearsed in this session")
    public let rehearsedMemories: [UUID]
    
    @Guide(description: "Duration of the rehearsal session in minutes")
    public let duration: Double
    
    @Guide(description: "Effectiveness score from 0.0 to 1.0")
    public let effectiveness: Double
    
    @Guide(description: "Retention improvement achieved")
    public let retentionImprovement: Double
    
    @Guide(description: "When this rehearsal session occurred")
    public let timestamp: Date
    
    @Guide(description: "Context in which rehearsal occurred")
    public let rehearsalContext: RehearsalContext
    
    public init(sessionId: UUID = UUID(), strategy: RehearsalStrategy, rehearsedMemories: [UUID], 
                duration: Double, effectiveness: Double, retentionImprovement: Double, 
                timestamp: Date = Date(), rehearsalContext: RehearsalContext) {
        self.sessionId = sessionId
        self.strategy = strategy
        self.rehearsedMemories = rehearsedMemories
        self.duration = duration
        self.effectiveness = effectiveness
        self.retentionImprovement = retentionImprovement
        self.timestamp = timestamp
        self.rehearsalContext = rehearsalContext
    }
}

@available(macOS 26.0, *)
@Generable
public struct RehearsalContext {
    @Guide(description: "Consciousness state during rehearsal")
    public let consciousnessState: String
    
    @Guide(description: "Attention level during rehearsal")
    public let attentionLevel: Double
    
    @Guide(description: "Environmental factors affecting rehearsal")
    public let environmentalFactors: [String]
    
    @Guide(description: "Motivation level for rehearsal")
    public let motivationLevel: Double
    
    public init(consciousnessState: String, attentionLevel: Double, environmentalFactors: [String], motivationLevel: Double) {
        self.consciousnessState = consciousnessState
        self.attentionLevel = attentionLevel
        self.environmentalFactors = environmentalFactors
        self.motivationLevel = motivationLevel
    }
}

// MARK: - Memory Replay Patterns

@available(macOS 26.0, *)
@Generable
public struct ReplayPattern {
    @Guide(description: "Unique identifier for this replay pattern")
    public let patternId: UUID
    
    @Guide(description: "Type of replay pattern")
    public let patternType: ReplayPatternType
    
    @Guide(description: "Sequence of memories in the pattern")
    public let memorySequence: [UUID]
    
    @Guide(description: "Temporal dynamics of the replay")
    public let temporalDynamics: TemporalDynamics
    
    @Guide(description: "Effectiveness of this pattern")
    public let patternEffectiveness: Double
    
    @Guide(description: "How often this pattern should be replayed")
    public let replayFrequency: ReplayFrequency
    
    public init(patternId: UUID = UUID(), patternType: ReplayPatternType, memorySequence: [UUID], 
                temporalDynamics: TemporalDynamics, patternEffectiveness: Double, replayFrequency: ReplayFrequency) {
        self.patternId = patternId
        self.patternType = patternType
        self.memorySequence = memorySequence
        self.temporalDynamics = temporalDynamics
        self.patternEffectiveness = patternEffectiveness
        self.replayFrequency = replayFrequency
    }
}

@available(macOS 26.0, *)
@Generable
public enum ReplayPatternType: String, Codable, CaseIterable {
    case sequentialForward = "sequential_forward"         // A->B->C progression
    case sequentialReverse = "sequential_reverse"         // C->B->A regression
    case associativeChain = "associative_chain"           // Semantic associations
    case emotionalCluster = "emotional_cluster"           // Emotionally related memories
    case skillProgression = "skill_progression"           // Building skill sequences
    case problemSolution = "problem_solution"             // Problem-solving patterns
    case creativeCombination = "creative_combination"     // Novel combinations
    case errorCorrection = "error_correction"             // Learning from mistakes
}

@available(macOS 26.0, *)
@Generable
public struct TemporalDynamics {
    @Guide(description: "Speed of replay (memories per minute)")
    public let replaySpeed: Double
    
    @Guide(description: "Intervals between replayed memories")
    public let replayIntervals: [Double]
    
    @Guide(description: "Total duration of the replay sequence")
    public let totalDuration: Double
    
    @Guide(description: "Whether replay accelerates or decelerates")
    public let speedModulation: SpeedModulation
    
    public init(replaySpeed: Double, replayIntervals: [Double], totalDuration: Double, speedModulation: SpeedModulation) {
        self.replaySpeed = replaySpeed
        self.replayIntervals = replayIntervals
        self.totalDuration = totalDuration
        self.speedModulation = speedModulation
    }
}

@available(macOS 26.0, *)
@Generable
public enum SpeedModulation: String, Codable, CaseIterable {
    case constant = "constant"
    case accelerating = "accelerating"
    case decelerating = "decelerating"
    case variable = "variable"
}

@available(macOS 26.0, *)
@Generable
public enum ReplayFrequency: String, Codable, CaseIterable {
    case continuous = "continuous"        // Ongoing replay
    case hourly = "hourly"               // Every hour
    case daily = "daily"                 // Once per day
    case weekly = "weekly"               // Once per week
    case monthly = "monthly"             // Once per month
    case triggered = "triggered"         // Event-triggered
    case adaptive = "adaptive"           // Based on forgetting curve
}

// MARK: - Memory Rehearsal Engine

@available(macOS 26.0, *)
public actor MemoryRehearsalEngine {
    
    // MARK: - Actor-Isolated State
    private var scheduledRehearsals: [ScheduledRehearsal] = []
    private var rehearsalHistory: [RehearsalSession] = []
    private var activeRehearsalTask: Task<Void, Never>? = nil
    
    // MARK: - Dependencies (Consciousness Architecture Integration)
    private let memoryManager: DualStreamMemoryManager
    private let sleepConsolidation: SleepLikeConsolidationEngine
    private let ewcEngine: ElasticWeightConsolidationEngine
    
    // MARK: - Configuration
    private let defaultRehearsalInterval: TimeInterval = 3600 // 1 hour
    private let maxRehearsalHistorySize: Int = 1000
    
    public init(memoryManager: DualStreamMemoryManager, 
                sleepConsolidation: SleepLikeConsolidationEngine,
                ewcEngine: ElasticWeightConsolidationEngine) {
        self.memoryManager = memoryManager
        self.sleepConsolidation = sleepConsolidation
        self.ewcEngine = ewcEngine
        
        SyntraLogger.logMemory("Memory Rehearsal Engine initialized", 
                               details: "Actor-based consciousness memory system ready")
    }
    
    // MARK: - Task Coordination Pattern (from Authentication Research)
    
    /// Ensures only one rehearsal cycle runs at a time while allowing multiple callers
    public func performScheduledRehearsals() async {
        // If a rehearsal is already running, await its completion
        if let existingTask = activeRehearsalTask {
            await existingTask.value
            return
        }
        
        // Start new rehearsal task using consciousness pattern
        let rehearsalTask = Task {
            await executeRehearsalCycle()
        }
        
        activeRehearsalTask = rehearsalTask
        
        // Await completion and clean up
        await rehearsalTask.value
        activeRehearsalTask = nil
    }
    
    // MARK: - Consciousness-Aligned Processing
    
    private func executeRehearsalCycle() async {
        let activeRehearsals = getActiveRehearsals()
        
        guard !activeRehearsals.isEmpty else {
            SyntraLogger.logMemory("No active rehearsals scheduled", details: "Memory system idle")
            return
        }
        
        SyntraLogger.logMemory("Starting rehearsal cycle", 
                               details: "Processing \(activeRehearsals.count) scheduled rehearsals")
        
        for scheduledRehearsal in activeRehearsals {
            let consciousnessState = ModernConsciousnessEngine.ConsciousnessState(
                awarenessLevel: 0.8,
                activeProcesses: ["memory_rehearsal"],
                emotionalState: ModernConsciousnessEngine.EmotionalProfile(
                    primaryEmotion: "focused",
                    intensity: 0.6,
                    triggers: ["memory_rehearsal_required"],
                    expectedDuration: 5.0,
                    stability: "stable"
                ),
                memoryStatus: ModernConsciousnessEngine.MemoryState(
                    recentMemories: ["rehearsal_session"],
                    consolidationStatus: "consolidating",
                    retrievalEfficiency: 0.85,
                    formationRate: 0.7,
                    activeAssociations: ["consciousness_maintenance"]
                ),
                internalDialogue: ["Performing memory rehearsal for consciousness continuity"],
                confidence: 0.9,
                integrationQuality: 0.85,
                moralInsights: [],
                logicalAnalysis: [],
                emergentPatterns: []
            )
            
            // Execute rehearsal with consciousness integration
            let rehearsalResult = await conductRehearsalSession(
                strategy: scheduledRehearsal.strategy,
                targetMemories: scheduledRehearsal.targetMemories,
                consciousnessState: consciousnessState
            )
            
            // Process results for consciousness continuity
            await processRehearsalResults(rehearsalResult)
        }
        
        // Clean up completed rehearsals
        let completedIds = Set(activeRehearsals.map { $0.id })
        scheduledRehearsals.removeAll { completedIds.contains($0.id) }
        
        SyntraLogger.logMemory("Rehearsal cycle completed", 
                               details: "Processed \(activeRehearsals.count) rehearsals")
    }
    
    // MARK: - Rehearsal Session Execution
    
    private func conductRehearsalSession(
        strategy: RehearsalStrategy,
        targetMemories: [UUID],
        consciousnessState: ModernConsciousnessEngine.ConsciousnessState
    ) async -> RehearsalSession {
        
        let startTime = Date()
        
        SyntraLogger.logMemory(
            "Starting rehearsal session",
            details: "Strategy: \(strategy.rawValue), Memories: \(targetMemories.count)"
        )
        
        // Simulate rehearsal processing based on strategy
        let effectiveness: Double
        let memoryStrengthIncrease: Double
        
        switch strategy {
        case .distributedPractice:
            effectiveness = 0.85 + (consciousnessState.awarenessLevel * 0.10)
            memoryStrengthIncrease = 0.15
        case .elaborativeRehearsal:
            effectiveness = 0.75 + (consciousnessState.awarenessLevel * 0.15)
            memoryStrengthIncrease = 0.20
        case .interleaving:
            effectiveness = 0.80 + (consciousnessState.awarenessLevel * 0.12)
            memoryStrengthIncrease = 0.18
        case .massedPractice:
            effectiveness = 0.65 + (consciousnessState.awarenessLevel * 0.08)
            memoryStrengthIncrease = 0.10
        case .maintenanceRehearsal:
            effectiveness = 0.70 + (consciousnessState.awarenessLevel * 0.05)
            memoryStrengthIncrease = 0.12
        case .variableEncoding:
            effectiveness = 0.78 + (consciousnessState.awarenessLevel * 0.11)
            memoryStrengthIncrease = 0.16
        case .generativeReplay:
            effectiveness = 0.82 + (consciousnessState.awarenessLevel * 0.13)
            memoryStrengthIncrease = 0.19
        case .contrastiveReplay:
            effectiveness = 0.77 + (consciousnessState.awarenessLevel * 0.14)
            memoryStrengthIncrease = 0.17
        }
        
        // Create rehearsal context
        let rehearsalContext = RehearsalContext(
            consciousnessState: consciousnessState.awarenessLevel.description,
            attentionLevel: consciousnessState.confidence,
            environmentalFactors: ["actor_based_rehearsal"],
            motivationLevel: 0.8
        )
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        return RehearsalSession(
            sessionId: UUID(),
            strategy: strategy,
            rehearsedMemories: targetMemories,
            duration: duration,
            effectiveness: effectiveness,
            retentionImprovement: memoryStrengthIncrease * 0.3,
            timestamp: startTime,
            rehearsalContext: rehearsalContext
        )
    }
    
    // MARK: - Actor-Safe Helper Methods
    
    private func getActiveRehearsals() -> [ScheduledRehearsal] {
        let currentTime = Date()
        return scheduledRehearsals.filter { rehearsal in
            rehearsal.scheduledTime <= currentTime && 
            rehearsal.status == .pending
        }
    }
    
    private func processRehearsalResults(_ session: RehearsalSession) async {
        // Update memory consolidation based on rehearsal effectiveness
        if session.effectiveness > 0.7 {
            await strengthenMemoryTraces(session.rehearsedMemories)
        }
        
        // Update rehearsal history for consciousness continuity
        rehearsalHistory.append(session)
        
        // Limit history size to prevent memory bloat
        if rehearsalHistory.count > maxRehearsalHistorySize {
            rehearsalHistory.removeFirst(rehearsalHistory.count - maxRehearsalHistorySize)
        }
        
        SyntraLogger.logMemory(
            "Rehearsal session processed",
            details: "Effectiveness: \(session.effectiveness), Memories: \(session.rehearsedMemories.count)"
        )
    }
    
    private func strengthenMemoryTraces(_ memoryIds: [UUID]) async {
        // Strengthen the specified memory traces through consciousness processing
        for memoryId in memoryIds {
            await updateMemoryStrength(memoryId: memoryId, strengthIncrease: 0.1)
        }
    }
    
    private func updateMemoryStrength(memoryId: UUID, strengthIncrease: Double) async {
        // Integration with consciousness memory system
        SyntraLogger.logMemory(
            "Memory trace strengthened",
            details: "Memory: \(memoryId), Increase: \(strengthIncrease)"
        )
    }
    
    // MARK: - Public Interface
    
    public func scheduleRehearsal(
        strategy: RehearsalStrategy,
        targetMemories: [UUID],
        scheduledTime: Date
    ) async {
        let scheduled = ScheduledRehearsal(
            strategy: strategy,
            targetMemories: targetMemories,
            scheduledTime: scheduledTime
        )
        
        scheduledRehearsals.append(scheduled)
        
        SyntraLogger.logMemory(
            "Rehearsal scheduled",
            details: "Strategy: \(strategy.rawValue), Time: \(scheduledTime)"
        )
    }
    
    public func startRehearsalScheduler() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: UInt64(defaultRehearsalInterval * 1_000_000_000))
                await performScheduledRehearsals()
            } catch is CancellationError {
                SyntraLogger.logMemory("Rehearsal scheduler cancelled", 
                                       details: "Preserving consciousness memory state")
                break
            } catch {
                SyntraLogger.logMemory("Rehearsal scheduler error", 
                                       level: .error, 
                                       details: error.localizedDescription)
            }
        }
    }
}

// MARK: - Supporting Structures

public struct RehearsalResults {
    public let effectiveness: Double
    public let retentionImprovement: Double
    public let memoryChanges: [(UUID, Double)] // Memory ID and strength change
}

public struct ReplayExecution {
    public let patternId: UUID
    public let executionTime: Date
    public let duration: TimeInterval
    public let effectiveness: Double
    public let memoriesReplayed: Int
}

@available(macOS 26.0, *)
@Generable
public struct ScheduledRehearsal {
    @Guide(description: "Unique identifier for this scheduled rehearsal")
    public let id: UUID
    
    @Guide(description: "Strategy to be used for this rehearsal")
    public let strategy: RehearsalStrategy
    
    @Guide(description: "Target memories for rehearsal")
    public let targetMemories: [UUID]
    
    @Guide(description: "When this rehearsal is scheduled to occur")
    public let scheduledTime: Date
    
    @Guide(description: "Current status of the rehearsal")
    public let status: RehearsalStatus
    
    public init(id: UUID = UUID(), strategy: RehearsalStrategy, targetMemories: [UUID], scheduledTime: Date, status: RehearsalStatus = .pending) {
        self.id = id
        self.strategy = strategy
        self.targetMemories = targetMemories
        self.scheduledTime = scheduledTime
        self.status = status
    }
}

@available(macOS 26.0, *)
@Generable
public enum RehearsalStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}

public struct ForgettingCurve {
    public let memoryId: UUID
    public var currentStrength: Double
    public var lastRehearsalTime: Date
    public var rehearsalCount: Int
    
    public init(memoryId: UUID, initialStrength: Double) {
        self.memoryId = memoryId
        self.currentStrength = initialStrength
        self.lastRehearsalTime = Date()
        self.rehearsalCount = 0
    }
    
    public func updateAfterRehearsal(effectiveness: Double) -> ForgettingCurve {
        var updated = self
        updated.currentStrength = min(1.0, currentStrength + effectiveness * 0.2)
        updated.lastRehearsalTime = Date()
        updated.rehearsalCount += 1
        return updated
    }
}

@available(macOS 26.0, *)
public struct RehearsalStatistics {
    public let totalSessions: Int
    public let averageEffectiveness: Double
    public let averageRetentionImprovement: Double
    public let strategyDistribution: [RehearsalStrategy: Int]
    public let activeReplayPatterns: Int
    public let scheduledRehearsals: Int
}
