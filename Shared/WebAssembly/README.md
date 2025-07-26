# SYNTRA WebAssembly Integration

This directory contains SYNTRA's WebAssembly implementation, supporting both **host mode** (running Wasm plugins) and **guest mode** (compiling SYNTRA to Wasm).

## Architecture Overview

```
WebAssembly/
├── Host/                   # Wasm host runtime (Swift)
│   └── WasmPluginManager.swift
└── Guest/                  # Swift → Wasm compilation
    ├── Sources/
    │   ├── SyntraCoreWasm/     # Wasm executable
    │   └── SyntraWasmLib/      # Core consciousness library
    ├── dist/                   # Compiled outputs
    └── Package.swift           # SwiftWasm build config
```

## Host Mode: Running WebAssembly Plugins

SYNTRA can load and execute WebAssembly plugins securely using WasmKit.

### Features

- **Secure Sandboxing**: Plugins run in isolated Wasm environments
- **Resource Limits**: Memory and execution time constraints
- **Consciousness Integration**: Direct integration with Valon/Modi processing
- **Cross-Platform**: Works on macOS, iOS, and Linux

### Usage

```swift
import SyntraWasmPluginManager

let pluginManager = WasmPluginManager(pluginConfigs: [
    "sentiment_analyzer": WasmPluginManager.PluginConfig(
        maxMemoryBytes: 16_000_000,  // 16MB
        maxExecutionTimeMs: 100,     // 100ms timeout
        allowedFunctions: ["analyze_sentiment"],
        allowFileSystem: false,
        allowNetwork: false
    )
])

// Load plugin
try pluginManager.loadPlugin(name: "sentiment_analyzer", from: pluginURL)

// Execute with timeout protection
let result: Double = try pluginManager.executeFunction(
    in: "sentiment_analyzer",
    function: "analyze_sentiment",
    parameters: [WasmValue.from("This is a great day!")],
    returning: Double.self
)
```

### Consciousness Processing

```swift
// Process with Valon (moral/emotional reasoning)
let valonResponse = try await pluginManager.processWithValon(
    input: "Should we help this person?",
    context: ["urgency": "high", "resources": "limited"]
)

// Process with Modi (logical/analytical reasoning)  
let modiResponse = try await pluginManager.processWithModi(
    input: "Calculate optimal resource allocation",
    context: ["constraints": constraints]
)
```

## Guest Mode: SYNTRA as WebAssembly

Compile SYNTRA's consciousness system to WebAssembly for universal deployment.

### Build Requirements

- **SwiftWasm SDK** (Swift 6.2+)
- **Binaryen** (`wasm-opt` for optimization)
- **Wasmtime** (for testing)

### Quick Start

```bash
# Build WebAssembly module
./Scripts/build_wasm.sh

# Or use Makefile
make wasm
```

### Deployment Targets

| Target | Runtime | Use Case |
|--------|---------|----------|
| **Browser** | JavaScript + WASI | Client-side AI processing |
| **Edge/Serverless** | Wasmtime/Spin | CDN compute, edge functions |
| **Containers** | WasmKit/Wasmer | Microservices, plugin systems |

### Browser Integration

```html
<!DOCTYPE html>
<html>
<head>
    <title>SYNTRA WebAssembly Demo</title>
    <script src="syntra-wasm.js"></script>
</head>
<body>
    <script>
        const syntra = new SyntraWasm();
        
        syntra.initialize().then(() => {
            // Process input with three-brain consciousness
            const result = syntra.processInput("How should I approach this ethical dilemma?");
            console.log("SYNTRA Response:", result);
            
            // Get consciousness state
            const state = syntra.getConsciousnessState();
            console.log("Valon influence:", state.valonWeight);  // 0.7 (70%)
            console.log("Modi influence:", state.modiWeight);    // 0.3 (30%)
        });
    </script>
</body>
</html>
```

### Serverless Deployment

