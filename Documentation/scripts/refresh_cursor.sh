#!/bin/bash

# Refresh Cursor Language Server Script
# This script helps resolve stale linter errors in Cursor

echo "🔄 Refreshing Cursor Language Server..."

# Clean Swift build artifacts
echo "🧹 Cleaning Swift build artifacts..."
swift package clean
rm -rf .build

# Resolve dependencies
echo "📦 Resolving Swift dependencies..."
swift package resolve

# Build project
echo "🔨 Building project..."
swift build

echo "✅ Build completed successfully!"

echo ""
echo "📋 Next steps in Cursor:"
echo "1. Press Cmd+Shift+P to open command palette"
echo "2. Type 'Developer: Reload Window' and select it"
echo "3. Or try 'Swift: Restart Language Server' if available"
echo ""
echo "🎨 For theme issues:"
echo "1. Press Cmd+Shift+P"
echo "2. Type 'Preferences: Color Theme'"
echo "3. Select 'Cursor Dark' or 'Cursor Light'"
echo ""
echo "🔄 If issues persist:"
echo "1. Press Cmd+Shift+P"
echo "2. Type 'Developer: Restart Extension Host'"
echo ""
echo "💡 You can also try:"
echo "- 'Preferences: Reset User Settings' to restore Cursor defaults" 