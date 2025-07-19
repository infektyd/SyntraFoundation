import XCTest
@testable import Valon
@testable import Modi
@testable import Drift
@testable import MemoryEngine
@testable import SyntraConfig
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
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cfg.json")
        let json = """
        {"useAppleLLM": true, "appleLLMApiKey": "test-model"}
        """
        try json.write(to: tmp, atomically: true, encoding: .utf8)
        var cfg = try loadConfig(path: tmp.path)
        XCTAssertEqual(cfg.useAppleLLM, true)
        XCTAssertEqual(cfg.appleLLMApiKey, "test-model")

        setenv("APPLE_LLM_API_KEY", "env-model", 1)
        cfg = try loadConfig(path: tmp.path)
        XCTAssertEqual(cfg.useAppleLLM, true)
        XCTAssertEqual(cfg.appleLLMApiKey, "env-model")
        unsetenv("APPLE_LLM_API_KEY")
    }

    func testProcessThroughBrainsBasicStructure() async throws {
        // Test the basic structure without Apple LLM (since it requires macOS 26.0+)
        let result = await BrainEngine.processThroughBrains("hi")
        
        // Verify basic structure
        XCTAssertNotNil(result["valon"])
        XCTAssertNotNil(result["modi"])
        XCTAssertNotNil(result["consciousness"])
        XCTAssertNotNil(result["internal_dialogue"])
        
        // On macOS < 26.0, Apple LLM should either be absent or show compatibility message
        if let appleLLM = result["appleLLM"] as? String {
            XCTAssertTrue(appleLLM.contains("Apple LLM requires macOS 26.0+") || appleLLM.contains("not available"))
        }
    }
}
