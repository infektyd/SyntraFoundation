<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>
# SYNTRA Foundation — Agents & Contributors Master Guide

_Last updated: August 2025_

## Project Vision & Guiding Architecture

**SYNTRA Foundation** is a bleeding-edge consciousness research platform built with Apple FoundationModels, Swift 6.x, and modern, modular engineering.
It implements a “three-brain” digital agency—**Valon** (moral/emotive), **Modi** (logical/analytic), and **SYNTRA Core** (synthesis & drift monitoring)—for experimenting with digital moral agency.

- **Valon**: 70%, creative/moral, “gut” responses and value alignment  
- **Modi**: 30%, analytic/logical, structured reasoning  
- **Core**: Orchestrator, moral continuity, monitors cognitive drift  

_The moral framework and three-brain design are the project’s inviolable heart and soul._

## What Makes SYNTRA Unique

- **Consciousness-first architecture** (not just chatbot logic)
- **Moral drift monitoring** and explicit ethical agency
- **FoundationModels integration**—Swift `@Generable`, `@Guide`, and real-time Apple LLMs
- **Voice/PTT**: Unified iOS/macOS voice, Push-to-Talk, ElevenLabs integration
- **Full-stack, cross-platform** via Apple ecosystem, modular Python-Swift bridge
- **Auditability**: Every cognitive decision logged, reviewed, and inspectable

## Core Engineering Rules (Critical for AIs and Humans Alike)

- **NEVER remove or edit FoundationModels annotations** (`@Generable`, `@Guide`), moral core weighting, or drift logs.
- **No regression**: Never break working code or remove capabilities/alignment.
- **No secret leakage**: Purge all keys/tokens from any repo history. Use `.gitignore`.
- **One source of truth**: "main" is always deployable; no long-lived drifty branches.
- **Atomic commits ONLY**: Each commit is *one logical change*. Do NOT batch unrelated features/fixes.

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
/               \# Project root: README.md, AGENTS_AND_CONTRIBUTORS.md, .gitignore, Package.swift, LICENSE

```

_All platform-specific code lives in `/Apps/<platform>`. Share as much as possible in `/Shared/`. Use `#if os(...)` in Swift for conditional code, never in shared core unless essential._

## Version & Toolchain Requirements

- macOS 26 (Tahoe), Apple Silicon (required for FoundationModels and latest Swift)
- Xcode 26 Beta 3+ (debugging, FoundationModels annotation support)
- Swift 6.x toolchain, latest SPM
- **Cursor IDE** (Claude Sonnet 4): accepted linter bugs, see “Bleeding Edge Issues” below

## Coding Standards, Build Hygiene & Troubleshooting

- **All new modules** must be registered in `Package.swift` and (if needed) Xcode targets.
- Only edit `Sources/` and project roots, unless fixing migration/legacy code.
- **ALWAYS** run and maintain tests before merging to `main`.
- **Purge all secrets**, logs, artifacts, and .DS_Store from git with strict `.gitignore` (see below).
- Clean CLI/builds with:

```

swift package clean \&\& rm -rf .build

```

and reload in Xcode after significant changes.

## .gitignore — Required Entries

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

## Bleeding-Edge Survival Kit (Troubleshooting Table)

| Symptom / Error | Most likely fix(s) |
| :-- | :-- |
| `'main' attribute cannot be used in a module that contains top-level code` | Only *one* file in your executable target should have `@main`. Use the grep/find build scripts below. Isolate main file in Package.swift. |
| SwiftUI TextField/TextEditor = no keyboard/just beeps (macOS 26 Beta 3) | Always use AppKit NSTextField bridge (see Example). Don't rely on SwiftUI for input in Beta 3. |
| FoundationModels symbols not found at link/run | Check Xcode version—must be Beta 3+, not Homebrew Swift toolchain. Reinstall SDK if needed. |
| Cursor IDE complains about @Guide/@Generable, but build works in Xcode | Ignore Cursor squiggles; trust `swift build` or Xcode. |
| Merge hell, endless conflicts, branch confusion | Rebase feature branches onto latest main *frequently*. Always use short-lived branches and atomic commits. |
| Accidental secret/log/pdf push | Use git-filter-repo/BFG to purge entire *history* of those files. Update .gitignore, communicate to all contributors immediately. |

**Debug scripts:**

```

swift build --verbose 2>\&1 | grep -A 10 -B 10 "main"
find swift -name "*.swift" -not -path "swift/Main/*"
find swift -name "*.swift" | grep -i "disabled"
swift package clean \&\& rm -rf .build

```

---

## 📦 Root/Demo File Disabling Policy (`@main`/legacy/experimental)

> **When disabling a root-level Swift file (`@main`, demo, or legacy), follow this policy:**
>
> 1. **Add a multi-line comment block at the top of the file** explaining:
>    - Why the file is commented out (e.g., `@main` conflict, demo/legacy, not needed right now, causing Xcode build issues, etc.)
>    - That any contributor can uncomment it and ensure only one `@main` exists in any target before use.
>
> 2. **Comment out the file** using `/* ... */` or prefixing each line with `//`.
>
> **Example header to copy:**
>
> ```
> //
> // [FILENAME].swift — Disabled per repo file policy
> //
> // This file is intentionally commented out to avoid build errors (`@main` conflict, demo/legacy). No project data/code is lost.
> // To restore: Uncomment all lines and ensure only one `@main` type in any executable target.
> // Never delete: This preserves all experiments and historical code.
> //
> ```
>
> **Never delete root/demo files; always comment+document as above!**
>
> This practice ensures “main explosion”/target confusion never blocks rapid work, with all code/experiments always available to future contributors and agents.

---

## Agent/Contributor Philosophy

- All code and messages must be direct, problem-solving, and focused. No preamble, no distraction.
- Honor and defend moral core, **never alter for expedience**.
- Embrace iteration—requirements and methods will adapt.
- Debug in tandem, not in silos—document fixes, shortcuts, and workarounds.

## Integration Example

```

import Foundation
import FoundationModels

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

## Known Platform & IDE Quirks

- **macOS 26 Betas (esp. Beta 3):**
    - SwiftUI input is broken, threading issues possible. Use AppKit/native bridges wherever stability is required.
- **Do NOT rely on networked/remote LLMs in production.**
- **Update all dependencies promptly** after major Apple releases—always test in a fresh workspace after migration.

## Final Notes

- This doc must always supersede all previous onboarding, architecture, and troubleshooting/branching policy docs.
- All agents (human or AI) contributing to SYNTRA Foundation are bound to uphold and document these standards.
- For any clarification or new edge-case, append to this doc directly after review.

**Maintained by the SYNTRA Foundation Project Leads (July 2025)**

