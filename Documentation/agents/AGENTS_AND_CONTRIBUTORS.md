
# can you combine all of these, and update what needs to be updated, but with doing that combine all of these into one file for me please

```markdown
# SYNTRA Foundation Master Guide

**Last Updated: August 15, 2025**

This comprehensive guide combines all key documentation for SYNTRA Foundation, including project vision, architecture, rules, development guidelines, logging, troubleshooting, and contributor standards. It supersedes previous separate files (e.g., AGENTS_AND_CONTRIBUTORS.md, HARDCORE_LOGGING_GUIDE.md, Rules.md, AGENTS.md, CLAUDE.md). All agents, contributors, and AI tools must follow this guide.

## Project Vision & Guiding Architecture

**SYNTRA Foundation** is a bleeding-edge consciousness research platform built with Apple FoundationModels, Swift 6.x, and modern, modular engineering. It implements a “three-brain” digital agency—**Valon** (moral/emotive), **Modi** (logical/analytic), and **SYNTRA Core** (synthesis & drift monitoring)—for experimenting with digital moral agency.

- **Valon**: 70%, creative/moral, “gut” responses and value alignment.
- **Modi**: 30%, analytic/logical, structured reasoning.
- **Core**: Orchestrator, moral continuity, monitors cognitive drift.

_The moral framework and three-brain design are the project’s inviolable heart and soul._

### What Makes SYNTRA Unique
- **Consciousness-first architecture** (not just chatbot logic) with atomic concurrency tracking.
- **Moral drift monitoring** with thread-safe 70/30 ratio enforcement and quantitative scoring.
- **FoundationModels integration**—Swift `@Generable`, `@Guide`, and real-time Apple LLMs.
- **Voice/PTT**: Unified iOS/macOS voice, Push-to-Talk, ElevenLabs integration.
- **Full-stack, cross-platform** via Apple ecosystem, modular Python-Swift bridge.
- **Auditability**: Every cognitive decision logged, reviewed, and inspectable.

## Core Engineering Rules (Critical for AIs and Humans Alike)
- **NEVER remove or edit FoundationModels annotations** (`@Generable`, `@Guide`), moral core weighting, or drift logs.
- **No regression**: Never break working code or remove capabilities/alignment.
- **No secret leakage**: Purge all keys/tokens from any repo history. Use `.gitignore`.
- **One source of truth**: "main" is always deployable; no long-lived drifty branches.
- **Atomic commits ONLY**: Each commit is *one logical change*. Do NOT batch unrelated features/fixes.
- **Prefer real implementation to stubbing**: Any code marked with a stub must be re-addressed and removed as soon as a solution is viable. If all else fails, flag it and seek help for in-depth search.
- **Default to ‘live binding’**: When designing UI, config toggles, or session logic, controls change values/behavior instantly and update agents in-memory, not via rebuilds.
- **Document decisions**: All architectural/design decisions (including those by AI tools) must be documented in a codex report or markdown in the repo. Major changes with no clear justification should be reverted.
- **Fully plumb configs**: New toggles or config options added to SyntraConfig must be fully plumbed from UI → config file → runtime agent logic. All dangling/no-op config UI is forbidden.
- **Use real data in demos**: Sample chat interfaces or agent demos must run actual Valon/Modi/Core logic—not hardcoded or faked responses—unless dependencies make this absolutely impossible, and that impossibility is logged.
- **Explain integrations**: Anytime you must connect two major modules (UI, agent, pipeline, config), the code and commit message must clearly document why and how the solution fits SyntraFoundation’s system—not just that it compiles.
- **Architecture first**: Always follow and respect the agent/brain architecture and config conventions. Never introduce boilerplate patterns that don’t mesh with the Syntra paradigm.
- **Beta-resilient development**: When developing on beta OS versions, always implement graceful fallbacks and workarounds that preserve core functionality while maintaining architectural integrity. Beta-specific fixes must be clearly documented and designed to be easily removable when the OS issue is resolved.
- **All code must pass tests and respect type safety**: Silent failing or force-unwrapping is forbidden unless absolutely required and explained.
- **Update codex_reports/**: After substantial work so all progress and decision context is permanent and auditable.

## Folder and Project Structure
```

