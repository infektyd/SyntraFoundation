import SwiftUI
#if os(iOS)
import UIKit
#endif

extension View {
    /// Thread-safe keyboard dismissal for iOS/macOS 26 Beta 3 compatibility
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            #if os(iOS)
            // CRITICAL: Ensure keyboard dismissal happens on main thread - Beta 3 fix
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            #endif
        }
    }
    
    /// Adaptive keyboard handling for Beta 3 compatibility
    func keyboardAdaptive() -> some View {
        #if os(iOS)
        self.modifier(KeyboardAdaptiveModifier())
        #else
        self
        #endif
    }
}

#if os(iOS)
@MainActor
struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                // CRITICAL: Register for keyboard notifications on main thread - Beta 3 fix
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { notification in
                    // Extract keyboard frame data to avoid data races
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    Task { @MainActor in
                        if let frame = keyboardFrame {
                            self.keyboardHeight = frame.height
                        }
                    }
                }
                
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    Task { @MainActor in
                        self.keyboardHeight = 0
                    }
                }
            }
    }
}
#endif 