import SwiftUI
import Foundation

@MainActor
public struct PTTButton: View {
    @State private var isDown = false
    @State private var isRecording = false
    
    private let onStart: () -> Void
    private let onStop: () -> Void
    private let isEnabled: Bool
    
    public init(
        isEnabled: Bool = true,
        onStart: @escaping @MainActor () -> Void,
        onStop: @escaping @MainActor () -> Void
    ) {
        self.isEnabled = isEnabled
        self.onStart = onStart
        self.onStop = onStop
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            buttonView
            statusLabel
        }
    }
    
    @ViewBuilder
    private var buttonView: some View {
        Circle()
            .fill(buttonColor)
            .frame(width: 80, height: 80)
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: isDown ? 4 : 2)
                    .scaleEffect(isDown ? 1.1 : 1.0)
            )
            .overlay(
                Image(systemName: buttonIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .scaleEffect(isDown ? 1.2 : 1.0)
            )
            .gesture(holdToTalkGesture)
            .accessibilityLabel("Hold to talk to SYNTRA")
            .accessibilityHint("Press and hold to record your voice message")
            .accessibilityAddTraits(isDown ? [.startsMediaSession] : [])
            .disabled(!isEnabled)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDown)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
    }
    
    @ViewBuilder
    private var statusLabel: some View {
        Text(statusText)
            .font(.caption)
            .foregroundColor(.secondary)
            .opacity(isDown || isRecording ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 0.2), value: isDown)
            .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
    
    private var holdToTalkGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isDown && isEnabled {
                    isDown = true
                    isRecording = true
                    
                    // Haptic feedback for voice input start
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    #endif
                    
                    onStart()
                }
            }
            .onEnded { _ in
                if isDown {
                    isDown = false
                    isRecording = false
                    
                    // Haptic feedback for voice input end
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    #endif
                    
                    onStop()
                }
            }
    }
    
    private var buttonColor: Color {
        if !isEnabled {
            return .gray.opacity(0.3)
        } else if isDown {
            return .red
        } else {
            return .accentColor
        }
    }
    
    private var borderColor: Color {
        if !isEnabled {
            return .gray.opacity(0.5)
        } else if isDown {
            return .red.opacity(0.8)
        } else {
            return .accentColor.opacity(0.6)
        }
    }
    
    private var buttonIcon: String {
        if !isEnabled {
            return "mic.slash"
        } else if isDown {
            return "mic.fill"
        } else {
            return "mic"
        }
    }
    
    private var statusText: String {
        if !isEnabled {
            return "Voice input disabled"
        } else if isDown {
            return "Recording..."
        } else {
            return "Hold to talk"
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 40) {
        PTTButton(
            isEnabled: true,
            onStart: { print("Started recording") },
            onStop: { print("Stopped recording") }
        )
        
        PTTButton(
            isEnabled: false,
            onStart: { },
            onStop: { }
        )
    }
    .padding()
}
#endif 