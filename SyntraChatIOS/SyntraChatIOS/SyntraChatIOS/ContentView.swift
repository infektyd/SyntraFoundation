import SwiftUI

struct ContentView: View {
    var body: some View {
        // Use the local, native ChatView which correctly uses our SyntraBrain.
        // This makes the UI code we've been fixing part of the active application.
        ChatView()
    }
} 