// ===========================================================================
//  Main.example.swift
//  SyntraFoundation ▸ APIs executable - SAFE TEMPLATE VERSION
//
//  *** THIS FILE IS INTENTIONALLY COMMENTED OUT ***
//  Copy, uncomment, and move/rename as needed for your own build.
//  Only the "real" Main.swift should ever have @main and target membership!
//
//  To use: Remove the leading // from each line and add @main if you want
//  this to be executable (never do this in the repo root; copy to proper
//  build location; see docs in AGENTS_AND_CONTRIBUTORS.md).
// ===========================================================================

// // import Foundation
// // import Network
// // import SyntraWrappers // SyntraCLIWrapper + helpers
//
// // // MARK: - Entry point
// //
// // // DO NOT add "@main" to this file in the template — only in your real executable!
// // // @main // <--- uncomment only IN YOUR CUSTOM Main.swift!
// // public struct SyntraAPIServer {
// //
// //     // PORT config: uses SYNTRA_PORT env var or defaults to 8080
// //     private static let port: NWEndpoint.Port = {
// //         if let val = ProcessInfo.processInfo.environment["SYNTRA_PORT"],
// //            let portInt = UInt16(val),
// //            let port = NWEndpoint.Port(rawValue: portInt) {
// //             return port
// //         }
// //         return NWEndpoint.Port(rawValue: 8080)!
// //     }()
// //
// //     public static func main() async throws {
// //         log("🧠 SYNTRA API Server starting on port \(port)…")
// //
// //         // Health-check (Syntra Core via SyntraCLIWrapper)
// //         log("🏥 Performing consciousness health check…")
// //         if await SyntraCLIWrapper.healthCheck() {
// //             log("✅ Consciousness core is responsive.")
// //         } else {
// //             log("⚠️ WARNING: health check failed – API calls may error.")
// //             log(" Did you run `swift build --product SyntraSwiftCLI`?")
// //         }
// //
// //         let listener = try NWListener(using: .tcp, on: port)
// //         listener.stateUpdateHandler = handleStateUpdate(_:)
// //         listener.newConnectionHandler = { connection in
// //             Task.detached { await handle(connection: connection) }
// //         }
// //         listener.start(queue: .main)
// //         log("🔄 Server running. Press Ctrl-C to stop.")
// //
// //         try await withTaskCancellationHandler(
// //             operation: { try await Task.sleep(nanoseconds: .max) },
// //             onCancel: { log("🛑 Shutting down…") }
// //         )
// //     }
// //
// //     // MARK: - Connection handling
// //     // ... (rest of the implementation omitted for brevity, as above)
// //
// //     // (All major functions are present and safe to uncomment as needed.)
// // }
// //
// // // SETUP NOTES:
// // // - Keep this file commented in the repo root or /Documentation. Never add to a build target.
// // // - Only the real Main.swift, in your executable target, should ever be uncommented.
// // // - See README.md and AGENTS_AND_CONTRIBUTORS.md for full instructions.
// //
// // // Happy hacking!
// ===========================================================================


