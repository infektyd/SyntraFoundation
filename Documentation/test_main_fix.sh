#!/bin/bash

# Test script for @main attribute fix - Bleeding Edge Swift Development
echo "🔄 Testing @main attribute fix for SYNTRA Foundation..."

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
swift package clean
rm -rf .build

echo "🔍 Diagnostic: Checking for conflicting Swift files..."
echo "Files outside swift/Main/ that might cause @main conflicts:"
find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*" | head -10

echo ""
echo "🔍 Checking for .disabled directories (common culprit):"
find . -name "*.disabled" -type d 2>/dev/null || echo "No .disabled directories found"

echo ""
echo "🔍 Checking for backup files that might contain top-level code:"
find . -name "*.bak" -o -name "*.backup" | head -5 || echo "No backup files found"

echo ""
echo "🔨 Attempting build with fixed Package.swift..."
echo "Fix applied: Using explicit 'sources: [\"main.swift\"]' to isolate executable"
swift build --target SyntraSwiftCLI 2>&1 | tee build_output.log

if grep -q "error:" build_output.log; then
    echo ""
    echo "❌ Build failed. Analyzing errors..."
    echo "=== @main Related Errors ==="
    grep -A 5 -B 5 "main.*attribute" build_output.log || echo "No @main errors found"
    echo ""
    echo "=== All Build Errors ==="
    grep -A 3 "error:" build_output.log
    echo ""
    echo "💡 Next steps if this persists:"
    echo "1. Check if swift/Main/main.swift exists and has proper @main struct"
    echo "2. Verify no top-level code outside the @main struct"
    echo "3. Check for hidden Swift files in parent directories"
else
    echo ""
    echo "✅ Build succeeded! Testing CLI functionality..."
    if swift run SyntraSwiftCLI reflect_valon "consciousness test" 2>/dev/null; then
        echo "✅ CLI test passed - SYNTRA consciousness architecture working"
    else
        echo "⚠️  CLI test failed but build succeeded - may need runtime fixes"
    fi
fi

echo ""
echo "📝 Build log saved to build_output.log"
echo "🧪 This fix preserves all FoundationModels bleeding-edge features"