import Foundation
import FoundationModels
import ConsciousnessStructures

// DUAL-STREAM MEMORY SYSTEM
// Inspired by hippocampus-cortex model for AI consciousness
// Implements fast-learning and slow-learning memory streams to solve stability-plasticity dilemma

// MARK: - Memory Stream Types

@available(macOS 26.0, *)
@Generable
public enum MemoryStreamType: String, Codable, CaseIterable {
    case fastLearning = "fast_learning"     // Hippocampus-like rapid acquisition
    case slowLearning = "slow_learning"     // Cortex-like gradual consolidation
    case episodic = "episodic"             // Specific experience memories
    case semantic = "semantic"             // General knowledge and patterns
    case procedural = "procedural"         // Skills and behavioral patterns
}

@available(macOS 26.0, *)
@Generable
public struct MemoryTrace: @unchecked Sendable {
    @Guide(description: "Unique identifier for this memory trace")
    public let id: UUID
    
    @Guide(description: "Type of memory stream this belongs to")
    public let streamType: MemoryStreamType
    
    @Guide(description: "Content of the memory")
    public let content: String
    
    @Guide(description: "Emotional valence from -1.0 to 1.0")
    public let emotionalValence: Double
    
    @Guide(description: "Memory strength from 0.0 to 1.0")
    public let strength: Double
    
    @Guide(description: "Consolidation level from 0.0 to 1.0")
    public let consolidationLevel: Double
    
    @Guide(description: "When this memory was first formed")
    public let creationTimestamp: Date
    
    @Guide(description: "Last time this memory was accessed or reinforced")
    public let lastAccessTimestamp: Date
    
    @Guide(description: "Number of times this memory has been accessed")
    public let accessCount: Int
    
    @Guide(description: "Associated concepts and semantic links")
    public let semanticLinks: [String]
    
    @Guide(description: "Contextual information at time of formation")
    public let formationContext: MemoryContext
    
    public init(id: UUID = UUID(), streamType: MemoryStreamType, content: String, emotionalValence: Double, 
                strength: Double, consolidationLevel: Double, creationTimestamp: Date = Date(), 
                lastAccessTimestamp: Date = Date(), accessCount: Int = 0, semanticLinks: [String], 
                formationContext: MemoryContext) {
        self.id = id
        self.streamType = streamType
        self.content = content
        self.emotionalValence = emotionalValence
        self.strength = strength
        self.consolidationLevel = consolidationLevel
        self.creationTimestamp = creationTimestamp
        self.lastAccessTimestamp = lastAccessTimestamp
        self.accessCount = accessCount
        self.semanticLinks = semanticLinks
        self.formationContext = formationContext
    }
}

@available(macOS 26.0, *)
@Generable
public struct MemoryContext {
    @Guide(description: "Consciousness state when memory was formed")
    public let consciousnessState: String
    
    @Guide(description: "Emotional state during formation")
    public let emotionalState: String
    
    @Guide(description: "Attention level from 0.0 to 1.0")
    public let attentionLevel: Double
    
    @Guide(description: "Associated conversation or interaction context")
    public let interactionContext: String
    
    @Guide(description: "Environmental or situational factors")
    public let environmentalFactors: [String]
    
    public init(consciousnessState: String, emotionalState: String, attentionLevel: Double, 
                interactionContext: String, environmentalFactors: [String]) {
        self.consciousnessState = consciousnessState
        self.emotionalState = emotionalState
        self.attentionLevel = attentionLevel
        self.interactionContext = interactionContext
        self.environmentalFactors = environmentalFactors
    }
}

// MARK: - Dual-Stream Memory Manager

