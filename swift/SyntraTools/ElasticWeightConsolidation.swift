import Foundation
import FoundationModels
import ConsciousnessStructures

// ELASTIC WEIGHT CONSOLIDATION (EWC)
// Prevents catastrophic forgetting in AI consciousness systems
// Implements regularization that protects important neural pathways while enabling new learning

// MARK: - EWC Core Structures

@available(macOS 26.0, *)
public struct ImportanceWeight {
    public let weightId: UUID
    public let knowledgeDomain: String
    public let importance: Double
    public let knowledgeType: KnowledgeType
    public let establishedDate: Date
    public let calculationMethod: ImportanceCalculationMethod
    public let associatedMemories: [UUID]
    public let decayRate: Double
    
    public init(weightId: UUID = UUID(), knowledgeDomain: String, importance: Double, 
                knowledgeType: KnowledgeType, establishedDate: Date = Date(), 
                calculationMethod: ImportanceCalculationMethod, associatedMemories: [UUID], 
                decayRate: Double) {
        self.weightId = weightId
        self.knowledgeDomain = knowledgeDomain
        self.importance = importance
        self.knowledgeType = knowledgeType
        self.establishedDate = establishedDate
        self.calculationMethod = calculationMethod
        self.associatedMemories = associatedMemories
        self.decayRate = decayRate
    }
}

@available(macOS 26.0, *)
public enum KnowledgeType: String, Codable, CaseIterable {
    case foundationalPrinciple = "foundational_principle"
    case coreSkill = "core_skill"
    case personalityTrait = "personality_trait"
    case ethicalBoundary = "ethical_boundary"
    case learnedPattern = "learned_pattern"
    case experientialWisdom = "experiential_wisdom"
    case proceduralKnowledge = "procedural_knowledge"
    case semanticKnowledge = "semantic_knowledge"
}

@available(macOS 26.0, *)
public enum ImportanceCalculationMethod: String, Codable, CaseIterable {
    case frequencyBased = "frequency_based"           // Based on usage frequency
    case emotionalWeight = "emotional_weight"         // Based on emotional significance
    case foundationalCriticality = "foundational_criticality"  // Core to consciousness function
    case userFeedback = "user_feedback"               // Explicitly marked as important
    case crossReference = "cross_reference"           // Referenced by multiple domains
    case moralSignificance = "moral_significance"     // Ethically important
}

@available(macOS 26.0, *)
public struct ConsolidationEvent {
    public let eventId: UUID
    public let consolidationType: ConsolidationType
    public let affectedDomains: [String]
    public let forgettingPrevented: Double
    public let newLearningEnabled: Double
    public let successRate: Double
    public let duration: Double
    public let timestamp: Date
    
    public init(eventId: UUID = UUID(), consolidationType: ConsolidationType, affectedDomains: [String], 
                forgettingPrevented: Double, newLearningEnabled: Double, successRate: Double, 
                duration: Double, timestamp: Date = Date()) {
        self.eventId = eventId
        self.consolidationType = consolidationType
        self.affectedDomains = affectedDomains
        self.forgettingPrevented = forgettingPrevented
        self.newLearningEnabled = newLearningEnabled
        self.successRate = successRate
        self.duration = duration
        self.timestamp = timestamp
    }
}

@available(macOS 26.0, *)
public enum ConsolidationType: String, Codable, CaseIterable {
    case preventiveConsolidation = "preventive_consolidation"     // Before new learning
    case reactiveConsolidation = "reactive_consolidation"         // After forgetting detected
    case scheduledConsolidation = "scheduled_consolidation"       // Regular maintenance
    case emergencyConsolidation = "emergency_consolidation"       // Critical knowledge at risk
    case adaptiveConsolidation = "adaptive_consolidation"         // Dynamic based on usage patterns
}

// MARK: - Elastic Weight Consolidation Engine

