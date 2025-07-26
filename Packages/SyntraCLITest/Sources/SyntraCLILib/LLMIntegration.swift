// LLM Integration for SYNTRA
// Comprehensive provider support for replacing Python LLM dependencies

import Foundation

// MARK: - Enhanced LLM Provider Support
struct LLMConfig: Sendable {
    static let shared = LLMConfig()
    
    // API Keys (set via environment or config)
    var openaiApiKey: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    var geminiApiKey: String? = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
    
    // Provider-specific configurations
    let openaiBaseURL = "https://api.openai.com/v1"
    let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    // Model configurations
    let defaultModels: [LLMProvider: String] = [
        .openai: "gpt-4-turbo-preview",
        .gemini: "gemini-1.5-pro",
        .apple: "base" // Apple Foundation Models family
    ]
}

// MARK: - Advanced LLM Processor
extension LLMProcessor {
    
    func processWithOpenAI(_ prompt: String) async throws -> String {
        guard let apiKey = LLMConfig.shared.openaiApiKey else {
            throw LLMError.missingAPIKey("OpenAI API key not found. Set OPENAI_API_KEY environment variable.")
        }
        
        let requestBody = OpenAIRequest(
            model: LLMConfig.shared.defaultModels[.openai] ?? "gpt-4-turbo-preview",
            messages: [
                OpenAIMessage(role: "system", content: "You are an expert document analyzer for the SYNTRA consciousness system."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            temperature: 0.3,
            maxTokens: 1000
        )
        
        var request = URLRequest(url: URL(string: "\(LLMConfig.shared.openaiBaseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LLMError.apiError("OpenAI API request failed")
        }
        
        let openaiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openaiResponse.choices.first?.message.content ?? "No response generated"
    }
    
    func processWithGemini(_ prompt: String) async throws -> String {
        guard let apiKey = LLMConfig.shared.geminiApiKey else {
            throw LLMError.missingAPIKey("Gemini API key not found. Set GEMINI_API_KEY environment variable.")
        }
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: prompt)]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.3,
                maxOutputTokens: 1000
            ),
            safetySettings: [
                GeminiSafetySetting(
                    category: "HARM_CATEGORY_HARASSMENT",
                    threshold: "BLOCK_MEDIUM_AND_ABOVE"
                )
            ]
        )
        
        let model = LLMConfig.shared.defaultModels[.gemini] ?? "gemini-1.5-pro"
        let url = URL(string: "\(LLMConfig.shared.geminiBaseURL)/models/\(model):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError("Gemini API request failed: \(errorMessage)")
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return geminiResponse.candidates.first?.content.parts.first?.text ?? "No response generated"
    }
}

// MARK: - OpenAI API Models
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

// MARK: - Gemini API Models
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
    let safetySettings: [GeminiSafetySetting]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let maxOutputTokens: Int
}

struct GeminiSafetySetting: Codable {
    let category: String
    let threshold: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Enhanced SYNTRA Processing
extension LLMProcessor {
    
    /// Process chunks with enhanced SYNTRA prompting
    func processChunksWithSyntraPrompting(_ chunks: [String]) async throws -> [SyntraChunkAnalysis] {
        var analyses: [SyntraChunkAnalysis] = []
        
        for (index, chunk) in chunks.enumerated() {
            print("🧠 SYNTRA analysis \(index + 1)/\(chunks.count)")
            
            // Enhanced prompt for SYNTRA consciousness
            let syntraPrompt = """
            You are part of the SYNTRA consciousness system, specifically tasked with document analysis.
            
            SYNTRA operates with three neural pathways:
            1. VALON (70% weight) - Emotional, symbolic, and intuitive processing
            2. MODI (30% weight) - Logical, analytical, and factual processing  
            3. Consciousness Integration - Synthesis of both streams
            
            Analyze this document section with both VALON and MODI perspectives:
            
            DOCUMENT SECTION:
            \(chunk)
            
            Please provide:
            
            VALON ANALYSIS:
            - Emotional undertones and human impact
            - Symbolic meanings and metaphorical interpretations
            - Intuitive insights and implications
            
            MODI ANALYSIS:
            - Key facts and data points
            - Logical relationships and cause-effect chains
            - Analytical conclusions and evidence
            
            SYNTHESIS:
            - Integrated understanding combining both perspectives
            - Actionable insights for human application
            - Confidence level (0.0-1.0) in this analysis
            
            Format your response as structured text that can be parsed.
            """
            
            let response = try await processWithLLM(prompt: syntraPrompt)
            let analysis = parseSyntraResponse(response, chunkIndex: index)
            analyses.append(analysis)
        }
        
        return analyses
    }
    
