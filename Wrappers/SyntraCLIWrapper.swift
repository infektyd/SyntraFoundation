// SyntraCLIWrapper.swift
// SyntraFoundation - Modern CLI wrapper, macOS-only
// swift-tools-version: 6.2

import Foundation

/// Robust async wrapper for the SYNTRA CLI process.
/// Routes higher-level calls to CLI subcommands via Process.
/// Never touches consciousness core directly—respects three-brain architecture.

public struct SyntraCLIWrapper {
    // MARK: - Error Types

    public enum SyntraError: Error, CustomStringConvertible {
        case executionFailed
        case badUTF8
        case timeout
        case notFound
        case platformNotSupported

        public var description: String {
            switch self {
            case .executionFailed:        return "CLI execution failed"
            case .badUTF8:                return "Output not valid UTF-8"
            case .timeout:                return "CLI call timed out"
            case .notFound:               return "Output not found"
            case .platformNotSupported:   return "Non-macOS platform"
            }
        }
    }

    // MARK: - Core CLI Call

    @discardableResult
    private static func runCLI(
        command: String,
        args: [String] = [],
        timeoutSeconds: Double = 30.0
    ) async throws -> String {
#if os(macOS)
        return try await withThrowingTaskGroup(of: String.self) { group in
            // Task: Process execution
            group.addTask {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                process.arguments = ["swift", "run", "SyntraSwiftCLI", command] + args
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                try process.run()
                process.waitUntilExit()
                guard process.terminationStatus == 0 else {
                    throw SyntraError.executionFailed
                }
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: data, encoding: .utf8) else {
                    throw SyntraError.badUTF8
                }
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            // Task: Timeout protection
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                throw SyntraError.timeout
            }
            // First to complete wins
            guard let result = try await group.next() else {
                throw SyntraError.executionFailed
            }
            group.cancelAll()
            return result
        }
#else
        throw SyntraError.platformNotSupported
#endif
    }

    // MARK: - Public API: Direct Command Wrappers

    /// Route input through SYNTRA's three-brain architecture.
    public static func processThroughBrains(_ input: String) async throws -> String {
        try await runCLI(command: "processThroughBrains", args: [input])
    }

    /// Structured consciousness output (JSON, etc).
    public static func processStructured(_ input: String) async throws -> String {
        try await runCLI(command: "processStructured", args: [input])
    }

    /// Get Valon (moral) reflection only.
    public static func reflectValon(_ input: String) async throws -> String {
        try await runCLI(command: "reflect_valon", args: [input])
    }

    /// Get Modi (logic) reflection only.
    public static func reflectModi(_ input: String) async throws -> String {
        try await runCLI(command: "reflect_modi", args: [input])
    }

    /// Run chat interface with SYNTRA (default consciousness synthesis).
    public static func chat(_ input: String) async throws -> String {
        try await runCLI(command: "chat", args: [input])
    }

    /// Check autonomy/moral refusal behavior.
    public static func checkAutonomy(_ input: String) async throws -> String {
        try await runCLI(command: "checkAutonomy", args: [input])
    }

    /// Three-brain process with drift monitoring.
    public static func processThroughBrainsWithDrift(_ input: String) async throws -> String {
        try await runCLI(command: "processThroughBrainsWithDrift", args: [input])
    }

    /// Test if Foundation Models are wired up via a direct CLI call.
    public static func testFoundationModel(_ prompt: String) async throws -> String {
        try await runCLI(command: "foundation_model", args: [prompt])
    }

    // MARK: - Health Check

    /// Quick check: CLI is available and chat works.
    public static func healthCheck() async -> Bool {
#if os(macOS)
        do {
            let result = try await runCLI(command: "chat", args: ["ping"], timeoutSeconds: 10.0)
            return !result.isEmpty
        } catch {
            print("⚠️ SYNTRA CLI health check failed: \(error)")
            return false
        }
#else
        print("⚠️ SYNTRA CLI health check: Platform not supported")
        return false
#endif
    }

    // MARK: - Batch API

    /// Batch process multiple inputs; each via full three-brain architecture.
    public static func batchProcess(_ inputs: [String]) async -> [(input: String, result: String?, error: Error?)] {
#if os(macOS)
        await withTaskGroup(of: (String, String?, Error?).self) { group in
            for input in inputs {
                group.addTask {
                    do {
                        let result = try await processThroughBrains(input)
                        return (input, result, nil)
                    } catch {
                        return (input, nil, error)
                    }
                }
            }
            var results: [(String, String?, Error?)] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
#else
        return []
#endif
    }
}

