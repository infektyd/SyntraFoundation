import Vapor
import SyntraKit

actor SyntraService {
    // This function now takes the decoded request, extracts the prompt,
    // and calls your core AI logic in the SyntraKit library.
    func process(request: ChatCompletionRequest) async throws -> String {
        let userPrompt = request.messages.last(where: { $0.role == "user" })?.content.text ?? ""

        guard !userPrompt.isEmpty else {
            // Vapor will catch this and turn it into a 400 Bad Request
            throw Abort(.badRequest, reason: "User prompt is empty or missing.")
        }

        // Call the refactored public function from your library
        return try await SyntraHandlers.handleProcessThroughBrains(userPrompt)
    }
}