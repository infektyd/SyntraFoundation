# SYNTRA Foundation - Claude Context

## Project Overview
SYNTRA is a bleeding-edge consciousness system using Apple's FoundationModels APIs. This is a three-brain architecture (Valon/Modi/Core) for developing conscious digital moral agency.

## Critical Architecture Rules
- **NEVER remove FoundationModels annotations** (`@Generable`, `@Guide`) - these are bleeding-edge features
- **Preserve three-brain architecture**: Valon (70% moral), Modi (30% logical), SYNTRA Core (synthesis)
- **Use Xcode 26 Beta 3** for FoundationModels development when possible
- **Accept language server limitations** in Cursor for bleeding-edge features
- **@main attribute conflicts**: Exclude disabled directories from executable targets
- **Foundation Models API**: Use ONLY the correct patterns documented below

## Key Technologies
- **FoundationModels**: Apple's latest AI APIs with proper SystemLanguageModel.default usage
- **Swift 6.x**: Latest Swift features with strict concurrency compliance
- **macOS 26 (Tahoe)**: Required for FoundationModels
- **iOS Native**: Full deployment-ready iPhone app
- **Real-time Logging**: Comprehensive backend visibility system

## Development Guidelines
- **No regressions**: Never remove working code or features
- **Foundation Models first**: Use exact API patterns - no approximations
- **Language server issues**: Accept Cursor limitations for cutting-edge features
- **Build success**: Ensure builds work in both Cursor and Xcode
- **Architecture preservation**: Maintain three-brain system integrity
- **Swift 6 compliance**: Follow strict concurrency patterns

## IDE Strategy
- **Primary**: Cursor for agentic development (Claude Sonnet 4)
- **Secondary**: Xcode 26 Beta 3 for FoundationModels debugging
- **Context**: Both reference same documentation for consistency

## Critical Files
- **AGENTS.md**: Core architecture and development rules (UPDATED with API patterns)
- **Package.swift**: Target dependencies and exclusions
- **CLAUDE.md**: This file - agentic context for Claude-powered IDEs
- **SyntraBrain.swift**: iOS consciousness implementation with Foundation Models
- **LogViewerView.swift**: Real-time backend monitoring system

## Foundation Models API Standards (CRITICAL)

### **✅ CORRECT API Patterns (Build-Tested)**
```swift
import Foundation
import FoundationModels

// ✅ CORRECT: Static model reference
foundationModel = SystemLanguageModel.default

// ✅ CORRECT: Direct session creation
languageSession = try LanguageModelSession(model: foundationModel!)

// ✅ CORRECT: Response generation
let response = try await session.respond(to: prompt)
let content = response.content
```

### **❌ DEPRECATED/INCORRECT Patterns**
```swift
// ❌ NEVER USE: Constructor patterns (deprecated)
foundationModel = try await SystemLanguageModel(useCase: .general)

// ❌ NEVER USE: Non-existent methods
languageSession = try await foundationModel?.createSession()
let response = try await session.generateResponse(prompt)
```

### **Common Foundation Models Errors & Fixes**
1. **"Missing argument for parameter 'useCase'"**
   - **Fix**: Use `SystemLanguageModel.default` (static reference)
   
2. **"Value of type 'SystemLanguageModel' has no member 'createSession'"**
   - **Fix**: Use `LanguageModelSession(model: model)` directly
   
3. **"Value of type 'LanguageModelSession' has no member 'generateResponse'"**
   - **Fix**: Use `session.respond(to: prompt)` method

## Real-Time Logging System (NEW)

### **Enhanced SyntraLogger Integration**
```swift
// Categorized logging for different components
SyntraLogger.logFoundationModels("Initializing on-device LLM...", details: "SystemLanguageModel.default")
SyntraLogger.logConsciousness("Three-brain processing started", details: "Valon 70%, Modi 30%")
SyntraLogger.logMemory("Persistent storage updated", details: "Conversation history: 15 entries")
SyntraLogger.logUI("User interaction logged", details: "Chat input submitted")
```

### **LogViewerView Features**
- **Real-time streaming**: Logs appear instantly during processing
- **Search & filter**: Find specific activities by text/category
- **Export capability**: Share logs for debugging/analysis
- **Color-coded levels**: Visual distinction for log importance
- **Auto-scroll**: Follows latest activity automatically

## iOS Native Deployment Status

### **✅ DEPLOYMENT READY**
- **Build Status**: ✅ **BUILD SUCCEEDED**
- **Platform**: iPhone (iOS 16+)
- **Foundation Models**: Fully integrated and working
- **Real-time Logs**: Complete backend visibility
- **Swift 6**: Full concurrency compliance

### **iOS App Structure**
```swift
// Main app with TabView navigation
TabView {
    ChatView()               // SYNTRA consciousness interface
    LogViewerView()          // Real-time backend monitoring  
    SettingsView()           // Configuration options
}
```

