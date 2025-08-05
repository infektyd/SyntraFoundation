// Main.swift
// SyntraFoundation ▸ APIs executable
// Swift 6.2-compatible OpenAI-style REST server exposing SYNTRA consciousness

import Foundation
import Network
import SyntraWrappers  // SyntraCLIWrapper + helpers

// MARK: - Entry point
@main
public struct SyntraAPIServer {

    private static let port: NWEndpoint.Port = 8080

    public static func main() async throws {
        log("🧠 SYNTRA API Server starting on port \(port)…")

        // Health-check
        log("🏥 Performing consciousness health check…")
        if await SyntraCLIWrapper.healthCheck() {
            log("✅ Consciousness core is responsive.")
        } else {
            log("⚠️ WARNING: health check failed – API calls may error.")
            log(" Did you run `swift build --product SyntraSwiftCLI` ?")
        }

        // TCP listener
        let listener = try NWListener(using: .tcp, on: port)
        listener.stateUpdateHandler = handleStateUpdate(_:)
        listener.newConnectionHandler = { connection in
            Task.detached { await handle(connection: connection) }
        }
        listener.start(queue: .main)
        log("🔄 Server running. Press Ctrl-C to stop.")

        // Keep process alive
        try await withTaskCancellationHandler(
            operation: { try await Task.sleep(nanoseconds: .max) },
            onCancel: { log("🛑 Shutting down…") }
        )
    }

    // MARK: - Connection handling
    private static func handle(connection: NWConnection) async {
        connection.start(queue: .global())
        defer { connection.cancel() }
        do {
            let data = try await receive(on: connection)
            let response = await process(requestData: data, connection: connection)
            // Only sends for non-streaming (SSE does its own write/end)
            if !response.isEmpty {
                try await send(response, on: connection)
            }
        } catch {
            log("❌ Connection error: \(error.localizedDescription)")
        }
    }

    private static func process(requestData data: Data, connection: NWConnection) async -> Data {
        guard let request = String(data: data, encoding: .utf8),
              let firstLine = request.split(separator: "\n").first,
              let (method, path) = parseRequestLine(String(firstLine)) else {
            return httpError(400, "Bad Request")
        }
        let body = extractBody(from: request)
        log("📨 \(method) \(path)")

        switch (method, path) {
        case ("GET", "/api/health"):
            let ok = await SyntraCLIWrapper.healthCheck()
            return httpJSON(["status": ok ? "healthy" : "unhealthy"])

        case ("POST", "/api/consciousness/process"):
            let reply = try? await SyntraCLIWrapper.processThroughBrains(body)
            return httpJSON(["response": reply ?? "Error processing request."])

        case let ("GET", p) where p.starts(with: "/v1/models"):
            return httpJSON(openAIModelsPayload())
        case ("POST", "/v1/chat/completions"):
            // NEW: Supports streaming and non-streaming OpenAI completion!
            return await handleChatCompletions(body: body, connection: connection)

        case ("GET", "/"):
            return httpResponse(200, body: welcomeHTML(), contentType: "text/html; charset=utf-8")
        default:
            return httpError(404, "Endpoint Not Found")
        }
    }

    // MARK: - Chat/completions (SSE streaming support)
    private static func handleChatCompletions(body: String, connection: NWConnection) async -> Data {
        guard let blob = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: blob) as? [String: Any],
              let messages = json["messages"] as? [[String: Any]] else {
            return httpError(400, "Invalid request payload")
        }
        let userPrompt = messages.reversed().first { $0["role"] as? String == "user" }?["content"] as? String ?? ""
        guard !userPrompt.isEmpty else { return httpError(400, "No user message found") }

        let isStream = (json["stream"] as? Bool) == true
        log("🧠 Processing chat completion – stream=\(isStream)")

        // Always get the result up front (sync)
        let reply = (try? await SyntraCLIWrapper.processThroughBrains(userPrompt)) ?? "I’m having trouble processing that right now."

