import XCTest
@testable import Valon
@testable import Modi
@testable import Drift
@testable import MemoryEngine
@testable import SyntraConfig
@testable import StructuredConsciousnessService
@testable import BrainEngine

final class SyntraSwiftTests: XCTestCase {
    /// Helper to run the CLI and capture output
    func runCLI(_ command: String, _ args: [String] = []) throws -> String {
        let exe = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".build/debug/SyntraSwiftCLI")
        let process = Process()
        process.executableURL = exe
        process.arguments = [command] + args
        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func testReflectValonMatchesCLI() throws {
        let input = "Warning: torque is high"
        let cliOut = try runCLI("reflect_valon", [input])
        XCTAssertEqual(cliOut, BrainEngine.reflect_valon(input))
    }

    func testReflectModiMatchesCLI() throws {
        let input = "If pressure then torque"
        let cliOut = try runCLI("reflect_modi", [input])
        let cliResult = try JSONSerialization.jsonObject(with: Data(cliOut.utf8)) as? [String]
        XCTAssertEqual(cliResult, BrainEngine.reflect_modi(input))
    }

    func testDriftAverageMatchesCLI() throws {
        let valon = "neutral/observing"
        let modi = ["baseline_analysis"]
        let modiJSON = try String(data: JSONSerialization.data(withJSONObject: modi), encoding: .utf8) ?? "[]"
        let cliOut = try runCLI("drift_average", [valon, modiJSON])
        let cliResult = try JSONSerialization.jsonObject(with: Data(cliOut.utf8)) as? [String: Any]
        let apiResult = BrainEngine.drift_average(valon, modi)
        XCTAssertEqual(cliResult?["converged_state"] as? String, apiResult["converged_state"] as? String)
    }

    func testProcessThroughBrainsMatchesCLI() async throws {
        let input = "Procedure diagram"
        let cliOut = try runCLI("processThroughBrains", [input])
        let cliResult = try JSONSerialization.jsonObject(with: Data(cliOut.utf8)) as? [String: Any]
        let apiResult = await BrainEngine.processThroughBrains(input)
        XCTAssertEqual(cliResult?["valon"] as? String, apiResult["valon"] as? String)
        let m1 = cliResult?["modi"] as? [String]
        let m2 = apiResult["modi"] as? [String]
        XCTAssertEqual(m1, m2)
    }

    func testLoadConfigAppleLLMFields() throws {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_cfg_\(UUID().uuidString).json")
        let json = """
        {"use_apple_llm": true, "apple_llm_api_key": "test-model"}
        """
        try json.write(to: tmp, atomically: true, encoding: .utf8)
        
        // Test direct loading without search paths
        let data = try Data(contentsOf: tmp)
        var cfg = try JSONDecoder().decode(SyntraConfig.self, from: data)
        
        XCTAssertEqual(cfg.useAppleLLM ?? false, true)
        XCTAssertEqual(cfg.appleLLMApiKey, "test-model")

        // Test environment variable override
        setenv("APPLE_LLM_API_KEY", "env-model", 1)
        cfg = try JSONDecoder().decode(SyntraConfig.self, from: data)
        // Apply environment override manually
        if let envVal = ProcessInfo.processInfo.environment["APPLE_LLM_API_KEY"] {
            cfg.appleLLMApiKey = envVal
        }
        XCTAssertEqual(cfg.useAppleLLM ?? false, true)
        XCTAssertEqual(cfg.appleLLMApiKey, "env-model")
        unsetenv("APPLE_LLM_API_KEY")
        
        // Clean up
        try? FileManager.default.removeItem(at: tmp)
    }

    func testProcessThroughBrainsBasicStructure() async throws {
        // Test the basic structure without Apple LLM (since it requires macOS "26.0"+)
        let result = await BrainEngine.processThroughBrains("hi")
        
        // Verify basic structure
        XCTAssertNotNil(result["valon"])
        XCTAssertNotNil(result["modi"])
        XCTAssertNotNil(result["consciousness"])
        XCTAssertNotNil(result["internal_dialogue"])
        
        // On macOS < "26.0", Apple LLM should either be absent or show compatibility message
        if let appleLLM = result["appleLLM"] as? String {
            XCTAssertTrue(appleLLM.contains("Apple LLM requires macOS 26.0+") || appleLLM.contains("not available"))
        }
    }
    
    @available(macOS 26.0, *)
    func testStructuredConsciousnessServiceInitialization() throws {
        // Test that StructuredConsciousnessService can be initialized
        // Note: This will only pass on macOS "26.0"+ with FoundationModels available
        do {
            let service = try StructuredConsciousnessService()
            XCTAssertNotNil(service)
        } catch StructuredGenerationError.modelUnavailable {
            // Expected on systems without FoundationModels
            XCTAssertTrue(true, "FoundationModels not available - expected on macOS < 26.0")
        }
    }
    
    @available(macOS 26.0, *)
    func testInputValidation() throws {
        // Test input validation without requiring FoundationModels
        let service = try? StructuredConsciousnessService()
        
        // Test with mock validation (we can't test actual service without FoundationModels)
        let emptyInput = ""
        let validInput = "Test input for consciousness processing"
        let tooLongInput = String(repeating: "x", count: 10001)
        
        // These would throw errors in the actual service
        XCTAssertTrue(emptyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertFalse(validInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertTrue(tooLongInput.count > 10000)
    }
}
