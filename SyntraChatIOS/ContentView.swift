import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        ChatView()
            .preferredColorScheme(nil) // Support system appearance
            .onAppear {
                setupGlobalIOSBehavior()
            }
    }
    
    /// Configure global iOS app behavior and appearance
    private func setupGlobalIOSBehavior() {
        // Setup notification permissions for future features
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[iOS Setup] Notification permission error: \(error)")
            } else {
                print("[iOS Setup] Notification permission granted: \(granted)")
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // iPhone SE size
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
                .previewDisplayName("iPhone SE")
            
            // iPhone Pro Max size
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
                .previewDisplayName("iPhone 15 Pro Max")
            
            // iPad size
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
} 