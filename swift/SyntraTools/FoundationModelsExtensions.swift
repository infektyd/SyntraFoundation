import Foundation
import FoundationModels

// FOUNDATIONMODELS EXTENSIONS
// Extensions to make common types compatible with @Generable macro

@available(macOS "26.0", *)
extension UUID: ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        let stringValue: String = try content.value(forProperty: "uuidString")
        guard let uuid = UUID(uuidString: stringValue) else {
            throw GeneratedContentError.invalidFormat("Invalid UUID string: \(stringValue)")
        }
        self = uuid
    }
}

@available(macOS "26.0", *)
extension Date: ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        let timeInterval: Double = try content.value(forProperty: "timeIntervalSince1970")
        self = Date(timeIntervalSince1970: timeInterval)
    }
}

// Error type for conversion failures
@available(macOS "26.0", *)
public enum GeneratedContentError: Error {
    case invalidFormat(String)
}
