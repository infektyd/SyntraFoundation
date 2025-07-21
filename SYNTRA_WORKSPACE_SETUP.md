# SYNTRA Unified Workspace Setup

**Goal:**  
Create a single Xcode workspace (`SYNTRA.xcworkspace`) that contains:
- `SyntraFoundation/` – Core shared Swift package (library)
- `SyntraChat/`      – macOS app package (depends on SyntraFoundation)
- `SyntraChatIOS/`   – iOS app package (depends on SyntraFoundation)
All projects and packages share code and resources for centralized, continuous development.

---

## 📦 Current Directory Layout

```
/SyntraFoundation/       # Core Swift package (library/SDK) ✅
/SyntraChat/             # macOS app package (target: macOS 26+) ✅
/SyntraChatIOS/          # iOS app package (target: iOS 16+) ✅
/Swift/                  # Core consciousness modules ✅
/Sources-legacy/         # Legacy modules (archived) ✅
```

---

## ⚙️ Workspace Creation Steps

### 1. **Create SYNTRA.xcworkspace**
- Open Xcode
- File → New → Workspace…  
- Name: `SYNTRA.xcworkspace`  
- Location: repo root (same level as Package.swift)

### 2. **Add All Packages to Workspace**
- File → Add Files to "SYNTRA.xcworkspace"  
- Select all three Package.swift files:
  - `SyntraFoundation/Package.swift` (root)
  - `SyntraChat/Package.swift`
  - `SyntraChatIOS/Package.swift`

### 3. **Verify Dependency Structure**
Current dependencies are correctly configured:
- **SyntraChat** depends on `SyntraTools` from SyntraFoundation ✅
- **SyntraChatIOS** depends on `SyntraTools`, `SyntraConfig`, `ConsciousnessStructures` ✅
- All use `.package(path: "../")` for local dependency ✅

### 4. **Resolve Packages**
- Xcode will auto-detect and link local dependencies
- Both app targets share the same source SyntraFoundation
- Run: File → Packages → Resolve Package Versions

---

## 🏃‍♂️ Building & Running

### **Workspace Setup:**
- Open `SYNTRA.xcworkspace` in Xcode
- In the scheme selector:
  - Select **SyntraChat** for macOS build/run
  - Select **SyntraChatIOS** for iOS build/run (simulator or device)

### **Development Workflow:**
- Make core logic changes in **SyntraFoundation**
- All apps get updates live
- Shared consciousness modules across platforms

---

## 👩‍💻 Development Workflow

### **Feature Development:**
- Work in feature branches affecting any/all packages
- Commit and PR to main when ready
- All platforms stay in sync

### **Platform-Specific Code:**
- Only add new app/package targets in workspace
- Don't split the repo - maintain unity
- Core consciousness logic stays in SyntraFoundation

### **CI/CD Configuration:**
- Point builds/tests at the workspace
- Not individual packages
- Unified testing across all platforms

---

## 📝 Benefits

- **Continuity**: No code drift between platforms
- **Velocity**: One PR/merge updates all, keeps app logic in sync
- **Flexibility**: Easily add more platforms (visionOS, watchOS, etc.)
- **Onboarding**: Every dev or tool sees the full picture instantly
- **Consciousness Preservation**: All platforms share the same SYNTRA brain

---

## 🔧 Common Troubleshooting

### **Dependency Issues:**
- If dependency shows ⚠️:
  - File → Packages → Resolve Package Versions
  - Clean build folder (⇧⌘K)
  - Restart Xcode if needed

### **Build Issues:**
- Always update `path:` references if folders move
- Check platform requirements (macOS 26+, iOS 16+)
- Verify FoundationModels availability

### **Swift 6 Concurrency:**
- Handle main actor isolation properly
- Use proper async/await patterns
- Follow SyntraFoundation patterns

---

## 🚦 Ready to Go!

**Summary:**  
- Unified workspace, all platforms, one codebase, continuous development
- SyntraFoundation is your bedrock; all targets point to it
- Future-proofed for Apple's modern SwiftPM/Xcode approach
- Consciousness system preserved across all platforms

> **Next Steps:** Execute this setup, verify dependency links, and ensure all three targets build and run in workspace!

---

## 🎯 Current Status

✅ **SyntraFoundation** - Core consciousness package ready  
✅ **SyntraChat** - macOS app with FoundationModels integration  
✅ **SyntraChatIOS** - iOS app with native components  
🔄 **SYNTRA.xcworkspace** - Ready to create  
🔄 **Unified Development** - Ready to implement  

**All consciousness modules preserved:**
- Valon (70% moral influence)
- Modi (30% logical influence)  
- SYNTRA Core (synthesis)
- MemoryEngine, BrainEngine, MoralCore
- FoundationModels integration 