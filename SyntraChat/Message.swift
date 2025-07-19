import Foundation

/// Represents a single chat message in the SYNTRA conversation
struct Message: Identifiable, Equatable {
    let id = UUID()
    let sender: String // "You" or "SYNTRA"
    let text: String
    let timestamp: Date
    let isError: Bool
    
    init(sender: String, text: String, isError: Bool = false) {
        self.sender = sender
        self.text = text
        self.timestamp = Date()
        self.isError = isError
    }
    
    /// Creates a user message
    static func user(_ text: String) -> Message {
        Message(sender: "You", text: text)
    }
    
    /// Creates a SYNTRA response message
    static func syntra(_ text: String) -> Message {
        Message(sender: "SYNTRA", text: text)
    }
    
    /// Creates an error message displayed as SYNTRA
    static func error(_ text: String) -> Message {
        Message(sender: "SYNTRA", text: text, isError: true)
    }
}