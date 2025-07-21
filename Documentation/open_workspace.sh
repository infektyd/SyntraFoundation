#!/bin/bash

# Open SYNTRA Unified Workspace
# This script opens the workspace from the correct directory

echo "🚀 Opening SYNTRA Unified Workspace..."
echo "======================================"

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Must run from SyntraFoundation root directory"
    echo "Please navigate to the SyntraFoundation directory first:"
    echo "cd /Users/hansaxelsson/SyntraFoundation"
    exit 1
fi

# Check if workspace exists
if [ ! -d "SYNTRA.xcworkspace" ]; then
    echo "❌ Error: SYNTRA.xcworkspace not found"
    echo "Please run the setup script first:"
    echo "./setup_unified_workspace.sh"
    exit 1
fi

echo "✅ Found SyntraFoundation root directory"
echo "✅ Found SYNTRA.xcworkspace"

# Open the workspace
echo "🔧 Opening SYNTRA.xcworkspace in Xcode..."
open SYNTRA.xcworkspace

echo ""
echo "🎉 Workspace opened successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. In Xcode, select your target:"
echo "   - SyntraChat (macOS)"
echo "   - SyntraChatIOS (iOS)"
echo "2. Build and run (Cmd+R)"
echo "3. Begin unified development!"
echo ""
echo "🧠 All consciousness modules are preserved:"
echo "- Valon (70% moral influence)"
echo "- Modi (30% logical influence)"
echo "- SYNTRA Core (synthesis)"
echo "- FoundationModels integration" 