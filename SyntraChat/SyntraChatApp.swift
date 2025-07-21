import SwiftUI

@available(macOS 26.0, *)
@main
struct SyntraChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    print("[SyntraChatApp] Window appeared")
                }
        }
        .defaultSize(width: 1000, height: 700)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)

        Settings {
            SettingsPanel(settings: ConfigViewModel())
        }
    }
}
