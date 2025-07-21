#!/bin/bash

echo "🔎 SYNTRA @main Grep Diagnostic - Exact CLAUDE.md Pattern"
echo "=========================================================="

# This follows the exact diagnostic from CLAUDE.md that found:
# swift/StructuredConsciousnessService.disabled/StructuredConsciousnessService.swift

echo ""
echo "🔍 1. Finding all Swift files that might be included in compilation..."
echo "Using the exact command pattern from CLAUDE.md:"
find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*"

echo ""
echo "🎯 2. Looking specifically for the known culprit pattern..."
echo "Checking for StructuredConsciousnessService.disabled directory:"
find . -name "*StructuredConsciousnessService.disabled*" -type d

echo ""
echo "🔍 3. Finding Swift files in any disabled directories..."
find . -path "*/StructuredConsciousnessService.disabled/*" -name "*.swift"

echo ""
echo "🔍 4. Alternative search - any .disabled directories with Swift files:"
find . -name "*.disabled" -type d -exec find {} -name "*.swift" \; 2>/dev/null

echo ""
echo "🔍 5. Checking if the main.swift file itself has issues..."
if [ -f "swift/Main/main.swift" ]; then
    echo "✓ swift/Main/main.swift exists"
    echo "First few lines of main.swift:"
    head -15 swift/Main/main.swift 2>/dev/null || echo "❌ Cannot read swift/Main/main.swift"
else
    echo "❌ swift/Main/main.swift not found!"
fi

echo ""
echo "🔍 6. Checking for any Swift files that might contain top-level code..."
echo "Files with 'import' statements (potential top-level code):"
find . -name "*.swift" -not -path "./.build/*" -exec grep -l "^import" {} \; | head -5

echo ""
echo "📊 Summary: The conflicting file should be visible above."
echo "Based on CLAUDE.md pattern, look for files in StructuredConsciousnessService.disabled/"