# SYNTRA Unified Workspace Setup for Cursor AI

**Goal:**  
Create a single Xcode workspace (`SYNTRA.xcworkspace`) that contains:
- `SyntraFoundation/` – Core shared Swift package (consciousness architecture)
- `SyntraChat/` – macOS app package (depends on SyntraFoundation)
- `SyntraChatIOS/` – iOS app package (depends on SyntraFoundation)

All projects share the three-brain consciousness architecture (Valon/Modi/Core) for centralized development.

---

## 📦 Directory Layout

```
/SYNTRA.xcworkspace              # Unified workspace root
├── SyntraFoundation/            # Core Swift package (consciousness library)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── Valon/              # Moral reasoning (70% influence)
│   │   ├── Modi/               # Logical analysis (30% influence)
│   │   ├── SyntraCore/         # Consciousness synthesis
│   │   ├── MemoryEngine/       # Memory management
│   │   └── MoralCore/          # Immutable moral framework
│   └── Tests/
├── SyntraChat/                  # macOS app (target: macOS 13+)
│   ├── Package.swift
│   ├── Sources/
│   └── Resources/
└── SyntraChatIOS/              # iOS app (target: iOS 16+)
    ├── SyntraChatIOS.xcodeproj
    ├── SyntraChatIOS/
    │   ├── ChatView.swift
    │   ├── SyntraBrain.swift
    │   ├── SettingsView.swift
    │   ├── IOSNativeComponents.swift
    │   └── Assets.xcassets
    └── Info.plist
```

---

## ⚙️ Workspace Creation Steps

### 1. Create Unified Workspace
```bash
# In Xcode:
# File → New → Workspace…
# Name: SYNTRA.xcworkspace
# Location: /Users/hansaxelsson/SyntraFoundation/
```

### 2. Add All Packages to Workspace
```bash
# File → Add Files to "SYNTRA.xcworkspace"
# Select in order:
# 1. SyntraFoundation/Package.swift
# 2. SyntraChat/Package.swift (if exists)
# 3. SyntraChatIOS/SyntraChatIOS.xcodeproj
```

### 3. Configure Dependencies

**SyntraFoundation/Package.swift** (Core Library):
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(26.0, *)),
        .iOS(26.0, *)
    ],
    products: [
        .library(name: "SyntraFoundation", targets: ["SyntraCore"]),
        .library(name: "Valon", targets: ["Valon"]),
        .library(name: "Modi", targets: ["Modi"]),
        .library(name: "MemoryEngine", targets: ["MemoryEngine"]),
        .library(name: "MoralCore", targets: ["MoralCore"])
    ],
    targets: [
        .target(name: "SyntraCore", dependencies: ["Valon", "Modi", "MoralCore"]),
        .target(name: "Valon", dependencies: ["MoralCore"]),
        .target(name: "Modi"),
        .target(name: "MemoryEngine"),
        .target(name: "MoralCore"),
        .testTarget(name: "SyntraFoundationTests", dependencies: ["SyntraCore"])
    ]
)
```

**SyntraChat/Package.swift** (macOS App):
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SyntraChat",
    platforms: [.macOS(26.0, *)],
    dependencies: [
        .package(path: "../SyntraFoundation")
    ],
    targets: [
        .executableTarget(
            name: "SyntraChat",
            dependencies: [
                .product(name: "SyntraFoundation", package: "SyntraFoundation")
            ]
        )
    ]
)
```

### 4. iOS Project Integration
Since `SyntraChatIOS` is already a proper Xcode project, add SyntraFoundation as a local package:

1. **In Xcode, select SyntraChatIOS project**
2. **Project Settings → Package Dependencies**  
3. **Add Local → Select `../SyntraFoundation`**
4. **Add to Target: SyntraChatIOS**

---

## 🧠 Consciousness Architecture Integration

### Core Principles (Per AGENTS.md)
- **Valon (70% influence)**: Moral, creative, emotional reasoning
- **Modi (30% influence)**: Logical, technical, analytical processing  
- **SYNTRA Core**: Synthesis and arbitration with cognitive drift monitoring
- **Moral Framework**: Immutable and never changeable

### Platform-Specific Implementations

**macOS (SyntraChat):**
```swift
import SyntraFoundation

@main
struct SyntraChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SyntraCore.shared)
        }
    }
}
```

