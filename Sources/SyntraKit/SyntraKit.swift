// SyntraKit.swift
// Swift 6.x-compatible

import Foundation
import FoundationModels
import SyntraCore
import ConversationalInterface
import SyntraTools

/// Core AI processing engine for Syntra
public class SyntraEngine {

    // ... (all existing functions in SyntraEngine remain the same) ...
    public static func getAvailableModel() throws -> SystemLanguageModel {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
            throw NSError(domain: "FoundationModels", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels not available on this device"])
        }
        return model
    }

    public static func estimateTokens(_ text: String) -> Int {
        let words = text.split(separator: " ").count
        let lines = text.split(whereSeparator: \.isNewline).count
        let specials = text.filter { "#`🍎\n[]{}".contains($0) }.count
        return Int(Double(words) * 1.5) + (text.count / 3) + (lines * 2) + specials
    }

    public static func truncatePrompt(_ prompt: String, maxTokens: Int = 1500, useOverlap: Bool = false) -> String {
        let estimated = estimateTokens(prompt)
        guard estimated > maxTokens else { return prompt }
        let ratio = Double(maxTokens) / Double(estimated)
        let targetLength = Int(Double(prompt.count) * ratio) - 200
        var truncated = String(prompt.prefix(targetLength)) + " [TRUNCATED: Exceeded limit]"
        print("[DEBUG] Truncated from ~\(estimated) to ~\(maxTokens) tokens; Length: \(truncated.count)")
        if useOverlap {
            let overlapSize = Int(Double(targetLength) * 0.2)
            truncated = String(prompt.suffix(overlapSize)) + truncated
        }
        return truncated
    }

    public static func preparePrompt(_ input: String, isInternal: Bool = false) -> String {
        let basePrompt = truncatePrompt(input)
        return isInternal ? "[Internal SYNTRA 3-brain] \(basePrompt)" : basePrompt
    }

    public static func continueSession(_ input: String, instructions: String? = nil) async throws -> String {
        let model = try getAvailableModel()
        let session = LanguageModelSession(model: model, instructions: instructions ?? "You are Syntra.")
        do {
            let response = try await session.respond(to: input)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize = error {
                let summary = try await session.respond(to: "Summarize everything so far in 5 bullets.").content
                let newSession = LanguageModelSession(model: model, instructions: "CONTEXT SUMMARY: \(summary)\n\nContinue the conversation as Syntra.")
                let response = try await newSession.respond(to: input)
                return "[CONTEXT SUMMARIZED]\n" + response.content
            } else {
                throw error
            }
        }
    }
}


/// Command handlers for different SYNTRA operations
public struct SyntraHandlers {

    // --- ADD THIS NEW STREAMING FUNCTION ---
    /// Handle process through brains request as a stream
    /// - Parameter input: Input text
    /// - Returns: A stream of processed response chunks
    public static func handleProcessThroughBrainsStream(_ input: String) async throws -> AsyncThrowingStream<String, Error> {
        // Acquire model and create a session
        let model = try SyntraEngine.getAvailableModel()
        let session = LanguageModelSession(model: model)

        // Create an AsyncThrowingStream that iterates the session's streaming response
        return AsyncThrowingStream<String, Error> { continuation in
            // Start a detached Task to iterate the async sequence from FoundationModels
            Task {
                do {
                    // session.streamResponse(...) returns an AsyncSequence of response snapshots/chunks
                    let stream = session.streamResponse(to: input)
                    for try await chunk in stream {
                        // Each chunk has a `.content` property (the textual portion)
                        continuation.yield(chunk.content)
                    }
                    // Completed normally
                    continuation.finish()
                } catch {
                    // Propagate error to the stream consumer
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    // --- END OF NEW FUNCTION ---

    /// Handle process through brains request
    /// - Parameter input: Input text
    /// - Returns: Processed response
    public static func handleProcessThroughBrains(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession(input)
    }

    // ... (all other existing functions in SyntraHandlers remain the same) ...
    public static func handleProcessStructured(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession("[Structured SYNTRA request] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    
    public static func handleReflectValon(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession("[Valon: moral reflection] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    
    public static func handleReflectModi(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession("[Modi: logical reflection] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    
    public static func handleProcessWithDrift(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession("[Drift monitored SYNTRA] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    
    public static func handleChat(_ input: String) async throws -> String {
        let out = try await SyntraEngine.continueSession(input)
        if out.contains("can't assist") {
            return "I'm doing well, thanks! How can I help you today?"
        }
        return out
    }
    
    public static func handleCheckAutonomy(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession("[Autonomy check] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    
    public static func handleFoundationModel(_ input: String) async throws -> String {
        try await SyntraEngine.continueSession(input)
    }
}


/// Utility functions for SYNTRA operations
public struct SyntraUtils {
    // ... (all existing functions in SyntraUtils remain the same) ...
    public static func isPingCommand(_ input: String) -> Bool {
        input == "ping"
    }

    public static func generatePongResponse() -> String {
        "PONG"
    }
    
    public static func generateUnknownCommandError(_ command: String) -> String {
        "Unknown command: \(command)"
    }
}