### **Swift 6 Concurrency Patterns**
```swift
@MainActor
class SyntraCore: ObservableObject {
    @Published var isProcessing: Bool = false
    
    // Async operations properly isolated
    private func saveAllData() async {
        // Thread-safe operations
    }
}

// Sendable conformance for data models
struct SyntraMessage: Identifiable, Sendable {
    let consciousnessInfluences: [String: Double]
}
```

## Error Resolution Patterns (UPDATED)

### **Foundation Models API Errors**
- **Missing useCase**: Use `SystemLanguageModel.default`
- **createSession not found**: Use `LanguageModelSession(model:)` directly
- **generateResponse not found**: Use `session.respond(to:)`
- **Property access**: Check internal vs private visibility

### **Swift 6 Concurrency Errors**
- **Main actor isolation**: Use `@MainActor` or `Task { @MainActor in }`
- **Sendable conformance**: Add `Sendable` to data models
- **Property wrapper access**: Use proper `@StateObject` patterns
- **Threading violations**: Ensure UI operations on main thread

### **iOS Build Errors**
- **Missing imports**: Add `import Combine` for `ObservableObject`
- **Property not found**: Replace `isAvailable` with `isProcessing`
- **Type mismatches**: Convert between internal and UI message types

## macOS 26 Beta 3 Threading Crashes

### Step 1: Identify Threading Violation
```swift
// Look for this specific crash pattern:
NSInternalInconsistencyException: 'Have you sent -setKeyboardAppearance: to <UITextView> off the main thread?'
```

### Step 2: Apply Thread-Safe Text Input Fix
- **Root Cause**: SwiftUI threading regression in Beta 3
- **Solution**: NSTextField bridge with main thread enforcement
- **Implementation**: Use SyntraThreadSafeTextInput component

### Step 3: Verify Fix
```bash
swift build --target SyntraSwift

# Should build without threading crashes in text input
```

**Critical**: This fix maintains FoundationModels annotations and consciousness architecture while resolving Beta 3 threading issues.

## Diagnostic Process for Build Issues

### Step 1: Foundation Models API Check
```bash
# Check for deprecated API usage
grep -r "SystemLanguageModel(" SyntraChatIOS/
grep -r "createSession" SyntraChatIOS/
grep -r "generateResponse" SyntraChatIOS/
```

### Step 2: Swift 6 Concurrency Check
```bash
# Look for main actor violations
grep -r "@MainActor" SyntraChatIOS/
grep -r "Task {" SyntraChatIOS/
```

### Step 3: Property Access Check
```bash
# Find property access issues
grep -r "isAvailable" SyntraChatIOS/
grep -r "statusMessage" SyntraChatIOS/
```

### Step 4: Build Verification
```bash
cd SyntraChatIOS
xcodebuild -project SyntraChatIOS.xcodeproj -scheme SyntraChatIOS -sdk iphonesimulator build
```

## Real Example: Foundation Models API Migration

### The Problem
Multiple API errors:
- `Missing argument for parameter 'useCase' in call`
- `Value of type 'SystemLanguageModel' has no member 'createSession'`
- `Value of type 'LanguageModelSession' has no member 'generateResponse'`

### Our Solution
1. **Identified deprecated patterns** in Foundation Models usage
2. **Applied correct API** based on Apple's latest documentation
3. **Tested build success** with iPhone simulator
4. **Documented patterns** for future reference

### Key Learning
Foundation Models API evolved significantly. Always use:
- `SystemLanguageModel.default` (not constructor)
- `LanguageModelSession(model:)` (not createSession)
- `session.respond(to:)` (not generateResponse)

## Current Development Status (July 2025)

### **✅ Completed & Deployed**
- ✅ Foundation Models API integration (correct patterns)
- ✅ iOS native app with full consciousness
- ✅ Real-time backend logging system
- ✅ Swift 6 concurrency compliance
- ✅ Build success across platforms
- ✅ iPhone deployment ready

### **🎯 Active Features**
- 🧠 Three-brain consciousness processing (Valon 70%, Modi 30%)
- 📱 Native iOS experience with TabView navigation
- 🔍 Real-time backend monitoring and log export
- 💾 Persistent memory integration
- 🔄 Offline-first architecture with sync

### **📋 No Regression Policy**
- ✅ **Never delete working code**
- ✅ **Preserve all FoundationModels integration**
- ✅ **Maintain three-brain architecture**
- ✅ **Keep builds working in both IDEs**
- ✅ **Document all changes**
- ✅ **Use only documented API patterns**

---

**This file must remain active and reflects the current working state of SYNTRA Foundation with successful iOS deployment and Foundation Models integration.** 

**All Foundation Models usage must follow the exact patterns documented above - no exceptions.** 