```javascript
// Spin/Fermyon edge function
import { ResponseBuilder } from "@fermyon/spin-sdk";
import { SyntraWasm } from "./syntra-wasm.js";

export async function handler(request) {
    const syntra = new SyntraWasm();
    await syntra.initialize();
    
    const input = await request.text();
    const result = syntra.processInput(input);
    
    return new ResponseBuilder()
        .header("Content-Type", "application/json")
        .body(JSON.stringify(result))
        .build();
}
```

## Security Model

### Host Mode Security

- **Memory Isolation**: Each plugin runs in separate Wasm memory space
- **Resource Limits**: CPU time and memory usage constraints
- **Function Allowlisting**: Only approved functions can be called
- **No System Access**: Plugins cannot access file system or network by default

### Guest Mode Security

- **Sandboxed Execution**: SYNTRA Wasm module runs in secure sandbox
- **WASI Subset**: Limited system interface for essential operations only
- **Static Analysis**: All WebAssembly modules can be statically analyzed
- **Reproducible Builds**: Deterministic compilation for supply chain security

## Performance Considerations

### Host Mode

- **JIT Compilation**: WasmKit compiles to native code for performance
- **Memory Pooling**: Reuse Wasm instances to reduce allocation overhead
- **Timeout Protection**: Prevents runaway plugin execution

### Guest Mode

- **Size Optimization**: `wasm-opt` reduces module size by ~30%
- **Startup Time**: Sub-millisecond initialization in browser
- **Memory Efficiency**: Shared memory model reduces footprint

## Development Workflow

### 1. Plugin Development

```bash
# Create new Wasm plugin (Rust example)
cargo new --lib my_syntra_plugin
cd my_syntra_plugin

# Configure for WebAssembly target
cat >> Cargo.toml << EOF
[lib]
crate-type = ["cdylib"]

[dependencies]
wasm-bindgen = "0.2"
EOF

# Build plugin
cargo build --target wasm32-unknown-unknown --release
wasm-opt -Os target/wasm32-unknown-unknown/release/my_syntra_plugin.wasm \
    -o my_syntra_plugin.opt.wasm
```

### 2. Testing

```bash
# Test host integration
swift test --filter WasmPluginManagerTests

# Test guest compilation
make wasm
cd WebAssembly/Guest/dist
python3 -m http.server 8000
# Open http://localhost:8000/demo.html
```

### 3. Integration

```swift
// Load your plugin in SYNTRA
let config = WasmPluginManager.PluginConfig(
    maxMemoryBytes: 32_000_000,
    maxExecutionTimeMs: 50,
    allowedFunctions: ["my_function"],
    allowFileSystem: false,
    allowNetwork: false
)

try pluginManager.loadPlugin(name: "my_plugin", from: pluginURL)
```

## Troubleshooting

### Common Issues

**SwiftWasm SDK not found**
```bash
# Install swiftly first
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash

# Install SwiftWasm SDK
swiftly install 6.2-snapshot
swift sdk install [SwiftWasm SDK URL]
```

**WebAssembly module won't load**
```bash
# Check module validity
wasm-objdump -h module.wasm
wasmtime run module.wasm
```

**Plugin execution timeout**
- Reduce complexity or increase timeout in PluginConfig
- Check for infinite loops in plugin code
- Profile with `wasmtime run --profile`

### Debug Mode

```swift
// Enable detailed logging
let manager = WasmPluginManager(pluginConfigs: configs)
manager.enableDebugLogging = true
```

## Roadmap

- [ ] **WASI Support**: File system and network access for plugins
- [ ] **Hot Reloading**: Update plugins without restart
- [ ] **Plugin Marketplace**: Distribute and discover SYNTRA plugins
- [ ] **Visual Debugger**: Browser-based Wasm debugging tools
- [ ] **Edge Optimization**: Specialized builds for edge environments

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.

## License

SYNTRA WebAssembly components are licensed under the same terms as SYNTRA Foundation. 