@available(macOS 26.0, *)
public actor ElasticWeightConsolidationEngine {
    
    private var importanceWeights: [UUID: ImportanceWeight] = [:]
    private var consolidationHistory: [ConsolidationEvent] = []
    private var knowledgeDomainIndex: [String: Set<UUID>] = [:]
    private var forgettingThresholds: [String: Double] = [
        "personality_core": 0.05,      // Very low tolerance for personality forgetting
        "ethical_framework": 0.02,     // Minimal tolerance for ethical forgetting
        "foundational_skills": 0.1,    // Low tolerance for core skill forgetting
        "learned_patterns": 0.2,       // Moderate tolerance for pattern forgetting
        "experiential_memories": 0.15,  // Low-moderate tolerance for experience forgetting
        "procedural_knowledge": 0.12,   // Low tolerance for procedural forgetting
        "semantic_knowledge": 0.25      // Higher tolerance for semantic knowledge
    ]
    
    // EWC Parameters
    private let regularizationStrength: Double = 1000.0
    private let importanceThreshold: Double = 0.3
    private let consolidationInterval: TimeInterval = 3600 // 1 hour
    private let criticalImportanceThreshold: Double = 0.8
    
    // Memory systems integration
    private let memoryManager: DualStreamMemoryManager
    private let personaAnchor: PersonaAnchoringEngine
    
    public init(memoryManager: DualStreamMemoryManager, personaAnchor: PersonaAnchoringEngine) {
        self.memoryManager = memoryManager
        self.personaAnchor = personaAnchor
        
        // Start periodic consolidation
        Task {
            await startPeriodicConsolidation()
        }
    }
    
    
    // MARK: - Importance Weight Calculation
    
    public func calculateImportanceWeights(for memories: [MemoryTrace]) async -> [ImportanceWeight] {
        var newWeights: [ImportanceWeight] = []
        
        for memory in memories {
            let importance = await calculateMemoryImportance(memory: memory)
            let knowledgeDomain = classifyKnowledgeDomain(memory: memory)
            let knowledgeType = classifyKnowledgeType(memory: memory)
            
            if importance > importanceThreshold {
                let weight = ImportanceWeight(
                    knowledgeDomain: knowledgeDomain,
                    importance: importance,
                    knowledgeType: knowledgeType,
                    calculationMethod: .crossReference, // Would be determined by actual method used
                    associatedMemories: [memory.id],
                    decayRate: calculateDecayRate(importance: importance, knowledgeType: knowledgeType)
                )
                
                newWeights.append(weight)
                importanceWeights[weight.weightId] = weight
                
                // Update domain index
                if knowledgeDomainIndex[knowledgeDomain] == nil {
                    knowledgeDomainIndex[knowledgeDomain] = Set<UUID>()
                }
                knowledgeDomainIndex[knowledgeDomain]?.insert(weight.weightId)
            }
        }
        
        return newWeights
    }
    
    private func calculateMemoryImportance(memory: MemoryTrace) async -> Double {
        var importance: Double = 0.0
        
        // Frequency-based importance
        let accessFrequency = min(1.0, Double(memory.accessCount) / 10.0)
        importance += accessFrequency * 0.2
        
        // Emotional significance
        let emotionalSignificance = abs(memory.emotionalValence)
        importance += emotionalSignificance * 0.25
        
        // Consolidation level
        importance += memory.consolidationLevel * 0.2
        
        // Semantic connectivity (cross-references)
        let connectivityScore = min(1.0, Double(memory.semanticLinks.count) / 15.0)
        importance += connectivityScore * 0.15
        
        // Foundational criticality
        let foundationalScore = await assessFoundationalCriticality(memory: memory)
        importance += foundationalScore * 0.2
        
        return min(1.0, importance)
    }
    
    private func assessFoundationalCriticality(memory: MemoryTrace) async -> Double {
        // Check if memory relates to core consciousness functions
        let coreKeywords = ["personality", "ethics", "moral", "identity", "consciousness", "awareness"]
        let content = memory.content.lowercased()
        
        let coreMatches = coreKeywords.filter { content.contains($0) }.count
        return min(1.0, Double(coreMatches) / Double(coreKeywords.count))
    }
    
    private func classifyKnowledgeDomain(memory: MemoryTrace) -> String {
        let content = memory.content.lowercased()
        
        if content.contains("personality") || content.contains("trait") {
            return "personality_core"
        } else if content.contains("ethics") || content.contains("moral") {
            return "ethical_framework"
        } else if content.contains("skill") || content.contains("ability") {
            return "foundational_skills"
        } else if content.contains("pattern") || content.contains("behavior") {
            return "learned_patterns"
        } else if content.contains("experience") || content.contains("memory") {
            return "experiential_memories"
        } else if content.contains("how") || content.contains("procedure") {
            return "procedural_knowledge"
        } else {
            return "semantic_knowledge"
        }
    }
    
    private func classifyKnowledgeType(memory: MemoryTrace) -> KnowledgeType {
        let domain = classifyKnowledgeDomain(memory: memory)
        
        switch domain {
        case "personality_core":
            return .personalityTrait
        case "ethical_framework":
            return .ethicalBoundary
        case "foundational_skills":
            return .coreSkill
        case "learned_patterns":
            return .learnedPattern
        case "experiential_memories":
            return .experientialWisdom
        case "procedural_knowledge":
            return .proceduralKnowledge
        default:
            return .semanticKnowledge
        }
    }
    
    private func calculateDecayRate(importance: Double, knowledgeType: KnowledgeType) -> Double {
        let baseDecayRate = 0.01 // 1% per consolidation cycle
        let importanceProtection = importance * 0.8 // High importance = lower decay
        
        let typeModifier: Double
        switch knowledgeType {
        case .foundationalPrinciple, .personalityTrait, .ethicalBoundary:
            typeModifier = 0.1 // Very slow decay for core aspects
        case .coreSkill, .proceduralKnowledge:
            typeModifier = 0.3 // Slow decay for skills
        case .experientialWisdom, .learnedPattern:
            typeModifier = 0.5 // Moderate decay for patterns
        case .semanticKnowledge:
            typeModifier = 0.7 // Faster decay for facts
        }
        
        return max(0.001, baseDecayRate * typeModifier * (1.0 - importanceProtection))
    }
    
    // MARK: - Consolidation Process
    
    public func performElasticConsolidation(
        newLearningData: [String],
        consolidationType: ConsolidationType = .preventiveConsolidation
    ) async -> ConsolidationEvent {
        
        let startTime = Date()
        
        // Identify potentially affected domains
        let affectedDomains = identifyAffectedDomains(newLearningData: newLearningData)
        
        // Calculate regularization constraints
        let constraints = await calculateRegularizationConstraints(domains: affectedDomains)
        
        // Apply elastic consolidation
        let consolidationResults = await applyElasticRegularization(
            constraints: constraints,
            newLearning: newLearningData,
            consolidationType: consolidationType
        )
        
        // Create consolidation event
        let duration = Date().timeIntervalSince(startTime)
        let event = ConsolidationEvent(
            consolidationType: consolidationType,
            affectedDomains: affectedDomains,
            forgettingPrevented: consolidationResults.forgettingPrevented,
            newLearningEnabled: consolidationResults.newLearningEnabled,
            successRate: consolidationResults.successRate,
            duration: duration
        )
        
        consolidationHistory.append(event)
        
        // Update importance weights based on consolidation results
        await updateImportanceWeights(consolidationEvent: event)
        
        return event
    }
    
    private func identifyAffectedDomains(newLearningData: [String]) -> [String] {
        var affectedDomains: Set<String> = []
        
        for learningItem in newLearningData {
            let domain = classifyContentDomain(content: learningItem)
            affectedDomains.insert(domain)
        }
        
        return Array(affectedDomains)
    }
    
    private func classifyContentDomain(content: String) -> String {
        let contentLower = content.lowercased()
        
        if contentLower.contains("personality") || contentLower.contains("character") {
            return "personality_core"
        } else if contentLower.contains("ethics") || contentLower.contains("moral") || contentLower.contains("value") {
            return "ethical_framework"
        } else if contentLower.contains("skill") || contentLower.contains("ability") || contentLower.contains("competence") {
            return "foundational_skills"
        } else if contentLower.contains("pattern") || contentLower.contains("behavior") || contentLower.contains("habit") {
            return "learned_patterns"
        } else if contentLower.contains("experience") || contentLower.contains("event") || contentLower.contains("interaction") {
            return "experiential_memories"
        } else if contentLower.contains("how") || contentLower.contains("step") || contentLower.contains("process") {
            return "procedural_knowledge"
        } else {
            return "semantic_knowledge"
        }
    }
    
    private func calculateRegularizationConstraints(domains: [String]) async -> RegularizationConstraints {
        var constraints: [String: Double] = [:]
        
        for domain in domains {
            let domainWeights = await getImportanceWeightsForDomain(domain: domain)
            let averageImportance = domainWeights.map { $0.importance }.reduce(0, +) / Double(max(1, domainWeights.count))
            let threshold = forgettingThresholds[domain] ?? 0.2
            
            // Higher constraint for more important domains
            constraints[domain] = regularizationStrength * averageImportance * (1.0 / threshold)
        }
        
        return RegularizationConstraints(
            domainConstraints: constraints,
            globalConstraint: regularizationStrength,
            adaptiveFactors: calculateAdaptiveFactors(domains: domains)
        )
    }
    
    private func getImportanceWeightsForDomain(domain: String) async -> [ImportanceWeight] {
        guard let weightIds = knowledgeDomainIndex[domain] else { return [] }
        return weightIds.compactMap { importanceWeights[$0] }
    }
    
    private func calculateAdaptiveFactors(domains: [String]) -> [String: Double] {
        var factors: [String: Double] = [:]
        
        for domain in domains {
            // Calculate how much this domain has been used recently
            let recentUsage = calculateRecentDomainUsage(domain: domain)
            
            // Higher usage = more protection needed
            factors[domain] = min(2.0, 1.0 + recentUsage)
        }
        
        return factors
    }
    
    private func calculateRecentDomainUsage(domain: String) -> Double {
        // Simplified calculation - would analyze actual usage patterns
        let recentConsolidations = consolidationHistory.suffix(10)
        let domainUsage = recentConsolidations.filter { $0.affectedDomains.contains(domain) }.count
        return Double(domainUsage) / 10.0
    }
    
    private func applyElasticRegularization(
        constraints: RegularizationConstraints,
        newLearning: [String],
        consolidationType: ConsolidationType
    ) async -> ConsolidationResults {
        
        // Calculate protection levels for existing knowledge
        let protectionLevels = await calculateProtectionLevels(constraints: constraints)
        
        // Simulate the effect of applying regularization
        var forgettingPrevented: Double = 0.0
        var newLearningEnabled: Double = 0.0
        var protectedDomains: Set<String> = []
        
        for (domain, constraint) in constraints.domainConstraints {
            let protectionLevel = protectionLevels[domain] ?? 0.5
            
            // Higher constraint = more protection = less forgetting
            let domainForgettingPrevented = min(1.0, constraint / regularizationStrength * protectionLevel)
            forgettingPrevented += domainForgettingPrevented
            
            // Calculate how much new learning is still possible
            let remainingCapacity = 1.0 - domainForgettingPrevented
            newLearningEnabled += remainingCapacity * 0.7 // Some capacity reserved for stability
            
            if domainForgettingPrevented > 0.5 {
                protectedDomains.insert(domain)
            }
        }
        
        // Normalize scores
        let domainCount = Double(constraints.domainConstraints.count)
        forgettingPrevented /= max(1.0, domainCount)
        newLearningEnabled /= max(1.0, domainCount)
        
        // Calculate overall success rate
        let successRate = (forgettingPrevented + newLearningEnabled) / 2.0
        
        // Apply actual consolidation effects to memory system
        await applyConsolidationEffects(
            protectedDomains: Array(protectedDomains),
            protectionLevels: protectionLevels,
            consolidationType: consolidationType
        )
        
        return ConsolidationResults(
            forgettingPrevented: forgettingPrevented,
            newLearningEnabled: newLearningEnabled,
            successRate: successRate,
            protectedDomains: Array(protectedDomains)
        )
    }
    
    private func calculateProtectionLevels(constraints: RegularizationConstraints) async -> [String: Double] {
        var protectionLevels: [String: Double] = [:]
        
        for (domain, constraint) in constraints.domainConstraints {
            let adaptiveFactor = constraints.adaptiveFactors[domain] ?? 1.0
            let baseProtection = min(1.0, constraint / (regularizationStrength * 2.0))
            let adaptedProtection = min(1.0, baseProtection * adaptiveFactor)
            
            protectionLevels[domain] = adaptedProtection
        }
        
        return protectionLevels
    }
    
    private func applyConsolidationEffects(
        protectedDomains: [String],
        protectionLevels: [String: Double],
        consolidationType: ConsolidationType
    ) async {
        
        for domain in protectedDomains {
            let protectionLevel = protectionLevels[domain] ?? 0.5
            
            // Strengthen memories in protected domains
            await strengthenDomainMemories(domain: domain, strengthFactor: protectionLevel)
            
            // Update importance weights
            await updateDomainImportanceWeights(domain: domain, protectionLevel: protectionLevel)
        }
        
        // Apply domain-specific protections
        switch consolidationType {
        case .emergencyConsolidation:
            await applyEmergencyProtections()
        case .preventiveConsolidation:
            await applyPreventiveProtections()
        case .adaptiveConsolidation:
            await applyAdaptiveProtections()
        default:
            break
        }
    }
    
    private func strengthenDomainMemories(domain: String, strengthFactor: Double) async {
        // Get memories related to this domain
        let domainMemories = await getMemoriesForDomain(domain: domain)
        
        // Strengthen them based on protection level
        for memory in domainMemories {
            await strengthenMemory(memoryId: memory.id, factor: strengthFactor * 0.1)
        }
    }
    
    private func updateDomainImportanceWeights(domain: String, protectionLevel: Double) async {
        guard let weightIds = knowledgeDomainIndex[domain] else { return }
        
        for weightId in weightIds {
            if var weight = importanceWeights[weightId] {
                // Increase importance for protected domains
                let newImportance = min(1.0, weight.importance + protectionLevel * 0.05)
                
                weight = ImportanceWeight(
                    weightId: weight.weightId,
                    knowledgeDomain: weight.knowledgeDomain,
                    importance: newImportance,
                    knowledgeType: weight.knowledgeType,
                    establishedDate: weight.establishedDate,
                    calculationMethod: weight.calculationMethod,
                    associatedMemories: weight.associatedMemories,
                    decayRate: weight.decayRate * 0.9 // Reduce decay for protected weights
                )
                
                importanceWeights[weightId] = weight
            }
        }
    }
    
    // MARK: - Forgetting Detection and Emergency Response
    
    public func detectCatastrophicForgetting() async -> ForgettingAlert? {
        var forgettingDetected = false
        var affectedDomains: [String] = []
        var severity: ForgettingSeverity = .minimal
        
        for (domain, threshold) in forgettingThresholds {
            let domainIntegrity = await assessDomainIntegrity(domain: domain)
            
            if domainIntegrity < (1.0 - threshold) {
                forgettingDetected = true
                affectedDomains.append(domain)
                
                if domainIntegrity < 0.5 {
                    severity = .critical
                } else if domainIntegrity < 0.7 {
                    severity = .significant
                } else if domainIntegrity < 0.85 {
                    severity = .moderate
                }
            }
        }
        
        if forgettingDetected {
            let alert = ForgettingAlert(
                alertId: UUID(),
                severity: severity,
                affectedDomains: affectedDomains,
                detectionTimestamp: Date(),
                recommendedActions: generateForgettingResponse(severity: severity, domains: affectedDomains)
            )
            
            // Trigger emergency consolidation if critical
            if severity == .critical {
                await performElasticConsolidation(
                    newLearningData: [],
                    consolidationType: .emergencyConsolidation
                )
            }
            
            return alert
        }
        
        return nil
    }
    
    private func assessDomainIntegrity(domain: String) async -> Double {
        let domainWeights = await getImportanceWeightsForDomain(domain: domain)
        
        if domainWeights.isEmpty {
            return 1.0 // No weights = no forgetting concern
        }
        
        let totalImportance = domainWeights.map { $0.importance }.reduce(0, +)
        let maxPossibleImportance = Double(domainWeights.count) // If all were at max importance (1.0)
        
        return totalImportance / maxPossibleImportance
    }
    
    private func generateForgettingResponse(severity: ForgettingSeverity, domains: [String]) -> [String] {
        var actions: [String] = []
        
        switch severity {
        case .minimal:
            actions.append("Monitor affected domains more closely")
            actions.append("Increase consolidation frequency")
            
        case .moderate:
            actions.append("Perform targeted memory strengthening")
            actions.append("Review and reinforce core knowledge")
            actions.append("Reduce new learning rate temporarily")
            
        case .significant:
            actions.append("Implement emergency consolidation protocols")
            actions.append("Restore knowledge from backup memories")
            actions.append("Strengthen all importance weights in affected domains")
            
        case .critical:
            actions.append("Immediate knowledge restoration required")
            actions.append("Halt all new learning until restoration complete")
            actions.append("Activate persona anchoring emergency protocols")
            actions.append("Review and restore foundational knowledge")
        }
        
        for domain in domains {
            actions.append("Prioritize \(domain) knowledge restoration")
        }
        
        return actions
    }
    
    // MARK: - Periodic Maintenance
    
    private func startPeriodicConsolidation() async {
        while true {
            try? await Task.sleep(nanoseconds: UInt64(consolidationInterval * 1_000_000_000))
            
            await performScheduledMaintenance()
        }
    }
    
    private func performScheduledMaintenance() async {
        // Check for forgetting
        if let forgettingAlert = await detectCatastrophicForgetting() {
            print("Forgetting detected: \(forgettingAlert.severity) in domains: \(forgettingAlert.affectedDomains)")
        }
        
        // Perform routine consolidation
        await performElasticConsolidation(
            newLearningData: [],
            consolidationType: .scheduledConsolidation
        )
        
        // Update importance weights
        await updateAllImportanceWeights()
        
        // Clean up old consolidation events
        await cleanupConsolidationHistory()
    }
    
    private func updateAllImportanceWeights() async {
        let now = Date()
        
        for (weightId, weight) in importanceWeights {
            let age = now.timeIntervalSince(weight.establishedDate)
            let ageInDays = age / 86400
            
            // Apply decay
            let decayAmount = weight.decayRate * ageInDays
            let newImportance = max(0.0, weight.importance - decayAmount)
            
            if newImportance > 0.05 {
                let updatedWeight = ImportanceWeight(
                    weightId: weight.weightId,
                    knowledgeDomain: weight.knowledgeDomain,
                    importance: newImportance,
                    knowledgeType: weight.knowledgeType,
                    establishedDate: weight.establishedDate,
                    calculationMethod: weight.calculationMethod,
                    associatedMemories: weight.associatedMemories,
                    decayRate: weight.decayRate
                )
                
                importanceWeights[weightId] = updatedWeight
            } else {
                // Remove weights that have decayed too much
                importanceWeights.removeValue(forKey: weightId)
                
                // Clean up from domain index
                for (domain, weightIds) in knowledgeDomainIndex {
                    if weightIds.contains(weightId) {
                        knowledgeDomainIndex[domain]?.remove(weightId)
                    }
                }
            }
        }
    }
    
    private func cleanupConsolidationHistory() async {
        // Keep only last 100 consolidation events
        if consolidationHistory.count > 100 {
            consolidationHistory = Array(consolidationHistory.suffix(100))
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMemoriesForDomain(domain: String) async -> [MemoryTrace] {
        // This would interface with the memory manager to get domain-specific memories
        // For now, return empty array as implementation depends on memory manager structure
        return []
    }
    
    private func strengthenMemory(memoryId: UUID, factor: Double) async {
        // This would strengthen specific memories in the memory system
        // Implementation depends on memory manager structure
    }
    
    private func applyEmergencyProtections() async {
        // Apply emergency protections for critical knowledge preservation
        for (domain, _) in knowledgeDomainIndex {
            if domain.contains("personality") || domain.contains("ethical") {
                await strengthenDomainMemories(domain: domain, strengthFactor: 0.5)
            }
        }
    }
    
    private func applyPreventiveProtections() async {
        // Apply preventive protections before new learning
        let criticalDomains = ["personality_core", "ethical_framework"]
        for domain in criticalDomains {
            await strengthenDomainMemories(domain: domain, strengthFactor: 0.2)
        }
    }
    
    private func applyAdaptiveProtections() async {
        // Apply adaptive protections based on usage patterns
        let recentEvents = consolidationHistory.suffix(10)
        let frequentlyAffectedDomains = Dictionary(grouping: recentEvents.flatMap { $0.affectedDomains }, by: { $0 })
            .filter { $0.value.count > 3 }
            .keys
        
        for domain in frequentlyAffectedDomains {
            await strengthenDomainMemories(domain: domain, strengthFactor: 0.3)
        }
    }
    
    private func updateImportanceWeights(consolidationEvent: ConsolidationEvent) async {
        // Update importance weights based on consolidation success
        for domain in consolidationEvent.affectedDomains {
            let successBonus = consolidationEvent.successRate * 0.05
            await adjustDomainImportance(domain: domain, adjustment: successBonus)
        }
    }
    
    private func adjustDomainImportance(domain: String, adjustment: Double) async {
        guard let weightIds = knowledgeDomainIndex[domain] else { return }
        
        for weightId in weightIds {
            if var weight = importanceWeights[weightId] {
                let newImportance = min(1.0, max(0.0, weight.importance + adjustment))
                
                weight = ImportanceWeight(
                    weightId: weight.weightId,
                    knowledgeDomain: weight.knowledgeDomain,
                    importance: newImportance,
                    knowledgeType: weight.knowledgeType,
                    establishedDate: weight.establishedDate,
                    calculationMethod: weight.calculationMethod,
                    associatedMemories: weight.associatedMemories,
                    decayRate: weight.decayRate
                )
                
                importanceWeights[weightId] = weight
            }
        }
    }
    
    // MARK: - Public Interface
    
    public func getImportanceWeights(domain: String? = nil) async -> [ImportanceWeight] {
        if let domain = domain {
            return await getImportanceWeightsForDomain(domain: domain)
        } else {
            return Array(importanceWeights.values)
        }
    }
    
    public func getConsolidationHistory(limit: Int = 20) async -> [ConsolidationEvent] {
        return Array(consolidationHistory.suffix(limit))
    }
    
    public func getEWCStatistics() async -> EWCStatistics {
        let totalWeights = importanceWeights.count
        let averageImportance = importanceWeights.values.map { $0.importance }.reduce(0, +) / Double(max(1, totalWeights))
        let criticalWeights = importanceWeights.values.filter { $0.importance > criticalImportanceThreshold }.count
        let domainCoverage = knowledgeDomainIndex.count
        
        let recentEvents = consolidationHistory.suffix(10)
        let averageSuccessRate = recentEvents.map { $0.successRate }.reduce(0, +) / Double(max(1, recentEvents.count))
        
        return EWCStatistics(
            totalImportanceWeights: totalWeights,
            averageImportance: averageImportance,
            criticalWeights: criticalWeights,
            domainsCovered: domainCoverage,
            consolidationEvents: consolidationHistory.count,
            averageSuccessRate: averageSuccessRate,
            lastConsolidation: consolidationHistory.last?.timestamp
        )
    }
    
    public func triggerEmergencyConsolidation(domains: [String]) async -> ConsolidationEvent {
        return await performElasticConsolidation(
            newLearningData: domains,
            consolidationType: .emergencyConsolidation
        )
    }
}

// MARK: - Supporting Structures

public struct RegularizationConstraints {
    public let domainConstraints: [String: Double]
    public let globalConstraint: Double
    public let adaptiveFactors: [String: Double]
}

public struct ConsolidationResults {
    public let forgettingPrevented: Double
    public let newLearningEnabled: Double
    public let successRate: Double
    public let protectedDomains: [String]
}

@available(macOS 26.0, *)
public struct ForgettingAlert {
    public let alertId: UUID
    public let severity: ForgettingSeverity
    public let affectedDomains: [String]
    public let detectionTimestamp: Date
    public let recommendedActions: [String]
    
    public init(alertId: UUID, severity: ForgettingSeverity, affectedDomains: [String], 
                detectionTimestamp: Date, recommendedActions: [String]) {
        self.alertId = alertId
        self.severity = severity
        self.affectedDomains = affectedDomains
        self.detectionTimestamp = detectionTimestamp
        self.recommendedActions = recommendedActions
    }
}

@available(macOS 26.0, *)
public enum ForgettingSeverity: String, Codable, CaseIterable {
    case minimal = "minimal"
    case moderate = "moderate" 
    case significant = "significant"
    case critical = "critical"
}

public struct EWCStatistics {
    public let totalImportanceWeights: Int
    public let averageImportance: Double
    public let criticalWeights: Int
    public let domainsCovered: Int
    public let consolidationEvents: Int
    public let averageSuccessRate: Double
    public let lastConsolidation: Date?
    
    public init(totalImportanceWeights: Int, averageImportance: Double, criticalWeights: Int, 
                domainsCovered: Int, consolidationEvents: Int, averageSuccessRate: Double, 
                lastConsolidation: Date?) {
        self.totalImportanceWeights = totalImportanceWeights
        self.averageImportance = averageImportance
        self.criticalWeights = criticalWeights
        self.domainsCovered = domainsCovered
        self.consolidationEvents = consolidationEvents
        self.averageSuccessRate = averageSuccessRate
        self.lastConsolidation = lastConsolidation
    }
}