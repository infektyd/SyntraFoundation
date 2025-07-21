#!/bin/bash

echo "🔄 SYNTRA @main Fix - Following CLAUDE.md Grep Diagnostic Pattern"
echo "================================================================="

echo ""
echo "🔍 Step 1: Get verbose build output to identify the exact conflicting file..."
swift build --verbose 2>&1 | grep -A 10 -B 10 "main" | head -30

echo ""
echo "🔍 Step 2: Check for specific @main error patterns..."
swift build 2>&1 | grep -i "error\|main"

echo ""
echo "🔍 Step 3: Find all Swift files that might be included (the culprit should be here)..."
find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*"

echo ""
echo "🔍 Step 4: Check for disabled directories that might be included..."
find . -name "*.disabled" -type d

echo ""
echo "🔍 Step 5: Look specifically for the StructuredConsciousnessService.disabled directory..."
find . -name "*StructuredConsciousnessService*" -type d

echo ""
echo "🔍 Step 6: Check if any disabled Swift files contain top-level code..."
echo "Checking for Swift files in disabled directories:"
find . -name "*.disabled" -type d -exec find {} -name "*.swift" \; 2>/dev/null

echo ""
echo "🧪 Step 7: Test the build with our fix..."
echo "Building SyntraSwiftCLI target..."
swift build --target SyntraSwiftCLI 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Build passed. Testing CLI functionality..."
    swift run SyntraSwiftCLI reflect_valon "test input" 2>/dev/null && echo "✅ CLI test passed" || echo "⚠️ CLI test failed but build succeeded"
else
    echo ""
    echo "❌ Build failed. The conflicting file is likely shown in the output above."
    echo "💡 Based on CLAUDE.md diagnostic pattern, look for files with top-level code outside @main struct."
fi

echo ""
echo "📝 Fix Applied:"
echo "- Added exclusions to StructuredConsciousnessService target"
echo "- Enhanced executable target exclusions for StructuredConsciousnessService.disabled"
echo "- Preserved explicit sources: ['main.swift'] isolation"
echo ""
echo "🔬 This follows the exact pattern that resolved the issue in CLAUDE.md"