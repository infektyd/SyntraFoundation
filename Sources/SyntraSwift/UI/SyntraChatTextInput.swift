import SwiftUI
import Foundation
#if canImport(AppKit)
import AppKit
#endif

@MainActor
public struct SyntraChatTextInput: View {
    @Binding var text: String
    @Binding var isProcessing: Bool
    @FocusState private var isFocused: Bool
    
    private let onSubmit: () async -> Void
    private let placeholder: String
    
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
        HStack {
            textInputField
            sendButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private var textInputField: some View {
        #if os(macOS)
        // AGENTS.md: NSTextField bridge for macOS 26 Beta 3 compatibility
        NativeTextField(
            text: $text,
            placeholder: placeholder,
            isEnabled: !isProcessing,
            onSubmit: { 
                Task { @MainActor in
                    await handleSubmit()
                }
            }
        )
        #else
        // Native SwiftUI for iOS - fixes iOS 26 Beta 3 crashes
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(1...4)
            .focused($isFocused)
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
                .foregroundStyle(text.isEmpty ? Color.secondary : Color.blue)
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

// AGENTS.md: macOS 26 Beta 3 NSTextField Bridge - NO REGRESSION
#if os(macOS)
struct NativeTextField: NSViewRepresentable {
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
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        nsView.isEnabled = isEnabled
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NativeTextField
        
        init(_ parent: NativeTextField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                Task { @MainActor in
                    parent.text = textField.stringValue
                }
            }
        }
        
        @MainActor
        @objc func textFieldAction(_ sender: NSTextField) {
            parent.onSubmit()
        }
    }
}
#endif 