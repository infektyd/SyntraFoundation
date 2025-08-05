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
TEST_DIR="WebAssembly/Guest/test"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
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
    
    # Check wasmtime for testing
    if ! command -v wasmtime &> /dev/null; then
        log_warn "wasmtime not found. Install for WebAssembly testing"
        log_warn "  brew install wasmtime"
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
    mkdir -p "$TEST_DIR"
    cd WebAssembly/Guest
    
    # Create Package.swift if it doesn't exist
    if [[ ! -f "Package.swift" ]]; then
        log_build "Creating Package.swift for WebAssembly"
        cat > Package.swift << 'EOF'
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraCoreWasm",
    platforms: [
        .custom("wasi", versionString: "preview1")
    ],
    products: [
        .executable(
            name: "SyntraCoreWasm",
            targets: ["SyntraCoreWasm"]
        ),
        .library(
            name: "SyntraWasmLib",
            targets: ["SyntraWasmLib"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SyntraCoreWasm",
            dependencies: ["SyntraWasmLib"],
            path: "Sources/SyntraCoreWasm"
        ),
        .target(
            name: "SyntraWasmLib",
            path: "Sources/SyntraWasmLib"
        )
    ]
)
EOF
    fi
    
    cd ../..
}

# Build WebAssembly module
build_wasm() {
    log_build "Building WebAssembly module"
    
    cd WebAssembly/Guest
    
    # Clean previous builds
    if [[ -d ".build" ]]; then
        log_info "Cleaning previous build artifacts"
        rm -rf .build
    fi
    
    # Build with SwiftWasm
    log_build "Compiling Swift to WebAssembly"
    swift build \
        --triple wasm32-unknown-wasi \
        --configuration release \
        --product SyntraCoreWasm || {
        log_error "WebAssembly build failed"
        exit 1
    }
    
    # Copy built module to dist directory
    local wasm_file=".build/wasm32-unknown-wasi/release/SyntraCoreWasm.wasm"
    if [[ -f "$wasm_file" ]]; then
        cp "$wasm_file" "../dist/SyntraCoreWasm.wasm"
        log_info "WebAssembly module built: dist/SyntraCoreWasm.wasm"
    else
        log_error "WebAssembly module not found: $wasm_file"
        exit 1
    fi
    
    cd ../..
}

# Optimize WebAssembly module
optimize_wasm() {
    log_build "Optimizing WebAssembly module"
    
    local wasm_file="WebAssembly/Guest/dist/SyntraCoreWasm.wasm"
    local optimized_file="WebAssembly/Guest/dist/SyntraCoreWasm-optimized.wasm"
    
    if [[ -f "$wasm_file" ]]; then
        if command -v wasm-opt &> /dev/null; then
            log_build "Running wasm-opt optimization"
            wasm-opt \
                -O4 \
                --enable-bulk-memory \
                --enable-reference-types \
                --enable-simd \
                "$wasm_file" \
                -o "$optimized_file" || {
                log_warn "WebAssembly optimization failed"
                return 1
            }
            
            # Replace original with optimized version
            mv "$optimized_file" "$wasm_file"
            log_info "WebAssembly module optimized"
        else
            log_warn "wasm-opt not available, skipping optimization"
        fi
    else
        log_error "WebAssembly module not found for optimization"
        exit 1
    fi
}

# Generate JavaScript bindings
generate_js_bindings() {
    log_build "Generating JavaScript bindings"
    
    local js_file="WebAssembly/Guest/dist/syntra-wasm.js"
    
    cat > "$js_file" << 'EOF'
// SYNTRA Foundation WebAssembly JavaScript Bindings
// Auto-generated for browser/Node.js integration

class SyntraWasmBridge {
    constructor(wasmModule) {
        this.wasm = wasmModule;
        this.exports = wasmModule.exports;
        this.memory = wasmModule.memory;
    }
    
    // Process input through SYNTRA consciousness
    processInput(input) {
        const inputBytes = new TextEncoder().encode(input);
        const inputPtr = this.wasm.exports.malloc(inputBytes.length);
        
        // Copy input to WASM memory
        const inputArray = new Uint8Array(this.memory.buffer, inputPtr, inputBytes.length);
        inputArray.set(inputBytes);
        
        // Call WASM function
        const resultPtr = this.wasm.exports.process_input(inputPtr, inputBytes.length);
        
        // Read result from WASM memory
        const result = new TextDecoder().decode(
            new Uint8Array(this.memory.buffer, resultPtr)
        );
        
        // Free memory
        this.wasm.exports.free(inputPtr);
        this.wasm.exports.free(resultPtr);
        
        return JSON.parse(result);
    }
    
    // Get consciousness state
    getConsciousnessState() {
        const statePtr = this.wasm.exports.get_consciousness_state();
        const state = new TextDecoder().decode(
            new Uint8Array(this.memory.buffer, statePtr)
        );
        
        this.wasm.exports.free(statePtr);
        return JSON.parse(state);
    }
    
    // Get processing history
    getProcessingHistory() {
        const historyPtr = this.wasm.exports.get_processing_history();
        const history = new TextDecoder().decode(
            new Uint8Array(this.memory.buffer, historyPtr)
        );
        
        this.wasm.exports.free(historyPtr);
        return JSON.parse(history);
    }
}

// Browser initialization
if (typeof window !== 'undefined') {
    window.SyntraWasmBridge = SyntraWasmBridge;
}

// Node.js initialization
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SyntraWasmBridge;
}
EOF
    
    log_info "JavaScript bindings generated: dist/syntra-wasm.js"
}

