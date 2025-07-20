import Foundation
import FoundationModels
import ConsciousnessStructures

// MODERN MEMORY VAULT
// Swift actor-based memory system replacing Python memory_vault
// Thread-safe, high-performance memory storage and retrieval

@available(macOS 26.0, *)
public actor ModernMemoryVault {
    
    // MARK: - Memory Data Structures
    
    @available(macOS 26.0, *)
    public struct MemoryItem {
        public let id: UUID
        public let content: String
        public let emotionalWeight: Double
        public let timestamp: Date
        public let associations: [String]
        public let memoryType: MemoryType
        public let consciousnessContext: ConsciousnessContext
        public let accessCount: Int
        public let consolidationLevel: Double
        public let memoryLinks: [UUID]
        
        public init(id: UUID = UUID(), content: String, emotionalWeight: Double, timestamp: Date = Date(), associations: [String], memoryType: MemoryType, consciousnessContext: ConsciousnessContext, accessCount: Int = 0, consolidationLevel: Double = 0.5, memoryLinks: [UUID] = []) {
            self.id = id
            self.content = content
            self.emotionalWeight = emotionalWeight
            self.timestamp = timestamp
            self.associations = associations
            self.memoryType = memoryType
            self.consciousnessContext = consciousnessContext
            self.accessCount = accessCount
            self.consolidationLevel = consolidationLevel
            self.memoryLinks = memoryLinks
        }
    }
    
    @available(macOS 26.0, *)
    public enum MemoryType: String, CaseIterable {
        case experience = "experience"
        case learning = "learning"
        case insight = "insight"
        case conversation = "conversation"
        case pattern = "pattern"
        case emotion = "emotion"
        case decision = "decision"
        case reflection = "reflection"
    }
    
    @available(macOS 26.0, *)
    public struct ConsciousnessContext {
        public let awarenessLevel: Double
        public let emotionalState: String
        public let activeProcesses: [String]
        public let integrationQuality: Double
        
        public init(awarenessLevel: Double, emotionalState: String, activeProcesses: [String], integrationQuality: Double) {
            self.awarenessLevel = awarenessLevel
            self.emotionalState = emotionalState
            self.activeProcesses = activeProcesses
            self.integrationQuality = integrationQuality
        }
    }
    
    @available(macOS 26.0, *)
    public struct MemorySearchResult {
        public let memory: MemoryItem
        public let relevanceScore: Double
        public let relevanceReason: String
        
        public init(memory: MemoryItem, relevanceScore: Double, relevanceReason: String) {
            self.memory = memory
            self.relevanceScore = relevanceScore
            self.relevanceReason = relevanceReason
        }
    }
    
    // MARK: - Storage
    
    private var memories: [UUID: MemoryItem] = [:]
    private var consolidationQueue: [UUID] = []
    private var accessHistory: [UUID: [Date]] = [:]
    private var semanticIndex: [String: Set<UUID>] = [:]
    private var emotionalIndex: [String: Set<UUID>] = [:]
    private var temporalIndex: [Date: Set<UUID>] = [:]
    
    // Configuration
    private let maxMemories: Int
    private let consolidationThreshold: Double
    private let maxConsolidationQueueSize: Int
    
    public init(maxMemories: Int = 10000, consolidationThreshold: Double = 0.8, maxConsolidationQueueSize: Int = 100) {
        self.maxMemories = maxMemories
        self.consolidationThreshold = consolidationThreshold
        self.maxConsolidationQueueSize = maxConsolidationQueueSize
    }
    
    // MARK: - Memory Storage
    
    public func storeMemory(_ memory: MemoryItem) async {
        // Store the memory
        memories[memory.id] = memory
        
        // Update indices
        updateIndices(for: memory)
        
        // Add to consolidation queue if not already consolidated
        if memory.consolidationLevel < consolidationThreshold {
            consolidationQueue.append(memory.id)
        }
        
        // Process consolidation if queue is getting full
        if consolidationQueue.count >= maxConsolidationQueueSize {
            await processConsolidationQueue()
        }
        
        // Memory management - remove oldest if over limit
        if memories.count > maxMemories {
            await removeOldestMemories()
        }
    }
    
    public func storeMemory(
        content: String,
        emotionalWeight: Double,
        associations: [String],
        memoryType: MemoryType,
        consciousnessContext: ConsciousnessContext
    ) async -> UUID {
        let memory = MemoryItem(
            content: content,
            emotionalWeight: emotionalWeight,
            associations: associations,
            memoryType: memoryType,
            consciousnessContext: consciousnessContext
        )
        
        await storeMemory(memory)
        return memory.id
    }
    
    // MARK: - Memory Retrieval
    
    public func retrieveMemory(id: UUID) async -> MemoryItem? {
        guard let memory = memories[id] else { return nil }
        
        // Record access
        await recordAccess(memoryId: id)
        
        // Return updated memory with incremented access count
        let updatedMemory = MemoryItem(
            id: memory.id,
            content: memory.content,
            emotionalWeight: memory.emotionalWeight,
            timestamp: memory.timestamp,
            associations: memory.associations,
            memoryType: memory.memoryType,
            consciousnessContext: memory.consciousnessContext,
            accessCount: memory.accessCount + 1,
            consolidationLevel: memory.consolidationLevel,
            memoryLinks: memory.memoryLinks
        )
        
        memories[id] = updatedMemory
        return updatedMemory
    }
    
    public func searchMemories(
        query: String,
        emotionalFilter: String? = nil,
        timeframe: TimeInterval? = nil,
        memoryTypes: [MemoryType]? = nil,
        limit: Int = 10
    ) async -> [MemorySearchResult] {
        
        var candidates: [MemoryItem] = []
        
        // Get all memories or filter by timeframe
        if let timeframe = timeframe {
            let cutoffDate = Date().addingTimeInterval(-timeframe)
            candidates = memories.values.filter { $0.timestamp >= cutoffDate }
        } else {
            candidates = Array(memories.values)
        }
        
        // Filter by memory types
        if let types = memoryTypes {
            candidates = candidates.filter { types.contains($0.memoryType) }
        }
        
        // Filter by emotional context
        if let emotionalFilter = emotionalFilter {
            candidates = candidates.filter { 
                $0.consciousnessContext.emotionalState.lowercased().contains(emotionalFilter.lowercased())
            }
        }
        
        // Calculate relevance scores
        var results: [MemorySearchResult] = []
        
        for memory in candidates {
            let relevanceScore = calculateRelevance(memory: memory, query: query)
            if relevanceScore > 0.1 { // Minimum relevance threshold
                let reason = generateRelevanceReason(memory: memory, query: query)
                results.append(MemorySearchResult(
                    memory: memory,
                    relevanceScore: relevanceScore,
                    relevanceReason: reason
                ))
            }
        }
        
        // Sort by relevance and limit results
        results.sort { $0.relevanceScore > $1.relevanceScore }
        return Array(results.prefix(limit))
    }
    
    public func getMemoriesByAssociation(_ association: String, limit: Int = 5) async -> [MemoryItem] {
        guard let memoryIds = semanticIndex[association.lowercased()] else { return [] }
        
        let memoryItems = memoryIds.compactMap { self.memories[$0] }
        return Array(memoryItems.prefix(limit))
    }
    
    public func getRelatedMemories(to memoryId: UUID, limit: Int = 5) async -> [MemoryItem] {
        guard let memory = memories[memoryId] else { return [] }
        
        var related: [MemoryItem] = []
        
        // Get directly linked memories
        for linkId in memory.memoryLinks {
            if let linkedMemory = memories[linkId] {
                related.append(linkedMemory)
            }
        }
        
        // Get memories with similar associations
        for association in memory.associations {
            if let associatedIds = semanticIndex[association.lowercased()] {
                for id in associatedIds where id != memoryId {
                    if let associatedMemory = memories[id] {
                        related.append(associatedMemory)
                    }
                }
            }
        }
        
        // Remove duplicates and limit
        let uniqueMemories = Array(Set(related.map { $0.id })).compactMap { memories[$0] }
        return Array(uniqueMemories.prefix(limit))
    }
    
    // MARK: - Memory Statistics
    
    public func getMemoryStatistics() async -> MemoryStatistics {
        let totalMemories = memories.count
        let averageEmotionalWeight = memories.values.map { $0.emotionalWeight }.reduce(0, +) / Double(totalMemories)
        let averageConsolidation = memories.values.map { $0.consolidationLevel }.reduce(0, +) / Double(totalMemories)
        let memoryTypeDistribution = Dictionary(grouping: memories.values, by: { $0.memoryType })
            .mapValues { $0.count }
        
        return MemoryStatistics(
            totalMemories: totalMemories,
            averageEmotionalWeight: averageEmotionalWeight,
            averageConsolidationLevel: averageConsolidation,
            memoriesInConsolidationQueue: consolidationQueue.count,
            memoryTypeDistribution: memoryTypeDistribution,
            uniqueAssociations: semanticIndex.count
        )
    }
    
    // MARK: - Memory Consolidation
    
    private func processConsolidationQueue() async {
        let batchSize = min(10, consolidationQueue.count)
        let batch = Array(consolidationQueue.prefix(batchSize))
        consolidationQueue.removeFirst(batchSize)
        
        for memoryId in batch {
            await consolidateMemory(memoryId)
        }
    }
    
    private func consolidateMemory(_ memoryId: UUID) async {
        guard var memory = memories[memoryId] else { return }
        
        // Calculate new consolidation level based on access patterns and emotional weight
        let accessFrequency = Double(accessHistory[memoryId]?.count ?? 0)
        let timeSinceCreation = Date().timeIntervalSince(memory.timestamp)
        let recency = max(0, 1.0 - (timeSinceCreation / (86400 * 30))) // 30 days decay
        
        let newConsolidationLevel = min(1.0, 
            memory.consolidationLevel + 
            (memory.emotionalWeight * 0.2) + 
            (accessFrequency * 0.1) + 
            (recency * 0.1)
        )
        
        // Update memory with new consolidation level
        memory = MemoryItem(
            id: memory.id,
            content: memory.content,
            emotionalWeight: memory.emotionalWeight,
            timestamp: memory.timestamp,
            associations: memory.associations,
            memoryType: memory.memoryType,
            consciousnessContext: memory.consciousnessContext,
            accessCount: memory.accessCount,
            consolidationLevel: newConsolidationLevel,
            memoryLinks: memory.memoryLinks
        )
        
        memories[memoryId] = memory
        
        // Generate semantic links to related memories
        await generateSemanticLinks(for: memory)
    }
    
    private func generateSemanticLinks(for memory: MemoryItem) async {
        var newLinks: Set<UUID> = Set(memory.memoryLinks)
        
        // Find memories with similar associations
        for association in memory.associations {
            if let relatedIds = semanticIndex[association.lowercased()] {
                for relatedId in relatedIds where relatedId != memory.id {
                    if newLinks.count < 5 { // Limit links to prevent memory explosion
                        newLinks.insert(relatedId)
                    }
                }
            }
        }
        
        // Update memory with new links
        let updatedMemory = MemoryItem(
            id: memory.id,
            content: memory.content,
            emotionalWeight: memory.emotionalWeight,
            timestamp: memory.timestamp,
            associations: memory.associations,
            memoryType: memory.memoryType,
            consciousnessContext: memory.consciousnessContext,
            accessCount: memory.accessCount,
            consolidationLevel: memory.consolidationLevel,
            memoryLinks: Array(newLinks)
        )
        
        memories[memory.id] = updatedMemory
    }
    
    // MARK: - Private Helper Methods
    
    private func updateIndices(for memory: MemoryItem) {
        // Update semantic index
        for association in memory.associations {
            let key = association.lowercased()
            if semanticIndex[key] == nil {
                semanticIndex[key] = Set<UUID>()
            }
            semanticIndex[key]?.insert(memory.id)
        }
        
        // Update emotional index
        let emotionalKey = memory.consciousnessContext.emotionalState.lowercased()
        if emotionalIndex[emotionalKey] == nil {
            emotionalIndex[emotionalKey] = Set<UUID>()
        }
        emotionalIndex[emotionalKey]?.insert(memory.id)
        
        // Update temporal index (by day)
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: memory.timestamp)
        if temporalIndex[dayKey] == nil {
            temporalIndex[dayKey] = Set<UUID>()
        }
        temporalIndex[dayKey]?.insert(memory.id)
    }
    
    private func recordAccess(memoryId: UUID) async {
        if accessHistory[memoryId] == nil {
            accessHistory[memoryId] = []
        }
        accessHistory[memoryId]?.append(Date())
        
        // Keep only recent access history (last 100 accesses)
        if let count = accessHistory[memoryId]?.count, count > 100 {
            accessHistory[memoryId] = Array(accessHistory[memoryId]!.suffix(100))
        }
    }
    
    private func calculateRelevance(memory: MemoryItem, query: String) -> Double {
        let queryLower = query.lowercased()
        var relevance: Double = 0.0
        
        // Content similarity
        if memory.content.lowercased().contains(queryLower) {
            relevance += 0.4
        }
        
        // Association similarity
        for association in memory.associations {
            if association.lowercased().contains(queryLower) {
                relevance += 0.3
            }
        }
        
        // Emotional weight boost
        relevance += memory.emotionalWeight * 0.2
        
        // Consolidation level boost
        relevance += memory.consolidationLevel * 0.1
        
        // Recent access boost
        if let lastAccess = accessHistory[memory.id]?.last {
            let timeSinceAccess = Date().timeIntervalSince(lastAccess)
            if timeSinceAccess < 3600 { // Last hour
                relevance += 0.1
            }
        }
        
        return min(relevance, 1.0)
    }
    
    private func generateRelevanceReason(memory: MemoryItem, query: String) -> String {
        let queryLower = query.lowercased()
        
        if memory.content.lowercased().contains(queryLower) {
            return "Content contains query terms"
        } else if memory.associations.contains(where: { $0.lowercased().contains(queryLower) }) {
            return "Associated with query concepts"
        } else if memory.emotionalWeight > 0.7 {
            return "High emotional significance"
        } else {
            return "Semantic similarity to query"
        }
    }
    
    private func removeOldestMemories() async {
        let sortedMemories = memories.values.sorted { 
            // Sort by consolidation level (ascending) and then by timestamp (ascending)
            if $0.consolidationLevel == $1.consolidationLevel {
                return $0.timestamp < $1.timestamp
            }
            return $0.consolidationLevel < $1.consolidationLevel
        }
        
        let toRemove = sortedMemories.prefix(memories.count - maxMemories + 1000) // Remove extra to prevent frequent cleanup
        
        for memory in toRemove {
            memories.removeValue(forKey: memory.id)
            
            // Clean up indices
            for association in memory.associations {
                semanticIndex[association.lowercased()]?.remove(memory.id)
            }
            
            let emotionalKey = memory.consciousnessContext.emotionalState.lowercased()
            emotionalIndex[emotionalKey]?.remove(memory.id)
            
            let calendar = Calendar.current
            let dayKey = calendar.startOfDay(for: memory.timestamp)
            temporalIndex[dayKey]?.remove(memory.id)
            
            accessHistory.removeValue(forKey: memory.id)
        }
    }
}

