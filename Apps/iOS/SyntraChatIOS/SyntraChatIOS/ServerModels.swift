import Foundation

// MARK: - Server Response Models
// These structs are designed to match the JSON structure from the Vapor server.

struct ServerChatCompletionResponse: Codable {
    let choices: [ServerChoice]
}

struct ServerChoice: Codable {
    let message: ServerResponseMessage
}

struct ServerResponseMessage: Codable {
    let content: String?
    let role: String
}