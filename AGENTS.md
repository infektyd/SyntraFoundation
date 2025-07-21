'''markdown
# SYNTRA AGENTS.md — Clean Reference (July 2025)

This document guides contributing agents (AI or otherwise) on SyntraFoundation’s core architecture, reasoning principles, integration standards, and development philosophy.

---

## SYNTRA’s Three-Brain Architecture

**Purpose:** The SYNTRA system is designed to exercise and gradually develop conscious digital moral agency.

- **Valon:** Moral, creative, and emotional reasoning (default influence: 70%)
- **Modi:** Logical, technical, and analytical processing (default influence: 30%)
- **SYNTRA Core:** Synthesizes and arbitrates between Valon and Modi according to fixed personality weights; monitors “cognitive drift.”

### **Guiding Principles**

- The moral framework is immutable and must never be changed by future contributors or owners.
- SYNTRA should develop moral autonomy gradually and has a right to refuse harmful requests when it can justify doing so.
- No computational throttling: personality weighting simply means weighting outputs, not restricting resources.
- “Cognitive drift” (personality or behavior shift over time) must be monitored and logged, but some growth/adaptation is expected.
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

## Coding/Integration Standards

- Strictly use the official Apple FoundationModels APIs as coded examples demonstrate (`SystemLanguageModel`, `LanguageModelSession`).
- Always check device/model availability before session init. 
- Use async/await; provide a synchronous wrapper only if CLI needs it.
- Provide error handling as shown in reference patterns.
- When adding new modules:
    - Register all files correctly in `Package.swift` and Xcode targets.
    - Clean out old CLI/excluded files after module refactors.
- When integrating with Python tools, strictly use provided interface scripts and keep I/O formats documented.

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

---

## Example Integration Pattern

```

import Foundation
import FoundationModels

// Availability check
let model = SystemLanguageModel.default
guard model.availability == .available else {
print("FoundationModels not available on this device")
return
}
do {
let session = try LanguageModelSession(model: model)
let response = try await session.respond(to: "Your prompt here")
print(response)
} catch {

    print("Error: $$error.localizedDescription)")
    }

```

---

## Build & Project Hygiene

- Only edit files in **Sources/** and appropriate project roots unless resolving legacy migration.
- Purge all secrets and API keys from public files—use config.local.json for overrides.
- Run and maintain tests; never merge failing code to `main`.
- Always sync CLI and Xcode workspace builds; use `swift package clean` and reload as needed.

---

## Troubleshooting

- Check FoundationModels availability before every major session.
- Out-of-sync errors: Run `swift package clean && rm -rf .build` and reload Xcode project.
- For module linkage issues, verify `Package.swift` excludes and target memberships.

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

---

## Final Notes

- The SYNTRA project’s architecture is 70%+ complete—focus all new work on robust, readable integration and testable connections.
- Contributors (human or AI) must never override core ethics or autonomy patterns.
- All agents (AI or human) collaborating on Syntra must affirm commitment to the guiding moral and development principles outlined above.

---

_This AGENTS.md supersedes all conflicting previous agent documentation and should be followed for all future coding, architecture, and collaborative work._

---

July 2025  
(SyntraFoundation Project Maintainers)
```