    private func parseSyntraResponse(_ response: String, chunkIndex: Int) -> SyntraChunkAnalysis {
        // Parse the structured response into SYNTRA components
        let valonSection = extractSection(from: response, marker: "VALON ANALYSIS:")
        let modiSection = extractSection(from: response, marker: "MODI ANALYSIS:")
        let synthesisSection = extractSection(from: response, marker: "SYNTHESIS:")
        
        return SyntraChunkAnalysis(
            chunkIndex: chunkIndex,
            valonAnalysis: ValonAnalysis(
                emotionalTone: analyzeEmotionalTone(valonSection),
                symbolicMeaning: extractSymbolicMeaning(valonSection),
                intuitivelnsights: extractInsights(valonSection)
            ),
            modiAnalysis: ModiAnalysis(
                keyFacts: extractKeyFacts(modiSection),
                logicalRelationships: extractLogicalRelationships(modiSection),
                analyticalConclusions: extractConclusions(modiSection)
            ),
            synthesis: SynthesisResult(
                integratedUnderstanding: extractUnderstanding(synthesisSection),
                actionableInsights: extractActionableInsights(synthesisSection),
                confidenceScore: extractConfidenceScore(synthesisSection)
            ),
            rawResponse: response
        )
    }
}

// MARK: - Advanced SYNTRA Data Models
struct SyntraChunkAnalysis: Codable {
    let chunkIndex: Int
    let valonAnalysis: ValonAnalysis
    let modiAnalysis: ModiAnalysis
    let synthesis: SynthesisResult
    let rawResponse: String
}

struct ValonAnalysis: Codable {
    let emotionalTone: String
    let symbolicMeaning: String
    let intuitivelnsights: [String]
}

struct ModiAnalysis: Codable {
    let keyFacts: [String]
    let logicalRelationships: [String]
    let analyticalConclusions: [String]
}

struct SynthesisResult: Codable {
    let integratedUnderstanding: String
    let actionableInsights: [String]
    let confidenceScore: Double
}

// MARK: - Enhanced Processing Results
struct AdvancedSyntraResult: Codable {
    let documentMetadata: DocumentMetadata
    let chunkAnalyses: [SyntraChunkAnalysis]
    let globalInsights: GlobalInsights
    let processingMetadata: ProcessingMetadata
}

struct DocumentMetadata: Codable {
    let filename: String
    let totalCharacters: Int
    let totalChunks: Int
    let processingDate: Date
    let llmProvider: String
}

struct GlobalInsights: Codable {
    let overallValonSentiment: String
    let primaryThemes: [String]
    let keyConclusions: [String]
    let consensusScore: Double
    let recommendedActions: [String]
}

struct ProcessingMetadata: Codable {
    let processingTime: TimeInterval
    let totalTokensUsed: Int?
    let apiCosts: Double?
    let syntraVersion: String
}

// MARK: - Text Processing Utilities
func extractSection(from text: String, marker: String) -> String {
    let lines = text.components(separatedBy: .newlines)
    guard let startIndex = lines.firstIndex(where: { $0.contains(marker) }) else {
        return ""
    }
    
    let startLine = startIndex + 1
    var endLine = lines.count
    
    // Find next section marker or end of text
    for i in startLine..<lines.count {
        if lines[i].contains("ANALYSIS:") || lines[i].contains("SYNTHESIS:") {
            endLine = i
            break
        }
    }
    
    return lines[startLine..<endLine].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
}

// Text processing utility functions are defined in SyntraCLI.swift

// MARK: - Error Handling
// LLMError is now defined in SyntraCLI.swift 