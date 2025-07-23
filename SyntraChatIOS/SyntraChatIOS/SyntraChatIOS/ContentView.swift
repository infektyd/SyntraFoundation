import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Main chat interface
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
            
            // Real-time backend log viewer
            LogViewerView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Backend Logs")
                }
            
            // Settings (if SettingsView exists)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
} 