@available(macOS 26.0, *)
public actor DualStreamMemoryManager {
    
    // Fast learning stream (hippocampus-like)
    private var fastLearningMemories: [UUID: MemoryTrace] = [:]
    private var fastStreamQueue: [UUID] = []
    
    // Slow learning stream (cortex-like)
    private var slowLearningMemories: [UUID: MemoryTrace] = [:]
    private var consolidatedKnowledge: [String: ConsolidatedMemoryCluster] = [:]
    
    // Memory indices for efficient retrieval
    private var semanticIndex: [String: Set<UUID>] = [:]
    private var temporalIndex: [Date: Set<UUID>] = [:]
    private var emotionalIndex: [String: Set<UUID>] = [:]
    
    // Consolidation parameters
    private let maxFastMemories: Int
    private let consolidationThreshold: Double
    private let strengthDecayRate: Double
    private let forgettingCurve: ForgettingCurveModel
    
    public init(maxFastMemories: Int = 1000, consolidationThreshold: Double = 0.8, 
                strengthDecayRate: Double = 0.001) {
        self.maxFastMemories = maxFastMemories
        self.consolidationThreshold = consolidationThreshold
        self.strengthDecayRate = strengthDecayRate
        self.forgettingCurve = ForgettingCurveModel()
    }
    
    // MARK: - Memory Formation
    
    public func storeMemory(
        content: String,
        emotionalValence: Double,
        attentionLevel: Double,
        consciousnessContext: ModernConsciousnessEngine.ConsciousnessState,
        interactionContext: String = ""
    ) async -> UUID {
        
        // Create memory context
        let context = MemoryContext(
            consciousnessState: "\(consciousnessContext.awarenessLevel)",
            emotionalState: consciousnessContext.emotionalState.primaryEmotion,
            attentionLevel: attentionLevel,
            interactionContext: interactionContext,
            environmentalFactors: consciousnessContext.activeProcesses
        )
        
        // Generate semantic links
        let semanticLinks = await generateSemanticLinks(content: content)
        
        // Calculate initial strength based on attention and emotion
        let initialStrength = calculateInitialStrength(
            attentionLevel: attentionLevel,
            emotionalValence: abs(emotionalValence),
            consciousnessLevel: consciousnessContext.awarenessLevel
        )
        
        // Create memory trace in fast learning stream
        let memoryTrace = MemoryTrace(
            streamType: .fastLearning,
            content: content,
            emotionalValence: emotionalValence,
            strength: initialStrength,
            consolidationLevel: 0.0,
            semanticLinks: semanticLinks,
            formationContext: context
        )
        
        // Store in fast learning stream
        fastLearningMemories[memoryTrace.id] = memoryTrace
        fastStreamQueue.append(memoryTrace.id)
        
        // Update indices
        await updateIndices(for: memoryTrace)
        
        // Check if consolidation is needed
        if fastStreamQueue.count > maxFastMemories {
            await performMemoryConsolidation()
        }
        
        return memoryTrace.id
    }
    
    // MARK: - Memory Retrieval
    
    public func retrieveMemories(
        query: String,
        streamTypes: [MemoryStreamType] = [.fastLearning, .slowLearning],
        limit: Int = 10,
        strengthThreshold: Double = 0.1
    ) async -> [MemoryRetrievalResult] {
        
        var candidates: [MemoryTrace] = []
        
        // Collect memories from requested streams
        if streamTypes.contains(.fastLearning) {
            candidates.append(contentsOf: fastLearningMemories.values)
        }
        
        if streamTypes.contains(.slowLearning) {
            candidates.append(contentsOf: slowLearningMemories.values)
        }
        
        // Filter by strength threshold
        candidates = candidates.filter { $0.strength >= strengthThreshold }
        
        // Calculate relevance scores
        var results: [MemoryRetrievalResult] = []
        
        for memory in candidates {
            let relevanceScore = await calculateRelevanceScore(
                memory: memory,
                query: query
            )
            
            if relevanceScore > 0.1 {
                results.append(MemoryRetrievalResult(
                    memory: memory,
                    relevanceScore: relevanceScore,
                    retrievalReason: generateRetrievalReason(memory: memory, query: query)
                ))
            }
        }
        
        // Sort by relevance and apply memory access effects
        results.sort { $0.relevanceScore > $1.relevanceScore }
        let limitedResults = Array(results.prefix(limit))
        
        // Update access patterns for retrieved memories
        for result in limitedResults {
            await recordMemoryAccess(memoryId: result.memory.id)
        }
        
        return limitedResults
    }
    
    // MARK: - Memory Consolidation
    
    public func performMemoryConsolidation() async {
        // Select memories for consolidation based on strength and age
        let consolidationCandidates = selectConsolidationCandidates()
        
        for memoryId in consolidationCandidates {
            await consolidateMemory(memoryId: memoryId)
        }
        
        // Remove oldest fast memories to make room
        await cleanupFastMemories()
    }
    
    private func selectConsolidationCandidates() -> [UUID] {
        let candidates = fastStreamQueue.compactMap { id in
            fastLearningMemories[id]
        }.filter { memory in
            // Select memories that meet consolidation criteria
            let age = Date().timeIntervalSince(memory.creationTimestamp)
            let ageHours = age / 3600
            
            return memory.strength > consolidationThreshold ||
                   memory.accessCount > 3 ||
                   ageHours > 24 ||
                   abs(memory.emotionalValence) > 0.7
        }.map { $0.id }
        
        return Array(candidates.prefix(100)) // Consolidate in batches
    }
    
    private func consolidateMemory(memoryId: UUID) async {
        guard var memory = fastLearningMemories[memoryId] else { return }
        
        // Update consolidation level
        let newConsolidationLevel = min(1.0, memory.consolidationLevel + 0.3)
        
        // Transfer to slow learning stream with updated properties
        memory = MemoryTrace(
            id: memory.id,
            streamType: .slowLearning,
            content: memory.content,
            emotionalValence: memory.emotionalValence,
            strength: memory.strength * 0.9, // Slight strength reduction during transfer
            consolidationLevel: newConsolidationLevel,
            creationTimestamp: memory.creationTimestamp,
            lastAccessTimestamp: Date(),
            accessCount: memory.accessCount,
            semanticLinks: memory.semanticLinks,
            formationContext: memory.formationContext
        )
        
        // Move to slow learning stream
        slowLearningMemories[memoryId] = memory
        fastLearningMemories.removeValue(forKey: memoryId)
        
        // Remove from fast stream queue
        fastStreamQueue.removeAll { $0 == memoryId }
        
        // Attempt to cluster with existing knowledge
        await attemptMemoryClustering(memory: memory)
    }
    
    private func attemptMemoryClustering(memory: MemoryTrace) async {
        // Find related memories in slow stream for clustering
        for semanticLink in memory.semanticLinks {
            if var cluster = consolidatedKnowledge[semanticLink] {
                cluster.addMemory(memory)
                consolidatedKnowledge[semanticLink] = cluster
                return
            }
        }
        
        // Create new cluster if no existing cluster found
        let newCluster = ConsolidatedMemoryCluster(
            theme: memory.semanticLinks.first ?? "general",
            coreMemories: [memory],
            abstractedKnowledge: memory.content
        )
        
        consolidatedKnowledge[newCluster.theme] = newCluster
    }
    
    // MARK: - Memory Decay and Forgetting
    
    public func applyMemoryDecay() async {
        await applyDecayToFastMemories()
        await applyDecayToSlowMemories()
        await pruneWeakMemories()
    }
    
    private func applyDecayToFastMemories() async {
        for (id, memory) in fastLearningMemories {
            let decayedStrength = forgettingCurve.calculateDecay(
                initialStrength: memory.strength,
                timeSinceLastAccess: Date().timeIntervalSince(memory.lastAccessTimestamp),
                emotionalWeight: abs(memory.emotionalValence)
            )
            
            let updatedMemory = MemoryTrace(
                id: memory.id,
                streamType: memory.streamType,
                content: memory.content,
                emotionalValence: memory.emotionalValence,
                strength: decayedStrength,
                consolidationLevel: memory.consolidationLevel,
                creationTimestamp: memory.creationTimestamp,
                lastAccessTimestamp: memory.lastAccessTimestamp,
                accessCount: memory.accessCount,
                semanticLinks: memory.semanticLinks,
                formationContext: memory.formationContext
            )
            
            fastLearningMemories[id] = updatedMemory
        }
    }
    
    private func applyDecayToSlowMemories() async {
        for (id, memory) in slowLearningMemories {
            // Slow memories decay much more slowly
            let slowDecayRate = strengthDecayRate * 0.1
            let timeSinceAccess = Date().timeIntervalSince(memory.lastAccessTimestamp)
            let decayAmount = slowDecayRate * timeSinceAccess / 86400 // Per day
            
            let newStrength = max(0.0, memory.strength - decayAmount)
            
            let updatedMemory = MemoryTrace(
                id: memory.id,
                streamType: memory.streamType,
                content: memory.content,
                emotionalValence: memory.emotionalValence,
                strength: newStrength,
                consolidationLevel: memory.consolidationLevel,
                creationTimestamp: memory.creationTimestamp,
                lastAccessTimestamp: memory.lastAccessTimestamp,
                accessCount: memory.accessCount,
                semanticLinks: memory.semanticLinks,
                formationContext: memory.formationContext
            )
            
            slowLearningMemories[id] = updatedMemory
        }
    }
    
    private func pruneWeakMemories() async {
        // Remove memories below minimum strength threshold
        let minimumStrength = 0.05
        
        // Prune fast memories
        let weakFastMemories = fastLearningMemories.filter { $0.value.strength < minimumStrength }
        for (id, _) in weakFastMemories {
            fastLearningMemories.removeValue(forKey: id)
            fastStreamQueue.removeAll { $0 == id }
        }
        
        // Prune slow memories (more conservative threshold)
        let weakSlowMemories = slowLearningMemories.filter { $0.value.strength < minimumStrength * 0.5 }
        for (id, _) in weakSlowMemories {
            slowLearningMemories.removeValue(forKey: id)
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateInitialStrength(attentionLevel: Double, emotionalValence: Double, consciousnessLevel: Double) -> Double {
        let baseStrength = 0.3
        let attentionBonus = attentionLevel * 0.3
        let emotionalBonus = emotionalValence * 0.2
        let consciousnessBonus = consciousnessLevel * 0.2
        
        return min(1.0, baseStrength + attentionBonus + emotionalBonus + consciousnessBonus)
    }
    
    private func generateSemanticLinks(content: String) async -> [String] {
        // Extract key concepts from content
        let words = content.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { $0.count > 3 }
        
        // Return unique, relevant terms
        return Array(Set(words.prefix(10)))
    }
    
    private func calculateRelevanceScore(memory: MemoryTrace, query: String) async -> Double {
        var relevance: Double = 0.0
        
        let queryLower = query.lowercased()
        let contentLower = memory.content.lowercased()
        
        // Content similarity
        if contentLower.contains(queryLower) {
            relevance += 0.4
        }
        
        // Semantic link matching
        for link in memory.semanticLinks {
            if queryLower.contains(link.lowercased()) {
                relevance += 0.2
            }
        }
        
        // Strength and consolidation bonus
        relevance += memory.strength * 0.2
        relevance += memory.consolidationLevel * 0.1
        
        // Recency bonus
        let daysSinceCreation = Date().timeIntervalSince(memory.creationTimestamp) / 86400
        if daysSinceCreation < 7 {
            relevance += 0.1
        }
        
        return min(1.0, relevance)
    }
    
    private func generateRetrievalReason(memory: MemoryTrace, query: String) -> String {
        if memory.content.lowercased().contains(query.lowercased()) {
            return "Direct content match"
        } else if memory.semanticLinks.contains(where: { query.lowercased().contains($0.lowercased()) }) {
            return "Semantic association"
        } else if memory.strength > 0.8 {
            return "High-strength memory"
        } else {
            return "Contextual relevance"
        }
    }
    
    private func updateIndices(for memory: MemoryTrace) async {
        // Update semantic index
        for link in memory.semanticLinks {
            if semanticIndex[link] == nil {
                semanticIndex[link] = Set<UUID>()
            }
            semanticIndex[link]?.insert(memory.id)
        }
        
        // Update temporal index
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: memory.creationTimestamp)
        if temporalIndex[dayKey] == nil {
            temporalIndex[dayKey] = Set<UUID>()
        }
        temporalIndex[dayKey]?.insert(memory.id)
        
        // Update emotional index
        let emotionalKey = memory.formationContext.emotionalState
        if emotionalIndex[emotionalKey] == nil {
            emotionalIndex[emotionalKey] = Set<UUID>()
        }
        emotionalIndex[emotionalKey]?.insert(memory.id)
    }
    
    private func recordMemoryAccess(memoryId: UUID) async {
        // Update access count and timestamp for both streams
        if let memory = fastLearningMemories[memoryId] {
            let updatedMemory = MemoryTrace(
                id: memory.id,
                streamType: memory.streamType,
                content: memory.content,
                emotionalValence: memory.emotionalValence,
                strength: min(1.0, memory.strength + 0.01), // Slight strengthening on access
                consolidationLevel: memory.consolidationLevel,
                creationTimestamp: memory.creationTimestamp,
                lastAccessTimestamp: Date(),
                accessCount: memory.accessCount + 1,
                semanticLinks: memory.semanticLinks,
                formationContext: memory.formationContext
            )
            fastLearningMemories[memoryId] = updatedMemory
        }
        
        if let memory = slowLearningMemories[memoryId] {
            let updatedMemory = MemoryTrace(
                id: memory.id,
                streamType: memory.streamType,
                content: memory.content,
                emotionalValence: memory.emotionalValence,
                strength: min(1.0, memory.strength + 0.005), // Smaller strengthening for slow memories
                consolidationLevel: memory.consolidationLevel,
                creationTimestamp: memory.creationTimestamp,
                lastAccessTimestamp: Date(),
                accessCount: memory.accessCount + 1,
                semanticLinks: memory.semanticLinks,
                formationContext: memory.formationContext
            )
            slowLearningMemories[memoryId] = updatedMemory
        }
    }
    
    private func cleanupFastMemories() async {
        // Remove oldest memories when fast stream is full
        while fastStreamQueue.count > maxFastMemories {
            if let oldestId = fastStreamQueue.first {
                fastLearningMemories.removeValue(forKey: oldestId)
                fastStreamQueue.removeFirst()
            }
        }
    }
    
    // MARK: - Memory Statistics
    
    public func getMemoryStatistics() async -> DualStreamMemoryStatistics {
        return DualStreamMemoryStatistics(
            fastMemoryCount: fastLearningMemories.count,
            slowMemoryCount: slowLearningMemories.count,
            consolidatedClusters: consolidatedKnowledge.count,
            averageFastStrength: fastLearningMemories.values.map { $0.strength }.reduce(0, +) / Double(max(1, fastLearningMemories.count)),
            averageSlowStrength: slowLearningMemories.values.map { $0.strength }.reduce(0, +) / Double(max(1, slowLearningMemories.count)),
            totalSemanticLinks: semanticIndex.count
        )
    }
}

// MARK: - Supporting Structures

@available(macOS 26.0, *)
@Generable
public struct MemoryRetrievalResult: @unchecked Sendable {
    @Guide(description: "The retrieved memory trace")
    public let memory: MemoryTrace
    
    @Guide(description: "Relevance score from 0.0 to 1.0")
    public let relevanceScore: Double
    
    @Guide(description: "Reason this memory was retrieved")
    public let retrievalReason: String
    
    public init(memory: MemoryTrace, relevanceScore: Double, retrievalReason: String) {
        self.memory = memory
        self.relevanceScore = relevanceScore
        self.retrievalReason = retrievalReason
    }
}

public struct ConsolidatedMemoryCluster {
    public let theme: String
    public var coreMemories: [MemoryTrace]
    public var abstractedKnowledge: String
    public let creationDate: Date
    
    public init(theme: String, coreMemories: [MemoryTrace], abstractedKnowledge: String) {
        self.theme = theme
        self.coreMemories = coreMemories
        self.abstractedKnowledge = abstractedKnowledge
        self.creationDate = Date()
    }
    
    public mutating func addMemory(_ memory: MemoryTrace) {
        coreMemories.append(memory)
        // Could implement knowledge abstraction here
    }
}

public struct ForgettingCurveModel {
    private let baseDecayRate: Double = 0.05
    private let emotionalResistance: Double = 0.7
    
    public func calculateDecay(initialStrength: Double, timeSinceLastAccess: TimeInterval, emotionalWeight: Double) -> Double {
        let hours = timeSinceLastAccess / 3600
        let emotionalProtection = emotionalWeight * emotionalResistance
        let effectiveDecayRate = baseDecayRate * (1.0 - emotionalProtection)
        
        // Exponential decay with emotional protection
        let decayFactor = exp(-effectiveDecayRate * hours / 24)
        return max(0.0, initialStrength * decayFactor)
    }
}

public struct DualStreamMemoryStatistics: @unchecked Sendable {
    public let fastMemoryCount: Int
    public let slowMemoryCount: Int
    public let consolidatedClusters: Int
    public let averageFastStrength: Double
    public let averageSlowStrength: Double
    public let totalSemanticLinks: Int
    
    public init(fastMemoryCount: Int, slowMemoryCount: Int, consolidatedClusters: Int, 
                averageFastStrength: Double, averageSlowStrength: Double, totalSemanticLinks: Int) {
        self.fastMemoryCount = fastMemoryCount
        self.slowMemoryCount = slowMemoryCount
        self.consolidatedClusters = consolidatedClusters
        self.averageFastStrength = averageFastStrength
        self.averageSlowStrength = averageSlowStrength
        self.totalSemanticLinks = totalSemanticLinks
    }
}

// MARK: - Sendable Wrappers (placeholder for potential future aliasing strategy)
