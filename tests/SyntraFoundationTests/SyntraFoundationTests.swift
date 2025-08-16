import XCTest
import Atomics
@testable import SyntraCore
@testable import SyntraTools
@testable import ConsciousnessStructures

@MainActor
final class SyntraFoundationTests: XCTestCase {
    
    func testSyntraCoreInitialization() {
        let core = SyntraCore.shared
        
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
        XCTAssertEqual(core.moralWeight, 0.7)
        XCTAssertEqual(core.logicalWeight, 0.3)
        XCTAssertFalse(core.isProcessing)
    }
    
    func testConsciousnessProcessing() async {
        let core = SyntraCore.shared
        let testInput = "Hello, how are you?"
        
        let response = await core.processWithValonModi(testInput)
        
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("SYNTRA Consciousness Response"))
        XCTAssertFalse(core.isProcessing)
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
    }
    
    func testDeviceAvailability() {
        let core = SyntraCore.shared
        
        // This will depend on the device running the test
        let isAvailable = core.isAvailable
        print("Device availability: \\(isAvailable)")
        print("CPU cores: \\(ProcessInfo.processInfo.processorCount)")
        print("Memory: \\(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")
        
        // Basic test that the property is accessible
        XCTAssertNotNil(isAvailable)
    }
    
    func testConsciousnessReset() {
        let core = SyntraCore.shared
        
        // Modify state
        core.consciousnessState = "test_state"
        core.lastResponse = "test_response"
        
        // Reset
        core.reset()
        
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
        XCTAssertEqual(core.lastResponse, "")
        XCTAssertFalse(core.isProcessing)
    }
    
    // MARK: - ConsciousnessMemoryManager Tests
    
    func testMemoryManagerSessionCounting() async {
        let manager = ConsciousnessMemoryManager.shared
        
        let initialCount = await manager.getTotalSessions()
        let sessionID = await manager.startNewSession()
        let newCount = await manager.getTotalSessions()
        
        XCTAssertEqual(newCount, initialCount + 1)
        XCTAssertNotEqual(sessionID, UUID())
    }
    
    func testMemoryManagerInteractionCounting() async {
        let manager = ConsciousnessMemoryManager.shared
        let sessionID = await manager.startNewSession()
        
        let initialCount = await manager.getTotalInteractions()
        
        let interaction = BrainInteractionTriad(
            modiFramework: AnalyticalFramework(frameworkName: "test", parameters: [:]),
            valonAssessment: EthicalEvaluation(evaluation: "test", emotionalWeight: 0.5),
            syntraMapping: CreativeSynthesis(rawRepresentation: "test", analogies: []),
            conflictPath: [],
            temporalContext: TemporalContextStamp(
                sessionUUID: sessionID,
                interactionSequence: 0,
                brainActivationLevels: [.modi: 0.5, .valon: 0.5]
            )
        )
        
        await manager.recordInteraction(interaction, sessionID: sessionID)
        let newCount = await manager.getTotalInteractions()
        
        XCTAssertEqual(newCount, initialCount + 1)
    }
    
    func testPatternAnalysis() async {
        let manager = ConsciousnessMemoryManager.shared
        let sessionID = await manager.startNewSession()
        
        // Create test interactions with repeating patterns
        let framework = AnalyticalFramework(frameworkName: "test_framework", parameters: [:])
        let evaluation = EthicalEvaluation(evaluation: "test_evaluation", emotionalWeight: 0.5)
        
        for i in 0..<5 {
            let interaction = BrainInteractionTriad(
                modiFramework: framework,
                valonAssessment: evaluation,
                syntraMapping: CreativeSynthesis(rawRepresentation: "test_\(i)", analogies: []),
                conflictPath: [],
                temporalContext: TemporalContextStamp(
                    sessionUUID: sessionID,
                    interactionSequence: i,
                    brainActivationLevels: [.modi: 0.5, .valon: 0.5]
                )
            )
            await manager.recordInteraction(interaction, sessionID: sessionID)
        }
        
        let patterns = await manager.analyzeInteractionPatterns(sessionID: sessionID)
        let stats = await manager.getPatternStatistics()
        
        XCTAssertEqual(patterns.count, 2) // Should find both framework and emotional patterns
        XCTAssertEqual(stats.totalDetections, 2)
        XCTAssertEqual(stats.commonPatterns["framework:test_framework"], 1)
        XCTAssertEqual(stats.commonPatterns["emotional:test_evaluation"], 1)
    }
    
    // MARK: - Collection Migration Tests
    
    func testOrderedDictionaryBehavior() async {
        let manager = ConsciousnessMemoryManager.shared
        let sessionID1 = await manager.startNewSession()
        let sessionID2 = await manager.startNewSession()
        
        // Create test interaction with specific content
        let inter1 = BrainInteractionTriad(
            modiFramework: AnalyticalFramework(frameworkName: "first", parameters: [:]),
            valonAssessment: EthicalEvaluation(evaluation: "first", emotionalWeight: 0.5),
            syntraMapping: CreativeSynthesis(rawRepresentation: "first", analogies: []),
            conflictPath: [],
            temporalContext: TemporalContextStamp(
                sessionUUID: sessionID1,
                interactionSequence: 0,
                brainActivationLevels: [.modi: 0.5, .valon: 0.5]
            )
        )
        
        let inter2 = BrainInteractionTriad(
            modiFramework: AnalyticalFramework(frameworkName: "second", parameters: [:]),
            valonAssessment: EthicalEvaluation(evaluation: "second", emotionalWeight: 0.5),
            syntraMapping: CreativeSynthesis(rawRepresentation: "second", analogies: []),
            conflictPath: [],
            temporalContext: TemporalContextStamp(
                sessionUUID: sessionID2,
                interactionSequence: 0,
                brainActivationLevels: [.modi: 0.5, .valon: 0.5]
            )
        )
        
        // Verify order by checking pattern analysis (should process in insertion order)
        await manager.recordInteraction(inter1, sessionID: sessionID1)
        await manager.recordInteraction(inter2, sessionID: sessionID2)
        let patterns = await manager.analyzeInteractionPatterns(sessionID: sessionID1)
        XCTAssertTrue(patterns.contains("framework:first"))
    }
    
    func testDequeBehavior() async {
        let manager = ConsciousnessMemoryManager.shared
        let sessionID = await manager.startNewSession()
        let interaction = BrainInteractionTriad(
            modiFramework: AnalyticalFramework(frameworkName: "test", parameters: [:]),
            valonAssessment: EthicalEvaluation(evaluation: "test", emotionalWeight: 0.5),
            syntraMapping: CreativeSynthesis(rawRepresentation: "test", analogies: []),
            conflictPath: [],
            temporalContext: TemporalContextStamp(
                sessionUUID: sessionID,
                interactionSequence: 0,
                brainActivationLevels: [.modi: 0.5, .valon: 0.5]
            )
        )
        
        await manager.recordInteraction(interaction, sessionID: sessionID)
        let patterns = await manager.analyzeInteractionPatterns(sessionID: sessionID)
        
        XCTAssertEqual(patterns.count, 2) // Should find framework/test and emotional/test
    }
}
