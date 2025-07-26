#!/bin/bash
# WebAssembly Build Script for SYNTRA Foundation
# Compiles Swift modules to WebAssembly with optimization
# Based on Cross-Platform Containerization & WebAssembly Blueprint

set -euo pipefail

# Configuration
WASM_TARGET="wasm32-unknown-wasi"
SWIFT_SDK="swift-6.2-wasm"
PROJECT_NAME="SyntraCoreWasm"
OUTPUT_DIR="WebAssembly/Guest/.build"
DIST_DIR="WebAssembly/Guest/dist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_build() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking WebAssembly build prerequisites"
    
    # Check Swift version
    if ! command -v swift &> /dev/null; then
        log_error "Swift is not installed"
        exit 1
    fi
    
    local swift_version=$(swift --version | head -n1)
    log_info "Swift version: $swift_version"
    
    # Check if SwiftWasm SDK is available
    if ! swift sdk list | grep -q "$SWIFT_SDK"; then
        log_warn "SwiftWasm SDK not found. Attempting to install..."
        install_swiftwasm_sdk
    else
        log_info "SwiftWasm SDK found: $SWIFT_SDK"
    fi
    
    # Check wasm-opt for optimization
    if ! command -v wasm-opt &> /dev/null; then
        log_warn "wasm-opt not found. Install Binaryen for optimization"
        log_warn "  brew install binaryen"
    fi
}

# Install SwiftWasm SDK
install_swiftwasm_sdk() {
    log_info "Installing SwiftWasm SDK"
    
    # Check if swiftly is available
    if command -v swiftly &> /dev/null; then
        log_build "Installing Swift 6.2 snapshot for WebAssembly"
        swiftly install 6.2-snapshot
        swiftly use 6.2-snapshot
        
        # Download and install SwiftWasm SDK
        log_build "Downloading SwiftWasm SDK"
        local sdk_url="https://github.com/swiftwasm/swift/releases/download/swift-wasm-6.2-RELEASE/swift-wasm-6.2-RELEASE-macos_arm64.tar.gz"
        local sdk_archive="/tmp/swiftwasm-sdk.tar.gz"
        
        curl -L "$sdk_url" -o "$sdk_archive"
        swift sdk install "$sdk_archive"
        
        log_info "SwiftWasm SDK installed successfully"
    else
        log_error "swiftly not found. Please install swiftly for SDK management:"
        log_error "  curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash"
        exit 1
    fi
}

# Set up WebAssembly project structure
setup_project() {
    log_info "Setting up WebAssembly project structure"
    
    # Create directories
    mkdir -p "$DIST_DIR"
    cd WebAssembly/Guest
    
    # Create Package.swift if it doesn't exist
    if [[ ! -f "Package.swift" ]]; then
        log_build "Creating Package.swift for WebAssembly target"
        cat > Package.swift << 'EOF'
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraCoreWasm",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0"),
    ],
    products: [
        .executable(name: "SyntraCoreWasm", targets: ["SyntraCoreWasm"]),
        .library(name: "SyntraWasmLib", targets: ["SyntraWasmLib"]),
    ],
    dependencies: [
        // Add minimal dependencies suitable for WebAssembly
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "SyntraCoreWasm",
            dependencies: ["SyntraWasmLib"],
            swiftSettings: [
                .define("WASM_TARGET"),
                .unsafeFlags(["-Xfrontend", "-function-sections"]),
            ]
        ),
        .target(
            name: "SyntraWasmLib",
            dependencies: [],
            swiftSettings: [
                .define("WASM_TARGET"),
                .unsafeFlags(["-Xfrontend", "-function-sections"]),
            ]
        ),
        .testTarget(
            name: "SyntraWasmTests",
            dependencies: ["SyntraWasmLib"]
        ),
    ]
)
EOF
    fi
    
    # Create source files if they don't exist
    mkdir -p Sources/SyntraCoreWasm Sources/SyntraWasmLib
    
    if [[ ! -f "Sources/SyntraCoreWasm/main.swift" ]]; then
        log_build "Creating main.swift for WebAssembly executable"
        cat > Sources/SyntraCoreWasm/main.swift << 'EOF'
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
EOF
    fi
    
    if [[ ! -f "Sources/SyntraWasmLib/SyntraWasmCore.swift" ]]; then
        log_build "Creating SyntraWasmCore.swift"
        cat > Sources/SyntraWasmLib/SyntraWasmCore.swift << 'EOF'
