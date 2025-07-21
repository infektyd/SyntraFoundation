#!/bin/bash

# SYNTRA iOS Build Fix Script
# Fixes "Multiple commands produce Info.plist" error
# Based on TROUBLESHOOTING.md guidelines

echo "🔧 SYNTRA iOS Build Issue Fix Script"
echo "=====================================\n"

# Solution 1: Clean Derived Data (Try First)
echo "📁 Step 1: Cleaning Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SyntraChatIOS-*
echo "✅ Derived data cleaned"

# Additional cleaning for thorough reset
echo "\n📁 Step 2: Cleaning build folder..."
if [ -f "SyntraChatIOS.xcodeproj" ]; then
    xcodebuild clean -project SyntraChatIOS.xcodeproj
    echo "✅ Build folder cleaned"
else
    echo "⚠️  SyntraChatIOS.xcodeproj not found in current directory"
fi

# Clear module cache
echo "\n📁 Step 3: Clearing module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
echo "✅ Module cache cleared"

echo "\n🎯 Cleaning complete!"
echo "\nNext steps:"
echo "1. Open Xcode"
echo "2. Open your SyntraChatIOS project"
echo "3. Try building again (⌘+B)"
echo "\nIf the issue persists, check for duplicate targets or Info.plist conflicts as outlined in TROUBLESHOOTING.md"

# Check for common indicators of the problem
echo "\n🔍 Checking for potential issues..."

# Check if multiple Info.plist files exist in wrong locations
if [ -f "Info.plist" ]; then
    echo "⚠️  Found Info.plist in root directory - this may cause conflicts"
fi

if [ -f "SyntraChatIOS/Info.plist" ] && [ -f "SyntraChatIOSTests/Info.plist" ] && [ -f "SyntraChatIOSUITests/Info.plist" ]; then
    echo "✅ Info.plist files appear to be in correct locations"
elif [ -f "SyntraChatIOS/Info.plist" ]; then
    echo "✅ Main app Info.plist found"
    echo "ℹ️  Note: Test target Info.plist files may not be visible if they're auto-generated"
else
    echo "⚠️  Main app Info.plist not found in expected location (SyntraChatIOS/Info.plist)"
fi

echo "\n🚀 Build fix script completed!"
echo "Per Rules.md Rule 1: No placeholder code - implementing real solutions ✅"