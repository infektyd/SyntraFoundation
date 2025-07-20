import Foundation
import FoundationModels

// FOUNDATIONMODELS EXTENSIONS
// Extensions to make common types compatible with @Generable macro

@available(macOS 26.0, *)
extension UUID: @retroactive ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        let stringValue: String = try content.value(forProperty: "uuidString")
        if let uuid = UUID(uuidString: stringValue) {
            self = uuid
        } else {
            throw GeneratedContentError.invalidFormat("Invalid UUID string: \(stringValue)")
        }
    }
}

@available(macOS 26.0, *)
extension UUID: @retroactive Generable {
    public var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["uuidString": self.uuidString])
    }
    
    public static var generationSchema: GenerationSchema {
        GenerationSchema(
            type: Self.self,
            properties: [
                GenerationSchema.Property(name: "uuidString", description: "String representation of UUID", type: String.self)
            ]
        )
    }
}

@available(macOS 26.0, *)
extension Date: @retroactive ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        let timeInterval: Double = try content.value(forProperty: "timeIntervalSince1970")
        self = Date(timeIntervalSince1970: timeInterval)
    }
}

@available(macOS 26.0, *)
extension Date: @retroactive Generable {
    public var generatedContent: GeneratedContent {
        GeneratedContent(properties: ["timeIntervalSince1970": self.timeIntervalSince1970])
    }
    
    public static var generationSchema: GenerationSchema {
        GenerationSchema(
            type: Self.self,
            properties: [
                GenerationSchema.Property(name: "timeIntervalSince1970", description: "Time interval since 1970", type: Double.self)
            ]
        )
    }
}

// Error type for conversion failures
@available(macOS 26.0, *)
public enum GeneratedContentError: Error {
    case invalidFormat(String)
}
