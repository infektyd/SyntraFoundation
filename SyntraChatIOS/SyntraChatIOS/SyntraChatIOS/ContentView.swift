import SwiftUI
import UIKit
import UserNotifications

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("🧠 SYNTRA Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("iOS Native Interface")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Simple test for ChatView
                ChatView()
                
                Spacer()
            }
            .navigationTitle("SYNTRA")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupGlobalIOSBehavior()
        }
    }
    
    /// Configure global iOS app behavior and appearance
    private func setupGlobalIOSBehavior() {
        // Ensure all UIKit appearance modifications happen on the main thread
        DispatchQueue.main.async {
            // Configure navigation bar appearance for the entire app
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.systemBackground
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            
            // Apply to all navigation bars
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
            // Configure tab bar appearance (if we add tabs in future)
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // Configure text field and text view appearances
            UITextField.appearance().keyboardAppearance = .default
            UITextView.appearance().keyboardAppearance = .default
            
            // Configure list appearance
            UITableView.appearance().backgroundColor = UIColor.systemBackground
            UITableView.appearance().separatorStyle = .none
        }
        
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