# Test WebAssembly module
test_wasm() {
    log_test "Testing WebAssembly module"
    
    local wasm_file="WebAssembly/Guest/dist/SyntraCoreWasm.wasm"
    
    if [[ ! -f "$wasm_file" ]]; then
        log_error "WebAssembly module not found for testing"
        return 1
    fi
    
    # Test with wasmtime if available
    if command -v wasmtime &> /dev/null; then
        log_test "Running WebAssembly tests with wasmtime"
        
        # Test consciousness processing
        echo '{"input": "Hello, how are you?"}' | wasmtime run "$wasm_file" || {
            log_warn "WebAssembly test failed"
            return 1
        }
        
        log_info "WebAssembly tests passed"
    else
        log_warn "wasmtime not available, skipping runtime tests"
    fi
    
    # Validate WASM file
    if command -v wasm-validate &> /dev/null; then
        log_test "Validating WebAssembly module"
        wasm-validate "$wasm_file" || {
            log_error "WebAssembly validation failed"
            return 1
        }
        log_info "WebAssembly validation passed"
    else
        log_warn "wasm-validate not available, skipping validation"
    fi
}

# Generate documentation
generate_docs() {
    log_build "Generating WebAssembly documentation"
    
    local docs_file="WebAssembly/Guest/dist/README.md"
    
    cat > "$docs_file" << 'EOF'
# SYNTRA Foundation WebAssembly Module

## Overview
This WebAssembly module provides SYNTRA's three-brain consciousness processing for browser and edge environments.

## Architecture
- **Valon (70%)**: Moral/emotional processing
- **Modi (30%)**: Logical/analytical processing  
- **Core Synthesis**: Combines Valon and Modi outputs

## Usage

### Browser
```javascript
import SyntraWasmBridge from './syntra-wasm.js';

// Load WASM module
const wasmModule = await WebAssembly.instantiateStreaming(
    fetch('./SyntraCoreWasm.wasm')
);

// Create bridge
const syntra = new SyntraWasmBridge(wasmModule.instance);

// Process input
const result = syntra.processInput("Hello, how are you?");
console.log(result);

// Get consciousness state
const state = syntra.getConsciousnessState();
console.log(state);
```

### Node.js
```javascript
const SyntraWasmBridge = require('./syntra-wasm.js');
const fs = require('fs');

// Load WASM module
const wasmBuffer = fs.readFileSync('./SyntraCoreWasm.wasm');
const wasmModule = await WebAssembly.instantiate(wasmBuffer);

// Create bridge and use as above
```

## API Reference

### `processInput(input: string)`
Processes text input through SYNTRA consciousness.
Returns: `SynthesisResult` object with response and confidence scores.

### `getConsciousnessState()`
Returns current consciousness state including processing count and confidence.

### `getProcessingHistory()`
Returns array of recent processing records.

## Build Information
- **Target**: wasm32-unknown-wasi
- **Optimization**: O4 with SIMD, bulk memory, reference types
- **Size**: Optimized for browser deployment
- **Compatibility**: Modern browsers with WebAssembly support

## Testing
```bash
# Run tests
wasmtime run SyntraCoreWasm.wasm

# Validate module
wasm-validate SyntraCoreWasm.wasm
```
EOF
    
    log_info "Documentation generated: dist/README.md"
}

# Create distribution package
create_distribution() {
    log_build "Creating distribution package"
    
    local dist_dir="WebAssembly/Guest/dist"
    local package_name="syntra-wasm-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    cd "$dist_dir"
    tar -czf "$package_name" *.wasm *.js *.md 2>/dev/null || {
        log_warn "Failed to create distribution package"
        return 1
    }
    
    log_info "Distribution package created: $package_name"
    cd ../..
}

# Main build function
main() {
    log_info "SYNTRA Foundation WebAssembly Build"
    log_info "Target: $WASM_TARGET"
    log_info "SDK: $SWIFT_SDK"
    
    # Validate we're in the right directory
    if [[ ! -f "Package.swift" ]] && [[ ! -f "WebAssembly/Guest/Package.swift" ]]; then
        log_error "Package.swift not found. Run from project root."
        exit 1
    fi
    
    check_prerequisites
    setup_project
    build_wasm
    optimize_wasm
    generate_js_bindings
    test_wasm
    generate_docs
    create_distribution
    
    log_info "WebAssembly build completed successfully"
    log_info "Output directory: WebAssembly/Guest/dist"
    log_info "Files generated:"
    ls -la WebAssembly/Guest/dist/ || true
}

# Run main function
main "$@" 