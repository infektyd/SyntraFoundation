import SwiftUI

@available(macOS 26.0, *)
@main
struct SyntraChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 650)
                .focusEffectDisabled(false)
                .onAppear {
                    // Ensure window can properly receive keyboard events
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let window = NSApplication.shared.windows.first {
                            window.makeFirstResponder(nil)
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentMinSize)
        .commands {
            // Add keyboard shortcuts for better accessibility
            CommandGroup(after: .newItem) {
                Button("Focus Input Field") {
                    // This will be handled by the ContentView focus state
                }
                .keyboardShortcut("i", modifiers: [.command])
            }
        }
    }
}
