// SyntraCLIWrapper.swift

import Foundation
import Modi
import Valon
import ConsciousnessStructures
import SyntraTools

public struct SyntraCLIWrapper {
    public enum SyntraError: Error, CustomStringConvertible {
        case executionFailed(String), badUTF8, timeout, notFound, platformNotSupported
        public var description: String {
            switch self {
            case .executionFailed(let details): return "CLI execution failed: \(details)"
            case .badUTF8: return "Output not valid UTF-8"
            case .timeout: return "CLI call timed out"
            case .notFound: return "Output not found"
            case .platformNotSupported: return "Non-macOS platform"
            }
        }
    }
    
    // SyntraCLIWrapper.swift (updated excerpt - added debugging)

    @discardableResult
    private static func runCLI(
        command: String,
        args: [String] = [],
        timeoutSeconds: Double = 60.0
    ) async throws -> String {
        #if os(macOS)
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                process.arguments = ["swift", "run", "SyntraSwiftCLI", command] + args
                let stdoutPipe = Pipe()
                let stderrPipe = Pipe()
                process.standardOutput = stdoutPipe
                process.standardError = stderrPipe
                
                print("🔧 [SyntraCLIWrapper] Running: \(["swift", "run", "SyntraSwiftCLI", command] + args)")
                do {
                    try process.run()
                    process.waitUntilExit()
                } catch {
                    throw SyntraError.executionFailed("Failed to start process: \(error.localizedDescription)")
                }
                
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                try? stdoutPipe.fileHandleForReading.close()
                try? stderrPipe.fileHandleForReading.close()
                
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                
                // Enhanced logging: Show all backend communication
                print("🔧 [SyntraCLIWrapper] Exit code: \(process.terminationStatus)")
                if !stdout.isEmpty { 
                    print("🔧 [SyntraCLIWrapper] STDOUT (\(stdout.count) chars): \(stdout.prefix(500))")
                    if stdout.count > 500 { print("🔧 [SyntraCLIWrapper] ...output truncated") }
                }
                if !stderr.isEmpty { 
                    print("🔧 [SyntraCLIWrapper] STDERR: \(stderr.prefix(500))")
                    if stderr.count > 500 { print("🔧 [SyntraCLIWrapper] ...stderr truncated") }
                }
                
                if process.terminationStatus != 0 {

                    let errorMsg = stderr.isEmpty ? "Process exited with code \(process.terminationStatus)" : stderr
                    throw SyntraError.executionFailed(errorMsg)
                }
                
                guard !stdout.isEmpty else {
                    throw SyntraError.notFound
                }
                
                return stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                throw SyntraError.timeout
            }
            
            guard let result = try await group.next() else {
                throw SyntraError.executionFailed("No result from task group")
            }
            
            group.cancelAll()
            return result
        }
        #else
        throw SyntraError.platformNotSupported
        #endif
    }

    
    // Public API shortcuts - UNCHANGED
    public static func processThroughBrains(_ input: String) async throws -> String {
        try await runCLI(command: "processThroughBrains", args: [input])
    }
    
    public static func processStructured(_ input: String) async throws -> String {
        try await runCLI(command: "processStructured", args: [input])
    }
    
    public static func reflectValon(_ input: String) async throws -> String {
        try await runCLI(command: "reflect_valon", args: [input])
    }
    
    public static func reflectModi(_ input: String) async throws -> String {
        try await runCLI(command: "reflect_modi", args: [input])
    }
    
    public static func chat(_ input: String) async throws -> String {
        try await runCLI(command: "chat", args: [input])
    }
    
    public static func checkAutonomy(_ input: String) async throws -> String {
        try await runCLI(command: "checkAutonomy", args: [input])
    }
    
    public static func processThroughBrainsWithDrift(_ input: String) async throws -> String {
        try await runCLI(command: "processThroughBrainsWithDrift", args: [input])
    }
    
    public static func testFoundationModel(_ prompt: String) async throws -> String {
        try await runCLI(command: "foundation_model", args: [prompt])
    }
    
    /// Enhanced analysis endpoint returning FlatJSONResponse
    public static func getEnhancedAnalysis(_ input: String) async throws -> FlatJSONResponse {
        let modi = Modi()
        let modiDist = modi.calculateEnhancedBayesian(input)
        let valonResponse = Valon.reflect_valon(input)
        let metrics = await ConsciousnessMemoryManager.shared.getEnhancedMetrics()
        
        let modiAnalysis = ModiAnalysis(
            probabilities: modiDist.probabilities,
            entropy: modiDist.entropy,
            prior: modiDist.prior,
            posterior: modiDist.posterior,
            likelihood: modiDist.likelihood
        )
        
        let valonAnalysis = ValonAnalysis(
            evaluation: valonResponse,
            emotionalWeight: 0.7
        )
        
        let metricsDict: [String: Double] = [
            "minValue": metrics.minValue,
            "maxValue": metrics.maxValue,
            "average": metrics.average,
            "standardDeviation": metrics.standardDeviation,
            "entropy": metrics.entropy,
            "driftScore": metrics.driftScore
        ]
        
        return FlatJSONResponse(
            modiAnalysis: modiAnalysis,
            valonAnalysis: valonAnalysis,
            metrics: metricsDict,
            timestamp: Date()
        )
    }
    
    // Health Check - ENHANCED
    public static func healthCheck() async -> Bool {
        #if os(macOS)
        do {
            let result = try await runCLI(command: "chat", args: ["ping"], timeoutSeconds: 15.0)
            return result.contains("PONG")
        } catch {
            print("🔧 [SyntraCLIWrapper] Health check failed: \(error)")
            return false
        }
        #else
        return false
        #endif
    }
}
