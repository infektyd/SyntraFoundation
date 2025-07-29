import UIKit

/// Test class for manual icon generation
class TestIconGeneration {
    
    /// Run icon generation test
    static func test() {
        print("🧪 Testing icon generation with Gemini image...")
        
        // First, test if we can load the source image
        if let sourceImage = IconGenerator.loadSourceImage() {
            print("✅ Source image loaded successfully: \(sourceImage.size)")
            
            // Generate just one test icon to verify the process works
            IconGenerator.generateIcon(size: 180, name: "Test-iPhone-60@3x")
            
            // If that works, generate all icons
            IconGenerator.generateAllIcons()
            
            print("🎯 Icon generation test completed!")
        } else {
            print("❌ Failed to load source image")
        }
    }
} 