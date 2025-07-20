import SwiftUI

@available(macOS 26.0, *)
@main
struct SyntraChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsPanel(settings: ConfigViewModel())
        }
    }
}
