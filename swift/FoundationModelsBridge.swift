#if canImport(FoundationModels)
import Foundation
import FoundationModels

@available(macOS 26.0, *)
@Generable
struct FMResult {
    @Guide(description: "Raw response from the language model")
    var text: String
}

@available(macOS 26.0, *)
public struct EchoTool: Tool {
    public let name = "echo"
    public let description = "Echo back the provided text"
    
    @Generable
    public struct Arguments {
        @Guide(description: "Text to echo back")
        var text: String
    }
    
    public func call(arguments: Arguments) async throws -> ToolOutput {
        return ToolOutput("Echo: \(arguments.text)")
    }
}

@available(macOS 26.0, *)
public func queryFoundationModel(_ prompt: String) async throws -> String {
    let model = SystemLanguageModel.default
    guard model.availability == .available else {
        throw FoundationModelsError.unavailable
    }
    
    let session = LanguageModelSession(model: model)
    let response = try await session.respond(to: prompt)
    return String(describing: response)
}

@available(macOS 26.0, *)
public func queryAppleLLM(_ prompt: String) async -> String {
    do {
        let model = SystemLanguageModel.default
        
        guard model.availability == .available else {
            return "[Apple LLM not available on this device]"
        }
        
        let session = LanguageModelSession(model: model)
        let response = try await session.respond(to: prompt)
        return String(describing: response)
        
    } catch {
        return "[Apple LLM error: \(error.localizedDescription)]"
    }
}

public func queryAppleLLMSync(_ prompt: String) -> String {
    let semaphore = DispatchSemaphore(value: 0)
    let resultBox = Box("")
    
    Task { @Sendable in
        let value: String
        if #available(macOS 26.0, *) {
            value = await queryAppleLLM(prompt)
        } else {
            value = "[Apple LLM requires macOS 26+]"
        }
        resultBox.setValue(value)
        semaphore.signal()
    }
    
    semaphore.wait()
    return resultBox.getValue()
}

final class Box<T>: @unchecked Sendable {
    private var value: T
    private let lock = NSLock()
    
    init(_ value: T) {
        self.value = value
    }
    
    func setValue(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
    
    func getValue() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

public enum FoundationModelsError: Error {
    case unavailable
    case sessionCreationFailed
    case generationFailed(String)
}
#else
public func queryFoundationModel(_ prompt: String) async throws -> String {
    "[foundation model unavailable]"
}
#endif
