import Foundation
import SyntraWasmLib

// SYNTRA Core WebAssembly Entry Point
// Minimal consciousness runtime for browser/edge deployment
// Implements three-brain architecture (Valon 70%, Modi 30%, Core synthesis)

@main
struct SyntraCoreWasm {
    static func main() {
        let core = SyntraWasmCore()
        
        // Initialize consciousness system
        core.initialize()
        
        // Export processing functions for JavaScript/host environment
        core.startEventLoop()
        
        // Log successful initialization
        print("SYNTRA WebAssembly Core initialized successfully")
        print("Three-brain architecture active: Valon (70%) + Modi (30%) + Core synthesis")
        print("Ready for consciousness processing requests")
    }
} 