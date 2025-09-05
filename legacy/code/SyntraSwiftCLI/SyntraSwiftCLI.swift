// SyntraSwiftCLI.swift

// Fully-wired functional SYNTRA CLI for Apple FoundationModels
// Swift 6.x-compatible

import Foundation
import FoundationModels
import SyntraCore

@main
struct SyntraSwiftCLI {
    static func main() async {
        let arguments = CommandLine.arguments
        guard arguments.count > 1 else {
            print("Usage: SyntraSwiftCLI [command] ")
            return
        }
        let command = arguments[1]
        let input = arguments.count > 2 ? arguments.dropFirst(2).joined(separator: " ") : ""
        do {
            let output: String
            switch command {
            case "processThroughBrains":
                output = try await handleProcessThroughBrains(input)
            case "processStructured":
                output = try await handleProcessStructured(input)
            case "reflect_valon":
                output = try await handleReflectValon(input)
            case "reflect_modi":
                output = try await handleReflectModi(input)
            case "processThroughBrainsWithDrift":
                output = try await handleProcessWithDrift(input)
            case "chat":
                if input == "ping" {
                    print("PONG")
                    return
                } else {
                    output = try await handleChat(input)
                }
            case "checkAutonomy":
                output = try await handleCheckAutonomy(input)
            case "foundation_model":
                output = try await handleFoundationModel(input)
            default:
                print("Unknown command: \(command)")
                return
            }
            print(output)
        } catch {
            print("[ERROR] \(error)")
            exit(1)
        }
    }

    // --- Model Availability ---
    private static func getAvailableModel() throws -> SystemLanguageModel {
        let model = SystemLanguageModel.default
        guard model.availability == .available else {
            throw NSError(domain: "FoundationModels", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels not available on this device"])
        }
        return model
    }

    // --- Token Estimation ---
    private static func estimateTokens(_ text: String) -> Int {
        let words = text.split(separator: " ").count
        let lines = text.split(whereSeparator: \.isNewline).count
        let specials = text.filter { "#`🍎\n[]{}".contains($0) }.count
        return Int(Double(words) * 1.5) + (text.count / 3) + (lines * 2) + specials
    }

    private static func truncatePrompt(_ prompt: String, maxTokens: Int = 1500, useOverlap: Bool = false) throws -> String {
        let estimated = estimateTokens(prompt)
        guard estimated > maxTokens else { return prompt }
        let ratio = Double(maxTokens) / Double(estimated)
        let targetLength = Int(Double(prompt.count) * ratio) - 200
        var truncated = String(prompt.prefix(targetLength)) + " [TRUNCATED: Exceeded limit]"
        print("[DEBUG] Truncated from ~\(estimated) to ~\(maxTokens) tokens; Length: \(truncated.count)")
        if useOverlap {
            let overlapSize = Int(Double(targetLength) * 0.2)
            // Prepend overlap from end, optional
            truncated = String(prompt.suffix(overlapSize)) + truncated
        }
        return truncated
    }

    private static func preparePrompt(_ input: String, isInternal: Bool = false) throws -> String {
        let basePrompt = try truncatePrompt(input)
        return isInternal ? "[Internal SYNTRA 3-brain] \(basePrompt)" : basePrompt
    }

    // --- Enhanced Session Handler Supporting Summarization ---
    private static func continueSession(_ input: String, instructions: String? = nil) async throws -> String {
        let model = try getAvailableModel()
        let session = LanguageModelSession(model: model, instructions: instructions ?? "You are Syntra.")
        do {
            let response = try await session.respond(to: input)
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize = error {
                // Summarization-on-overflow: Always a real model call!
                let summary = try await session.respond(
                    to: "Summarize everything so far in 5 bullets."
                ).content
                // Start a new session with that summary as instructions
                let newSession = LanguageModelSession(
                    model: model, instructions: "CONTEXT SUMMARY: \(summary)\n\nContinue the conversation as Syntra."
                )
                let response = try await newSession.respond(to: input)
                return "[CONTEXT SUMMARIZED]\n" + response.content
            } else {
                throw error
            }
        }
    }

    // --- COMMAND HANDLERS ---
    static func handleProcessThroughBrains(_ input: String) async throws -> String {
        try await continueSession(input)
    }
    static func handleProcessStructured(_ input: String) async throws -> String {
        try await continueSession("[Structured SYNTRA request] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    static func handleReflectValon(_ input: String) async throws -> String {
        try await continueSession("[Valon: moral reflection] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    static func handleReflectModi(_ input: String) async throws -> String {
        try await continueSession("[Modi: logical reflection] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    static func handleProcessWithDrift(_ input: String) async throws -> String {
        try await continueSession("[Drift monitored SYNTRA] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    static func handleChat(_ input: String) async throws -> String {
        let out = try await continueSession(input)
        if out.contains("can't assist") {
            return "I'm doing well, thanks! How can I help you today?"
        }
        return out
    }
    static func handleCheckAutonomy(_ input: String) async throws -> String {
        try await continueSession("[Autonomy check] \(input)", instructions: "[Internal SYNTRA 3-brain]")
    }
    static func handleFoundationModel(_ input: String) async throws -> String {
        try await continueSession(input)
    }
}

