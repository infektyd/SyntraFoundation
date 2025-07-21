import SwiftUI

@main
struct SyntraChatIOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // Support system light/dark mode
                .onAppear {
                    // Configure iOS-specific app behavior
                    setupIOSAppearance()
                }
        }
    }
    
    private func setupIOSAppearance() {
        // Configure iOS navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure iOS keyboard appearance
        UITextView.appearance().keyboardAppearance = .default
        UITextField.appearance().keyboardAppearance = .default
    }
} 