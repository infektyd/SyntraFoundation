#!/bin/bash

echo "🔍 SYNTRA @main Conflict Diagnostic - Following CLAUDE.md Pattern"
echo "============================================================="

echo ""
echo "🔍 Step 1: Finding all Swift files that might conflict with @main..."
find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*" 2>/dev/null | head -20

echo ""
echo "🔍 Step 2: Looking for the specific StructuredConsciousnessService.disabled directory..."
find . -name "*StructuredConsciousnessService*" -type d 2>/dev/null

echo ""
echo "🔍 Step 3: Looking for Swift files in disabled directories..."
find . -name "*.disabled" -type d -exec find {} -name "*.swift" \; 2>/dev/null

echo ""
echo "🔍 Step 4: Checking for Swift files with top-level code (grep patterns)..."
echo "Files containing 'import' statements (potential top-level code):"
find . -name "*.swift" -not -path "./.build/*" -exec grep -l "^import" {} \; 2>/dev/null | head -10

echo ""
echo "🔍 Step 5: Files containing @main attribute:"
find . -name "*.swift" -not -path "./.build/*" -exec grep -l "@main" {} \; 2>/dev/null

echo ""
echo "🔍 Step 6: Checking Package.swift target paths that might include disabled files:"
echo "Current StructuredConsciousnessService target path:"
grep -A 3 "StructuredConsciousnessService" Package.swift

echo ""
echo "🔍 Step 7: Looking for potential conflicts in swift/ directory structure..."
ls -la swift/ 2>/dev/null | grep -E "(disabled|\.disabled|\.bak|\.backup)"

echo ""
echo "✅ Diagnostic complete. The conflicting file should be visible above."