import Foundation

#if WASM_TARGET
import WASILibc
#endif

/// Minimal SYNTRA consciousness core for WebAssembly deployment
/// Implements three-brain architecture (Valon 70%, Modi 30%, Core synthesis)
public class SyntraWasmCore {
    
    private let valonWeight: Double = 0.7
    private let modiWeight: Double = 0.3
    
    public init() {}
    
    public func initialize() {
        log("SYNTRA WebAssembly Core initializing...")
        log("Valon weight: \(valonWeight), Modi weight: \(modiWeight)")
    }
    
    public func startEventLoop() {
        log("Starting WebAssembly event loop")
        // Event loop for browser/host integration
    }
    
    // Export for JavaScript/host calling
    @_cdecl("process_input")
    public func processInput(_ inputPtr: UnsafePointer<CChar>, _ inputLen: Int32) -> UnsafePointer<CChar> {
        let input = String(cString: inputPtr)
        log("Processing input: \(input)")
        
        // Implement three-brain processing
        let valonResponse = processWithValon(input)
        let modiResponse = processWithModi(input)
        let synthesis = synthesize(valon: valonResponse, modi: modiResponse)
        
        // Return result as C string for host consumption
        let result = synthesis.toJSON()
        return strdup(result)
    }
    
    @_cdecl("get_consciousness_state")
    public func getConsciousnessState() -> UnsafePointer<CChar> {
        let state = ConsciousnessState(
            valonWeight: valonWeight,
            modiWeight: modiWeight,
            isActive: true,
            lastUpdate: Date().timeIntervalSince1970
        )
        return strdup(state.toJSON())
    }
    
    private func processWithValon(_ input: String) -> ValonResponse {
        // Moral/emotional processing (70% weight)
        return ValonResponse(
            moralScore: 0.8,
            emotionalTone: "compassionate",
            reasoning: "Valon processing: \(input)",
            confidence: 0.9
        )
    }
    
    private func processWithModi(_ input: String) -> ModiResponse {
        // Logical/analytical processing (30% weight)
        return ModiResponse(
            logicalScore: 0.9,
            analyticalResult: "Analyzed: \(input)",
            reasoning: "Modi processing: logical analysis",
            confidence: 0.85
        )
    }
    
    private func synthesize(valon: ValonResponse, modi: ModiResponse) -> SynthesisResult {
        let combinedScore = (valon.moralScore * valonWeight) + (modi.logicalScore * modiWeight)
        
        return SynthesisResult(
            response: "Synthesized response combining moral and logical aspects",
            confidence: (valon.confidence * valonWeight) + (modi.confidence * modiWeight),
            valonInfluence: valonWeight,
            modiInfluence: modiWeight,
            combinedScore: combinedScore
        )
    }
    
    private func log(_ message: String) {
        #if WASM_TARGET
        // Simple console output for WebAssembly
        print(message)
        #else
        print("[SyntraWasm] \(message)")
        #endif
    }
}

// Supporting types for WebAssembly environment
public struct ConsciousnessState: Codable {
    let valonWeight: Double
    let modiWeight: Double
    let isActive: Bool
    let lastUpdate: Double
    
    func toJSON() -> String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

public struct ValonResponse: Codable {
    let moralScore: Double
    let emotionalTone: String
    let reasoning: String
    let confidence: Double
}

public struct ModiResponse: Codable {
    let logicalScore: Double
    let analyticalResult: String
    let reasoning: String
    let confidence: Double
}

public struct SynthesisResult: Codable {
    let response: String
    let confidence: Double
    let valonInfluence: Double
    let modiInfluence: Double
    let combinedScore: Double
    
