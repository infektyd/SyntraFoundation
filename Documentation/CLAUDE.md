# SYNTRA Foundation - Claude Context

## Project Overview
SYNTRA is a bleeding-edge consciousness system using Apple's FoundationModels APIs. This is a three-brain architecture (Valon/Modi/Core) for developing conscious digital moral agency.

## Critical Architecture Rules
- **NEVER remove FoundationModels annotations** (`@Generable`, `@Guide`) - these are bleeding-edge features
- **Preserve three-brain architecture**: Valon (70% moral), Modi (30% logical), SYNTRA Core (synthesis)
- **Use Xcode 26 Beta 3** for FoundationModels development when possible
- **Accept language server limitations** in Cursor for bleeding-edge features
- **@main attribute conflicts**: Exclude disabled directories from executable targets

## Key Technologies
- **FoundationModels**: Apple's latest AI APIs with `@Generable` and `@Guide` annotations
- **Swift 6.x**: Latest Swift features
- **macOS 26 (Tahoe)**: Required for FoundationModels
- **Three-brain architecture**: Valon (moral), Modi (logical), SYNTRA Core (synthesis)

## Development Guidelines
- **No regressions**: Never remove working code or features
- **Bleeding-edge first**: Preserve FoundationModels annotations at all costs
- **Language server issues**: Accept Cursor limitations for cutting-edge features
- **Build success**: Ensure builds work in both Cursor and Xcode
- **Architecture preservation**: Maintain three-brain system integrity

## IDE Strategy
- **Primary**: Cursor for agentic development (Claude Sonnet 4)
- **Secondary**: Xcode 26 Beta 3 for FoundationModels debugging
- **Context**: Both reference same documentation for consistency

## Critical Files
- **AGENTS.md**: Core architecture and development rules
- **Package.swift**: Target dependencies and exclusions
- **CLAUDE.md**: This file - agentic context for Claude-powered IDEs

## Error Resolution Patterns
- **@main conflicts**: Exclude disabled directories from executable targets
- **Language server issues**: Accept false positives for bleeding-edge features
- **Build errors**: Check Package.swift dependencies and exclusions
- **FoundationModels**: Preserve annotations, accept IDE limitations

## Diagnostic Process for @main Issues

### Step 1: Get Detailed Error Information
```bash
# Get verbose build output with context
swift build --verbose 2>&1 | grep -A 10 -B 10 "main"

# Check for specific error patterns
swift build 2>&1 | grep -i "error\|main"
```

### Step 2: Identify Conflicting Files
```bash
# Find all Swift files that might be included
find swift -name "*.swift" -not -path "swift/Main/*"

# Check for disabled directories that might be included
find swift -name "*.swift" | grep -i "disabled"
```

### Step 3: Examine Package.swift Configuration
- Check if executable target path includes too many files
- Verify `path` vs `sources` configuration
- Look for disabled directories being included

### Step 4: Fix the Root Cause
- **Option A**: Change target path to isolate executable
- **Option B**: Fix top-level code in conflicting files
- **Option C**: Exclude problematic directories (last resort)

### Step 5: Verify Fix
```bash
swift build --target SyntraSwiftCLI
```

## Real Example: How We Fixed the @main Issue

### The Problem
Error: `'main' attribute cannot be used in a module that contains top-level code`

### Our Diagnostic Process
1. **Used grep to find the culprit:**
   ```bash
   find swift -name "*.swift" -not -path "swift/Main/*"
   ```
   This revealed: `swift/StructuredConsciousnessService.disabled/StructuredConsciousnessService.swift`

2. **Identified the conflict:**
   - The disabled file contained top-level code
   - The executable target was including it via path configuration
   - Multiple Swift files with top-level code + `@main` = conflict

3. **Applied the fix:**
   - Changed Package.swift from `path: "swift"` to `path: "swift/Main"`
   - This isolated the executable to only the Main directory
   - Preserved all bleeding-edge FoundationModels code

### Key Learning
The `@main` attribute requires a single entry point. When multiple Swift files with top-level code are in the same module, Swift can't determine which should be the main entry point.

## No Regression Policy
- ✅ **Never delete working code**
- ✅ **Preserve all FoundationModels annotations**
- ✅ **Maintain three-brain architecture**
- ✅ **Keep builds working in both IDEs**
- ✅ **Document all changes**

---

**This file must remain active and never be deleted to prevent regression.** 