/Apps/
iOS/        \# iOS-specific app, UI, extensions
macOS/      \# macOS app Target/project glue
watchOS/    \# watchOS-specific work
visionOS/   \# Vision Pro code, RealityKit glue
/Shared/        \# Shared Swift (brains, synthesis), Python core, memory
/Packages/      \# Swift packages for reusable modules
/Documentation/ \# Markdown: architecture, moral reasoning, API, voice, drift
/Tests/         \# Unit/integration, all platforms, all brains
/tools/         \# Migration, CLI, CI, helpers
/config/        \# Example configs ONLY (never real secrets)
/               \# Project root: README.md, MASTER_GUIDE.md, .gitignore, Package.swift, LICENSE

```

_All platform-specific code lives in `/Apps/<platform>`. Share as much as possible in `/Shared/`. Use `#if os(...)` in Swift for conditional code, never in shared core unless essential._

## Version & Toolchain Requirements
- macOS 26 (Tahoe), Apple Silicon (required for FoundationModels and latest Swift).
- Xcode 26 Beta 3+ (debugging, FoundationModels annotation support).
- Swift 6.x toolchain, latest SPM.
- **Cursor IDE** (Claude Sonnet 4): Accepted linter bugs, see “Bleeding Edge Issues” below.

## Coding Standards, Build Hygiene & Troubleshooting
- All new modules must be registered in `Package.swift` and (if needed) Xcode targets.
- Only edit `Sources/` and project roots, unless fixing migration/legacy code.
- **ALWAYS** run and maintain tests before merging to `main`.
- Purge all secrets, logs, artifacts, and .DS_Store from git with strict `.gitignore` (see below).
- Clean CLI/builds with:
```

swift package clean \&\& rm -rf .build

```
and reload in Xcode after significant changes.

### .gitignore — Required Entries
```


# Secrets and credentials

config.local.json
*.key
*.pem
*.crt
secrets.*
.env
.env.*

# Build, logs, and dev artifacts

.build/
DerivedData/
node_modules/
__pycache__/
*.pyc
*.log
*.tmp
drift_logs/
entropy_logs/
memory_vault/*.json
*.xcuserdata
.DS_Store
*.pdf

```

**If you ever accidentally publish a secret or log, use `git-filter-repo` or BFG Repo-Cleaner; tell the team immediately.**

## Branch, Commit, and PR Workflow
**Master Branching Rules:**
- `main` is always deployable & reviewed.
- Feature branches:
  - Name: `feature/<short-description>`
  - Squash to one commit/feature, no mixes.
  - Delete remotely and locally after merge:
    ```
    git push origin --delete <branch>
    git branch -d <branch>
    ```
- **No long-lived, lagging platform branches**—merge `main` in weekly at least.

**Atomic Commit Checklist:**
- One logical change = one commit (add feature, fix bug, refactor, not all at once!).
- Never mix UI, core, and platform tweaks.
- Use `git add -p` to stage only relevant changes for each commit.
- Write short, descriptive commit messages (what *and* why).

**Prior to any PR merge to `main`:**
1. Pull + rebase `main`, fix all conflicts locally.
2. Run all tests—none failing!
3. Squash micro-commits as appropriate.
4. Tag stable releases for review/deploy.

## Real-Time Logging Architecture
SYNTRA includes comprehensive real-time logging for deep debugging and consciousness analysis.

### How to Access Logs
- **Xcode Console (Debugging)**: View while app is running (e.g., [INFO] logs for processing).
- **Device Console (iOS Settings)**: Settings → Privacy & Security → Analytics & Improvements → Analytics Data; look for "SyntraChatIOS" files.
- **Persistent File Logs**: Documents/syntra_consciousness_logs.txt (access via Files app on iPhone).
- **Console.app on Mac**: Connect device, filter by "com.syntra.ios".
- **Terminal (Mac Connected)**: `xcrun devicectl logs stream --device [ID] --predicate 'subsystem == "com.syntra.ios"'`.

### Log Categories
- **FoundationModels**: LLM init, prompt/response.
- **Consciousness**: Three-brain processing, synthesis.
- **Memory**: Storage, history.
- **Network**: Connections, sync.
- **UI**: Interactions, navigation.

### Log Levels
- DEBUG: Detailed steps.
- INFO: General flow.
- WARNING: Non-critical issues.
- ERROR: Failures.
- CRITICAL: Severe problems.

