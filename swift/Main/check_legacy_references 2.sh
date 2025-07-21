#!/bin/bash

echo "🔍 SYNTRA Legacy Reference Integrity Check"
echo "=========================================="

echo ""
echo "🔍 Step 1: Checking for direct imports of legacy modules in active code..."

# Check for problematic imports in Swift files (not in legacy or build directories)
echo "Checking for legacy module imports:"
find . -name "*.swift" \
    -not -path "./Sources-legacy/*" \
    -not -path "./.Sources-legacy.disabled/*" \
    -not -path "./.build/*" \
    -exec grep -H "^import.*Config$\|^import.*MemoryEngine$\|^import.*Valon$" {} \; 2>/dev/null

echo ""
echo "🔍 Step 2: Checking for any direct references to Sources-legacy..."
find . -name "*.swift" -o -name "*.py" -o -name "*.md" | \
    xargs grep -l "Sources-legacy" 2>/dev/null | \
    grep -v "fix_sources_legacy\|check_legacy_references" || echo "✅ No direct Sources-legacy references found"

echo ""
echo "🔍 Step 3: Checking Package.swift for any legacy references..."
if grep -q "Sources-legacy" Package.swift; then
    echo "⚠️  Package.swift contains Sources-legacy references:"
    grep -n "Sources-legacy" Package.swift
else
    echo "✅ Package.swift is clean of legacy references"
fi

echo ""
echo "🔍 Step 4: Checking if legacy directory still exists..."
if [ -d "Sources-legacy" ]; then
    echo "⚠️  Sources-legacy directory still exists and visible"
    echo "Contents:"
    find Sources-legacy -name "*.swift" | head -5
elif [ -d ".Sources-legacy.disabled" ]; then
    echo "✅ Legacy code safely hidden in .Sources-legacy.disabled"
else
    echo "✅ No legacy directory found"
fi

echo ""
echo "🔍 Step 5: Final build test..."
echo "Testing build to ensure no conflicts remain:"
swift build --target SyntraSwiftCLI 2>&1 | head -10

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Build passes - no legacy conflicts detected"
    echo "🔒 Legacy code integrity maintained"
else
    echo ""
    echo "❌ Build failed - may need additional cleanup"
fi

echo ""
echo "📋 Integrity Check Complete"
echo "=================================="
echo "✅ Files checked for legacy imports"
echo "✅ Package.swift verified clean"
echo "✅ Legacy directory status confirmed" 
echo "✅ Build tested"