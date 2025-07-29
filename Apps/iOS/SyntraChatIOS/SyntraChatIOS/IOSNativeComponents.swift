import SwiftUI
import UIKit

// MARK: - iOS Native Message Bubble

struct MessageBubble: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.sender == .syntra {
                // SYNTRA avatar
                Image(systemName: message.sender.systemImageName)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            } else {
                Spacer(minLength: 50) // Push user messages to right
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
                    .foregroundColor(bubbleTextColor)
                    .clipShape(BubbleShape(isFromUser: message.sender == .user))
                    .contextMenu {
                        Button("Copy") {
                            // CRITICAL: Ensure UIKit operations on main thread - Beta 3 threading fix
                            DispatchQueue.main.async {
                                UIPasteboard.general.string = message.text
                            }
                        }
                        Button("Share") {
                            shareMessage()
                        }
                    }
                
                // Timestamp
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if message.sender == .user {
                Spacer(minLength: 50) // Push user messages to right
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.accessibilityLabel)
    }
    
    private var bubbleBackground: some View {
        Group {
            if message.isError {
                Color.red.opacity(0.8)
            } else {
                switch message.sender {
                case .user:
                    Color.blue
                case .syntra:
                    Color(UIColor.systemGray5)
                }
            }
        }
    }
    
    private var bubbleTextColor: Color {
        if message.isError {
            return .white
        }
        switch message.sender {
        case .user:
            return .white
        case .syntra:
            return Color(UIColor.label)
        }
    }
    
    private func shareMessage() {
        // CRITICAL: Ensure UIKit operations on main thread - Beta 3 threading fix
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(
                activityItems: [message.text],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
}

// MARK: - Custom Bubble Shape

struct BubbleShape: Shape {
    let isFromUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight, isFromUser ? .bottomLeft : .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}

// MARK: - iOS Native Chat Input Bar

struct ChatInputBar: View {
    @Binding var text: String
    let isProcessing: Bool
    let onSend: () -> Void
    let onMic: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Use thread-safe text input to prevent Beta 3 crashes
            CrashSafeTextInput(
                text: $text,
                placeholder: "Message SYNTRA...",
                isEnabled: !isProcessing,
                onSubmit: onSend
            )

            if isProcessing {
                ProgressView()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .onChange(of: text) { _, newValue in
            // Trigger haptic feedback for typing (subtle)
            if !newValue.isEmpty && newValue.count % 10 == 0 {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}

// MARK: - iOS Loading Indicator

struct SyntraLoadingView: View {
    @State private var rotationDegree: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundColor(.blue)
                .rotationEffect(.degrees(rotationDegree))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotationDegree)
                .onAppear {
                    rotationDegree = 360
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("SYNTRA is thinking...")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("Processing consciousness layers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - iOS Settings Components

struct IOSSettingsToggle: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - iOS System Status View

struct SystemStatusView: View {
    let brain: SyntraBrain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(!brain.isProcessing ? .green : .orange)
                    .frame(width: 8, height: 8)
                
                Text(brain.isProcessing ? "Processing..." : "Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if brain.isProcessing {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            
            if brain.isProcessing {
                Text("Device requirements: 4+ CPU cores, 4GB+ RAM")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - iOS Keyboard Handling

extension View {
    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            // CRITICAL: Ensure UIKit operations on main thread - Beta 3 threading fix
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                // CRITICAL: Ensure UIKit operations on main thread - Beta 3 threading fix
                DispatchQueue.main.async {
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        // Use UIWindowScene.windows instead of deprecated UIApplication.shared.windows
                        let safeAreaBottom: CGFloat
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            safeAreaBottom = window.safeAreaInsets.bottom
                        } else {
                            safeAreaBottom = 0
                        }
                        keyboardHeight = keyboardFrame.height - safeAreaBottom
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }
} 
