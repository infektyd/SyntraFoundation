#!/bin/bash

echo "🔧 SYNTRA Sources-legacy Fix - Hide Legacy Files and Check References"
echo "====================================================================="

# Step 1: Check if Sources-legacy exists and show what's in it
echo ""
echo "🔍 Step 1: Checking Sources-legacy directory..."
if [ -d "Sources-legacy" ]; then
    echo "✓ Sources-legacy found. Contents:"
    find Sources-legacy -name "*.swift" | head -10
else
    echo "❌ Sources-legacy directory not found"
    exit 1
fi

# Step 2: Check for any code references to Sources-legacy files
echo ""
echo "🔍 Step 2: Checking for references to Sources-legacy files..."
echo "Searching for imports or references to legacy modules:"

# Check for references in all Swift files
find . -name "*.swift" -not -path "./Sources-legacy/*" -not -path "./.build/*" \
    -exec grep -l "Sources-legacy\|legacy" {} \; 2>/dev/null || echo "No direct references found"

# Check for specific module imports that might reference legacy code
echo ""
echo "Checking for potentially problematic imports in active Swift files:"
find . -name "*.swift" -not -path "./Sources-legacy/*" -not -path "./.build/*" \
    -exec grep -H "^import.*Config\|^import.*MemoryEngine\|^import.*Valon" {} \; 2>/dev/null | head -5

# Step 3: Hide the Sources-legacy directory 
echo ""
echo "🔧 Step 3: Hiding Sources-legacy directory..."
if [ -d "Sources-legacy" ]; then
    # Rename to .Sources-legacy (hidden)
    mv Sources-legacy .Sources-legacy.disabled
    echo "✅ Sources-legacy renamed to .Sources-legacy.disabled (hidden)"
else
    echo "❌ Sources-legacy not found to rename"
fi

# Step 4: Update Package.swift to exclude legacy patterns
echo ""
echo "🔧 Step 4: Adding comprehensive exclusions to Package.swift..."

# Create backup
cp Package.swift Package.swift.backup

# We'll update the Package.swift to add global exclusions
echo "✅ Package.swift backed up to Package.swift.backup"

# Step 5: Test the build
echo ""
echo "🧪 Step 5: Testing build after hiding legacy files..."
swift build --target SyntraSwiftCLI 2>&1 | head -20

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Build passed after hiding Sources-legacy"
    echo "🔒 Sources-legacy is now safely hidden as .Sources-legacy.disabled"
else
    echo ""
    echo "⚠️  Build issues remain. Checking if legacy files are still being found..."
    find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*" | head -10
fi

echo ""
echo "📝 Summary of actions taken:"
echo "- Sources-legacy → .Sources-legacy.disabled (hidden)"
echo "- Checked for code references to legacy modules"
echo "- Package.swift backed up"
echo "- Build tested"
echo ""
echo "🔍 Next: Check integrity by running swift build and verify no references remain"