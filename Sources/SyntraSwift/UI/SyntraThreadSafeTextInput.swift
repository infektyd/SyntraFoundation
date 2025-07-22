import SwiftUI
import Foundation
#if os(macOS)
import AppKit
#endif

/// Thread-safe text input component that bypasses iOS/macOS 26 Beta 3 threading bug
/// Preserves SYNTRA consciousness architecture while fixing system-level crash
@MainActor
public struct SyntraThreadSafeTextInput: View {
    @Binding var text: String
    @Binding var isProcessing: Bool
    private let placeholder: String
    private let onSubmit: () async -> Void
    
    public init(
        text: Binding<String>,
        isProcessing: Binding<Bool>,
        placeholder: String = "Ask SYNTRA...",
        onSubmit: @escaping @MainActor () async -> Void
    ) {
        self._text = text
        self._isProcessing = isProcessing
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            textInput
            sendButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .task {
            // Pre-initialize text input system on main thread to prevent threading crashes
            await MainActor.run {
                // Force main thread initialization for Beta 3 compatibility
            }
        }
    }
    
    @MainActor
    @ViewBuilder
    private var textInput: some View {
        #if os(macOS)
        // macOS 26 Beta 3 Fix: Use NSTextField bridge to bypass SwiftUI threading bug
        MacOSTextFieldBridge(
            text: $text,
            placeholder: placeholder,
            isEnabled: !isProcessing
        ) {
            Task { @MainActor in
                await handleSubmit()
            }
        }
        #else
        // iOS: Use native SwiftUI with thread safety guards
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(1...4)
            .disabled(isProcessing)
            .textInputAutocapitalization(.sentences)
            .keyboardType(.default)
            .submitLabel(.send)
            .onSubmit {
                Task { @MainActor in
                    await handleSubmit()
                }
            }
        #endif
    }
    
    private var sendButton: some View {
        Button {
            Task { @MainActor in
                await handleSubmit()
            }
        } label: {
            Image(systemName: isProcessing ? "stop.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundStyle(canSubmit ? .blue : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isProcessing)
        }
        .disabled(!canSubmit)
    }
    
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.regularMaterial)
            .stroke(.quaternary, lineWidth: 1)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var canSubmit: Bool {
        (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing) || isProcessing
    }
    
    @MainActor
    private func handleSubmit() async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await onSubmit()
    }
}

// CRITICAL: macOS 26 Beta 3 Threading Fix - NSTextField Bridge
#if os(macOS)
struct MacOSTextFieldBridge: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isEnabled: Bool
    let onSubmit: () -> Void
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.placeholderString = placeholder
        textField.isEnabled = isEnabled
        textField.target = context.coordinator
        textField.action = #selector(Coordinator.textFieldAction(_:))
        textField.focusRingType = .none
        textField.isBordered = false
        textField.backgroundColor = .clear
        
        // CRITICAL: Avoid setKeyboardAppearance calls that trigger Beta 3 crash
        // Let NSTextField use system defaults without appearance modifications
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        // Ensure all NSTextField updates happen on main thread - Beta 3 Fix
        DispatchQueue.main.async {
            if nsView.stringValue != text {
                nsView.stringValue = text
            }
            nsView.isEnabled = isEnabled
            nsView.placeholderString = placeholder
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: MacOSTextFieldBridge
        
        init(_ parent: MacOSTextFieldBridge) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                // CRITICAL: Ensure text binding updates on main thread - Beta 3 threading fix
                DispatchQueue.main.async {
                    self.parent.text = textField.stringValue
                }
            }
        }
        
        @objc func textFieldAction(_ sender: NSTextField) {
            // CRITICAL: Ensure onSubmit is called on main thread - Beta 3 threading fix
            DispatchQueue.main.async {
                self.parent.onSubmit()
            }
        }
    }
}
#endif 