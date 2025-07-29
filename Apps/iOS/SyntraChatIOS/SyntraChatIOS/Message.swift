import Foundation
import UIKit

/// Represents a single chat message in the SYNTRA conversation - iOS optimized
struct Message: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let sender: MessageSender
    let text: String
    let timestamp: Date
    let isError: Bool
    
    init(id: UUID = UUID(), sender: MessageSender, text: String, isError: Bool = false) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = Date()
        self.isError = isError
    }
    
    /// Creates a user message
    static func user(_ text: String) -> Message {
        Message(sender: .user, text: text)
    }
    
    /// Creates a SYNTRA response message
    static func syntra(_ text: String) -> Message {
        Message(sender: .syntra, text: text)
    }
    
    /// Creates an error message displayed as SYNTRA
    static func error(_ text: String) -> Message {
        Message(sender: .syntra, text: text, isError: true)
    }
    
    /// Computed property for UI compatibility
    var isFromUser: Bool {
        return sender == .user
    }
    
    /// Accessibility label for VoiceOver
    var accessibilityLabel: String {
        let timeString = timestamp.formatted(date: .omitted, time: .shortened)
        return "\(sender.displayName) at \(timeString): \(text)"
    }
    
    /// iOS-native haptic feedback type for this message
    var hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch sender {
        case .user:
            return .light // Subtle feedback for user messages
        case .syntra:
            return isError ? .heavy : .medium // Stronger feedback for SYNTRA responses
        }
    }
}

enum MessageSender: String, CaseIterable, Codable {
    case user = "user"
    case syntra = "syntra"
    
    var displayName: String {
        switch self {
        case .user:
            return "You"
        case .syntra:
            return "SYNTRA"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .user:
            return "person.circle.fill"
        case .syntra:
            return "brain.head.profile"
        }
    }
    
    var bubbleColor: String {
        switch self {
        case .user:
            return "blue"
        case .syntra:
            return "gray"
        }
    }
} 