// Main.swift
// SyntraFoundation ▸ APIs executable
// Swift 6.0-compatible OpenAI-style REST server exposing SYNTRA consciousness

import Foundation
import Network
import FoundationModels // Crucial for LanguageModelSession.GenerationError
import SyntraWrappers // SyntraCLIWrapper + helpers

// MARK: - Custom Logging (Fixes Darwin log conflict)
private func log(_ message: String) {
    print("[SYNTRA API] [\(Date())] \(message)")
}

// MARK: - Custom Errors
enum HTTPError: Error {
    case badRequest
    case payloadTooLarge
    case internalServerError
}

// MARK: - Request Guard
struct RequestGuard {
    static let maxBodyBytes = 5_000_000 // 5 MB safety cap
    static func validate(_ body: Data) throws {
        guard body.count <= maxBodyBytes else { throw HTTPError.payloadTooLarge }
    }
}

// MARK: - ChatCompletionRequest (Decodable for JSON parsing)
struct ChatCompletionRequest: Decodable {
    struct Message: Decodable {
        let role: String
        let content: String
    }
    let model: String?
    let stream: Bool?
    let messages: [Message]
}

// MARK: - Entry point
@main
public struct SyntraAPIServer {
    private static let port: NWEndpoint.Port = 8081

    public static func main() async throws {
        log("🧠 SYNTRA API Server starting on port \(port)…")
        log("🏥 Performing consciousness health check…")
        if await SyntraCLIWrapper.healthCheck() {
            log("✅ Consciousness core is responsive.")
        } else {
            log("⚠️ WARNING: health check failed – API calls may error.")
            log(" Did you run `swift build --product SyntraSwiftCLI` ?")
        }
        let listener = try NWListener(using: .tcp, on: port)
        listener.stateUpdateHandler = handleStateUpdate(_:)
        listener.newConnectionHandler = { connection in
            Task.detached { await handle(connection: connection) }
        }
        listener.start(queue: .main)
        log("🔄 Server running. Press Ctrl-C to stop.")
        try await withTaskCancellationHandler(
            operation: { try await Task.sleep(nanoseconds: .max) },
            onCancel: { log("🛑 Shutting down…") }
        )
    }

    // MARK: - Listener State Handler
    private static func handleStateUpdate(_ state: NWListener.State) {
        switch state {
        case .ready:
            log("Listener ready on port \(port)")
        case .failed(let error):
            log("Listener failed: \(error.localizedDescription)")
            fatalError("Cannot recover from listener error")
        default:
            break
        }
    }
}

// MARK: - Connection handling
extension SyntraAPIServer {
    private static func handle(connection: NWConnection) async {
        connection.start(queue: .global())
        defer { connection.cancel() }
        do {
            let data = try await receive(on: connection)
            let response = await process(requestData: data, connection: connection)
            if !response.isEmpty {
                try await send(response, on: connection)
            }
        } catch {
            log("❌ Connection error: \(error.localizedDescription)")
        }
    }

