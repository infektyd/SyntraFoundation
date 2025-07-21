#!/bin/bash

# Test script for @main attribute fix
echo "🔄 Testing @main attribute fix..."

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
swift package clean
rm -rf .build

echo "🔍 Checking for conflicting Swift files..."
find . -name "*.swift" -not -path "./.build/*" -not -path "./swift/Main/*" | head -10

echo "🔨 Attempting build with fixed Package.swift..."
swift build --target SyntraSwiftCLI 2>&1 | tee build_output.log

if grep -q "error:" build_output.log; then
    echo "❌ Build failed. Checking detailed errors..."
    grep -A 5 -B 5 "main.*attribute" build_output.log || echo "No @main errors found"
    grep -A 3 "error:" build_output.log
else
    echo "✅ Build succeeded! Testing CLI..."
    swift run SyntraSwiftCLI reflect_valon "test input" || echo "CLI test failed but build succeeded"
fi

echo "📝 Build log saved to build_output.log"