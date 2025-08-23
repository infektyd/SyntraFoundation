import Foundation
import Network
import FoundationModels
import SyntraWrappers
import Modi

// Minimal JSON value to support Codable parameter schemas and tool arguments
enum JSONValue: Codable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null; return }
        if let b = try? container.decode(Bool.self) { self = .bool(b); return }
        if let n = try? container.decode(Double.self) { self = .number(n); return }
        if let s = try? container.decode(String.self) { self = .string(s); return }
        if let a = try? container.decode([JSONValue].self) { self = .array(a); return }
        if let o = try? container.decode([String: JSONValue].self) { self = .object(o); return }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let b): try container.encode(b)
        case .number(let n): try container.encode(n)
        case .string(let s): try container.encode(s)
        case .array(let a): try container.encode(a)
        case .object(let o): try container.encode(o)
        }
    }

    // Schema helpers for OpenAI-like tool parameter docs
    static func stringSchema(description: String) -> JSONValue {
        .object(["type": .string("string"), "description": .string(description)])
    }
    static func enumSchema(values: [String], description: String) -> JSONValue {
        .object([
            "type": .string("string"),
            "enum": .array(values.map { .string($0) }),
            "description": .string(description)
        ])
    }
    static func arrayOfStringsSchema(description: String) -> JSONValue {
        .object([
            "type": .string("array"),
            "items": .object(["type": .string("string")]),
            "description": .string(description)
        ])
    }
}

private let debugEnabled = (ProcessInfo.processInfo.environment["SYNTRA_API_VERBOSE"] == "1")
private let defaultOpTimeoutMs: Int = Int(ProcessInfo.processInfo.environment["SYNTRA_API_TIMEOUT_MS"] ?? "") ?? 20000
private let progressTickMs: Int = Int(ProcessInfo.processInfo.environment["SYNTRA_API_PROGRESS_MS"] ?? "") ?? 1000

private func log(_ message: String) {
    if debugEnabled {
        print("[SYNTRA API] [\(Date())] \(message)")
    }
}

enum HTTPError: Error {
    case badRequest, payloadTooLarge, internalServerError, clientClosed, noData
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
    // OpenAI tools/function-calling fields
    struct ToolFunction: Codable {
        let name: String
        let description: String?
        let parameters: [String: JSONValue]?
    }
    struct ToolDefinition: Codable {
        let type: String // "function"
        let function: ToolFunction
    }
    enum ToolChoice: Decodable {
        case auto
        case none
        case function(name: String)

        private struct ChoiceObject: Decodable { let type: String; let function: Func
            struct Func: Decodable { let name: String } }

        init(from decoder: Decoder) throws {
            // Accept string or object per OpenAI spec
            if let single = try? decoder.singleValueContainer() {
                if let s = try? single.decode(String.self) {
                    switch s.lowercased() {
                    case "auto": self = .auto
                    case "none": self = .none
                    default: throw DecodingError.dataCorruptedError(in: single, debugDescription: "Invalid tool_choice string")
                    }
                    return
                }
            }
            let obj = try ChoiceObject(from: decoder)
            if obj.type == "function" { self = .function(name: obj.function.name) }
            else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported tool_choice")) }
        }
    }

    let model: String?
    let stream: Bool?
    let messages: [Message]
    let tools: [ToolDefinition]?
    let toolChoice: ToolChoice?
}

@main
public struct SyntraAPIServer {
    private static let port: NWEndpoint.Port = 8081

