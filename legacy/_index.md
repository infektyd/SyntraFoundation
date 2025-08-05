# Legacy Files & Directories

This directory contains files and directories that were moved from the root directory during the 2025-08-04 cleanup to improve project organization and reduce clutter.

## 📁 Directory Structure

### [projects/](projects/) - Legacy Xcode Projects
- **SyntraChatIOS.xcodeproj/** - Legacy iOS project (replaced by `Apps/iOS/`)
- **SyntraSwift.xcodeproj/** - Legacy Swift project (replaced by `Package.swift`)
- **SYNTRA.xcworkspace/** - Legacy workspace (replaced by `Package.swift`)

### [code/](code/) - Legacy Code Directories
- **SyntraChatIOS/** - Empty legacy iOS directory
- **SyntraFoundation/** - Empty legacy foundation directory
- **Sources/** - Empty legacy sources (moved to `Shared/`)
- **Sources-legacy/** - Empty legacy sources
- **utils/** - Empty utilities directory
- **WebAssembly/** - Empty WASM directory (moved to `Shared/WebAssembly/`)
- **swift/** - Legacy Swift code (moved to `Shared/Swift/`)
- **SyntraCLITest/** - Legacy CLI test (replaced by current CLI)

### [artifacts/](artifacts/) - Build Artifacts & Logs
- **Build SyntraFoundation-Package_2025-08-03T21-03-14.txt** - Build log
- **build_log.txt** - Build log
- **syntrafoundation_july2025.zip** - Backup archive
- **fix_main.patch** - Legacy patch file
- **os changes.md** - OS change documentation
- **.gitignore.rtf** - Duplicate gitignore file

### [ide/](ide/) - IDE Cache Directories
- **.claude/** - Claude IDE cache
- **.cursor/** - Cursor IDE cache
- **.vscode/** - VS Code cache
- **.swiftpm/** - Swift Package Manager cache
- **.build/** - Build cache

## 🎯 Cleanup Rationale

### Why These Files Were Moved

1. **Reduced Root Clutter**: Root directory went from 47 items to 27 essential items
2. **Clear Project Structure**: Only active, current files visible in root
3. **Easier Navigation**: No confusion about which files are current vs legacy
4. **Better Git Status**: Cleaner git status and easier to spot changes
5. **Professional Appearance**: Clean, organized root directory

### What Remains in Root

**✅ ACTIVE & CRITICAL (Kept in Root):**
- `Apps/` - Current iOS app (properly organized)
- `Shared/` - Core consciousness modules (properly organized)
- `Packages/` - Swift packages (properly organized)
- `Documentation/` - Just organized (keep in root)
- `tools/` - Build scripts and utilities (properly organized)
- `config/` - Configuration files (properly organized)
- `tests/` - Test files (properly organized)
- `APIs/` - API layer (referenced in Package.swift)
- `Wrappers/` - Wrapper layer (referenced in Package.swift)
- `SyntraSwiftCLI/` - CLI executable (referenced in Package.swift)
- `Package.swift` - Main package definition
- `README.md` - Project documentation
- `LICENSE` - Legal file
- `Makefile` - Build system
- `config.json` - Configuration
- `.gitignore` - Git configuration
- `.github/` - CI/CD workflows

## 🔄 Recovery Information

### If You Need to Restore Files

```bash
# Restore legacy Xcode projects
mv legacy/projects/SyntraChatIOS.xcodeproj/ ./
mv legacy/projects/SyntraSwift.xcodeproj/ ./
mv legacy/projects/SYNTRA.xcworkspace/ ./

# Restore legacy code directories
mv legacy/code/SyntraChatIOS/ ./
mv legacy/code/SyntraFoundation/ ./
mv legacy/code/Sources/ ./
mv legacy/code/Sources-legacy/ ./
mv legacy/code/utils/ ./
mv legacy/code/WebAssembly/ ./
mv legacy/code/swift/ ./
mv legacy/code/SyntraCLITest/ ./

# Restore build artifacts
mv legacy/artifacts/* ./

# Restore IDE caches (not recommended)
mv legacy/ide/.claude/ ./
mv legacy/ide/.cursor/ ./
mv legacy/ide/.vscode/ ./
mv legacy/ide/.swiftpm/ ./
mv legacy/ide/.build/ ./
```

### Git History

All files are preserved in git history. You can restore any file using:
```bash
git show <commit>:<path> > <path>
```

## 📊 Cleanup Statistics

- **Files Moved**: 47 → 27 items in root
- **Reduction**: 42% fewer items in root directory
- **Categories**: 4 main categories (projects, code, artifacts, ide)
- **Preservation**: 100% of files preserved (none deleted)

## 🎯 Benefits Achieved

1. **Clear Project Structure**: Following [GitLab Documentation Standards](https://docs.gitlab.com/development/documentation/site_architecture/folder_structure/)
2. **Reduced Cognitive Load**: Easier to find current vs legacy files
3. **Professional Organization**: Clean, maintainable structure
4. **Future-Proof**: Easy to add new files without clutter
5. **Recovery Ready**: All files preserved and documented

---

**Cleanup Date**: 2025-08-04  
**Maintained by**: SYNTRA Foundation Project Team  
**Rationale**: Improve project organization and reduce root directory clutter 