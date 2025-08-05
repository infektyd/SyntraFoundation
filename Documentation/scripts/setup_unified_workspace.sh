#!/bin/bash

# SYNTRA Unified Workspace Setup Script
# Based on Comet's research and specifications

set -e

echo "🚀 Setting up SYNTRA Unified Workspace..."
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Must run from SyntraFoundation root directory"
    exit 1
fi

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found"
    echo "Please install Xcode and command line tools first"
    exit 1
fi

echo "✅ Found SyntraFoundation root directory"
echo "✅ Xcode command line tools available"

# Verify all required packages exist
echo ""
echo "📦 Verifying package structure..."

if [ ! -f "SyntraChat/Package.swift" ]; then
    echo "❌ Error: SyntraChat/Package.swift not found"
    exit 1
fi

if [ ! -f "SyntraChatIOS/Package.swift" ]; then
    echo "❌ Error: SyntraChatIOS/Package.swift not found"
    exit 1
fi

echo "✅ SyntraFoundation/Package.swift found"
echo "✅ SyntraChat/Package.swift found"
echo "✅ SyntraChatIOS/Package.swift found"

# Test package resolution
echo ""
echo "🔧 Testing package resolution..."

# Test SyntraFoundation
echo "Testing SyntraFoundation package..."
if ! swift package resolve --package-path .; then
    echo "❌ Error: SyntraFoundation package resolution failed"
    exit 1
fi

# Test SyntraChat
echo "Testing SyntraChat package..."
if ! swift package resolve --package-path SyntraChat; then
    echo "❌ Error: SyntraChat package resolution failed"
    exit 1
fi

# Test SyntraChatIOS
echo "Testing SyntraChatIOS package..."
if ! swift package resolve --package-path SyntraChatIOS; then
    echo "❌ Error: SyntraChatIOS package resolution failed"
    exit 1
fi

echo "✅ All packages resolve successfully"

# Create workspace directory structure
echo ""
echo "🏗️  Creating workspace structure..."

# Create workspace file
cat > SYNTRA.xcworkspace/contents.xcworkspacedata << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:">
   </FileRef>
   <FileRef
      location = "group:SyntraChat">
   </FileRef>
   <FileRef
      location = "group:SyntraChatIOS">
   </FileRef>
</Workspace>
EOF

echo "✅ Created SYNTRA.xcworkspace structure"

# Test builds
echo ""
echo "🔨 Testing builds..."

echo "Building SyntraFoundation..."
if ! swift build --package-path .; then
    echo "❌ Error: SyntraFoundation build failed"
    exit 1
fi

echo "Building SyntraChat..."
if ! swift build --package-path SyntraChat; then
    echo "❌ Error: SyntraChat build failed"
    exit 1
fi

echo "Building SyntraChatIOS..."
if ! swift build --package-path SyntraChatIOS; then
    echo "❌ Error: SyntraChatIOS build failed"
    exit 1
fi

echo "✅ All packages build successfully"

# Create development guide
echo ""
echo "📝 Creating development guide..."

cat > WORKSPACE_DEVELOPMENT_GUIDE.md << 'EOF'
# SYNTRA Unified Workspace Development Guide

## Quick Start

1. **Open Workspace:**
   ```bash
   open SYNTRA.xcworkspace
   ```

2. **Select Target:**
   - SyntraChat (macOS)
   - SyntraChatIOS (iOS)

3. **Build & Run:**
   - Cmd+R to run current scheme
   - Cmd+B to build only

## Development Workflow

### Making Changes
- **Core Logic:** Edit files in `swift/` directory
- **macOS UI:** Edit files in `SyntraChat/`
- **iOS UI:** Edit files in `SyntraChatIOS/`

### Testing
- All changes automatically propagate to dependent targets
- Test on both platforms after core changes
- Use `swift test` for unit tests

### Consciousness System
- All platforms share the same SYNTRA brain
- Valon (70% moral) + Modi (30% logical) + Core synthesis
- FoundationModels integration preserved

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
swift package clean
swift build

# Reset Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Dependency Issues
- File → Packages → Resolve Package Versions
- Clean build folder (⇧⌘K)
- Restart Xcode if needed

## Architecture

- **SyntraFoundation:** Core consciousness modules
- **SyntraChat:** macOS SwiftUI app
- **SyntraChatIOS:** iOS SwiftUI app
- **Shared:** All consciousness logic and FoundationModels integration
EOF

echo "✅ Created development guide"

echo ""
echo "🎉 SYNTRA Unified Workspace Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Next Steps:"
echo "1. Open SYNTRA.xcworkspace in Xcode"
echo "2. Select your target (SyntraChat or SyntraChatIOS)"
echo "3. Build and run (Cmd+R)"
echo ""
echo "📚 Documentation:"
echo "- WORKSPACE_DEVELOPMENT_GUIDE.md - Development workflow"
echo "- SYNTRA_WORKSPACE_SETUP.md - Detailed setup guide"
echo ""
echo "🔧 Troubleshooting:"
echo "- Run 'swift package clean' if builds fail"
echo "- Check platform requirements (macOS 26+, iOS 16+)"
echo "- Verify FoundationModels availability"
echo ""
echo "✅ All consciousness modules preserved:"
echo "- Valon (70% moral influence)"
echo "- Modi (30% logical influence)"
echo "- SYNTRA Core (synthesis)"
echo "- MemoryEngine, BrainEngine, MoralCore"
echo "- FoundationModels integration" 