#!/bin/bash

echo "🔧 Building and running SYNTRA iOS app with debug logging..."

# Build the app
echo "📦 Building..."
xcodebuild -project SyntraChatIOS.xcodeproj -scheme SyntraChatIOS -sdk iphonesimulator build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
    
    echo "🚀 Looking for debug output in Console.app..."
    echo "In Console.app, filter for: SyntraApp"
    echo "Expected debug messages:"
    echo "  🚀 [SyntraApp] App struct init() called"
    echo "  ✅ [SyntraApp] App struct init() completed"  
    echo "  🪟 [SyntraApp] Creating WindowGroup..."
    echo "  ✨ [SyntraApp] ContentView appeared! UI is working!"
    echo "  🎯 [TestView] TestView appeared - basic SwiftUI is working!"
    
    echo ""
    echo "📱 You can also run the app manually in Xcode and check Xcode's debug console"
    echo "If you see ALL the debug messages but NO UI window, it's a Beta 4 window creation bug."
    echo "If you see some messages but it stops, we found where it crashes!"
    
else
    echo "❌ Build failed!"
fi