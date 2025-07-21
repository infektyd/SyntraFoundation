#!/bin/bash

# SYNTRA iOS Build Diagnostics Script
# Diagnoses "Multiple commands produce Info.plist" error
# Following TROUBLESHOOTING.md systematic approach

echo "🔍 SYNTRA iOS Build Diagnostics"
echo "================================\n"

# Check project structure
echo "📋 Step 1: Analyzing project structure..."

if [ -f "SyntraChatIOS.xcodeproj/project.pbxproj" ]; then
    echo "✅ Found Xcode project file"
    
    # Count targets in project
    TARGET_COUNT=$(grep -c "isa = PBXNativeTarget" SyntraChatIOS.xcodeproj/project.pbxproj)
    echo "📊 Found $TARGET_COUNT targets in project"
    
    # Check for duplicate target names
    echo "\n🎯 Checking for target name conflicts..."
    grep -A 5 "isa = PBXNativeTarget" SyntraChatIOS.xcodeproj/project.pbxproj | grep "name = " | sort
    
else
    echo "❌ SyntraChatIOS.xcodeproj not found"
    exit 1
fi

# Check Info.plist file locations
echo "\n📄 Step 2: Checking Info.plist locations..."

INFOPLISTS_FOUND=0

if [ -f "SyntraChatIOS/Info.plist" ]; then
    echo "✅ Main app: SyntraChatIOS/Info.plist"
    INFOPLISTS_FOUND=$((INFOPLISTS_FOUND + 1))
fi

if [ -f "SyntraChatIOSTests/Info.plist" ]; then
    echo "✅ Tests: SyntraChatIOSTests/Info.plist"
    INFOPLISTS_FOUND=$((INFOPLISTS_FOUND + 1))
fi

if [ -f "SyntraChatIOSUITests/Info.plist" ]; then
    echo "✅ UI Tests: SyntraChatIOSUITests/Info.plist"
    INFOPLISTS_FOUND=$((INFOPLISTS_FOUND + 1))
fi

# Check for Info.plist in wrong locations
if [ -f "Info.plist" ]; then
    echo "⚠️  Found Info.plist in root directory - POTENTIAL CONFLICT!"
    INFOPLISTS_FOUND=$((INFOPLISTS_FOUND + 1))
fi

if find . -name "Info.plist" -not -path "./SyntraChatIOS/Info.plist" -not -path "./SyntraChatIOSTests/Info.plist" -not -path "./SyntraChatIOSUITests/Info.plist" | grep -q "."; then
    echo "⚠️  Found Info.plist files in unexpected locations:"
    find . -name "Info.plist" -not -path "./SyntraChatIOS/Info.plist" -not -path "./SyntraChatIOSTests/Info.plist" -not -path "./SyntraChatIOSUITests/Info.plist"
fi

echo "📊 Total Info.plist files found: $INFOPLISTS_FOUND"

# Check bundle identifiers in project file
echo "\n🏷️  Step 3: Checking bundle identifiers..."

if grep -q "PRODUCT_BUNDLE_IDENTIFIER" SyntraChatIOS.xcodeproj/project.pbxproj; then
    echo "Bundle identifiers found in project:"
    grep "PRODUCT_BUNDLE_IDENTIFIER" SyntraChatIOS.xcodeproj/project.pbxproj | sort | uniq
else
    echo "⚠️  No bundle identifiers found in project file"
fi

# Check for build phases that might conflict
echo "\n⚖️  Step 4: Analyzing build phases..."

if grep -q "Copy Bundle Resources" SyntraChatIOS.xcodeproj/project.pbxproj; then
    COPY_PHASES=$(grep -c "Copy Bundle Resources" SyntraChatIOS.xcodeproj/project.pbxproj)
    echo "📋 Found $COPY_PHASES 'Copy Bundle Resources' phases"
    
    # Check if Info.plist is being copied as a resource (common mistake)
    if grep -A 10 -B 5 "Copy Bundle Resources" SyntraChatIOS.xcodeproj/project.pbxproj | grep -q "Info.plist"; then
        echo "⚠️  POTENTIAL ISSUE: Info.plist found in Copy Bundle Resources phase"
        echo "   This can cause the 'multiple commands produce' error"
    fi
fi

# Check derived data for existing conflicts
echo "\n🗂️  Step 5: Checking derived data..."

DERIVED_DATA_DIRS=$(find ~/Library/Developer/Xcode/DerivedData -name "SyntraChatIOS-*" -type d 2>/dev/null | wc -l)
echo "📊 Found $DERIVED_DATA_DIRS derived data directories for SyntraChatIOS"

if [ $DERIVED_DATA_DIRS -gt 0 ]; then
    echo "🧹 Recommendation: Clean derived data before building"
fi

# Summary and recommendations
echo "\n📝 DIAGNOSIS SUMMARY"
echo "==================="

if [ $INFOPLISTS_FOUND -eq 3 ]; then
    echo "✅ Info.plist files appear to be in correct locations"
elif [ $INFOPLISTS_FOUND -gt 3 ]; then
    echo "⚠️  ISSUE DETECTED: Too many Info.plist files found ($INFOPLISTS_FOUND)"
    echo "   This is likely causing the 'multiple commands produce' error"
else
    echo "ℹ️  Standard Info.plist configuration detected"
fi

echo "\n🔧 RECOMMENDED SOLUTIONS (in order):"
echo "1. Run './fix-build-issue.sh' to clean derived data"
echo "2. If issue persists, check for duplicate targets in Xcode"
echo "3. Verify Info.plist paths in Build Settings"
echo "4. Check bundle identifiers are unique"
echo "5. Remove Info.plist from Copy Bundle Resources if present"

echo "\n📚 Reference: See TROUBLESHOOTING.md for detailed solutions"
echo "🚀 Following SYNTRA Foundation guidelines - no placeholders, real solutions"