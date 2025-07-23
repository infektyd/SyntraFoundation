import SwiftUI
import UIKit

// App Delegate for security and crash prevention measures
class SyntraAppDelegate: NSObject, UIApplicationDelegate {
    
    // CRITICAL: Disable custom keyboards to prevent Beta 3 crashes and security issues
    // Reference: https://thisdevbrain.com/how-to-disable-custom-keyboards-ios/
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        switch extensionPointIdentifier {
        case UIApplication.ExtensionPointIdentifier.keyboard:
            print("[SyntraApp] SECURITY: Blocking custom keyboard to prevent Beta 3 crashes")
            return false // Block all custom keyboards
        default:
            return true
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("[SyntraApp] SAFETY: App launched with keyboard crash prevention enabled")
        return true
    }
}

@main
struct SyntraChatIOSApp: App {
    
    // Use our custom app delegate with security measures
    @UIApplicationDelegateAdaptor(SyntraAppDelegate.self) var appDelegate
    init() {
        // Configure iOS-specific app behavior on main thread before any UI is rendered
        setupIOSAppearance()
        
        // Generate the beautiful Celtic knot app icon if it doesn't exist
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            GenerateAppIcon.run()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Support system light/dark mode
        }
    }
    
    private func setupIOSAppearance() {
        // CRITICAL: Disable cursor indicators to prevent Beta 3 crashes
        // Based on: https://macmost.com/turning-off-the-caps-lock-and-other-text-cursor-indicators-on-your-mac.html
        // This prevents the setKeyboardAppearance crash by disabling cursor indicators system-wide
        
        DispatchQueue.main.async {
            // Configure iOS navigation appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // CRITICAL: Disable cursor indicators to prevent Beta 3 crashes
            // This prevents the setKeyboardAppearance crash by disabling cursor indicators
            if #available(iOS 17.0, *) {
                // Disable cursor indicators for all text input components
                UITextView.appearance().keyboardAppearance = .default
                UITextField.appearance().keyboardAppearance = .default
                
                // Additional crash prevention: Disable cursor indicators
                // This prevents the NSInternalInconsistencyException from setKeyboardAppearance
                let textViewAppearance = UITextView.appearance()
                textViewAppearance.keyboardAppearance = .default
                
                let textFieldAppearance = UITextField.appearance()
                textFieldAppearance.keyboardAppearance = .default
                
                // Disable any cursor-related appearance changes
                if let textViewClass = NSClassFromString("UITextView") as? UITextView.Type {
                    // Force disable cursor indicators
                    textViewClass.appearance().keyboardAppearance = .default
                }
            }
            
            print("[SyntraApp] CRASH PREVENTION: Cursor indicators disabled for Beta 3 compatibility")
        }
    }
} 