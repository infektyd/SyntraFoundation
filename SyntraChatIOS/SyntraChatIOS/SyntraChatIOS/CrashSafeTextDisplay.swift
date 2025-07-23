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
        // Use HStack with individual characters to completely avoid Text input mechanisms
        // This prevents any cursor interaction that could trigger setKeyboardAppearance crashes
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                // Each character is a separate view to prevent text selection
                Text(String(character))
                    .foregroundColor(color)
                    .font(isPartial ? .body.italic() : .body)
                    .allowsHitTesting(false)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Completely ignore all taps
                    }
            }
        }
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .onTapGesture {
            // Completely ignore all taps
        }
        .background(
            // Invisible background to catch any stray touches
            Rectangle()
                .fill(Color.clear)
                .allowsHitTesting(false)
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
                        .stroke(.red.opacity(0.3), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .onTapGesture {
            // Completely ignore all taps
        }
    }
} 