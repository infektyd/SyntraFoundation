import Foundation

/// Professional HTTP request logging system with security controls and structured output
/// Supports both development debugging and production-safe logging with configurable levels
public struct HTTPRequestLogger {
    
    // MARK: - Configuration
    
    /// Log levels from least to most verbose
    public enum LogLevel: String, CaseIterable, Comparable {
        case off = "OFF"
        case error = "ERROR"
        case warn = "WARN"
        case info = "INFO"
        case debug = "DEBUG"
        case trace = "TRACE"
        
        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            let order: [LogLevel] = [.off, .error, .warn, .info, .debug, .trace]
            guard let lhsIndex = order.firstIndex(of: lhs),
                  let rhsIndex = order.firstIndex(of: rhs) else { return false }
            return lhsIndex < rhsIndex
        }
    }
    
    /// Output format for logs
    public enum LogFormat: String {
        case plain = "PLAIN"
        case json = "JSON"
        case logfmt = "LOGFMT"
    }
    
    // MARK: - Environment Configuration
    
    /// Current log level (default: INFO for production safety)
    public static var logLevel: LogLevel {
        guard let envLevel = ProcessInfo.processInfo.environment["SYNTRA_LOG_LEVEL"],
              let level = LogLevel(rawValue: envLevel.uppercased()) else {
            return .info
        }
        return level
    }
    
    /// Whether to log sensitive data like full request bodies (default: false for security)
    public static var logSensitiveData: Bool {
        guard let envValue = ProcessInfo.processInfo.environment["SYNTRA_LOG_SENSITIVE_DATA"] else {
            return false
        }
        return ["true", "1", "yes", "on"].contains(envValue.lowercased())
    }
    
    /// Log output format (default: PLAIN for readability)
    public static var logFormat: LogFormat {
        guard let envFormat = ProcessInfo.processInfo.environment["SYNTRA_LOG_FORMAT"],
              let format = LogFormat(rawValue: envFormat.uppercased()) else {
            return .plain
        }
        return format
    }
    
    /// Maximum body preview length in characters (default: 500)
    public static var maxBodyPreviewLength: Int {
        guard let envValue = ProcessInfo.processInfo.environment["SYNTRA_MAX_BODY_PREVIEW"],
              let value = Int(envValue), value > 0 else {
            return 500
        }
        return value
    }
    
    /// Maximum hex body length in bytes before truncation (default: 8KB)
    public static var maxHexBodyLength: Int {
        guard let envValue = ProcessInfo.processInfo.environment["SYNTRA_MAX_HEX_BODY"],
              let value = Int(envValue), value > 0 else {
            return 8192
        }
        return value
    }
    
    // MARK: - Core Logging Functions
    
    /// Log a complete HTTP request with all details
    /// - Parameters:
    ///   - requestData: Raw HTTP request data
    ///   - connection: Network connection (for remote address if available)
    ///   - level: Log level for this entry (default: INFO)
    public static func logHTTPRequest(
        requestData: Data,
        connection: Any? = nil,
        level: LogLevel = .info
    ) {
        guard shouldLog(level: level) else { return }
        
        do {
            let parsedRequest = try parseHTTPRequest(requestData)
            let logEntry = createLogEntry(
                level: level,
                category: "HTTP_REQUEST",
                message: "Incoming HTTP request",
                details: [
                    "method": parsedRequest.method,
                    "path": parsedRequest.path,
                    "headers_count": String(parsedRequest.headers.count),
                    "body_length": String(parsedRequest.body.count),
                    "request_size": String(requestData.count)
                ],
                requestData: parsedRequest
            )
            output(logEntry)
            
            // Log detailed breakdown if debug or trace level
            if level >= .debug {
                logRequestDetails(parsedRequest, level: level)
            }
            
        } catch {
            logError("Failed to parse HTTP request: \(error)", data: requestData)
        }
    }
    
    /// Log request parsing or processing errors safely
    /// - Parameters:
    ///   - message: Error description
    ///   - error: Optional error object
    ///   - data: Optional raw data that caused the error
    public static func logError(
        _ message: String,
        error: Error? = nil,
        data: Data? = nil
    ) {
        guard shouldLog(level: .error) else { return }
        
        var details: [String: String] = ["error_message": message]
        
        if let error = error {
            details["error_type"] = String(describing: type(of: error))
            details["error_description"] = error.localizedDescription
        }
        
        if let data = data {
            details["data_size"] = String(data.count)
            if logSensitiveData && data.count <= 1000 {
                details["data_preview"] = safeStringFromData(data, maxLength: 200)
            }
        }
        
        let logEntry = createLogEntry(
            level: .error,
            category: "HTTP_ERROR",
            message: message,
            details: details
        )
        output(logEntry)
    }
    
    // MARK: - Request Parsing
    
    private struct ParsedHTTPRequest {
        let method: String
        let path: String
        let headers: [String: String]
        let body: Data
        let rawRequest: String
    }
    
    private static func parseHTTPRequest(_ data: Data) throws -> ParsedHTTPRequest {
        guard let requestString = String(data: data, encoding: .utf8) else {
            throw HTTPLoggerError.invalidUTF8
        }
        
        let lines = requestString.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else {
            throw HTTPLoggerError.missingRequestLine
        }
        
        // Parse request line: "METHOD /path HTTP/1.1"
        let components = firstLine.components(separatedBy: " ")
        guard components.count >= 2 else {
            throw HTTPLoggerError.malformedRequestLine(firstLine)
        }
        
        let method = components[0]
        let path = components[1]
        
        // Parse headers
        var headers: [String: String] = [:]
        var headerEndIndex = 1
        
        for i in 1..<lines.count {
            let line = lines[i]
            if line.isEmpty {
                headerEndIndex = i
                break
            }
            
            if let colonIndex = line.firstIndex(of: ":") {
                let key = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                headers[key.lowercased()] = value
            }
        }
        
        // Extract body
        let bodyLines = Array(lines[(headerEndIndex + 1)...])
        let bodyString = bodyLines.joined(separator: "\r\n")
        let body = bodyString.data(using: .utf8) ?? Data()
        
        return ParsedHTTPRequest(
            method: method,
            path: path,
            headers: headers,
            body: body,
            rawRequest: requestString
        )
    }
    
    // MARK: - Detailed Logging
    
    private static func logRequestDetails(_ request: ParsedHTTPRequest, level: LogLevel) {
        // Log headers (filtered for security)
        if !request.headers.isEmpty {
            let filteredHeaders = filterSensitiveHeaders(request.headers)
            let logEntry = createLogEntry(
                level: level,
                category: "HTTP_HEADERS",
                message: "Request headers",
                details: ["headers_json": jsonString(from: filteredHeaders) ?? "{}"]
            )
            output(logEntry)
        }
        
        // Log body preview and hex if sensitive data logging is enabled
        if !request.body.isEmpty && logSensitiveData {
            logBodyDetails(request.body, level: level)
        } else if !request.body.isEmpty {
            let logEntry = createLogEntry(
                level: level,
                category: "HTTP_BODY",
                message: "Request body (content hidden for security)",
                details: [
                    "body_size": String(request.body.count),
                    "body_preview": "[HIDDEN - set SYNTRA_LOG_SENSITIVE_DATA=true to view]"
                ]
            )
            output(logEntry)
        }
    }
    
    private static func logBodyDetails(_ body: Data, level: LogLevel) {
        // Body preview (first N characters)
        let preview = safeStringFromData(body, maxLength: maxBodyPreviewLength)
        
        // Hex representation with smart truncation
        let hexData = createHexRepresentation(body)
        
        let logEntry = createLogEntry(
            level: level,
            category: "HTTP_BODY",
            message: "Request body details",
            details: [
                "body_size": String(body.count),
                "body_preview": preview,
                "body_hex": hexData.hex,
                "hex_truncated": String(hexData.wasTruncated),
                "hex_full_size": String(body.count)
            ]
        )
        output(logEntry)
    }
    
    // MARK: - Security & Utility Functions
    
    private static func filterSensitiveHeaders(_ headers: [String: String]) -> [String: String] {
        let sensitiveKeys = ["authorization", "cookie", "x-api-key", "x-auth-token", "bearer"]
        
        return headers.compactMapValues { key, value in
            if sensitiveKeys.contains(key.lowercased()) {
                return logSensitiveData ? value : "[REDACTED]"
            }
            return value
        }
    }
    
    private static func safeStringFromData(_ data: Data, maxLength: Int) -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            return "[NON-UTF8 DATA: \(data.count) bytes]"
        }
        
        if string.count <= maxLength {
            return string
        }
        
        return String(string.prefix(maxLength)) + "... [TRUNCATED]"
    }
    
    private static func createHexRepresentation(_ data: Data) -> (hex: String, wasTruncated: Bool) {
        if data.count <= maxHexBodyLength {
            return (data.map { String(format: "%02x", $0) }.joined(), false)
        }
        
        let startBytes = data.prefix(maxHexBodyLength / 2)
        let endBytes = data.suffix(maxHexBodyLength / 2)
        
        let startHex = startBytes.map { String(format: "%02x", $0) }.joined()
        let endHex = endBytes.map { String(format: "%02x", $0) }.joined()
        
        let truncatedHex = "\(startHex)...[TRUNCATED \(data.count - maxHexBodyLength) bytes]...\(endHex)"
        return (truncatedHex, true)
    }
    
    // MARK: - Log Formatting & Output
    
    private static func createLogEntry(
        level: LogLevel,
        category: String,
        message: String,
        details: [String: String] = [:],
        requestData: ParsedHTTPRequest? = nil
    ) -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        switch logFormat {
        case .json:
            return formatAsJSON(timestamp: timestamp, level: level, category: category, message: message, details: details)
        case .logfmt:
            return formatAsLogfmt(timestamp: timestamp, level: level, category: category, message: message, details: details)
        case .plain:
            return formatAsPlain(timestamp: timestamp, level: level, category: category, message: message, details: details)
        }
    }
    
    private static func formatAsPlain(
        timestamp: String,
        level: LogLevel,
        category: String,
        message: String,
        details: [String: String]
    ) -> String {
        var output = "[\(timestamp)] \(level.rawValue) [\(category)] \(message)"
        
        if !details.isEmpty {
            let formattedDetails = details.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
            output += " | \(formattedDetails)"
        }
        
        return output
    }
    
    private static func formatAsJSON(
        timestamp: String,
        level: LogLevel,
        category: String,
        message: String,
        details: [String: String]
    ) -> String {
        var logObject: [String: Any] = [
            "timestamp": timestamp,
            "level": level.rawValue,
            "category": category,
            "message": message
        ]
        
        if !details.isEmpty {
            logObject["details"] = details
        }
        
        return jsonString(from: logObject) ?? formatAsPlain(timestamp: timestamp, level: level, category: category, message: message, details: details)
    }
    
    private static func formatAsLogfmt(
        timestamp: String,
        level: LogLevel,
        category: String,
        message: String,
        details: [String: String]
    ) -> String {
        var pairs = [
            "timestamp=\(timestamp)",
            "level=\(level.rawValue)",
            "category=\(category)",
            "message=\"\(message)\""
        ]
        
        for (key, value) in details {
            pairs.append("\(key)=\"\(value)\"")
        }
        
        return pairs.joined(separator: " ")
    }
    
    private static func jsonString(from object: Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    private static func shouldLog(level: LogLevel) -> Bool {
        return level <= logLevel
    }
    
    private static func output(_ logEntry: String) {
        print(logEntry)
        fflush(stdout)
    }
}

// MARK: - Error Types

private enum HTTPLoggerError: Error, LocalizedError {
    case invalidUTF8
    case missingRequestLine
    case malformedRequestLine(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "Request data is not valid UTF-8"
        case .missingRequestLine:
            return "HTTP request missing request line"
        case .malformedRequestLine(let line):
            return "Malformed HTTP request line: \(line)"
        }
    }
}

// MARK: - Convenience Extensions

extension Dictionary {
    func compactMapValues<T>(_ transform: (Key, Value) throws -> T?) rethrows -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            if let transformedValue = try transform(key, value) {
                result[key] = transformedValue
            }
        }
        return result
    }
}