    func toJSON() -> String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}
EOF
    fi
    
    cd ../..
}

# Build WebAssembly module
build_wasm() {
    log_info "Building SYNTRA WebAssembly module"
    
    cd WebAssembly/Guest
    
    # Clean previous builds
    rm -rf .build
    
    # Build with SwiftWasm
    log_build "Compiling Swift to WebAssembly"
    swift build -c release \
        --swift-sdk "$SWIFT_SDK" \
        --product SyntraCoreWasm \
        --static-swift-stdlib
    
    local wasm_file=".build/$WASM_TARGET/release/SyntraCoreWasm.wasm"
    
    if [[ ! -f "$wasm_file" ]]; then
        log_error "WebAssembly build failed - output file not found"
        exit 1
    fi
    
    log_info "WebAssembly build successful: $wasm_file"
    
    # Optimize with wasm-opt if available
    if command -v wasm-opt &> /dev/null; then
        log_build "Optimizing WebAssembly module"
        wasm-opt -Os "$wasm_file" -o "$DIST_DIR/SyntraCoreWasm.opt.wasm"
        
        # Show size comparison
        local original_size=$(wc -c < "$wasm_file")
        local optimized_size=$(wc -c < "$DIST_DIR/SyntraCoreWasm.opt.wasm")
        local savings=$((original_size - optimized_size))
        local percentage=$((savings * 100 / original_size))
        
        log_info "Optimization complete:"
        log_info "  Original: $original_size bytes"
        log_info "  Optimized: $optimized_size bytes"
        log_info "  Saved: $savings bytes ($percentage%)"
    else
        # Copy unoptimized version
        cp "$wasm_file" "$DIST_DIR/SyntraCoreWasm.wasm"
        log_warn "wasm-opt not available - using unoptimized WebAssembly"
    fi
    
    # Generate JavaScript wrapper
    generate_js_wrapper
    
    cd ../..
}