    public static func main() async throws {
        log("🏥 Performing consciousness health check…")
        let ok: Bool
        do {
            ok = try await withTimeoutProgress(label: "health", timeoutMs: defaultOpTimeoutMs) { @Sendable in
                await SyntraCLIWrapper.healthCheck()
            }
        } catch is TimeoutError {
            log("⏰ Health check timed out after \(defaultOpTimeoutMs)ms")
            ok = false
        } catch {
            log("❌ Health check error: \(error)")
            ok = false
        }
        if ok {
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
        } catch HTTPError.clientClosed {
            log("🔌 Client closed connection (normal).")
        } catch HTTPError.noData {
            log("🔎 No data yet (benign wakeup).")
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
        // If client sent "Expect: 100-continue", acknowledge before we read the body.
        let lowerHeaders = String(headers).lowercased()
        if lowerHeaders.contains("expect: 100-continue") {
            _ = try? await sendRaw("HTTP/1.1 100 Continue\r\n\r\n".data(using: .utf8) ?? Data(), on: connection)
        }
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
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
                if let error {
                    cont.resume(throwing: error)
                } else if let data, !data.isEmpty {
                    cont.resume(returning: data)
                } else if isComplete {
                    cont.resume(throwing: HTTPError.clientClosed) // normal EOF
                } else {
                    cont.resume(throwing: HTTPError.noData) // spurious wakeup
                }
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
    private struct TimeoutError: Error, Sendable {}

    private static func withTimeoutProgress<T: Sendable>(
        label: String,
        timeoutMs: Int,
        tickMs: Int = progressTickMs,
        _ op: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        let start = DispatchTime.now().uptimeNanoseconds

        // Progress ticker runs independently; cancel when done
        let ticker = Task { @Sendable in
            var elapsed = 0
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(tickMs) * 1_000_000)
                elapsed += tickMs
                log("⏳ [\(label)] waiting \(elapsed)ms…")
            }
        }

        do {
            let result = try await withThrowingTaskGroup(of: T.self) { group in
                // The actual operation
                group.addTask { @Sendable in try await op() }

                // Absolute timeout
                group.addTask { @Sendable in
                    try await Task.sleep(nanoseconds: UInt64(timeoutMs) * 1_000_000)
                    throw TimeoutError()
                }

                let r = try await group.next()! // first to complete wins
                group.cancelAll()
                return r
            }
            ticker.cancel()
            let end = DispatchTime.now().uptimeNanoseconds
            let durMs = Int(Double(end - start) / 1_000_000.0)
            log("✅ [\(label)] completed in \(durMs)ms")
            return result
        } catch {
            ticker.cancel()
            throw error
        }
    }

    private static func httpResponse(_ code: Int, body: String, contentType: String = "text/plain; charset=utf-8") -> Data {
        let headers =
            "HTTP/1.1 \(code) \(statusText(code))\r\n" +
            "Date: \(httpDate())\r\n" +
            "Content-Type: \(contentType)\r\n" +
            "Content-Length: \(body.utf8.count)\r\n" +
            "Access-Control-Allow-Origin: *\r\n" +
            "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n" +
            "Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin\r\n" +
            "Vary: Origin\r\n" +
            "Connection: close\r\n" +
            "\r\n"
        return (headers + body).data(using: .utf8)!
    }

    private static func httpDate(_ date: Date = Date()) -> String {
        // RFC 1123 format, GMT
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.timeZone = TimeZone(secondsFromGMT: 0)
        fmt.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        return fmt.string(from: date)
    }
    
