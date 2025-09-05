// ChatCompletionRequest.swift
// Migrated from legacy Main.swift file
// OpenAI-compatible chat completion request structures

import Foundation

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