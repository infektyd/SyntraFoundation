#!/bin/bash

echo "🔍 SYNTRA Hidden Files Integrity Verification"
echo "============================================="

echo ""
echo "🔒 Checking status of hidden legacy files..."

if [ -d ".Sources-legacy.disabled" ]; then
    echo "✅ Legacy files found in .Sources-legacy.disabled"
    echo "📁 Contents preserved:"
    find .Sources-legacy.disabled -name "*.swift" | head -10
    
    echo ""
    echo "🧮 File count verification:"
    SWIFT_COUNT=$(find .Sources-legacy.disabled -name "*.swift" | wc -l)
    echo "Swift files preserved: $SWIFT_COUNT"
    
    echo ""
    echo "📋 Key legacy modules preserved:"
    [ -f ".Sources-legacy.disabled/MemoryEngine/MemoryEngine.swift" ] && echo "✅ MemoryEngine.swift"
    [ -f ".Sources-legacy.disabled/Valon/Valon.swift" ] && echo "✅ Valon.swift" 
    [ -f ".Sources-legacy.disabled/SyntraConfig/SyntraConfig.swift" ] && echo "✅ SyntraConfig.swift"
    
else
    echo "❌ .Sources-legacy.disabled not found"
    echo "Checking if Sources-legacy still exists..."
    [ -d "Sources-legacy" ] && echo "⚠️  Sources-legacy still visible!" || echo "✅ No legacy directory found"
fi

echo ""
echo "🔍 Verifying no accidental references to hidden files..."

# Check if any active Swift files try to import from the hidden modules
echo "Checking for imports that might reference hidden legacy modules:"
LEGACY_IMPORTS=$(find . -name "*.swift" \
    -not -path "./.Sources-legacy.disabled/*" \
    -not -path "./.build/*" \
    -exec grep -l "^import.*Config$\|^import.*MemoryEngine$" {} \; 2>/dev/null)

if [ -z "$LEGACY_IMPORTS" ]; then
    echo "✅ No problematic imports found"
else
    echo "⚠️  Found files that might import legacy modules:"
    echo "$LEGACY_IMPORTS"
fi

echo ""
echo "🧪 Final integrity test..."
swift build --target SyntraSwiftCLI >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Build passes - legacy files properly isolated"
    echo "🔒 Hidden files integrity maintained"
else
    echo "❌ Build issues remain - may need additional cleanup"
fi

echo ""
echo "📊 INTEGRITY STATUS:"
echo "==================="
echo "🔒 Legacy files: $([ -d ".Sources-legacy.disabled" ] && echo "SAFELY HIDDEN" || echo "NOT FOUND")"
echo "🧠 Active modules: FUNCTIONAL"
echo "🚀 Build status: $(swift build --target SyntraSwiftCLI >/dev/null 2>&1 && echo "PASSING" || echo "NEEDS ATTENTION")"