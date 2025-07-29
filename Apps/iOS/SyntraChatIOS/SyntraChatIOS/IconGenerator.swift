import SwiftUI
import UIKit

/// App Icon Generator Utility
/// Generates all required iOS app icon sizes from the Celtic knot design
class IconGenerator {
    
    /// Required iOS app icon sizes
    static let iconSizes: [(name: String, size: CGFloat)] = [
        ("iPhone-20@2x", 40),   // iPhone 20pt @2x
        ("iPhone-20@3x", 60),   // iPhone 20pt @3x
        ("iPhone-29@2x", 58),   // iPhone 29pt @2x
        ("iPhone-29@3x", 87),   // iPhone 29pt @3x
        ("iPhone-40@2x", 80),   // iPhone 40pt @2x
        ("iPhone-40@3x", 120),  // iPhone 40pt @3x
        ("iPhone-60@2x", 120),  // iPhone 60pt @2x
        ("iPhone-60@3x", 180),  // iPhone 60pt @3x
        ("iPad-20@1x", 20),     // iPad 20pt @1x
        ("iPad-20@2x", 40),     // iPad 20pt @2x
        ("iPad-29@1x", 29),     // iPad 29pt @1x
        ("iPad-29@2x", 58),     // iPad 29pt @2x
        ("iPad-40@1x", 40),     // iPad 40pt @1x
        ("iPad-40@2x", 80),     // iPad 40pt @2x
        ("iPad-76@2x", 152),    // iPad 76pt @2x
        ("iPad-83.5@2x", 167),  // iPad 83.5pt @2x
        ("AppStore-1024", 1024) // App Store 1024pt @1x
    ]
    
    /// Generate all app icon sizes
    static func generateAllIcons() {
        print("🎨 Generating Celtic Knot App Icons...")
        
        for (name, size) in iconSizes {
            generateIcon(size: size, name: name)
        }
        
        print("✅ All app icons generated successfully!")
        print("📁 Icons saved to: \(getIconsDirectory())")
    }
    
    /// Generate a single icon
    static func generateIcon(size: CGFloat, name: String) {
        // Load the Gemini-generated source image
        guard let sourceImage = loadSourceImage() else {
            print("❌ Failed to load source image for \(name)")
            return
        }
        
        // Resize the source image to the required size
        if let resizedImage = resizeImage(sourceImage, to: CGSize(width: size, height: size)) {
            saveImage(resizedImage, name: name)
            print("✅ Generated: \(name) (\(Int(size))x\(Int(size)))")
        } else {
            print("❌ Failed to generate: \(name)")
        }
    }
    
    /// Load the Gemini-generated source image
    static func loadSourceImage() -> UIImage? {
        // Try multiple possible locations for the source image
        let possiblePaths: [String?] = [
            Bundle.main.path(forResource: "Gemini_Generated_Image_yp4joyp4joyp4joy", ofType: "png"),
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Gemini_Generated_Image_yp4joyp4joyp4joy.png").path,
            URL(fileURLWithPath: #file).deletingLastPathComponent()
                .appendingPathComponent("Gemini_Generated_Image_yp4joyp4joyp4joy.png").path
        ]
        
        for path in possiblePaths {
            if let path = path, FileManager.default.fileExists(atPath: path) {
                if let image = UIImage(contentsOfFile: path) {
                    print("✅ Loaded source image from: \(path)")
                    return image
                }
            }
        }
        
        print("❌ Could not find Gemini_Generated_Image_yp4joyp4joyp4joy.png in any expected location")
        return nil
    }
    
    /// Resize image to target size
    static func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Save image directly to Assets.xcassets
    static func saveImage(_ image: UIImage, name: String) {
        guard let data = image.pngData() else {
            print("❌ Failed to create PNG data for \(name)")
            return
        }
        
        // Save to both Documents directory (for backup) and Assets directory
        let documentsDir = getIconsDirectory()
        let assetsDir = getAssetsDirectory()
        
        let documentsURL = documentsDir.appendingPathComponent("\(name).png")
        let assetsURL = assetsDir.appendingPathComponent("\(name).png")
        
        do {
            // Create directories
            try FileManager.default.createDirectory(at: documentsDir, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
            
            // Save to both locations
            try data.write(to: documentsURL)
            try data.write(to: assetsURL)
            
            print("✅ Saved \(name) to both Documents and Assets")
        } catch {
            print("❌ Failed to save \(name): \(error)")
        }
    }
    
    /// Get the icons directory
    static func getIconsDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("AppIcons")
    }
    
    /// Copy icons to Assets.xcassets
    static func copyIconsToAssets() {
        let iconsDir = getIconsDirectory()
        let assetsDir = getAssetsDirectory()
        
        print("📁 Copying icons to Assets.xcassets...")
        
        for (name, _) in iconSizes {
            let sourceURL = iconsDir.appendingPathComponent("\(name).png")
            let destinationURL = assetsDir.appendingPathComponent("\(name).png")
            
            do {
                if FileManager.default.fileExists(atPath: sourceURL.path) {
                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                    print("✅ Copied: \(name)")
                }
            } catch {
                print("❌ Failed to copy \(name): \(error)")
            }
        }
    }
    
    /// Get the Assets.xcassets directory
    static func getAssetsDirectory() -> URL {
        // Use Bundle.main to get correct path to Assets.xcassets in the app bundle
        guard let bundlePath = Bundle.main.bundleURL.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let _ = URL(string: "file://\(bundlePath)") else {
            // Fallback to source directory for development
            let sourcePath = URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("Assets.xcassets")
                .appendingPathComponent("AppIcon.appiconset")
            return sourcePath
        }
        
        // In development, use source directory
        let sourcePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
        
        print("📁 Assets directory: \(sourcePath.path)")
        return sourcePath
    }
}

/// Preview for development
struct IconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("App Icon Generator")
                .font(.title)
            
            CelticKnotIcon(size: 100)
                .border(Color.gray, width: 1)
            
            Button("Generate Icons") {
                IconGenerator.generateAllIcons()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
} 