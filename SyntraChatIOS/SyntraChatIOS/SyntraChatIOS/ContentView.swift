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
            
            // Memory Vault Viewer - Real-time storage monitoring
            MemoryVaultViewer()
                .tabItem {
                    Image(systemName: "memorychip")
                    Text("Memory Vault")
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