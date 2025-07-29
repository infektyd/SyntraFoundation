import XCTest
@testable import SyntraCore

@MainActor
final class SyntraFoundationTests: XCTestCase {
    
    func testSyntraCoreInitialization() {
        let core = SyntraCore()
        
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
        XCTAssertEqual(core.moralWeight, 0.7)
        XCTAssertEqual(core.logicalWeight, 0.3)
        XCTAssertFalse(core.isProcessing)
    }
    
    func testConsciousnessProcessing() async {
        let core = SyntraCore()
        let testInput = "Hello, how are you?"
        
        let response = await core.processWithValonModi(testInput)
        
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(response.contains("SYNTRA Consciousness Response"))
        XCTAssertFalse(core.isProcessing)
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
    }
    
    func testDeviceAvailability() {
        let core = SyntraCore()
        
        // This will depend on the device running the test
        let isAvailable = core.isAvailable
        print("Device availability: \\(isAvailable)")
        print("CPU cores: \\(ProcessInfo.processInfo.processorCount)")
        print("Memory: \\(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")
        
        // Basic test that the property is accessible
        XCTAssertNotNil(isAvailable)
    }
    
    func testConsciousnessReset() {
        let core = SyntraCore()
        
        // Modify state
        core.consciousnessState = "test_state"
        core.lastResponse = "test_response"
        
        // Reset
        core.reset()
        
        XCTAssertEqual(core.consciousnessState, "contemplative_neutral")
        XCTAssertEqual(core.lastResponse, "")
        XCTAssertFalse(core.isProcessing)
    }
} 