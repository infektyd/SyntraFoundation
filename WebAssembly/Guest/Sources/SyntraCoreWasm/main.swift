import Foundation
import SyntraWasmLib

// SYNTRA Core WebAssembly Entry Point
// Minimal consciousness runtime for browser/edge deployment

@main
struct SyntraCoreWasm {
    static func main() {
        let core = SyntraWasmCore()
        
        // Initialize consciousness system
        core.initialize()
        
        // Export processing functions for JavaScript/host environment
        core.startEventLoop()
    }
} 