// MARK: - Supporting Types

@available(macOS 26.0, *)
public struct MemoryStatistics {
    public let totalMemories: Int
    public let averageEmotionalWeight: Double
    public let averageConsolidationLevel: Double
    public let memoriesInConsolidationQueue: Int
    public let memoryTypeDistribution: [ModernMemoryVault.MemoryType: Int]
    public let uniqueAssociations: Int
    
    public init(totalMemories: Int, averageEmotionalWeight: Double, averageConsolidationLevel: Double, memoriesInConsolidationQueue: Int, memoryTypeDistribution: [ModernMemoryVault.MemoryType: Int], uniqueAssociations: Int) {
        self.totalMemories = totalMemories
        self.averageEmotionalWeight = averageEmotionalWeight
        self.averageConsolidationLevel = averageConsolidationLevel
        self.memoriesInConsolidationQueue = memoriesInConsolidationQueue
        self.memoryTypeDistribution = memoryTypeDistribution
        self.uniqueAssociations = uniqueAssociations
    }
}

// MARK: - Memory Vault Manager

@available(macOS 26.0, *)
@MainActor
@Observable
public class MemoryVaultManager {
    public private(set) var vault: ModernMemoryVault
    public private(set) var statistics: MemoryStatistics?
    
    public init() {
        self.vault = ModernMemoryVault()
        
        // Load statistics periodically
        Task {
            await updateStatistics()
        }
    }
    
