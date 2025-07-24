import SwiftUI

/// CRITICAL: Completely non-interactive text display to prevent Beta 3 crashes
/// This component bypasses all SwiftUI text input mechanisms that cause setKeyboardAppearance crashes
/// Based on macOS 26 Beta 3/4 threading issues documented in Apple Developer Forums
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

/// Enhanced crash-safe text display with additional protection layers
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