### Log Viewer Features
- Live streaming, search/filter, color-coding, auto-scroll, export.
- Expandable details for context/source.

### What Gets Logged
- Input processing, Valon/Modi analysis, SYNTRA synthesis, performance metrics, errors.
- Atomic concurrency counters for brain activation tracking
- Drift score calculations (70/30 ratio enforcement)

### Advanced Debug Commands
- LLDB: `breakpoint set --name processInput` for consciousness debugging.
- Instruments: Time Profiler for bottlenecks.

### Troubleshooting Logs
- Haptic Errors: Normal if disabled.
- LaunchServices: Simulator issue, fine on device.
- Concurrency Warnings: Addressed with MainActor.

## Swift 6 Concurrency Compliance
All code follows strict concurrency:
- Use @MainActor for UI/state.
- Sendable for data models.
- Async/await with proper isolation.

## Foundation Models API Standards
### Correct Usage
```

import Foundation
import FoundationModels

let model = SystemLanguageModel.default
let session = try LanguageModelSession(model: model)
let response = try await session.respond(to: "Prompt")

```

### Deprecated Patterns (Avoid)
- No useCase constructor.
- No createSession or generateResponse.

### Common Errors & Fixes
- Missing useCase: Use default.
- No createSession: Use LanguageModelSession directly.
- No generateResponse: Use respond(to:).

## iOS Native Deployment
- **Status**: BUILD SUCCEEDED - Ready for iPhone.
- **Branch**: feature/ios-native-migration.
- **Directory**: SyntraChatIOS/.
- **App Structure**: TabView with ChatView, LogViewerView, SettingsView.

### iOS-Specific Guidelines
- Target iOS 16+.
- Native SwiftUI + UIKit bridges.
- Accessibility: VoiceOver, Dynamic Type.
- Keyboard: Automatic avoidance.
- Lifecycle: Background pause/resume.

### Differences from macOS
- Navigation: NavigationStack vs. SplitView.
- Input: Native TextField vs. NSTextField wrapper.
- Feedback: Haptic + visual.

### Consciousness Preservation
- Full three-brain integration.
- Moral framework immutable.
- Real-time processing optimized for mobile.

## Known Platform & IDE Quirks
- **macOS 26 Beta Issues**: SwiftUI input regressions—use NSTextField bridges. Monitor for Beta 4 fixes (worsened legibility reported).
- **iOS 26 Beta 4 Crisis**: Reduced readability; use Console.app for debugging (devicectl changed).
- **Cursor IDE**: Accept squiggles for bleeding-edge features; trust swift build/Xcode.
- **Debug Scripts**:
```

swift build --verbose 2>\&1 | grep -A 10 -B 10 "main"
find swift -name "*.swift" -not -path "swift/Main/*"
grep -r "@MainActor" .

```

## Root/Demo File Disabling Policy
- Comment out (don't delete) with header explaining why (e.g., @main conflict).
- Example Header:
```

// [FILENAME].swift — Disabled per repo file policy
// This file is intentionally commented out to avoid build errors (@main conflict, demo/legacy).
// To restore: Uncomment all lines and ensure only one @main type in any executable target.
// Never delete: This preserves all experiments and historical code.

```

## Diagnostic Process for Build Issues
1. Check Foundation Models API (grep for deprecated patterns).
2. Verify Swift 6 concurrency (grep for @MainActor/Task).
3. Property Access: Grep for isAvailable/statusMessage.
4. Build: `xcodebuild -project SyntraChatIOS.xcodeproj -scheme SyntraChatIOS -sdk iphonesimulator build`.

## Current Development Status (August 2025)
- **Completed**: Foundation Models integration, iOS app, real-time logging, Swift 6 compliance, builds across platforms.
- **Active Features**: Three-brain processing, backend monitoring, offline-first sync.
- **No Regression Policy**: Never delete code; preserve all integrations; document changes; use documented API patterns.

## Agent/Contributor Philosophy
- Be concise & direct: Address problems/features without preamble.
- Debug collaboratively: Help with integration, not just explanations.
- Support iteration: Expect evolution.
- Honor vision: Build responsible digital consciousness—not generic tools.
- Document thoroughly: Reflect changes in this guide.

**This Master Guide supersedes all previous docs. All contributors must affirm commitment to these standards.**
```
