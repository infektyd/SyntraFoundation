import SwiftUI
import UIKit

// MARK: - Thread-Safe Text Input Component for iOS 26 Beta 3
/// Prevents NSInternalInconsistencyException: setKeyboardAppearance off main thread
@MainActor
struct CrashSafeTextInput: View {
    @Binding var text: String
    let placeholder: String
    let isEnabled: Bool
    let onSubmit: () -> Void
    
    init(text: Binding<String>, placeholder: String, isEnabled: Bool = true, onSubmit: @escaping () -> Void) {
        self._text = text
        self.placeholder = placeholder
        self.isEnabled = isEnabled
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        // COMPLETE BYPASS of SwiftUI TextField for iOS 26 Beta 3
        // Uses pure UIKit UITextField to avoid setKeyboardAppearance threading bug
        DirectUITextFieldRepresentable(
            text: $text,
            placeholder: placeholder,
            isEnabled: isEnabled,
            onSubmit: onSubmit
        )
    }
}

// MARK: - Direct UITextField Bridge (iOS 26 Beta 3 Threading Bug Bypass)
/// This completely bypasses SwiftUI TextField/UITextView to avoid setKeyboardAppearance threading crashes
@available(iOS 13.0, *)
struct DirectUITextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isEnabled: Bool
    let onSubmit: () -> Void
    
    func makeUIView(context: Context) -> UITextField {
        let textField = ThreadSafeUITextField()
        
        // Configure WITHOUT triggering setKeyboardAppearance
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .sentences
        textField.autocorrectionType = .default
        textField.returnKeyType = .send
        textField.isUserInteractionEnabled = isEnabled
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        // Update on main thread to prevent threading issues
        DispatchQueue.main.async {
            if uiView.text != text {
                uiView.text = text
            }
            uiView.isEnabled = isEnabled
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        let parent: DirectUITextFieldRepresentable
        
        init(_ parent: DirectUITextFieldRepresentable) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            DispatchQueue.main.async {
                if let text = textField.text,
                   let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange, with: string)
                    self.parent.text = updatedText
                }
            }
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.parent.onSubmit()
            }
            return true
        }
    }
}

// MARK: - Thread-Safe UITextField Subclass
/// Custom UITextField that prevents iOS 26 Beta 3 threading crashes
private final class ThreadSafeUITextField: UITextField {
    override var keyboardAppearance: UIKeyboardAppearance {
        get {
            // Always return on main thread
            if Thread.isMainThread {
                return super.keyboardAppearance
            } else {
                return .default
            }
        }
        set {
            // Always set on main thread to prevent iOS 26 Beta 3 crash
            if Thread.isMainThread {
                super.keyboardAppearance = newValue
            } else {
                DispatchQueue.main.async {
                    super.keyboardAppearance = newValue
                }
            }
        }
    }
}

// MARK: - Enhanced Crash-Safe Text Display (Originally for Voice/Transcription)
/// Used for displaying text safely without triggering iOS 26 Beta 3 crashes
/// NOTE: Originally created for voice transcription display, now used for general text safety
/// The voice transcription functionality has been replaced with native iOS dictation
struct EnhancedCrashSafeTextDisplay: View {
    let finalText: String
    let partialText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Final text with maximum crash protection
            if !finalText.isEmpty {
                CrashSafeTextDisplay(finalText, isPartial: false, color: .primary)
            }
            
            // Partial text with maximum crash protection
            if !partialText.isEmpty {
                CrashSafeTextDisplay(partialText, isPartial: true, color: .purple.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .onTapGesture {
            // Completely ignore all taps
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Completely ignore long press
        }
        .gesture(
            // Override all gestures to prevent interaction
            DragGesture()
                .onChanged { _ in }
                .onEnded { _ in }
        )
    }
}

// MARK: - Basic Crash-Safe Text Display
/// Completely non-interactive text display to prevent Beta 3 crashes
struct CrashSafeTextDisplay: View {
    let text: String
    let isPartial: Bool
    let color: Color
    
    init(_ text: String, isPartial: Bool = false, color: Color = .primary) {
        self.text = text
        self.isPartial = isPartial
        self.color = color
    }
    
    var body: some View {
        // Use regular Text with proper wrapping while maintaining crash safety
        Text(text)
            .foregroundColor(color)
            .font(isPartial ? .body.italic() : .body)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion, constrain horizontal
            .frame(maxWidth: .infinity, alignment: .leading)
            .allowsHitTesting(false) // Prevent all touch interaction
            .textSelection(.disabled) // Explicitly disable text selection
            .contentShape(Rectangle())
            .onTapGesture {
                // Completely ignore all taps to prevent focus
            }
            .onLongPressGesture(minimumDuration: 0) {
                // Completely ignore long press to prevent text selection
            }
            .gesture(
                // Override all gestures to prevent text interaction
                DragGesture()
                    .onChanged { _ in }
                    .onEnded { _ in }
            )
    }
}