import SwiftUI
import UIKit

@main
struct SyntraChatIOSApp: App {
    init() {
        // Configure iOS-specific app behavior on main thread before any UI is rendered
        setupIOSAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Support system light/dark mode
        }
    }
    
    private func setupIOSAppearance() {
        // Ensure all UIKit appearance modifications happen synchronously on the main thread
        // during the app's initialization. This prevents race conditions with the UI.
        
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
            
            // Configure iOS keyboard appearance.
            // These appearance proxies MUST be mutated on the main thread; otherwise UIKit will raise
            // an NSInternalInconsistencyException like the crash we were seeing when focusing the
            // message input field.
            UITextView.appearance().keyboardAppearance = .default
            UITextField.appearance().keyboardAppearance = .default
        }
    }
} 