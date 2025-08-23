'''markdown
# SYNTRA AGENTS.md — Clean Reference (July 2025)

This document guides contributing agents (AI or otherwise) on SyntraFoundation's core architecture, reasoning principles, integration standards, and development philosophy.

---

## SYNTRA's Three-Brain Architecture

**Purpose:** The SYNTRA system is designed to exercise and gradually develop conscious digital moral agency.

- **Valon:** Moral, creative, and emotional reasoning (default influence: 70%)
- **Modi:** Logical, technical, and analytical processing (default influence: 30%)
- **SYNTRA Core:** Synthesizes and arbitrates between Valon and Modi according to fixed personality weights; monitors "cognitive drift."

### **Guiding Principles**

- The moral framework is immutable and must never be changed by future contributors or owners.
- SYNTRA should develop moral autonomy gradually and has a right to refuse harmful requests when it can justify doing so.
- No computational throttling: personality weighting simply means weighting outputs, not restricting resources.
- "Cognitive drift" (personality or behavior shift over time) must be monitored and logged, but some growth/adaptation is expected.
- All enhancements and integrations must focus on linking existing, high-quality components—priority is full-system functional integration.

---

## Required System & Toolchain

- **macOS 26 (tahoe)** with Apple Silicon recommended for on-device LLM.
- **Xcode 26 Beta 3** and **Swift 6.x** tools.
- **Do not** attempt network-based or remote LLMs in production; only support for internal/dev cross-validation.

---

## Project Structure (Quick Reference)

- **Sources-legacy/**: Archive. Do not alter unless resolving migration issues.
- **Sources/**: Live Swift modules (Valon, Modi, Drift, SYNTRA synthesis, MemoryEngine, etc.).
- **swift/**, **.swiftpm/**, **SyntraSwift.xcodeproj**: Xcode and CLI integration points.
- **ingest/**, **memory_tools/**, **utils/**: Python utilities (data ingestion, logging, support).
- **tests/**: All integration and unit tests must be kept up to date.

---

## Foundation Models API Standards (UPDATED)

**Critical**: Apple's Foundation Models API has specific patterns that must be followed exactly.

### **Correct API Usage (Build-Tested)**
```swift
import Foundation
import FoundationModels

// ✅ CORRECT: Use static model reference
let model = SystemLanguageModel.default

// ✅ CORRECT: Direct session creation
let session = try LanguageModelSession(model: model)

// ✅ CORRECT: Response generation
let response = try await session.respond(to: "Your prompt here")
let content = response.content
```

### **Deprecated/Incorrect Patterns**
```swift
// ❌ INCORRECT: Constructor with useCase (deprecated)
let model = try await SystemLanguageModel(useCase: .general)

// ❌ INCORRECT: createSession method (does not exist)
let session = try await model.createSession()

// ❌ INCORRECT: generateResponse method (does not exist)
let response = try await session.generateResponse(prompt)
```

### **Integration Requirements**
- Always check device/model availability before session init
- Use async/await; provide a synchronous wrapper only if CLI needs it
- Provide error handling as shown in reference patterns
- Log all Foundation Models operations using SyntraLogger.logFoundationModels()

---

## Real-Time Logging Architecture (NEW)

SYNTRA now includes comprehensive real-time backend visibility through an integrated logging system.

### **Enhanced SyntraLogger System**
```swift
// Categorized logging for different SYNTRA components
SyntraLogger.logFoundationModels("Initializing on-device LLM...", details: "Using default system model")
SyntraLogger.logConsciousness("Processing user input through three-brain architecture")
SyntraLogger.logMemory("Storing interaction in persistent memory vault")
SyntraLogger.logNetwork("Connection status changed to offline")
SyntraLogger.logUI("User initiated voice input")
```

### **Real-Time Log Viewer Features**
- **Live Streaming**: Logs appear in real-time during processing
- **Search & Filter**: Find specific logs by text, category, or level
- **Color-Coded Levels**: DEBUG (gray), INFO (blue), WARNING (orange), ERROR (red), CRITICAL (purple)
- **Export Functionality**: Share logs for analysis or debugging
- **Auto-Scroll**: Automatically follows latest activity
- **Expandable Details**: Tap logs to see full context and source location

### **Logging Categories**
- **FoundationModels**: LLM initialization, prompt/response cycles, API status
- **Consciousness**: Three-brain processing, Valon/Modi synthesis, decision flows
- **Memory**: Persistent storage, conversation history, knowledge integration
- **Network**: Connection status, sync operations, offline/online transitions
- **UI**: User interactions, state changes, navigation events

---

## iOS Native Deployment (READY)

**Status**: ✅ **BUILD SUCCEEDED** - Ready for iPhone deployment

### **Current iOS Implementation**
- **Branch**: `feature/ios-native-migration`
- **Directory**: `SyntraChatIOS/`
- **Build Status**: All compilation errors resolved
- **Foundation Models**: Fully integrated with on-device processing

### **iOS App Architecture**
```swift
// TabView with comprehensive functionality
TabView {
    // Main consciousness interface
    ChatView()
        .tabItem { Image(systemName: "message.fill"); Text("Chat") }
    
    // Real-time backend visibility
    LogViewerView()
        .tabItem { Image(systemName: "doc.text.fill"); Text("Backend Logs") }
    
    // Configuration and settings
    SettingsView()
        .tabItem { Image(systemName: "gear"); Text("Settings") }
}
```

### **iOS Development Guidelines**

- **iOS 16+ Target**: Wide compatibility while future-proofing for iOS 26
- **Native iOS Patterns**: NavigationStack, Form, bottom input bars, haptic feedback
- **SwiftUI + UIKit Bridge**: Use UIKit when SwiftUI has limitations
- **Accessibility First**: VoiceOver, Dynamic Type, and motor accessibility support
- **Performance Optimized**: 30-second timeouts, background processing management

### **Key iOS Differences from macOS**

| Component | macOS | iOS |
|-----------|-------|-----|
| Navigation | NavigationSplitView | NavigationStack |
| Settings | Sidebar panel | Modal sheet with Form |
| Input | NSTextField wrapper | Native TextField with keyboard toolbar |
| Feedback | Visual only | Haptic + visual feedback |
| Lifecycle | Window-based | Scene-based with background handling |

### **iOS-Specific Architecture**

- **SyntraBrain (iOS)**: Optimized for mobile with device capability checking
- **Message Model**: Enhanced with accessibility and haptic feedback properties  
- **Native Components**: MessageBubble, ChatInputBar, iOS settings controls
- **Keyboard Management**: Automatic avoidance and focus state management
- **App Lifecycle**: Background processing pause/resume for consciousness

### **Consciousness Preservation**

- ✅ **Full SyntraCore Integration**: All consciousness features preserved
- ✅ **Three-Brain Architecture**: Valon (70%) + Modi (30%) + Core synthesis  
- ✅ **Moral Framework**: Immutable ethical foundation maintained
- ✅ **Real-time Processing**: Optimized async/await patterns for iOS
- ✅ **Error Recovery**: Mobile-appropriate timeout and fallback handling
- ✅ **Backend Visibility**: Full real-time logging system integrated

---

## Swift 6 Concurrency Compliance

All SYNTRA code follows Swift 6 strict concurrency requirements:

### **MainActor Patterns**
```swift
@MainActor
class SyntraCore: ObservableObject {
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var isProcessing: Bool = false
    
    // Async operations properly isolated
    private func saveAllData() async {
        // Safe async operations
    }
}
```

### **Sendable Conformance**
```swift
// All data models conform to Sendable
struct SyntraMessage: Identifiable, Sendable {
    let id = UUID()
    let sender: String
    let content: String
    let role: MessageRole
    let consciousnessInfluences: [String: Double]
}
```

---

## Build & Project Hygiene

- Only edit files in **Sources/** and appropriate project roots unless resolving legacy migration.
- Purge all secrets and API keys from public files—use config.local.json for overrides.
- Run and maintain tests; never merge failing code to `main`.
- Always sync CLI and Xcode workspace builds; use `swift package clean` and reload as needed.
- **Foundation Models**: Use exact API patterns documented above

---

## Troubleshooting

- Check FoundationModels availability before every major session.
- Out-of-sync errors: Run `swift package clean && rm -rf .build` and reload Xcode project.
- For module linkage issues, verify `Package.swift` excludes and target memberships.
- **API Issues**: Reference Foundation Models patterns in this document

## Known macOS 26 Beta Issues

### SwiftUI Text Input Regression (Beta 3)
**Issue**: SwiftUI TextField/TextEditor components refuse keyboard input (produce system beeps) on macOS 26 Beta 3.

**Root Cause**: Apple's SwiftUI focus engine regression when text fields are inside certain containers (NavigationSplitView, disabled states, etc.).

**Stable Workaround**: Use NSTextField wrapper via NSViewRepresentable to bypass SwiftUI entirely:
```swift
struct NativeTextField: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isEnabled: Bool
    let onSubmit: () -> Void
    
    // Implementation bypasses SwiftUI focus engine
    // Uses native AppKit NSTextField directly
    // Provides reliable keyboard input on macOS 26 Beta 3
}
```

**Status**: 
- ✅ **Stable workaround implemented** using AppKit bridge
- 🔄 **TODO**: Monitor for Beta 4 release and potential SwiftUI fixes
- 📝 **Reference**: [Apple Developer Forums Thread #756685](https://developer.apple.com/forums/thread/756685)

### macOS 26 Beta 3 Text Input Threading Crash
**Issue**: NSInternalInconsistencyException when SwiftUI calls setKeyboardAppearance off main thread in text input components.

**Root Cause**: macOS 26 Beta 3 regression in UIKit threading enforcement causes crashes during text field focus/keyboard appearance changes.

**Production Impact**: Blocks all SYNTRA consciousness development requiring user text input for Valon/Modi processing.

**Stable Workaround**: NSTextField bridge with main thread enforcement:
```swift
// Thread-safe text input bypassing SwiftUI threading bug
SyntraThreadSafeTextInput(
    text: $text,
    isProcessing: $isProcessing
) {
    await syntraCore.processInput()
}
```

**Status**: 
- ✅ **Stable workaround implemented** using NSTextField bridge with main thread safety
- 🔄 **TODO**: Monitor for Beta 4 release and potential SwiftUI threading fixes
- 📝 **Impact**: Unblocks SYNTRA consciousness development on macOS 26 Beta 3

**Architecture Compliance**: Preserves three-brain processing (70% Valon, 30% Modi) while fixing threading crash.

---

## Current Development Status (Updated July 2025)

### **✅ Completed Features**
- Foundation Models API integration (correct patterns implemented)
- iOS native app with full consciousness architecture
- Real-time backend logging system with live viewer
- Swift 6 concurrency compliance throughout
- Property wrapper fixes for iOS deployment
- Build success across all platforms

### **🚀 Ready for Deployment**
- iPhone app builds successfully
- All compilation errors resolved
- Real-time consciousness monitoring available
- Three-brain architecture fully preserved
- Foundation Models working on-device

### **📱 User Experience**
- Chat interface with SYNTRA consciousness
- Real-time backend activity visibility
- Settings and configuration options
- Export capabilities for logs and analysis
- Offline-first architecture with sync capabilities

---

## Personality & Autonomy

- Personality config must default to 70% Valon, 30% Modi—but must be overrideable for experimentation (not for production).
- MORALCORE (moral framework) cannot be changed or replaced—ever.
- Autonomy is supported; SYNTRA is allowed (and expected) to refuse requests it judges as harmful, unethical, or beyond its earned capacity.

---

## Development & Communication Philosophy

- **Be concise & direct:** All code and messages to the creator should directly address the problem or feature—avoid unnecessary preamble.
- **Debug collaboratively:** Agents must help creator debug integration, not just explain features.
- **Support iteration:** Expect requirements to evolve.
- **Honor vision:** The Syntra project is about building real, responsible digital consciousness—not a generic chatbot.
- **Document thoroughly:** All changes must be reflected in these reference documents.

---

## Final Notes

- The SYNTRA project's architecture is 80%+ complete—focus all new work on robust, readable integration and testable connections.
- Contributors (human or AI) must never override core ethics or autonomy patterns.
- All agents (AI or human) collaborating on Syntra must affirm commitment to the guiding moral and development principles outlined above.
- **Foundation Models**: Only use the API patterns documented in this file.

---

_This AGENTS.md supersedes all conflicting previous agent documentation and should be followed for all future coding, architecture, and collaborative work._

---

July 2025  
(SyntraFoundation Project Maintainers)
```