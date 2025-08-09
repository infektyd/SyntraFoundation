import Foundation
import Network
import FoundationModels
import SyntraWrappers

private func log(_ message: String) {
    print("[SYNTRA API] [\(Date())] \(message)")
}

enum HTTPError: Error {
    case badRequest, payloadTooLarge, internalServerError
}

struct RequestGuard {
    static let maxBodyBytes = 5_000_000
    static func validate(_ body: Data) throws {
        guard body.count <= maxBodyBytes else { throw HTTPError.payloadTooLarge }
    }
}

struct ChatCompletionRequest: Decodable {
    struct Message: Decodable {
        let role: String
        let content: Content
        enum Content: Decodable {
            case string(String)
            case array([ContentPart])
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else if let array = try? container.decode([ContentPart].self) {
                    self = .array(array)
                } else {
                    throw DecodingError.typeMismatch(Content.self, DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected String or Array for content"
                    ))
                }
            }
            var text: String {
                switch self {
                case .string(let str): return str
                case .array(let parts): return parts.compactMap { $0.text }.joined(separator: " ")
                }
            }
        }
        struct ContentPart: Decodable {
            let type: String
            let text: String?
        }
    }
    let model: String?
    let stream: Bool?
    let messages: [Message]
}

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

    private static func handleStateUpdate(_ state: NWListener.State) {
        switch state {
        case .ready: log("Listener ready on port \(port)")
        case .failed(let error):
            log("Listener failed: \(error.localizedDescription)")
            fatalError("Cannot recover from listener error")
        default: break
        }
    }

    private static func handle(connection: NWConnection) async {
        connection.start(queue: .global())
        defer { connection.cancel() }
        do {
            let request = try await receiveHTTPRequest(on: connection)
            log("📥 RAW FULL HTTP DATA (\(request.count) bytes):\n\(String(data: request, encoding: .utf8) ?? "<non-UTF8 binary>")")
            let response = await process(requestData: request, connection: connection)
            if !response.isEmpty {
                try await send(response, on: connection)
            }
        } catch {
            log("❌ Connection error: \(error)")
        }
    }

    // HTTP/1.1 parser: reads headers, then Content-Length bytes for body
    private static func receiveHTTPRequest(on connection: NWConnection) async throws -> Data {
        var rawData = Data()
        let delimiter = Data("\r\n\r\n".utf8)
        while !rawData.contains(delimiter) {
            let chunk = try await receiveChunk(on: connection)
            rawData.append(chunk)
        }
        guard let headerString = String(data: rawData, encoding: .utf8),
              let headerRange = headerString.range(of: "\r\n\r\n") else {
            throw NSError(domain: "HTTP", code: 1)
        }
        let headerLen = headerString[..<headerRange.upperBound].utf8.count
        let headers = headerString[..<headerRange.upperBound]
        let contentLength = extractContentLength(from: String(headers)) ?? 0
        var body = Data(rawData.suffix(from: headerLen))
        while body.count < contentLength {
            let chunk = try await receiveChunk(on: connection)
            body.append(chunk)
        }
        log("💾 Extracted Body (\(body.count) bytes) of expected \(contentLength) bytes")
        return rawData.prefix(headerLen) + body
    }

    private static func extractContentLength(from headers: String) -> Int? {
        for line in headers.split(separator: "\n") {
            if line.lowercased().starts(with: "content-length:") {
                let val = line.split(separator: ":").last?.trimmingCharacters(in: .whitespaces)
                if let v = val, let num = Int(v) { return num }
            }
        }
        return nil
    }

    private static func receiveChunk(on connection: NWConnection) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, error in
                if let error { cont.resume(throwing: error) }
                else if let data { cont.resume(returning: data) }
                else { cont.resume(throwing: NSError(domain: "net", code: -1)) }
            }
        }
    }

    private static func sendRaw(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { cont in
            connection.send(content: data, completion: .contentProcessed { _ in cont.resume() })
        }
    }
    private static func send(_ data: Data, on connection: NWConnection) async throws {
        try await withCheckedThrowingContinuation { cont in
            connection.send(content: data, completion: .contentProcessed { error in
                error == nil ? cont.resume() : cont.resume(throwing: error!)
            })
        }
    }

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
    private static func httpJSON(_ object: [String: Any]) -> Data {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let string = String(data: data, encoding: .utf8)
        else { return httpError(500, "JSON serialization failed") }
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
        if let range = request.range(of: "\r\n\r\n") { return String(request[range.upperBound...]) }
        if let range = request.range(of: "\n\n") { return String(request[range.upperBound...]) }
        return ""
    }
    private static func summarizeLargePrompt(_ prompt: String) async throws -> String {
        return String(prompt.prefix(8000)) + " [Summarized]"
    }
    private static func process(requestData data: Data, connection: NWConnection) async -> Data {
        guard let requestStr = String(data: data, encoding: .utf8),
              let firstLine = requestStr.split(separator: "\n").first,
              let (method, path) = parseRequestLine(String(firstLine))
        else {
            log("❌ Could not parse first request line from:\n\(String(data: data, encoding: .utf8) ?? "<non-UTF8>")")
            return httpError(400, "Bad Request")
        }
        log("🔎 FULL REQUEST DATA:\n\(requestStr)")
        log("🧾 Parsed request: method=\(method), path=\(path)")
        if method == "OPTIONS" {
            return httpResponse(200, body: "", contentType: "application/json; charset=utf-8")
        }
        let body = extractBody(from: requestStr)
        log("💾 Extracted Body (\(body.count) chars):\n\(body.prefix(500))")
        switch (method, path) {
        case ("GET", "/api/health"):
            let ok = await SyntraCLIWrapper.healthCheck()
            log("🌡️ HealthCheck result: \(ok)")
            return httpJSON(["status": ok ? "healthy" : "unhealthy"])
        case ("POST", "/api/consciousness/process"):
            let reply = try? await SyntraCLIWrapper.processThroughBrains(body)
            log("🧬 consciousness/process reply: \(reply ?? "nil")")
            return httpJSON(["response": reply ?? "Error processing request."])
        case let ("GET", p) where p.starts(with: "/v1/models"):
            log("📦 openAIModelsPayload called")
            return httpJSON(openAIModelsPayload())
        case ("POST", "/v1/chat/completions"):
            return await handleChatCompletions(body: body, connection: connection)
        case ("GET", "/"):
            return httpResponse(200, body: welcomeHTML(), contentType: "text/html; charset=utf-8")
        default:
            log("❓ Unknown endpoint: \(method) \(path)")
            return httpError(404, "Endpoint Not Found")
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
        <html>
        <head><title>Syntra API Server</title></head>
        <body>
        <h1>Syntra API</h1>
        <p>OpenAI-compatible endpoints:</p>
        <ul>
            <li>GET /api/health</li>
            <li>POST /api/consciousness/process</li>
            <li>GET /v1/models</li>
            <li>POST /v1/chat/completions</li>
        </ul>
        </body>
        </html>
        """
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

    private static func createNonStreamingResponse(
        reply: String, model: String?, stream: Bool?
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

    private static func streamResponse(
        reply: String, model: String?, stream: Bool?, connection: NWConnection
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

    private static func handleChatCompletions(body: String, connection: NWConnection) async -> Data {
        log("🔍 PROCESSING: Chat completions request")
        log("📝 Full incoming body string length: \(body.count)")
        guard let blob = body.data(using: .utf8) else {
            log("❌ UTF8 conversion failed for body:\n\(body.prefix(500))")
            return httpError(400, "Invalid UTF-8")
        }
        do {
            try RequestGuard.validate(blob)
        } catch {
            log("❌ Payload too large: \(blob.count) bytes")
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
            log("✅ Decoded ChatCompletionRequest: message count=\(request.messages.count)")
            let userPrompt = request.messages.reversed().first(where: { $0.role == "user" })?.content.text ?? ""
            log("✏️ Extracted userPrompt (\(userPrompt.count) chars):\n\(userPrompt.prefix(100))")
            guard !userPrompt.isEmpty else {
                log("❌ Empty user prompt")
                return httpError(400, "Empty user prompt")
            }
            let processedPrompt: String
            if userPrompt.count > 8000 {
                log("📏 Summarizing large prompt (orig count: \(userPrompt.count))...")
                processedPrompt = (try? await summarizeLargePrompt(userPrompt)) ?? userPrompt
            } else {
                processedPrompt = userPrompt
            }
            log("🧠 Processing prompt (first 100 chars):\n\(processedPrompt.prefix(100))")
            var reply: String = ""
            do {
                log("🔧 Calling SyntraCLIWrapper.processThroughBrains with prompt...")
                reply = try await SyntraCLIWrapper.processThroughBrains(processedPrompt)
                log("✅ Got successful reply (first 100 chars):\n\(reply.prefix(100))")
            } catch let error as LanguageModelSession.GenerationError {
                log("❌ LanguageModelSession.GenerationError: \(error)")
                return await streamErrorResponse(message: "Language model generation failed: \(error.localizedDescription)", connection: connection)
            } catch {
                log("❌ OTHER CLI ERROR (full object): \(error)")
                return await streamErrorResponse(message: "Unexpected error: \(error.localizedDescription)", connection: connection)
            }
            let isStream = request.stream == true
            log("📤 Responding with streaming=\(isStream)...")
            if isStream {
                return await streamResponse(reply: reply, model: request.model, stream: request.stream, connection: connection)
            } else {
                return createNonStreamingResponse(reply: reply, model: request.model, stream: request.stream)
            }
        } catch {
            log("❌ Unexpected decoding error (full object): \(error)")
            return httpJSON(["error": ["code": 500, "message": "Internal error: \(error.localizedDescription)"]])
        }
    }
}