    public func storeMemoryFromConsciousness(
        content: String,
        emotionalWeight: Double,
        consciousnessState: ModernConsciousnessEngine.ConsciousnessState
    ) async -> UUID {
        
        let context = ModernMemoryVault.ConsciousnessContext(
            awarenessLevel: consciousnessState.awarenessLevel,
            emotionalState: consciousnessState.emotionalState.primaryEmotion,
            activeProcesses: consciousnessState.activeProcesses,
            integrationQuality: consciousnessState.integrationQuality
        )
        
        let associations = generateAssociations(from: consciousnessState)
        let memoryType = determineMemoryType(from: content, consciousness: consciousnessState)
        
        return await vault.storeMemory(
            content: content,
            emotionalWeight: emotionalWeight,
            associations: associations,
            memoryType: memoryType,
            consciousnessContext: context
        )
    }
    
    public func searchMemories(query: String, limit: Int = 5) async -> [ModernMemoryVault.MemorySearchResult] {
        return await vault.searchMemories(query: query, limit: limit)
    }
    
    public func updateStatistics() async {
        statistics = await vault.getMemoryStatistics()
    }
    
    private func generateAssociations(from consciousness: ModernConsciousnessEngine.ConsciousnessState) -> [String] {
        var associations: [String] = []
        
        associations.append(consciousness.emotionalState.primaryEmotion)
        associations.append(contentsOf: consciousness.activeProcesses)
        associations.append(contentsOf: consciousness.moralInsights.map { extractKeyword($0) }.compactMap { $0 })
        associations.append(contentsOf: consciousness.logicalAnalysis.map { extractKeyword($0) }.compactMap { $0 })
        associations.append(contentsOf: consciousness.emergentPatterns.map { extractKeyword($0) }.compactMap { $0 })
        
        return Array(Set(associations)) // Remove duplicates
    }
    
    private func determineMemoryType(from content: String, consciousness: ModernConsciousnessEngine.ConsciousnessState) -> ModernMemoryVault.MemoryType {
        let contentLower = content.lowercased()
        
        if contentLower.contains("learn") || contentLower.contains("understand") {
            return .learning
        } else if contentLower.contains("feel") || consciousness.emotionalState.intensity > 0.7 {
            return .emotion
        } else if contentLower.contains("decide") || contentLower.contains("choose") {
            return .decision
        } else if consciousness.activeProcesses.contains("pattern_recognition") {
            return .pattern
        } else if consciousness.emergentPatterns.count > 0 {
            return .insight
        } else {
            return .experience
        }
    }
    
    private func extractKeyword(_ text: String) -> String? {
        let words = text.split(separator: " ")
        return words.first { $0.count > 3 }?.lowercased().trimmingCharacters(in: .punctuationCharacters)
    }
}
