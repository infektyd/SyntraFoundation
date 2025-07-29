#!/bin/bash

echo "🚀 Launching SYNTRA iOS App..."

# Build and run the app
xcodebuild -project SyntraChatIOS.xcodeproj -scheme SyntraChatIOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' clean build

if [ $? -eq 0 ]; then
    APP_PATH="/Users/hansaxelsson/Library/Developer/Xcode/DerivedData/SyntraChatIOS-cyrzdlhmlyvdmpgihqfmqysqswoh/Build/Products/Debug-iphonesimulator/SyntraChatIOS.app"
    
    echo "📱 Installing app to simulator..."
    xcrun simctl install booted "$APP_PATH"
    
    echo "🎬 Launching app..."
    xcrun simctl launch booted Infektyd.SyntraChatIOS
    
    echo "📋 To see debug output, run:"
    echo "xcrun simctl spawn booted log stream --predicate 'process == \"SyntraChatIOS\"'"
    
else
    echo "❌ Build failed!"
fi