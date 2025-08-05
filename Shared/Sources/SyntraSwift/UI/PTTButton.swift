/*
 * PTTButton.swift - TEMPORARILY DISABLED
 * 
 * This PTT (Push-to-Talk) button component has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when PTT functionality may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 */

/*
import SwiftUI
import AVFoundation

public struct PTTButton: View {
    @Binding var isEnabled: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    @State private var isPressed = false
    @State private var pressTimer: Timer?
    
    public init(isEnabled: Bool, onStart: @escaping () -> Void, onStop: @escaping () -> Void) {
        self._isEnabled = .constant(isEnabled)
        self.onStart = onStart
        self.onStop = onStop
    }
    
    public var body: some View {
        Button(action: {
            if isPressed {
                stopRecording()
            } else {
                startRecording()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
                
                Image(systemName: isPressed ? "stop.fill" : "mic.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    private func startRecording() {
        isPressed = true
        onStart()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func stopRecording() {
        isPressed = false
        onStop()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    VStack(spacing: 20) {
        PTTButton(
            isEnabled: true,
            onStart: { print("Started recording") },
            onStop: { print("Stopped recording") }
        )
        
        PTTButton(
            isEnabled: false,
            onStart: { print("Started recording") },
            onStop: { print("Stopped recording") }
        )
    }
    .padding()
}
*/ 