    private static func statusText(_ code: Int) -> String {
        switch code {
        case 204: return "No Content"
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
        else { return httpError(400, "JSON serialization failed") }
        return httpResponse(200, body: string, contentType: "application/json; charset=utf-8")
    }
    private static func httpJSONError(status: Int, type: String, message: String) -> Data {
        let obj: [String: Any] = [
            "error": [
                "type": type,
                "message": message,
                "code": status
            ]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: obj),
              let string = String(data: data, encoding: .utf8)
        else { return httpError(400, "JSON serialization failed") }
        return httpResponse(status, body: string, contentType: "application/json; charset=utf-8")
    }
    private static func httpError(_ code: Int, _ message: String) -> Data {
        // Emit JSON and set the actual HTTP status code.
        let obj: [String: Any] = [
            "error": [
                "message": message,
                "code": code
            ]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: obj),
              let string = String(data: data, encoding: .utf8)
        else {
            return httpResponse(400,
                                body: #"{"error":{"message":"JSON serialization failed","code":500}}"#,
                                contentType: "application/json; charset=utf-8")
        }
        return httpResponse(code, body: string, contentType: "application/json; charset=utf-8")
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
            // CORS preflight: empty body, standard headers
            return httpResponse(204, body: "", contentType: "application/json; charset=utf-8")
        }
        let body = extractBody(from: requestStr)
        log("💾 Extracted Body (\(body.count) chars):\n\(body.prefix(500))")
        switch (method, path) {
        case ("GET", "/api/health"):
            let ok = await SyntraCLIWrapper.healthCheck()
            log("🌡️ HealthCheck result: \(ok)")
            return httpJSON(["status": ok ? "healthy" : "unhealthy"])
        case ("GET", "/v1/tools"):
            log("🧰 Listing available tools")
            return httpJSON(availableToolsPayload())
        case ("POST", "/api/consciousness/process"):
            let reply = try? await SyntraCLIWrapper.processThroughBrains(body)
            log("🧬 consciousness/process reply: \(reply ?? "nil")")
            return httpJSON(["response": reply ?? "Error processing request."])
        case let ("GET", p) where p == "/models" || p.starts(with: "/v1/models"):
            log("📦 openAIModelsPayload called")
            return httpJSON(openAIModelsPayload())
        case ("POST", "/chat/completions"), ("POST", "/v1/chat/completions"):
            return await handleChatCompletions(body: body, connection: connection)
        case ("GET", "/"):
            return httpResponse(200, body: welcomeHTML(), contentType: "text/html; charset=utf-8")
        case ("GET", "/api/version"):
            return httpJSON(["version": "SYNTRA-API 0.1"])
        case ("GET", "/api/tags"):
            return httpJSON([
                "models": [
                    ["name": "syntra/valon:latest"]
                ]
            ])
        case ("GET", "/api/ps"), ("POST", "/api/ps"):
            return httpJSON(["models": []])
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
            <li>GET /v1/tools</li>
        </ul>
        </body>
        </html>
        """
    }

    private static func streamErrorResponse(message: String, connection: NWConnection) async -> Data {
        let headers =
            "HTTP/1.1 500 Internal Server Error\r\n" +
            "Date: \(httpDate())\r\n" +
            "Content-Type: text/event-stream; charset=utf-8\r\n" +
            "Cache-Control: no-cache\r\n" +
            "Connection: keep-alive\r\n" +
            "Access-Control-Allow-Origin: *\r\n" +
            "Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n" +
            "Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin\r\n" +
            "Vary: Origin\r\n" +
            "X-Accel-Buffering: no\r\n" +
            "\r\n"

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
        let headers =
            "HTTP/1.1 200 OK\r\n" +
            "Date: \(httpDate())\r\n" +
            "Content-Type: text/event-stream; charset=utf-8\r\n" +
            "Cache-Control: no-cache\r\n" +
            "Connection: keep-alive\r\n" +
            "Access-Control-Allow-Origin: *\r\n" +
            "Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n" +
            "Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin\r\n" +
            "Vary: Origin\r\n" +
            "X-Accel-Buffering: no\r\n" +
            "\r\n"
        
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

    private static func processBayesianRequest(content: String) -> String {
        // Flexible parsing: Split and scan for params
        let parts = content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        var prior = 0.5, likelihood = 0.5, evidence = 1.0
        var factors: [String: Double] = [:]
        let scenario = parts.joined(separator: " ")  // Default to full content

        var i = 0
        while i < parts.count {
            let key = parts[i].lowercased().trimmingCharacters(in: .punctuationCharacters)
            if key == "prior", i+1 < parts.count { 
                prior = Double(parts[i+1]) ?? 0.5
                i += 2 
            } else if key == "likelihood", i+1 < parts.count { 
                likelihood = Double(parts[i+1]) ?? 0.5
                i += 2 
            } else if key == "evidence", i+1 < parts.count { 
                evidence = Double(parts[i+1]) ?? 1.0
                i += 2 
            } else if key == "factors" {
                i += 1
                while i < parts.count && !["prior", "likelihood", "evidence"].contains(parts[i].lowercased()) {
                    let factorKey = parts[i]
                    i += 1
                    if i < parts.count, let val = Double(parts[i]) { 
                        factors[factorKey] = val 
                    }
                    i += 1
                }
            } else { 
                i += 1 
            }
        }
        // Call Modi and format readable output
        let modi = Modi()
        let bayesianResult = modi.calculateEnhancedBayesian(scenario)
        let analysis = modi.performLogicalAnalysis(scenario)
        
        var result = "Bayesian Assessment:\n"
        result += "Scenario: \(scenario)\n"
        result += "Prior: \(prior), Likelihood: \(likelihood), Evidence: \(evidence)\n"
        result += "Domain Probabilities: \(bayesianResult.probabilities)\n"
        result += "Entropy: \(bayesianResult.entropy)\n"
        result += "Logical Analysis: \(analysis)\n"
        
        return result
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
            
            // Check for Bayesian keywords and force Bayesian analysis
            let content = processedPrompt.lowercased()
            if content.contains("posterior") || content.contains("risk") || content.contains("breakdown") || content.contains("assess") || content.contains("compute") || content.contains("bayesian") || content.contains("probability") {
                log("🎯 Bayesian keywords detected - forcing Bayesian analysis")
                let bayesianResult = processBayesianRequest(content: processedPrompt)
                reply = bayesianResult
            } else {
                do {
                    log("🔧 Calling SyntraCLIWrapper.processThroughBrains with prompt...")
                    reply = try await withTimeoutProgress(label: "syntra:process", timeoutMs: defaultOpTimeoutMs) { @Sendable in
                        try await SyntraCLIWrapper.processThroughBrains(processedPrompt)
                    }
                    log("✅ Got successful reply (first 100 chars):\n\(reply.prefix(100))")
                } catch is TimeoutError {
                    log("⏰ Syntra backend timed out after \(defaultOpTimeoutMs)ms")
                    return await streamErrorResponse(
                        message: "Gateway timeout: Syntra core did not respond in \(defaultOpTimeoutMs)ms.",
                        connection: connection
                    )
                } catch let error as LanguageModelSession.GenerationError {
                    log("❌ LanguageModelSession.GenerationError: \(error)")
                    return await streamErrorResponse(
                        message: "Language model generation failed: \(error.localizedDescription)",
                        connection: connection
                    )
                } catch {
                    log("❌ OTHER CLI ERROR (full object): \(error)")
                    return await streamErrorResponse(
                        message: "Unexpected error: \(error.localizedDescription)",
                        connection: connection
                    )
                }
            }

            // Tool integration: parse tool intentions from reply and execute when allowed
            let toolPolicyAllows = (request.toolChoice == nil) || {
                switch request.toolChoice! {
                case .auto: return true
                case .none: return false
                case .function: return true
                }
            }()

            var executedToolCalls: [ExecutedToolCall] = []
            if toolPolicyAllows {
                let wantedToolName: String? = {
                    if case let .function(name) = request.toolChoice { return name } else { return nil }
                }()
                let detected = parseToolCalls(from: reply, restrictTo: wantedToolName)
                for call in detected {
                    if let exec = await executeTool(call) {
                        executedToolCalls.append(exec)
                    }
                }
                if !executedToolCalls.isEmpty {
                    // Append summarized tool results to the reply for user visibility
                    let toolSummaries = executedToolCalls.map { $0.summaryForUser }.joined(separator: "\n\n")
                    reply += "\n\n[Tool Results]\n" + toolSummaries
                }
            }
            let isStream = request.stream == true
            log("📤 Responding with streaming=\(isStream)...")
            if isStream {
                return await streamResponse(reply: reply, model: request.model, stream: request.stream, connection: connection)
            } else {
                return createNonStreamingToolAwareResponse(reply: reply, model: request.model, stream: request.stream, toolCalls: executedToolCalls)
            }
        } catch let decErr as DecodingError {
            log("❌ DecodingError in /v1/chat/completions: \(decErr)")
            return httpJSONError(status: 400,
                                 type: "invalid_request_error",
                                 message: "Invalid JSON for chat.completions: \(decErr.localizedDescription)")
        } catch {
            log("❌ Unexpected error in /v1/chat/completions: \(error)")
            return httpJSONError(status: 500,
                                 type: "internal_error",
                                 message: "Internal error: \(error.localizedDescription)")
        }
    }
}

// MARK: - OpenAI Tools Catalog
extension SyntraAPIServer {
    private static func availableTools() -> [ChatCompletionRequest.ToolDefinition] {
        return [
            .init(type: "function", function: .init(
                name: "execute_shell",
                description: "Execute a shell command in the project workspace. Return stdout/stderr and exit code.",
                parameters: [
                    "command": JSONValue.stringSchema(description: "The shell command to execute.")
                ]
            )),
            .init(type: "function", function: .init(
                name: "file_operations",
                description: "Read/write/list files within the project workspace.",
                parameters: [
                    "operation": JSONValue.enumSchema(values: ["read","write","list"], description: "File operation type"),
                    "path": JSONValue.stringSchema(description: "Target file or directory path (absolute or relative to workspace)"),
                    "content": JSONValue.stringSchema(description: "Content to write (required for write)")
                ]
            )),
            .init(type: "function", function: .init(
                name: "git_operations",
                description: "Run safe git commands in the repository (status, diff, log, add, commit).",
                parameters: [
                    "args": JSONValue.arrayOfStringsSchema(description: "Git arguments, e.g. ['status','-s']")
                ]
            )),
            .init(type: "function", function: .init(
                name: "analyze_project",
                description: "Analyze the project (file counts, Swift lines, package targets).",
                parameters: [:]
            ))
        ]
    }

    private static func availableToolsPayload() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        let tools = availableTools()
        let toolsArray: [[String: Any]] = tools.compactMap { tool in
            guard let data = try? encoder.encode(tool),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
            return obj
        }
        return ["object": "list", "data": toolsArray]
    }
}

// MARK: - Tool Execution
extension SyntraAPIServer {
    private static let workspaceRoot = FileManager.default.currentDirectoryPath

    private struct ParsedToolCall {
        let name: String
        let argumentsJSON: String
    }

    private struct ExecutedToolCall {
        let id: String
        let name: String
        let arguments: [String: Any]
        let result: [String: Any]

        var summaryForUser: String {
            let argsStr = (try? serializeJSON(arguments)) ?? "{}"
            let resStr = (try? serializeJSON(result)) ?? "{}"
            return "- Tool: \(name)\n  args: \(argsStr)\n  result: \(resStr.prefix(2000))"
        }
    }

    private static func createNonStreamingToolAwareResponse(
        reply: String, model: String?, stream: Bool?, toolCalls: [ExecutedToolCall]
    ) -> Data {
        let now = Int(Date().timeIntervalSince1970)
        let chatId = "chatcmpl-\(UUID().uuidString)"
        var message: [String: Any] = [
            "role": "assistant",
            "content": reply
        ]
        if !toolCalls.isEmpty {
            message["tool_calls"] = toolCalls.map { call in
                [
                    "id": call.id,
                    "type": "function",
                    "function": [
                        "name": call.name,
                        "arguments": (try? serializeJSON(call.arguments)) ?? "{}",
                        "result": call.result // Non-standard field for convenience but content also includes results
                    ]
                ]
            }
        }
        let payload: [String: Any] = [
            "id": chatId,
            "object": "chat.completion",
            "created": now,
            "model": model ?? "gpt-4",
            "choices": [[
                "index": 0,
                "message": message,
                "finish_reason": "stop"
            ]]
        ]
        return httpJSON(payload)
    }

    // Parse tool calls heuristically from SYNTRA's textual reply
    private static func parseToolCalls(from reply: String, restrictTo: String?) -> [ParsedToolCall] {
        var out: [ParsedToolCall] = []
        let text = reply

        // 1) ```bash ...``` blocks -> execute_shell
        if let bashBlocks = firstRegexMatches(text, pattern: "```(?:bash|sh)\\n([\\s\\S]*?)```", options: [.dotMatchesLineSeparators]) {
            for cmd in bashBlocks {
                guard restrictTo == nil || restrictTo == "execute_shell" else { continue }
                let args: [String: Any] = ["command": cmd.trimmingCharacters(in: .whitespacesAndNewlines)]
                if let json = try? serializeJSON(args) {
                    out.append(.init(name: "execute_shell", argumentsJSON: json))
                }
            }
        }

        // 2) inline `command` -> execute_shell (single line)
        if let inline = firstRegexMatches(text, pattern: "`([^`\\n]+)`", options: []) {
            for cmd in inline {
                guard restrictTo == nil || restrictTo == "execute_shell" else { continue }
                if cmd.contains(" ") || cmd.contains("/") || cmd.contains("git") { // heuristic: looks like a command
                    let args: [String: Any] = ["command": cmd]
                    if let json = try? serializeJSON(args) {
                        out.append(.init(name: "execute_shell", argumentsJSON: json))
                    }
                }
            }
        }

        // 3) function style: name({json}) for file_operations/git_operations/analyze_project
        let names = ["file_operations","git_operations","analyze_project"]
        for n in names {
            if let blocks = firstRegexMatches(text, pattern: "\\b(n)\\s*\\((\\{[\\s\\S]*?\\})\\)", options: [.dotMatchesLineSeparators], templateName: n) {
                for json in blocks {
                    guard restrictTo == nil || restrictTo == n else { continue }
                    out.append(.init(name: n, argumentsJSON: json))
                }
            }
        }
        return out
    }

    private static func executeTool(_ call: ParsedToolCall) async -> ExecutedToolCall? {
        let id = "call_\(UUID().uuidString)"
        guard let argsAny = try? parseJSONString(call.argumentsJSON) as? [String: Any] else {
            return ExecutedToolCall(id: id, name: call.name, arguments: [:], result: ["error": "Invalid arguments JSON"])
        }
        do {
            switch call.name {
            case "execute_shell":
                let command = (argsAny["command"] as? String) ?? ""
                let result = try await runShell(command)
                return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: result)
            case "file_operations":
                let result = try fileOperations(argsAny)
                return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: result)
            case "git_operations":
                let result = try await runGit(argsAny)
                return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: result)
            case "analyze_project":
                let result = analyzeProject()
                return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: result)
            default:
                return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: ["error": "Unknown tool"])
            }
        } catch {
            return ExecutedToolCall(id: id, name: call.name, arguments: argsAny, result: ["error": error.localizedDescription])
        }
    }

    // Workspace-safe path resolution
    private static func safePath(_ input: String) throws -> String {
        let path = (input as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: path, relativeTo: URL(fileURLWithPath: workspaceRoot)).standardized
        let root = URL(fileURLWithPath: workspaceRoot).standardized
        guard url.path.hasPrefix(root.path) else { throw NSError(domain: "tools", code: 1, userInfo: [NSLocalizedDescriptionKey: "Path outside workspace"]) }
        return url.path
    }

    // Tool: file_operations
    private static func fileOperations(_ args: [String: Any]) throws -> [String: Any] {
        let fm = FileManager.default
        guard let op = args["operation"] as? String else { throw NSError(domain: "tools", code: 2, userInfo: [NSLocalizedDescriptionKey: "operation required"]) }
        guard let raw = args["path"] as? String else { throw NSError(domain: "tools", code: 3, userInfo: [NSLocalizedDescriptionKey: "path required"]) }
        let path = try safePath(raw)
        switch op {
        case "read":
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let text = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            return ["path": path, "content": text]
        case "write":
            let content = (args["content"] as? String) ?? ""
            let dir = (path as NSString).deletingLastPathComponent
            if !fm.fileExists(atPath: dir) { try fm.createDirectory(atPath: dir, withIntermediateDirectories: true) }
            try content.data(using: .utf8)?.write(to: URL(fileURLWithPath: path))
            return ["path": path, "bytes": content.utf8.count]
        case "list":
            let items = try fm.contentsOfDirectory(atPath: path)
            return ["path": path, "entries": items]
        default:
            throw NSError(domain: "tools", code: 4, userInfo: [NSLocalizedDescriptionKey: "unsupported operation"])
        }
    }

    // Tool: git_operations (safe subset)
    private static func runGit(_ args: [String: Any]) async throws -> [String: Any] {
        guard var argv = args["args"] as? [String], !argv.isEmpty else { throw NSError(domain: "tools", code: 5, userInfo: [NSLocalizedDescriptionKey: "args required"]) }
        // Deny destructive commands unless explicitly allowed (no push by default)
        let forbidden = ["push", "reset", "clean", "rebase", "checkout", "branch", "remote", "stash", "merge", "pull"]
        if forbidden.contains(argv[0]) { throw NSError(domain: "tools", code: 6, userInfo: [NSLocalizedDescriptionKey: "git command not allowed"]) }
        argv.insert("git", at: 0)
        return try await runProcess(argv: argv)
    }

    // Tool: execute_shell (timeout, workspace CWD)
    private static func runShell(_ command: String) async throws -> [String: Any] {
        // Basic guardrails: deny multi-line here-docs and backgrounding
        if command.contains("<<") { throw NSError(domain: "tools", code: 7, userInfo: [NSLocalizedDescriptionKey: "heredoc not allowed"]) }
        return try await runProcess(argv: ["/opt/homebrew/bin/zsh", "-lc", command])
    }

    private static func runProcess(argv: [String]) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { cont in
            let proc = Process()
            proc.currentDirectoryPath = workspaceRoot
            proc.executableURL = URL(fileURLWithPath: argv[0])
            proc.arguments = Array(argv.dropFirst())
            let outPipe = Pipe(); let errPipe = Pipe()
            proc.standardOutput = outPipe
            proc.standardError = errPipe

            let timeoutSec: TimeInterval = 15
            let deadline = DispatchTime.now() + timeoutSec
            DispatchQueue.global().asyncAfter(deadline: deadline) {
                if !proc.isRunning { return }
                proc.terminate()
            }
            do { try proc.run() } catch { return cont.resume(throwing: error) }
            proc.terminationHandler = { p in
                let stdout = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                let stderr = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                let result: [String: Any] = [
                    "argv": argv,
                    "exit_code": Int(p.terminationStatus),
                    "stdout": stdout,
                    "stderr": stderr
                ]
                cont.resume(returning: result)
            }
        }
    }

    // Tool: analyze_project
    private static func analyzeProject() -> [String: Any] {
        let fm = FileManager.default
        let root = workspaceRoot
        var swiftFiles = 0
        var totalSwiftLines = 0
        var packages = 0
        let enumerator = fm.enumerator(atPath: root)
        while let item = enumerator?.nextObject() as? String {
            if item.hasPrefix(".git/") || item.hasPrefix(".build/") || item.contains("/DerivedData/") { enumerator?.skipDescendants(); continue }
            if item.hasSuffix("Package.swift") { packages += 1 }
            if item.hasSuffix(".swift") {
                swiftFiles += 1
                if let data = try? Data(contentsOf: URL(fileURLWithPath: (root as NSString).appendingPathComponent(item))),
                   let text = String(data: data, encoding: .utf8) {
                    totalSwiftLines += text.split(whereSeparator: \.isNewline).count
                }
            }
        }
        return ["swift_files": swiftFiles, "swift_lines": totalSwiftLines, "packages": packages, "root": root]
    }
}

// MARK: - Small utilities
extension SyntraAPIServer {
    // JSON helpers for Any
    fileprivate struct AnyCodableJSON: Codable {
        let value: Any
        init(_ value: Any) { self.value = value }
        init(from decoder: Decoder) throws {
            // Accept arbitrary JSON without decoding into concrete types
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) { self.value = str; return }
            if let num = try? container.decode(Double.self) { self.value = num; return }
            if let bool = try? container.decode(Bool.self) { self.value = bool; return }
            if let obj = try? container.decode([String: AnyCodableJSON].self) { self.value = obj; return }
            if let arr = try? container.decode([AnyCodableJSON].self) { self.value = arr; return }
            self.value = [:]
        }
        func encode(to encoder: Encoder) throws {
            // Only used to emit schema-like JSON maps for docs; encode dictionaries if possible
            var container = encoder.singleValueContainer()
            if let dict = value as? [String: Any] {
                let data = try JSONSerialization.data(withJSONObject: dict)
                if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    try container.encode(obj.mapValues { AnyCodableJSON($0) })
                    return
                }
            } else if let arr = value as? [Any] {
                try container.encode(arr.map { AnyCodableJSON($0) })
                return
            } else if let str = value as? String { try container.encode(str); return }
            else if let num = value as? Double { try container.encode(num); return }
            else if let bool = value as? Bool { try container.encode(bool); return }
            try container.encode([String: AnyCodableJSON]())
        }
        // Minimal schema shims for OpenAI parameters docs
        static func stringSchema(description: String) -> AnyCodableJSON { AnyCodableJSON(["type": "object_property", "schema": ["type": "string"], "description": description]) }
        static func enumSchema(values: [String], description: String) -> AnyCodableJSON { AnyCodableJSON(["type": "object_property", "schema": ["type": "string", "enum": values], "description": description]) }
        static func arrayOfStringsSchema(description: String) -> AnyCodableJSON { AnyCodableJSON(["type": "object_property", "schema": ["type": "array", "items": ["type": "string"]], "description": description]) }
    }

    fileprivate static func serializeJSON(_ obj: Any) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: obj, options: [.withoutEscapingSlashes])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    fileprivate static func parseJSONString(_ s: String) throws -> Any {
        let data = s.data(using: .utf8) ?? Data()
        return try JSONSerialization.jsonObject(with: data)
    }
    fileprivate static func firstRegexMatches(_ text: String, pattern: String, options: NSRegularExpression.Options, templateName: String? = nil) -> [String]? {
        let pat = templateName == nil ? pattern : pattern.replacingOccurrences(of: "(n)", with: NSRegularExpression.escapedPattern(for: templateName!))
        guard let rx = try? NSRegularExpression(pattern: pat, options: options) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = rx.matches(in: text, options: [], range: range)
        if matches.isEmpty { return nil }
        return matches.compactMap { m in
            if m.numberOfRanges >= 2, let r = Range(m.range(at: 1), in: text) {
                return String(text[r])
            }
            return nil
        }
    }
}

