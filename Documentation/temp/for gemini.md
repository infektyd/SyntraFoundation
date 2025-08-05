<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# mke a clean and clear guide.md for an gemini 2.5 pro to implement the changes within cursor pro ide

Here’s a **clean, step-by-step GUIDE** for a Gemini 2.5 Pro agent operating in Cursor Pro IDE, covering exactly how to implement and maintain the bleeding edge SYNTRA (FoundationModels, AI core) while safely patching around SwiftUI Beta UI bugs. This is fully aligned with current best practices, your project standards, and atomic PR discipline.

# SYNTRA Foundation — Gemini 2.5 Pro Implementation Guide for Cursor Pro IDE

**Purpose:**
Ensure SYNTRA codebase always targets iOS/macOS 26+, unlocking all FoundationModels/AI/modern APIs, **while applying robust, atomic UI patches for known SwiftUI Beta input bugs** (no regressions, no downleveling, always recoverable).

## **1. Set Deployment Targets to iOS/macOS 26**

**Task:**
Update every target (app, framework, test, package) to require iOS 26.0/macOS 26.0.

**How:**

- In Xcode:
    - Open `.xcodeproj`/`.xcworkspace`.
    - For *every* target:
        - Go to **Build Settings → iOS/macOS Deployment Target**, set to `26.0`.
- In `Package.swift`:

```swift
platforms: [
    .iOS(.v26),
    .macOS(.v26)
],
```

    - Save and commit.


## **2. Guard Bleeding-Edge API Usage**

**Task:**
Any code accessing newer APIs *must* have `@available`/`if #available` guards, even though your target is >=26 (for build clarity and doc safety).

**How:**

- For functions/classes:

```swift
@available(iOS 26.0, *)
func useModernAI() { ... }
```

- For usage:

```swift
if #available(iOS 26.0, *) {
    // AI/core feature code
}
```

- Do a project-wide search for legacy guards and update all to `26.0` as appropriate.


## **3. Patch Beta-Broken SwiftUI Input Using UIKit/AppKit Bridges**

**Task:**
Where SwiftUI input crashes (keyboard, focus, editing), *bridge* to UIKit (iOS) or AppKit (macOS) and gate usage.

**How:**

- Replace `TextField`, `TextEditor` with a custom wrapper:

```swift
import SwiftUI

struct SafeTextInput: UIViewRepresentable {
    @Binding var text: String
    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        // Set keyboard traits, appearance, etc.
        return tf
    }
    func updateUIView(_ view: UITextField, context: Context) {
        view.text = text
    }
}
```

Replace affected UI spots with this component.
- For macOS, do the same with `NSTextField` via `NSViewRepresentable`.
- Always ensure all UI input code runs on the main thread (`@MainActor`).


## **4. Rigorous Crash Logging \& State Recovery**

**Task:**
Auto-save all **agentic state, memory, UI mode** at every critical event. On crash, *auto-reload* last snapshot.

**How:**

- Implement:

```swift
func saveCurrentAppState() {
    // Save SyntraPersistentState (see docs)
}
func recoverAppStateIfNeeded() {
    // Attempt restore on launch
}
```

See detailed code/guide in `/Documentation/AIImplementationPlaybook.md`[^1].
- Ensure logging of:
    - Crash events
    - Last input processed
    - Memory keys/brain state


## **5. Clean .gitignore/Artifact Hygiene**

- Confirm `.gitignore` is strict: excludes `logs/`, `.DS_Store`, `drift_logs/`, all artifacts.
- **Never track machine-generated files.**
- On accident, use `git-filter-repo` or BFG to scrub all history. Update teammates.


## **6. Test, Document, and Isolate All Workarounds**

**Process:**

1. Annotate *every* UI workaround (file, purpose, origin, removal plan) at top of file and in `Documentation/BETA_KNOWN_BUGS.md`.
2. **Docs:** For each iOS/macOS/Xcode Beta, record test results. Remove workaround *immediately* once Apple fixes issue.

## **7. CI/CD and Recipe Scripts for Consistent Builds**

- All automation/workflows (`.github/workflows/`) must reference Xcode/macOS 26+ runners.
- For Docker/CI, use the latest supported Swift base image (never reference stale/removed tags).

```yaml
runs-on: macos-15  # Or latest-available for Xcode 26
# For Docker
FROM swift:latest
```

- Validate with:

```bash
xcodebuild -showsdks  # confirm 26+
```

- Clean before commit:

```bash
xcodebuild clean
swift package clean && rm -rf .build
```


## **8. Enforce Atomic PR/Commit Policy**

- **One fix/feature per branch/PR.**
    - Never mix UI workaround and model code.
- Squash PRs, rebase on main, run all tests before merge.


## **9. Guidance for Any AI Codegen (Gemini, Claude, etc) Used in Cursor Pro**

- **No hallucination or “fix it by downlevel”**:
    - *Never* recommend lowering deployment target for “UI stability.”
    - All code and config must preserve iOS/macOS 26+ base.
- **All state, memory, moral core annotations, and logs must be preserved** per `AGENTS_AND_CONTRIBUTORS.md` and never removed for expedience.
- **Document all patches/fixes, rollback status, and commit rationale.**


## **10. Removal Plan**

- On *each* new beta/Xcode:

1. Smoke test UI input with/without workaround.
2. If fixed, remove workaround immediately.
3. Update all docs and notify team.


## **Reference Implementation and Policies**

- `/AGENTS_AND_CONTRIBUTORS.md` — master architectural/legal doc[^2]
- `/Documentation/AIImplementationPlaybook.md` — auto reentry/log/caching contract[^1]
- `/Documentation/BETA_KNOWN_BUGS.md` — known/remaining UI/SDK issues

*Keep these up to date with every workaround, recovery, or rollback.*

**This guide ensures:**

- You ship the most advanced agentic AI code on Apple’s stack.
- No UI regression blocks your R\&D.
- All workarounds are atomic and tracked—removed at the first safety signal from Apple.

Ready for Gemini 2.5 Pro/Cursor deployment!
If you need code templates, PR checklist, or more, specify the step and I’ll provide a snippet.

<div style="text-align: center">⁂</div>

[^1]: can-you-come-up-with-an-MD-for-an-ai-agent-in-curs.md

[^2]: AGENTS_AND_CONTRIBUTORS.md

[^3]: comet-explinations.md

[^4]: Cross-Platform-Containerization-WebAssembly-Blue.md

[^5]: now-i-need-instructions-to-make-sure-all-of-these.md

[^6]: Requirements.txt

[^7]: Research-and-analyze-the-latest-advances-in-voice.md

[^8]: Work-Requested.md

[^9]: yes-into-clean-instructions-for-claude-4-sonnet-t.md

[^10]: i-think-backend-response.md

