
# 🦾 SYNTRA Foundation — AI Implementation Playbook: Auto Reentry, State Safety, and Logging

_Last updated: July 2025_

## Objective

Automate and harden agentic auto-reentry, safe logging, and UI/brain state recovery for SyntraChatIOS and related app targets. Ensure that, after crash, interruption, deployment, or device resync, both user context and three-brain memory persist seamlessly.

## 1. **Persisting Brain + UI State for Auto Reentry**

### On Every Significant State Change:

- **Save session brain-state, UI mode, and latest memory snapshot.**
- *Recommended targets*:
    - Brain state transition: idle, processing, ready
    - User submits input, receives response
    - App moves to background or is terminated

```swift
struct SyntraPersistentState: Codable {
    var memorySnapshot: [ConversationItem]
    var brainState: BrainState // e.g. idle, processing, ready
    var uiState: UIState       // e.g. chat open, login, voice active, etc.
}

func saveCurrentAppState() {
    let state = SyntraPersistentState(
        memorySnapshot: memoryBank.snapshot(),
        brainState: brain.current,
        uiState: ui.currentState
    )
    storeToDiskOrDefaults(state)
}
```


### On App Launch/Reentry:

- **Attempt to restore the last persisted state; if missing, start fresh.**

```swift
func recoverAppStateIfNeeded() {
    if let state = loadStateFromDiskOrDefaults() {
        memoryBank.restore(from: state.memorySnapshot)
        brain.current = state.brainState
        ui.setState(state.uiState)
        log("Auto reentry performed at launch.")
    } else {
        log("No prior state found. Cold start.")
    }
}
```


## 2. **Crash/Interruption Detection and Reporting**

- **On crash/kill, always log a record with the agent’s last activity.**
- *(Use iOS `applicationWillTerminate`, Swift `do...catch`, or global error handler)*

```swift
func applicationWillTerminate(_ application: UIApplication) {
    saveCurrentAppState()
    log("applicationWillTerminate: Agent state snapshotted")
}
```

- Optionally, add a session UUID and log crash/kill events for drift or forensic insights.


## 3. **Safe Caching of Logs and Model Artifacts**

- **Logs must sync to disk frequently** (not just kept in memory).
- All logs **rotate** or cap file size (e.g., 1MB chunks) to avoid storage overload.
- Do not keep write handles to deleted files.
- Logs should include: timestamp, brain state, memory keys updated, error or agentic cycle reason for state change.


## 4. **Improved Speech Recognition Error Handling**

- **If speech input fails (e.g., “no speech detected”),** auto-prompt the user or gracefully retry.

```swift
if error.domain == kAFAssistantErrorDomain && error.code == 1110 {
    ui.showAlert("No speech detected. Please try speaking again.")
    autoRetrySpeechRecognitionIfRequired()
}
```


## 5. **Concurrency Warning Fixes (Swift 6.x)**

- **Review all forced sync operations** (`DispatchQueue.sync`, `.wait()`) in any actor context.
- Prefer `await` and native async functions whenever possible.
- If absolutely necessary, document any force-sync and ensure it is not called from a concurrent actor/task.
- On “Potential Structural Swift Concurrency Issue,” annotate in log and issue tracker.


## 6. **Validation Checklist for Agent (Human or AI):**

- [ ] On launch after crash/quit, app resumes brain state and UI as it was pre-crash.
- [ ] All user memory, conversation, and agentic logs are present after reentry.
- [ ] No memory or log loss occurs from interruptions or forced app termination.
- [ ] App icon generator and other key features gracefully degrade if asset files/folders are missing.
- [ ] Any concurrency warnings are logged as issues and, if persistent, refactored for async safety.
- [ ] Voice/speech errors result in clear user feedback and do not crash session/state.


## 7. **Debug, Test, and Iterate**

- **Simulate reentry** by force quitting app mid-session; relaunch and verify agent’s memory \& state recovery.
- **Capture logs** before/after crash/retry for proof.
- **For each fix, add a test or log assertion so future AI agents and humans can maintenance/evolve with confidence.**


## 8. **Document All Changes**

- Each agent must document fix rationale, new behaviors, and test results in AGENTS_AND_CONTRIBUTORS.md or equivalent.


### 🚨 **NOTE:** Always test all resilience features on both simulator and real device.


# Swift & Xcode
#
# Covers build artifacts, user-specific settings, and dependencies.
# Inspired by best practices from github.com/github/gitignore and cocoacasts.com.

## Build generated
build/
DerivedData/
.build/

## Swift Package Manager
# Ignore source code from dependencies managed by SPM.
# Adjust if you have local packages you do want to track.
Packages/
Package.pins
Package.resolved

## User-specific settings
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.xcscmblueprint

## Shared data exceptions
# We want to track shared schemes and workspace data for consistent builds.
!xcshareddata/
!xcschemes/

## macOS system files
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

## Temporary & Backup Files
*.swp
*~.nib
*.moved-aside

# Project-Specific (from AGENTS_AND_CONTRIBUTORS.md)
#
# Secrets, credentials, logs, and other sensitive or generated content.

## Secrets and credentials
config.local.json
*.key
*.pem
*.crt
secrets.*
.env
.env.*

## Build, logs, and dev artifacts
__pycache__/
*.pyc
*.log
*.tmp
drift_logs/
entropy_logs/
memory_vault/*.json

## Documentation
# Ignoring PDFs as per project guidelines, often large binaries.
*.pdf

## Dependency Managers
# Standard practice for CocoaPods and Carthage.
Pods/
Carthage/Build
Carthage/Checkouts