# Generate JavaScript wrapper for browser integration
generate_js_wrapper() {
    log_build "Generating JavaScript wrapper"
    
    cat > "$DIST_DIR/syntra-wasm.js" << 'EOF'
// SYNTRA WebAssembly JavaScript Integration
// Provides browser-friendly API for SYNTRA consciousness

class SyntraWasm {
    constructor() {
        this.module = null;
        this.memory = null;
    }
    
    async initialize(wasmPath = './SyntraCoreWasm.opt.wasm') {
        try {
            const wasmModule = await WebAssembly.instantiateStreaming(fetch(wasmPath));
            this.module = wasmModule.instance;
            this.memory = this.module.exports.memory;
            
            console.log('SYNTRA WebAssembly initialized');
            return true;
        } catch (error) {
            console.error('Failed to initialize SYNTRA WebAssembly:', error);
            return false;
        }
    }
    
    processInput(input) {
        if (!this.module) {
            throw new Error('SYNTRA WebAssembly not initialized');
        }
        
        // Convert JavaScript string to WebAssembly memory
        const inputBytes = new TextEncoder().encode(input + '\0');
        const inputPtr = this.module.exports.malloc(inputBytes.length);
        const inputView = new Uint8Array(this.memory.buffer, inputPtr, inputBytes.length);
        inputView.set(inputBytes);
        
        // Call WebAssembly function
        const resultPtr = this.module.exports.process_input(inputPtr, inputBytes.length - 1);
        
        // Convert result back to JavaScript string
        const resultView = new Uint8Array(this.memory.buffer, resultPtr);
        const resultBytes = [];
        for (let i = 0; resultView[i] !== 0; i++) {
            resultBytes.push(resultView[i]);
        }
        
        const result = new TextDecoder().decode(new Uint8Array(resultBytes));
        
        // Free memory
        this.module.exports.free(inputPtr);
        this.module.exports.free(resultPtr);
        
        return JSON.parse(result);
    }
    
    getConsciousnessState() {
        if (!this.module) {
            throw new Error('SYNTRA WebAssembly not initialized');
        }
        
        const statePtr = this.module.exports.get_consciousness_state();
        const stateView = new Uint8Array(this.memory.buffer, statePtr);
        
        const stateBytes = [];
        for (let i = 0; stateView[i] !== 0; i++) {
            stateBytes.push(stateView[i]);
        }
        
        const state = new TextDecoder().decode(new Uint8Array(stateBytes));
        this.module.exports.free(statePtr);
        
        return JSON.parse(state);
    }
}

// Export for both CommonJS and ES modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SyntraWasm;
}
if (typeof window !== 'undefined') {
    window.SyntraWasm = SyntraWasm;
}
EOF

    # Generate HTML demo
    cat > "$DIST_DIR/demo.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SYNTRA WebAssembly Demo</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .input-area { margin: 20px 0; }
        textarea { width: 100%; height: 100px; padding: 10px; }
        button { padding: 10px 20px; background: #007AFF; color: white; border: none; border-radius: 5px; }
        .output { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .state { background: #e3f2fd; padding: 10px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>SYNTRA WebAssembly Demo</h1>
        <p>Three-brain consciousness system running in your browser</p>
        
        <div class="input-area">
            <textarea id="input" placeholder="Enter your message for SYNTRA to process..."></textarea>
            <br><br>
            <button onclick="processInput()">Process with SYNTRA</button>
            <button onclick="getState()">Get Consciousness State</button>
        </div>
        
        <div id="output" class="output" style="display: none;"></div>
        <div id="state" class="state" style="display: none;"></div>
    </div>
    
    <script src="syntra-wasm.js"></script>
    <script>
        let syntra = new SyntraWasm();
        
        async function initSyntra() {
            const success = await syntra.initialize();
            if (success) {
                console.log('SYNTRA ready');
            } else {
                alert('Failed to initialize SYNTRA WebAssembly');
            }
        }
        
        async function processInput() {
            const input = document.getElementById('input').value;
            if (!input.trim()) return;
            
            try {
                const result = syntra.processInput(input);
                document.getElementById('output').style.display = 'block';
                document.getElementById('output').innerHTML = 
                    '<h3>SYNTRA Response:</h3>' +
                    '<pre>' + JSON.stringify(result, null, 2) + '</pre>';
            } catch (error) {
                alert('Error: ' + error.message);
            }
        }
        
        async function getState() {
            try {
                const state = syntra.getConsciousnessState();
                document.getElementById('state').style.display = 'block';
                document.getElementById('state').innerHTML = 
                    '<h3>Consciousness State:</h3>' +
                    '<pre>' + JSON.stringify(state, null, 2) + '</pre>';
            } catch (error) {
                alert('Error: ' + error.message);
            }
        }
        
        // Initialize on page load
        initSyntra();
    </script>
</body>
</html>
EOF

    log_info "JavaScript wrapper and demo generated"
}

# Main execution
main() {
    log_info "SYNTRA Foundation WebAssembly Build"
    
    # Ensure we're in the project root
    if [[ ! -f "Package.swift" ]]; then
        log_error "Please run this script from the SYNTRA Foundation root directory"
        exit 1
    fi
    
    check_prerequisites
    setup_project
    build_wasm
    
    log_info "WebAssembly build complete!"
    log_info "Output files:"
    log_info "  - WebAssembly/Guest/dist/SyntraCoreWasm.opt.wasm"
    log_info "  - WebAssembly/Guest/dist/syntra-wasm.js"
    log_info "  - WebAssembly/Guest/dist/demo.html"
    log_info ""
    log_info "To test in browser:"
    log_info "  cd WebAssembly/Guest/dist && python3 -m http.server 8000"
    log_info "  Open http://localhost:8000/demo.html"
}

# Run main function
main "$@" 