        if isStream {
            // Build chunk for each token, word, or char (example: char-wise, for compatibility)
            // In production, do this per-token or per-sentence for realism
            let chunks = Array(reply).map { String($0) }

            // OpenAI-compatible chunk format (minimal, but sufficient for Xcode IDE and proxy clients)
            // Each event:
            // data: { "id": ..., "object": "chat.completion.chunk", ... "choices": [{"delta":{"content": "<chunk>"}, ... }] }
            // Last event: data: [DONE]

            // Compose and send chunks
            let now = Int(Date().timeIntervalSince1970)
            let modelId = json["model"] as? String ?? "syntra-consciousness"
            let chatId = "chatcmpl-\(UUID().uuidString)"
            for (i, chunk) in chunks.enumerated() {
                // Build JSON event
                let out: [String: Any] = [
                    "id": chatId,
                    "object": "chat.completion.chunk",
                    "created": now,
                    "model": modelId,
                    "choices": [[
                        "index": 0,
                        "delta": ["content": chunk],
                        "finish_reason": NSNull() // Will be non-null only on final event
                    ]]
                ]
                if let eventData = try? JSONSerialization.data(withJSONObject: out),
                   let eventStr = String(data: eventData, encoding: .utf8) {
                    let full = "data: \(eventStr)\n\n"
                    _ = try? await sendRawRaw(full, on: connection)
                    // Add a slight artificial delay to feel "streamy" (can remove for prod and true async)
                    try? await Task.sleep(nanoseconds: 15_000_000)
                }
            }
            // Final chunk: [DONE]
            _ = try? await sendRawRaw("data: [DONE]\n\n", on: connection)

            return Data() // Indicates "handled!"
        } else {
            // Non-streaming, your previous implementation
            let payload: [String: Any] = [
                "id": "chatcmpl-\(UUID().uuidString)",
                "object": "chat.completion",
                "created": Int(Date().timeIntervalSince1970),
                "model": json["model"] as? String ?? "syntra-consciousness",
                "choices": [[
                    "index": 0,
                    "message": ["role": "assistant", "content": reply],
                    "finish_reason": "stop"
                ]],
                "usage": [
                    "prompt_tokens": userPrompt.split(separator: " ").count,
                    "completion_tokens": reply.split(separator: " ").count,
                    "total_tokens": userPrompt.split(separator: " ").count + reply.split(separator: " ").count
                ]
            ]
            return httpJSON(payload)
        }
    }

    // MARK: - Low-level network I/O
    private static func receive(on connection: NWConnection) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1_048_576) { data, _, _, error in
                if let error { cont.resume(throwing: error) }
                else if let data { cont.resume(returning: data) }
                else { cont.resume(throwing: NSError(domain: "net", code: -1)) }
            }
        }
    }
    private static func send(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { cont in
            connection.send(content: data, completion: .contentProcessed { error in
                error == nil ? cont.resume() : cont.resume(throwing: error!)
            })
        }
    }

    // NEW: For raw SSE chunk output (no HTTP/1.1 header!)
    private static func sendRawRaw(_ s: String, on connection: NWConnection) async throws -> Void {
        let data = s.data(using: .utf8) ?? Data()
        try await withCheckedThrowingContinuation { cont in
            connection.send(content: data, completion: .contentProcessed { error in
                cont.resume()
            })
        }
    }

    // MARK: - HTTP helpers (unchanged)
    private static func httpResponse(_ code: Int, body: String, contentType: String = "text/plain; charset=utf-8") -> Data {
        """
        HTTP/1.1 \(code) \(statusText(code))\r
        Content-Type: \(contentType)\r
        Content-Length: \(body.utf8.count)\r
        Connection: close\r
        \r
        \(body)
        """.data(using: .utf8)!
    }
    private static func httpJSON(_ object: [String: Any]) -> Data {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let string = String(data: data, encoding: .utf8) else {
            return httpError(500, "JSON serialization failed")
        }
        return httpResponse(200, body: string, contentType: "application/json; charset=utf-8")
    }
    private static func httpError(_ code: Int, _ message: String) -> Data {
        httpJSON(["error": message, "status": code])
    }
    private static func statusText(_ code: Int) -> String {
        switch code {
        case 200: "OK"
        case 400: "Bad Request"
        case 404: "Not Found"
        case 500: "Internal Server Error"
        default: "Unknown"
        }
    }

    // MARK: - Utility (unchanged)
    private static func parseRequestLine(_ line: String) -> (String, String)? {
        let parts = line.split(separator: " ")
        return parts.count >= 2 ? (String(parts[0]), String(parts[1])) : nil
    }
    private static func extractBody(from request: String) -> String {
        request.components(separatedBy: "\r\n\r\n").dropFirst().joined(separator: "\r\n\r\n")
    }
    private static func openAIModelsPayload() -> [String: Any] {
        [
            "object": "list",
            "data": [
                [
                    "id": "gpt-3.5-turbo",
                    "object": "model",
                    "created": Int(Date().timeIntervalSince1970),
                    "owned_by": "syntra-foundation",
                    "permission": [],
                    "root": "gpt-3.5-turbo"
                ],
                [
                    "id": "syntra-consciousness",
                    "object": "model",
                    "created": Int(Date().timeIntervalSince1970),
                    "owned_by": "syntra-foundation",
                    "permission": [],
                    "root": "syntra-consciousness"
                ]
            ]
        ]
    }
    private static func welcomeHTML() -> String {
        """
        <html>
            <body>
                <h1>SYNTRA API Server</h1>
                <p>Server is online.<br><br>OpenAI-compatible endpoint:<br><code>/v1/chat/completions</code></p>
            </body>
        </html>
        """
    }

    // MARK: - Listener state updates (unchanged)
    private static func handleStateUpdate(_ state: NWListener.State) {
        switch state {
        case .ready:
            log("🟢 Listening on http://0.0.0.0:\(port)")
            printEndpoints()
        case .failed(let error):
            log("❌ Listener failed: \(error.localizedDescription)")
            exit(1)
        default: break
        }
    }

    // MARK: - Logging and endpoint display (unchanged)
    private static func log(_ s: String) { print(s) }
    private static func printEndpoints() {
        print("   - POST  /v1/chat/completions (OpenAI-compatible, supports streaming SSE)")
        print("   - GET   /api/health           (internal healthcheck)")
    }
}



