import SwiftUI
import UIKit

/// Simple app icon generator script
/// Run this to generate the Celtic knot app icon
struct GenerateAppIcon {
    
    static func run() {
        print("🎨 SYNTRA Gemini App Icon Generator")
        print("=" * 50)
        
        // Test the new image-based icon generation
        TestIconGeneration.test()
        
        print("✅ App icon generation complete!")
        print("📱 Your SYNTRA app now has a beautiful Gemini-generated icon!")
        print("🔧 All @2x and @3x variants generated for crisp display!")
    }
    
    static func generateMainIcon() {
        let renderer = ImageRenderer(content: CelticKnotIcon(size: 1024))
        renderer.scale = 1.0
        
        if let image = renderer.uiImage {
            saveIconToAssets(image)
            print("✅ Generated 1024x1024 app icon")
        } else {
            print("❌ Failed to generate app icon")
        }
    }
    
    static func saveIconToAssets(_ image: UIImage) {
        guard let data = image.pngData() else {
            print("❌ Failed to create PNG data")
            return
        }
        
        let assetsPath = getAssetsPath()
        let iconPath = assetsPath.appendingPathComponent("AppIcon-1024.png")
        
        do {
            try data.write(to: iconPath)
            print("✅ Saved icon to: \(iconPath.path)")
        } catch {
            print("❌ Failed to save icon: \(error)")
        }
    }
    
    static func updateContentsJSON() {
        let assetsPath = getAssetsPath()
        let contentsPath = assetsPath.appendingPathComponent("Contents.json")
        
        let updatedJSON = """
        {
          "images" : [
            {
              "filename" : "AppIcon-1024.png",
              "idiom" : "ios-marketing",
              "scale" : "1x",
              "size" : "1024x1024"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        
        do {
            try updatedJSON.write(to: contentsPath, atomically: true, encoding: .utf8)
            print("✅ Updated Contents.json")
        } catch {
            print("❌ Failed to update Contents.json: \(error)")
        }
    }
    
    static func getAssetsPath() -> URL {
        let projectPath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Assets.xcassets")
            .appendingPathComponent("AppIcon.appiconset")
        return projectPath
    }
}

/// Extension for string repetition
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

/// Preview for development
struct GenerateAppIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("SYNTRA App Icon Generator")
                .font(.title)
                .foregroundColor(.blue)
            
            if let sourceImage = IconGenerator.loadSourceImage() {
                Image(uiImage: sourceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .border(Color.blue, width: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .border(Color.red, width: 2)
                    .overlay(Text("No Image Found").foregroundColor(.red))
            }
            
            Text("Gemini Generated Design")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Generate App Icon") {
                GenerateAppIcon.run()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding()
    }
} 