import SwiftUI
import SyntraSwift

struct ContentView: View {
    // Initialize the configuration for the Syntra Core.
    // This can be expanded later to load from a file or user defaults.
    private let config = SyntraConfig()

    var body: some View {
        // Use the modern, platform-adaptive chat view from our shared library.
        SyntraChatView(config: config)
    }
} 