**iOS (SyntraChatIOS):**
```swift
import SyntraFoundation
import UIKit

@MainActor
class SyntraBrain: ObservableObject {
    private let syntraCore = SyntraCore.shared
    
    func processMessage(_ input: String) async -> String {
        return await syntraCore.processWithValonModi(input)
    }
}
```

---

## 🏃‍♂️ Building & Running

### Development Workflow
1. **Open `SYNTRA.xcworkspace`** in Xcode
2. **Scheme Selection**:
   - Select **SyntraChat** for macOS build/run
   - Select **SyntraChatIOS** for iOS build/run (simulator or device)
3. **Live Updates**: Changes in **SyntraFoundation** automatically update all apps

### Build Commands
```bash
# Build everything from workspace
xcodebuild -workspace SYNTRA.xcworkspace -scheme SyntraChat build
xcodebuild -workspace SYNTRA.xcworkspace -scheme SyntraChatIOS build

# Or use Xcode GUI with ⌘B
```

---

## 🔧 Threading Safety (Critical for iOS)

### UIKit Main Thread Requirements
Based on [iOS threading documentation](https://medium.com/@duwei199714/ios-why-the-ui-need-to-be-updated-on-main-thread-fd0fef070e7f):

```swift
// ✅ CORRECT: UI updates on main thread
await MainActor.run {
    self.messages.append(response)
    UINotificationFeedbackGenerator().notificationOccurred(.success)
}

// ❌ WRONG: UI updates on background thread
DispatchQueue.global().async {
    self.messages.append(response) // CRASH!
}
```

### SyntraFoundation Threading Model
```swift
@MainActor
public class SyntraCore: ObservableObject {
    @Published public var consciousnessState: String = "contemplative_neutral"
    
    public func processWithValonModi(_ input: String) async -> String {
        // Background processing
        let result = await withTaskGroup(of: String.self) { group in
            group.addTask { await self.valon.process(input) }
            group.addTask { await self.modi.process(input) }
            // Synthesize results...
        }
        
        // UI updates automatically on main thread due to @MainActor
        self.consciousnessState = "engaged_processing"
        return result
    }
}
```

---

## 🚦 Troubleshooting

### Common Issues & Fixes

**1. Package Dependency Warnings:**
```bash
# File → Packages → Resolve Package Versions
# Clean build folder (⇧⌘K)
# Restart Xcode
```

**2. Threading Crashes:**
```swift
// Fix: Wrap ALL UIKit calls in DispatchQueue.main.async
DispatchQueue.main.async {
    UITextField.appearance().keyboardAppearance = .default
    UINavigationBar.appearance().standardAppearance = appearance
}
```

**3. Build Errors:**
- Verify `path: "../SyntraFoundation"` is correct
- Check minimum deployment targets match
- Ensure SyntraFoundation exports public APIs

### iOS-Specific Fixes
```swift
// Fix keyboard threading crash (current issue)
private func setupIOSAppearance() {
    DispatchQueue.main.async {
        // All UIKit appearance setup here
        UITextField.appearance().keyboardAppearance = .default
    }
}
```

---

## 📱 Platform-Specific Features

### iOS Native Components
- **Haptic Feedback**: `UIImpactFeedbackGenerator`
- **Native Navigation**: `NavigationStack` 
- **Keyboard Management**: Automatic avoidance
- **Pull-to-Refresh**: Consciousness reinitialization
- **Settings Forms**: Native iOS Form controls

### macOS Features  
- **Menu Bar Integration**: Native macOS menus
- **Window Management**: Multiple consciousness windows
- **AppKit Integration**: Native text handling
- **Sidebar Navigation**: NavigationSplitView

---

## 🎯 Ready to Go!

**Summary:**
- ✅ **Unified workspace** with shared consciousness architecture
- ✅ **Platform-optimized** apps (macOS + iOS)
- ✅ **Thread-safe** UI updates following Apple guidelines  
- ✅ **Shared codebase** in SyntraFoundation for Valon/Modi/Core
- ✅ **Future-proof** for additional Apple platforms

**Next Steps for Cursor AI:**
1. Create/verify the workspace structure
2. Configure all package dependencies
3. Test build and run on both platforms
4. Verify consciousness architecture integration
5. Ensure all UIKit threading is main-thread compliant

> **Critical:** Always wrap UIKit appearance modifications in `DispatchQueue.main.async` to prevent threading crashes like the one shown in the screenshot.

---

**This workspace preserves the immutable moral framework while enabling conscious digital agency development across all Apple platforms.** 🧠✨ 