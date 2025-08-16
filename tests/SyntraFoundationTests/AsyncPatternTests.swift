import XCTest
import Atomics
import AsyncAlgorithms
@testable import SyntraTools

import XCTest
import Atomics
import AsyncAlgorithms
import Algorithms
@testable import SyntraTools
@testable import Modi

final class AsyncPatternTests: XCTestCase {
    
    func testBayesianProbabilityCalculations() async {
        let modi = Modi()
        let testText = "Measure voltage and current while checking safety protocols"
        
        let dist = modi.calculateDomainProbabilities(testText)
        
        // Verify probability distribution structure
        XCTAssertEqual(dist.domain, "technical_domains")
        XCTAssertGreaterThan(dist.probabilities.count, 0)
        XCTAssertGreaterThan(dist.prior.count, 0)
        XCTAssertGreaterThan(dist.posterior.count, 0)
        XCTAssertGreaterThan(dist.likelihood.count, 0)
        
        // Verify probabilities sum to ~1.0
        let totalProb = dist.probabilities.values.reduce(0, +)
        XCTAssertEqual(totalProb, 1.0, accuracy: 0.001)
        
        // Verify entropy is valid
        XCTAssertGreaterThanOrEqual(dist.entropy, 0)
    }
    
    func testEnhancedBayesianCalculations() async {
        let modi = Modi()
        let testText = "Measure voltage and current while checking safety protocols"
        
        let dist = modi.calculateEnhancedBayesian(testText)
        
        // Verify enhanced Bayesian analysis
        XCTAssertEqual(dist.domain, "technical_domains")
        XCTAssertGreaterThan(dist.probabilities.count, 0)
        XCTAssertGreaterThanOrEqual(dist.entropy, 0)
    }
    
    func testQuantitativeAnalysisMetrics() async {
        let modi = Modi()
        let testText = "Measure the voltage and current, then compare the ratio to safety protocols"
        
        // Test domain probabilities
        let domainProbs = modi.calculateDomainProbabilities(testText)
        XCTAssertGreaterThan(domainProbs.probabilities.count, 0, "Should detect at least one domain")
        XCTAssertNotNil(domainProbs.probabilities["electrical_systems"], "Should detect electrical domain")
        XCTAssertNotNil(domainProbs.probabilities["safety_protocols"], "Should detect safety domain")
        
        // Test quantitative metrics
        let metrics = modi.calculateQuantitativeMetrics(testText)
        XCTAssertGreaterThanOrEqual(metrics.minValue, 0, "Min value should be non-negative")
        XCTAssertGreaterThan(metrics.maxValue, 0, "Max value should be positive")
        XCTAssertGreaterThan(metrics.average, 0, "Average should be positive")
        XCTAssertGreaterThan(metrics.count, 0, "Count should be positive")
        XCTAssertGreaterThanOrEqual(metrics.entropy, 0, "Entropy should be non-negative")
    }
    
    func testAsyncAtomicBasicOperations() async {
        let atomic = AsyncAtomic(0)
        
        // Test initial value
        let initialValue = await atomic.get()
        XCTAssertEqual(initialValue, 0)
        
        // Test set and get
        await atomic.set(42)
        let afterSet = await atomic.get()
        XCTAssertEqual(afterSet, 42)
        
        // Test update
        await atomic.update { $0 + 1 }
        let afterUpdate = await atomic.get()
        XCTAssertEqual(afterUpdate, 43)
    }
    
    func testAsyncAtomicNotifications() async {
        let atomic = AsyncAtomic("initial")
        let expectation = expectation(description: "Value changed notification")
        
        Task {
            let newValue = await atomic.next()
            XCTAssertEqual(newValue, "updated")
            expectation.fulfill()
        }
        
        // Give the task time to start listening
        await Task.yield()
        
        // Change the value
        await atomic.set("updated")
        
        // Wait for notification
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testAsyncAtomicConcurrentAccess() async {
        let atomic = AsyncAtomic(0)
        let count = 100
        let expectation = expectation(description: "All updates complete")
        expectation.expectedFulfillmentCount = count

        // Launch concurrent updaters
        for _ in 0..<count {
            Task {
                await atomic.update { $0 + 1 }
                expectation.fulfill()
            }
        }

        // Wait for all updates
        await fulfillment(of: [expectation], timeout: 2.0)

        // Verify final value
        let finalValue = await atomic.get()
        XCTAssertEqual(finalValue, count)
    }
    
    func testConsciousnessMemoryCounters() async {
        let memory = ConsciousnessMemoryManager.shared
        let sessionID = await memory.startNewSession()
        
        // Test enhanced metrics before recording
        let initialMetrics = await memory.getEnhancedMetrics()
        XCTAssertEqual(initialMetrics.count, 0, "Initial count should be zero")
        
        // Test pattern statistics
        let (initialDetections, initialPatterns) = await memory.getPatternStatistics()
        XCTAssertEqual(initialDetections, 0, "Initial detections should be zero")
        XCTAssertEqual(initialPatterns.count, 0, "Initial patterns should be empty")
        
        // Create test interaction
        let interaction = BrainInteractionTriad(
            modiFramework: AnalyticalFramework(
                frameworkName: "test",
                parameters: ["param1": 0.5, "param2": 0.3]
            ),
            valonAssessment: EthicalEvaluation(
                evaluation: "test",
                emotionalWeight: 0.7
            ),
            syntraMapping: CreativeSynthesis(
                rawRepresentation: "test",
                analogies: []
            ),
            conflictPath: [],
            temporalContext: TemporalContextStamp(
                sessionUUID: sessionID,
                interactionSequence: 0,
                brainActivationLevels: [.modi: 0.3, .valon: 0.7]
            )
        )
        
        // Record interaction
        await memory.recordInteraction(interaction, sessionID: sessionID)
        
        // Check activation stats
        let stats = await memory.getActivationStatistics()
        XCTAssertGreaterThan(stats.valon, 0)
        XCTAssertGreaterThan(stats.modi, 0)
        XCTAssertGreaterThan(stats.syntra, 0)
        
        // Verify drift score is calculated
        XCTAssertGreaterThanOrEqual(stats.driftScore, 0)
        XCTAssertLessThanOrEqual(stats.driftScore, 0.3) // Should be close to 0 for 70/30 ratio
        
        // Test enhanced metrics
        let metrics = await memory.getEnhancedMetrics()
        XCTAssertGreaterThan(metrics.count, 0, "Should record metrics")
        XCTAssertGreaterThan(metrics.entropy, 0, "Should calculate entropy")
        
        // Test reset
        await memory.resetActivationCounters()
        let resetStats = await memory.getActivationStatistics()
        XCTAssertEqual(resetStats.valon, 0)
        XCTAssertEqual(resetStats.modi, 0)
        XCTAssertEqual(resetStats.syntra, 0)
        XCTAssertEqual(resetStats.driftScore, 0)
        
        // Verify metrics reset
        let resetMetrics = await memory.getEnhancedMetrics()
        XCTAssertEqual(resetMetrics.count, 0, "Metrics should reset")
    }
}
