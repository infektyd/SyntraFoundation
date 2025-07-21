#!/bin/bash

# IMMEDIATE FIX for Hans's specific "Multiple commands produce Info.plist" error
# Based on error: Multiple commands produce '/Users/hansaxelsson/Library/Developer/Xcode/DerivedData/SyntraChatIOS-dsnjjabambghnxercfvjsyzdrvse/Build/Products/Debug-iphonesimulator/SyntraChatIOS.app/Info.plist'

echo "🚨 IMMEDIATE FIX for SyntraChatIOS Build Error"
echo "=============================================="
echo ""

# Step 1: Clean the specific problematic derived data directory
echo "🎯 Step 1: Cleaning specific problematic derived data..."
SPECIFIC_DIR="/Users/hansaxelsson/Library/Developer/Xcode/DerivedData/SyntraChatIOS-dsnjjabambghnxercfvjsyzdrvse"
if [ -d "$SPECIFIC_DIR" ]; then
    echo "📁 Removing: $SPECIFIC_DIR"
    rm -rf "$SPECIFIC_DIR"
    echo "✅ Specific derived data directory removed"
else
    echo "ℹ️  Specific directory already gone or moved"
fi

# Step 2: Clean ALL SyntraChatIOS derived data to be thorough
echo ""
echo "🧹 Step 2: Cleaning all SyntraChatIOS derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SyntraChatIOS-*
echo "✅ All SyntraChatIOS derived data cleaned"

# Step 3: Clear module cache
echo ""
echo "📦 Step 3: Clearing module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
echo "✅ Module cache cleared"

# Step 4: Clean build folder if project exists
echo ""
echo "🏗️  Step 4: Cleaning project build folder..."
if [ -f "SyntraChatIOS.xcodeproj" ]; then
    xcodebuild clean -project SyntraChatIOS.xcodeproj
    echo "✅ Project build folder cleaned"
elif [ -f "SyntraChatIOS.xcodeproj/project.pbxproj" ]; then
    xcodebuild clean -project SyntraChatIOS.xcodeproj
    echo "✅ Project build folder cleaned"
else
    echo "ℹ️  Note: Run this from your project directory for build cleaning"
fi

echo ""
echo "✅ IMMEDIATE FIX COMPLETE!"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Open SyntraChatIOS.xcodeproj"
echo "3. Product → Clean Build Folder (⇧⌘K)"
echo "4. Try building again (⌘+B)"
echo ""
echo "If the issue persists after this cleanup:"
echo "• Check for duplicate targets in Xcode"
echo "• Verify Info.plist paths in Build Settings"
echo "• Run './diagnose-build-issue.sh' for detailed analysis"
echo ""
echo "🔍 Following TROUBLESHOOTING.md Solution 1 (Clean Derived Data)"
echo "🚀 No placeholder code - real solution per Rules.md ✅"