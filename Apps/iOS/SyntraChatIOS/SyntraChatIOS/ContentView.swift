import SwiftUI

struct ContentView: View {
    @EnvironmentObject var syntraBrain: SyntraBrain
    @State private var hasUIError = false
    
    init() {
        print("🎯🎯🎯 [ContentView] ===== CONTENTVIEW INIT CALLED =====")
    }
    
    var body: some View {
        Group {
            if hasUIError {
                // Fallback UI for debugging
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                    
                    Text("UI Loading Error")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("SYNTRA experienced a UI loading issue. This fallback interface is active.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Retry Main Interface") {
                        hasUIError = false
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Simple working chat for debugging
                    VStack {
                        Text("Simple Chat Test:")
                            .font(.headline)
                        Text("Messages: \(syntraBrain.messages.count)")
                        Text("Processing: \(syntraBrain.isProcessing ? "Yes" : "No")")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            } else {
                mainInterface
                    .onAppear {
                        print("✅ [ContentView] Main interface appeared successfully!")
                    }
            }
        }
    }
    
    @ViewBuilder
    private var mainInterface: some View {
        // print("📱📱📱 [ContentView] ===== CREATING TABVIEW BODY =====") - Moved to onAppear
        
        TabView {
            // Main chat interface - now uses shared SyntraBrain
            Group {
                ChatView()
                    .onAppear { print("✅ [Tab] ChatView tab loaded") }
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chat")
            }
            
            // Memory and knowledge vault
            Group {
                MemoryVaultViewer()
                    .onAppear { print("✅ [Tab] Memory tab loaded") }
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("Memory")
            }
            
            // Real-time backend logs
            Group {
                LogViewerView()
                    .onAppear { print("✅ [Tab] LogViewer tab loaded") }
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Backend Logs")
            }
            
            // Settings and configuration
            Group {
                SettingsView()
                    .onAppear { print("✅ [Tab] SettingsView tab loaded") }
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .onAppear { 
            print("📱📱📱 [ContentView] ===== CREATING TABVIEW BODY =====")
            print("✅ [ContentView] Full TabView interface loaded") 
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("📱 [ContentView] App became active, UI still responsive")
        }
    }
} 