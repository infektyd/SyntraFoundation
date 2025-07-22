import SwiftUI
import Foundation
#if os(macOS)
import AppKit
#endif

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
        onSubmit: @escaping () async -> Void
    ) {
        self._text = text
        self._isProcessing = isProcessing
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack {
            textInput
            sendButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .task {
            // Ensure all text operations happen on main thread
            await MainActor.run {
                // Pre-warm text input system to avoid threading issues
            }
        }
    }
    
    @MainActor
    @ViewBuilder
    private var textInput: some View {
        #if os(macOS)
        // AGENTS.md: NSTextField bridge for macOS 26 Beta 3 compatibility
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
        // Native SwiftUI for iOS - no threading issues
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
            Image(systemName: isProcessing ? "stop.circle" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundStyle(text.isEmpty ? .secondary : Color.blue)
        }
        .disabled(text.isEmpty && !isProcessing)
    }
    
    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.thinMaterial)
            .stroke(.quaternary, lineWidth: 1)
    }
    
    @MainActor
    private func handleSubmit() async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await onSubmit()
    }
}

// AGENTS.md: macOS 26 Beta 3 Threading Fix - NO REGRESSION
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
        
        // CRITICAL: Avoid setKeyboardAppearance that triggers Beta 3 bug
        // Don't set keyboardAppearance - let it use system default
        // This prevents the threading violation crash
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        // Ensure all updates happen on main thread - Beta 3 Fix
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
                // Ensure text binding updates on main thread - Critical for Beta 3
                DispatchQueue.main.async {
                    self.parent.text = textField.stringValue
                }
            }
        }
        
        @objc func textFieldAction(_ sender: NSTextField) {
            // Direct call since we're already on MainActor
            parent.onSubmit()
        }
    }
}
#endif 