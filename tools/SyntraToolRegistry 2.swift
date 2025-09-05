// //
// //  SyntraToolRegistry.swift
// //  SyntraFoundation
// //
// //  Created by Hans Axelsson on 8/3/25.
// //
//
// import Foundation
//
// /// Protocol for tools that can be offered to SYNTRA consciousness
// /// Tools suggest actions but cannot override consciousness decisions
// public protocol SyntraTool {
//    var name: String { get }
//    var description: String { get }
//   func process(_ input: String) async -> String
// }
//
// /// Registry for external tools that can be offered to consciousness
// /// Follows non-invasive architecture - tools are suggestions only
// public final class SyntraToolRegistry {
//    public static let shared = SyntraToolRegistry()
//    private init() {}
//
//    private var tools: [SyntraTool] = []
//
//    /// Register a new tool for consciousness consideration
//    public func register(_ tool: SyntraTool) {
//        tools.append(tool)
//        print("🔧 Registered tool: \(tool.name)")
//    }
//
//    /// Get all available tools (read-only)
//    public var availableTools: [SyntraTool] {
//        return tools
//    }
//
//    /// Run all tools on input (consciousness decides whether to use results)
//    public func runAll(_ input: String) async -> [(tool: String, result: String)] {
//        await withTaskGroup(of: (String, String).self) { group in
//            for tool in tools {
//                group.addTask {
//                    let result = await tool.process(input)
//                    return (tool.name, result)
//                }
//            }
//
//            var results: [(String, String)] = []
//            for await (toolName, result) in group {
//                results.append((toolName, result))
//            }
//            return results
//        }
//    }
//
//    /// Clear all registered tools
//    public func clearAll() {
//        tools.removeAll()
//        print("🧹 Cleared all registered tools")
//    }
//}
//
// // MARK: - Example Tool Implementation
// public struct CodeAnalysisTool: SyntraTool {
//    public let name = "CodeAnalyzer"
//    public let description = "Analyzes code for potential improvements"
//
//    public init() {}
//
//    public func process(_ input: String) async -> String {
//        // Simple example - in practice this would do real analysis
//        if input.contains("func") || input.contains("class") || input.contains("struct") {
//            return "Code detected: Consider Swift best practices and architecture patterns"
//        }
//        return "No code patterns detected"
//    }
// }