    private static func sendRaw(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { cont in
            connection.send(content: data, completion: .contentProcessed { _ in cont.resume() })
        }
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

    private static func parseRequestLine(_ line: String) -> (String, String)? {
        let parts = line.split(separator: " ")
        return parts.count >= 2 ? (String(parts[0]), String(parts[1])) : nil
    }

    private static func extractBody(from request: String) -> String {
        if let range = request.range(of: "\r\n\r\n") {
            return String(request[range.upperBound...])
        }
        if let range = request.range(of: "\n\n") {
            return String(request[range.upperBound...])
        }
        return ""
    }

    private static func summarizeLargePrompt(_ prompt: String) async throws -> String {
        // This is a compatibility shim for non-overlapping model limits
        return String(prompt.prefix(8000)) + " [Summarized]"
    }

    private static func process(requestData data: Data, connection: NWConnection) async -> Data {
        guard let request = String(data: data, encoding: .utf8),
              let firstLine = request.split(separator: "\n").first,
              let (method, path) = parseRequestLine(String(firstLine)) else {
            return httpError(400, "Bad Request")
        }
        if method == "OPTIONS" {
            return httpResponse(200, body: "", contentType: "application/json; charset=utf-8")
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
            return await handleChatCompletions(body: body, connection: connection)
        case ("GET", "/"):
            return httpResponse(200, body: welcomeHTML(), contentType: "text/html; charset=utf-8")
        default:
            return httpError(404, "Endpoint Not Found")
        }
    }
}

// MARK: - Chat/completions (Enhanced with better error handling and LLM summarization)
extension SyntraAPIServer {
    private static func handleChatCompletions(body: String, connection: NWConnection) async -> Data {
        log("🔍 PROCESSING: Chat completions request")
        guard let blob = body.data(using: .utf8) else {
            log("❌ UTF8 conversion failed")
            return httpError(400, "Invalid UTF-8")
        }
        do {
            try RequestGuard.validate(blob)
        } catch {
            log("❌ Payload too large")
            return httpError(413, "Payload too large")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.allowsJSON5 = true
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        do {
            let request = try decoder.decode(ChatCompletionRequest.self, from: blob)
            log("🔍 message count: \(request.messages.count)")
            let userPrompt = request.messages.reversed().first(where: { $0.role == "user" })?.content ?? ""
            guard !userPrompt.isEmpty else {
                log("❌ Empty user prompt")
                return httpError(400, "Empty user prompt")
            }
            let processedPrompt: String
            if userPrompt.count > 8000 {
                log("📏 Summarizing large prompt...")
                processedPrompt = (try? await summarizeLargePrompt(userPrompt)) ?? userPrompt
            } else {
                processedPrompt = userPrompt
            }
            log("🧠 Processing prompt: '\(processedPrompt.prefix(100))...'")
            let reply: String
            do {
                log("🔧 Calling SyntraCLIWrapper.processThroughBrains...")
                reply = try await SyntraCLIWrapper.processThroughBrains(processedPrompt)
                log("✅ Got successful reply: '\(reply.prefix(100))...'")
            } catch let error as LanguageModelSession.GenerationError {
                log("❌ GUARDRAIL VIOLATION: \(error)")
                switch error {
                case .exceededContextWindowSize:
                    log("☝️ Exceeded context window. Summarizing and restarting session...")
                    let summary = (try? await SyntraCLIWrapper.processThroughBrains("Summarize the conversation up to now (preserve Valon/Modi perspectives, max 5 bullets)."))
                    let instructions = "CONTEXT SUMMARY: \(summary ?? "[Summary unavailable]")\nContinue the conversation directly below."
                    let continued = try? await SyntraCLIWrapper.processThroughBrains("\(instructions)\n\n[USER]: \(processedPrompt)")
                    return httpJSON(["response": "[CONTEXT SUMMARIZED]\n" + (continued ?? "[Error after summarization.]")])
                case .guardrailViolation(let context):
                    return await streamErrorResponse(
                        message: "Model refused: \(context.debugDescription)",
                        connection: connection)
                case .unsupportedLanguageOrLocale:
                    return await streamErrorResponse(message: "Language or locale not supported.", connection: connection)
                case .assetsUnavailable:
                    return await streamErrorResponse(message: "Required model assets unavailable.", connection: connection)
                case .unsupportedGuide:
                    return await streamErrorResponse(message: "Unsupported guide or prompt type.", connection: connection)
                case .decodingFailure:
                    return await streamErrorResponse(message: "Response decoding failed.", connection: connection)
                case .rateLimited:
                    return await streamErrorResponse(message: "Rate limit exceeded.", connection: connection)
                case .concurrentRequests:
                    return await streamErrorResponse(message: "Too many concurrent requests.", connection: connection)
                @unknown default:
                    return await streamErrorResponse(message: "Unknown error: \(error.localizedDescription)", connection: connection)
                }
            } catch {
                log("❌ OTHER CLI ERROR: \(error.localizedDescription)")
                return await streamErrorResponse(message: "Unexpected error: \(error.localizedDescription)", connection: connection)
            }

            let isStream = request.stream == true
            log("📤 Responding with streaming=\(isStream)")
            if isStream {
                return await streamResponse(reply: reply, model: request.model, stream: request.stream, connection: connection)
            } else {
                return createNonStreamingResponse(reply: reply, model: request.model, stream: request.stream)
            }
        } catch {
            log("❌ Unexpected decoding error: \(error)")
            return httpJSON(["error": ["code": 500, "message": "Internal error: \(error.localizedDescription)"]])
        }
    }

    private static func streamResponse(
        reply: String,
        model: String?,
        stream: Bool?,
        connection: NWConnection
    ) async -> Data {
        let headers = """
        HTTP/1.1 200 OK\r
        Content-Type: text/event-stream\r
        Cache-Control: no-cache\r
        Connection: keep-alive\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: POST, GET, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type, Authorization\r
        \r
        """
        _ = try? await sendRaw(headers.data(using: .utf8) ?? Data(), on: connection)
        let words = reply.components(separatedBy: " ")
        let chunks = words.enumerated().map { index, word in index == words.count - 1 ? word : word + " " }
        let now = Int(Date().timeIntervalSince1970)
        let modelId = model ?? "gpt-4"
        let chatId = "chatcmpl-\(UUID().uuidString)"
        for chunk in chunks {
            let out: [String: Any] = [
                "id": chatId,
                "object": "chat.completion.chunk",
                "created": now,
                "model": modelId,
                "choices": [[
                    "index": 0,
                    "delta": ["content": chunk],
                    "finish_reason": NSNull()
                ]]
            ]
            if let eventData = try? JSONSerialization.data(withJSONObject: out),
               let eventStr = String(data: eventData, encoding: .utf8) {
                _ = try? await sendRaw("data: \(eventStr)\n\n".data(using: .utf8) ?? Data(), on: connection)
                try? await Task.sleep(nanoseconds: 25_000_000)
            }
        }
        let finalChunk: [String: Any] = [
            "id": chatId,
            "object": "chat.completion.chunk",
            "created": now,
            "model": modelId,
            "choices": [[
                "index": 0,
                "delta": [:],
                "finish_reason": "stop"
            ]]
        ]
        if let finalData = try? JSONSerialization.data(withJSONObject: finalChunk),
           let finalStr = String(data: finalData, encoding: .utf8) {
            _ = try? await sendRaw("data: \(finalStr)\n\n".data(using: .utf8) ?? Data(), on: connection)
        }
        _ = try? await sendRaw("data: [DONE]\n\n".data(using: .utf8) ?? Data(), on: connection)
        return Data()
    }

    private static func createNonStreamingResponse(
        reply: String,
        model: String?,
        stream: Bool?
    ) -> Data {
        let payload: [String: Any] = [
            "id": "chatcmpl-\(UUID().uuidString)",
            "object": "chat.completion",
            "created": Int(Date().timeIntervalSince1970),
            "model": model ?? "gpt-4",
            "choices": [[
                "index": 0,
                "message": ["role": "assistant", "content": reply],
                "finish_reason": "stop"
            ]],
            "usage": [
                "prompt_tokens": 50,
                "completion_tokens": reply.split(separator: " ").count,
                "total_tokens": 50 + reply.split(separator: " ").count
            ]
        ]
        return httpJSON(payload)
    }

    private static func streamErrorResponse(message: String, connection: NWConnection) async -> Data {
        let headers = """
        HTTP/1.1 500 Internal Server Error\r
        Content-Type: text/event-stream\r
        Cache-Control: no-cache\r
        Connection: keep-alive\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: POST, GET, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type, Authorization\r
        \r
        """
        _ = try? await sendRaw(headers.data(using: .utf8) ?? Data(), on: connection)
        let errorChunk: [String: Any] = [
            "id": "chatcmpl-error",
            "object": "chat.completion.chunk",
            "created": Int(Date().timeIntervalSince1970),
            "model": "gpt-4",
            "choices": [[
                "index": 0,
                "delta": ["content": "[ERROR] \(message)"],
                "finish_reason": "error"
            ]]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: errorChunk),
           let str = String(data: data, encoding: .utf8) {
            _ = try? await sendRaw("data: \(str)\n\n".data(using: .utf8) ?? Data(), on: connection)
        }
        _ = try? await sendRaw("data: [DONE]\n\n".data(using: .utf8) ?? Data(), on: connection)
        return Data()
    }
}

// MARK: - Low-level network I/O
extension SyntraAPIServer {
    private static func receive(on connection: NWConnection) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 10_485_760) { data, _, _, error in
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
}

// MARK: - HTTP helpers with CORS applied to ALL responses
extension SyntraAPIServer {
    private static func httpResponse(_ code: Int, body: String, contentType: String = "text/plain; charset=utf-8") -> Data {
        """
        HTTP/1.1 \(code) \(statusText(code))\r
        Content-Type: \(contentType)\r
        Content-Length: \(body.utf8.count)\r
        Access-Control-Allow-Origin: *\r
        Access-Control-Allow-Methods: POST, GET, OPTIONS\r
        Access-Control-Allow-Headers: Content-Type, Authorization\r
        Connection: close\r
        \r
        \(body)
        """.data(using: .utf8)!
    }

    private static func statusText(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 400: return "Bad Request"
        case 404: return "Not Found"
        case 413: return "Payload Too Large"
        case 500: return "Internal Server Error"
        default: return "Unknown"
        }
    }

    private static func openAIModelsPayload() -> [String: Any] {
        [
            "object": "list",
            "data": [
                [
                    "id": "gpt-4",
                    "object": "model",
                    "created": Int(Date().timeIntervalSince1970),
                    "owned_by": "syntra-foundation",
                    "permission": [],
                    "root": "gpt-4"
                ],
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
        <h1>Server is online.</h1>
        <p><strong>OpenAI-compatible endpoints:</strong></p>
        <ul>
            <li>POST /v1/chat/completions (Xcode 26 compatible)</li>
            <li>GET /v1/models</li>
            <li>GET /api/health</li>
        </ul>
        """
    }
}

