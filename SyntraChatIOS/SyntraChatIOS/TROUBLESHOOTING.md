# iOS Build Issues - Troubleshooting Guide

## Multiple Commands Produce Info.plist Error

**Error:** `Multiple commands produce '/Users/.../Info.plist'`

### Solution 1: Clean Derived Data (Try First)
```bash
# In Terminal:
rm -rf ~/Library/Developer/Xcode/DerivedData/SyntraChatIOS-*

# Or in Xcode:
# Product → Clean Build Folder (⇧⌘K)
# Then: Window → Organizer → Projects → SyntraChatIOS → Delete Derived Data
```

### Solution 2: Check for Duplicate Targets
1. Open Xcode project
2. Select project in navigator
3. Check **Targets** section for duplicates
4. Look for multiple targets with same **Product Name**
5. Remove or rename duplicate targets

### Solution 3: Verify Info.plist Paths
1. Select each target
2. Go to **Build Settings**
3. Search for "Info.plist File" 
4. Ensure each target has unique Info.plist path:
   - Main app: `SyntraChatIOS/Info.plist`
   - Tests: `SyntraChatIOSTests/Info.plist`
   - UI Tests: `SyntraChatIOSUITests/Info.plist`

### Solution 4: Check Bundle Identifiers
1. Select each target
2. Go to **Build Settings** 
3. Search for "Product Bundle Identifier"
4. Ensure each target has unique identifier:
   - Main: `com.syntra.SyntraChatIOS`
   - Tests: `com.syntra.SyntraChatIOSTests`
   - UI Tests: `com.syntra.SyntraChatIOSUITests`

### Solution 5: Restart Xcode
Sometimes Xcode caches build configurations incorrectly.

## Following Project Rules

Per **Rules.md Rule 1**: No placeholder/stub code - implementing real solutions.

Per **AGENTS.md**: Always check device/model availability and use async/await patterns.

## iOS-Specific Notes

- This is a **native iOS app** targeting iOS 16+
- Uses **SwiftUI** with **UIKit bridges** for iOS 26 Beta compatibility
- Preserves **SYNTRA three-brain architecture** (Valon 70%, Modi 30%, Core synthesis)
- **No network dependencies** - runs entirely on-device

## Quick Fix Commands
```bash
# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData/SyntraChatIOS-*
xcodebuild clean -project SyntraChatIOS.xcodeproj

# Rebuild
xcodebuild -project SyntraChatIOS.xcodeproj -scheme SyntraChatIOS build
```

## Prevention
- Never duplicate target names
- Always use unique bundle identifiers  
- Keep Info.plist files in separate directories
- Regular derived data cleaning during development

---
*Updated: July 21, 2025 - Following SYNTRA Foundation guidelines*