🍎 SYNTRA Chat iOS — Native & API Integration
Overview
My motivation for this project began with simple curiosity—a pet project meant as a diagnostic tool. It has since transformed into what you see in this repository. With a “why not?” mentality, I’ve invested significant time and multidisciplinary learning. This isn’t the end for Syntra; it’s opened new doors for creativity that I’m excited to explore.

🧠 SYNTRA
Symbolic Neural Transduction and Reasoning Architecture
The central AI system, fusing symbolic reasoning with real-world signals. Contains VALON, MODI, and SYNTRA Core.

🔧 MODI
Mechanistic Observation and Diagnostic Intelligence
Grounded logic—tracks drift, evaluates sensor patterns, handles deductive cognition.

🔮 VALON
Variable Abstraction and Lateral Ontologic Network
The creative/emotional brain—handles abstraction, emotional anchoring, and nonlinear reasoning.

Server/API Layer (NEW 🆕)
Syntra API Layer is now included—enabling OpenAI-compatible HTTP endpoints on localhost, powered by a Swift-native backend and FoundationModels LLMs.

✨ Highlights
OpenAI-style REST Endpoints (/v1/chat/completions, /v1/models, etc.)

Streaming & Non-streaming chat completions

SyntraCLIWrapper bridge: secure, task-isolated CLI for LLM model execution

Health Checks: /api/health

macOS 26+, Xcode 26+, Apple Silicon only

See [output-from-debug.md] for sample logs and behavior.

🏗️ Architecture
iOS-Native Client
NavigationStack: Modern iOS navigation

Bottom Input Bar: Feels truly native

Haptic Feedback: For all key state changes

Settings Form: iOS standards, live rebindings

Pull-to-Refresh & Accessibility: For all users

API Layer
Fully async Swift concurrency

Robust HTTP/1.1 parser with body size guarantee & streaming responses

OpenAI-compatible JSON schemas

Modular endpoint logic—easy to extend and document

CLI Isolation: All LLM work delegated to a separate process (hardening)

🚀 Quick Start
Prerequisites
macOS 26+ (Tahoe), Apple Silicon required

Xcode 26+ + latest Swift toolchain

iOS 26+ Device or Simulator

[Optional] Docker/Podman for container builds

Building & Running
iOS App
bash
open Apps/iOS/SyntraChatIOS/SyntraChatIOS.xcodeproj
# Select and run on device/simulator
API Server
bash
swift build --target SyntraAPILayer
swift run syntra-api-server
# Server on http://localhost:8081/
CLI Tools
bash
swift build --product SyntraSwiftCLI
swift run SyntraSwiftCLI <command> [input]
See source for available commands: processThroughBrains, chat, foundation_model, etc.

🌐 API & CLI Endpoints
API Endpoints
Method	Path	Description
GET	/api/health	Health check
POST	/api/consciousness/process	Model-backed completions
GET	/v1/models	Model listing (OpenAI)
POST	/v1/chat/completions	OpenAI chat completions
GET	/	Welcome page (HTML)
Full streaming support via event-stream for /v1/chat/completions

Standard OpenAI-compatible payloads

CLI Shortcuts
All model-backed completions, health checks, and debug commands available in Swift CLI

Example:
bash
swift run SyntraSwiftCLI chat "hello syntra"
📚 Documentation
AGENTS_AND_CONTRIBUTORS.md — Project vision, rules, and standards

Rules.md — Detailed coding/arch policy

HARDCORE_LOGGING_GUIDE.md — Debug strategies

output-from-debug.md — Real logs showing end-to-end system integration

CHANGELOG.md — All major changes and rollbacks

🪄 Recent Changes (2025-08-09)
✅ Syntra API Layer: Full local OpenAI-compatible HTTP/1.1 server with streaming

✅ CLI/LLM Integration: Model execution fully isolated w/ detailed logging

✅ Multi-target builds: swift build --target ... for each module

✅ Documentation update: This README, debug logs, and API docs

⚠️ Deprecated: Previous Python or node.js proxy layers—now entirely native Swift

See [output-from-debug.md] for debug output and API behavior.

🎛️ Configuration
All compile-time settings in Package.swift and config/

No .env or external secrets used

Ports, limits (max payload, token windows) are documented inline in server source

Development Notes
OpenAI and custom endpoints coexist in a single codebase

Atomic commits required (see AGENTS_AND_CONTRIBUTORS.md)

All code is test-backed, type-safe, and avoids stubs as per project rules

📄 License
This iOS and API migration maintains the main SyntraFoundation license. See LICENSE for details.

Built with ❤️ for iOS and developers by the SYNTRA team

[CHANGELOG SUMMARY]
2025-08-09: API server, CLI integration, OpenAI endpoints, docs update

2025-08-04: WebAssembly, containerization, build pipeline changes
