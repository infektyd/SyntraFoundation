import SwiftUI

#if os(iOS)
extension View {
    @MainActor
    func syntraKeyboardAdaptive() -> some View {
        self
            .textInputAutocapitalization(.sentences)
            .keyboardType(.default)
            .autocorrectionDisabled(false)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                // iOS 26 Beta 3 keyboard handling
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                // Keyboard dismissal handling
            }
    }
}
#endif 