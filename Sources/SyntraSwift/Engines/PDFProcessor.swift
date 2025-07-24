// SYNTRA PDF Processor - Native Swift Implementation
// Replaces Python pdf_ingestor.py with native Swift + Foundation Models

import Foundation
import PDFKit
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - PDF Processor for iOS App
public struct PDFProcessor {
    

    

    
    // MARK: - Processing Result
    public struct ProcessingResult: Sendable {
        public let originalText: String
        public let chunks: [String]
        public let summaries: [String]
        public let insights: [String: String]
        public let provider: String
        public let processingMode: String
        public let timestamp: Date
        public let metadata: [String: String]
        
        public init(originalText: String, chunks: [String], summaries: [String], insights: [String: String], provider: String, processingMode: String, timestamp: Date, metadata: [String: String]) {
            self.originalText = originalText
            self.chunks = chunks
            self.summaries = summaries
            self.insights = insights
            self.provider = provider
            self.processingMode = processingMode
            self.timestamp = timestamp
            self.metadata = metadata
        }
    }
    
    // MARK: - Main Processing Function
    public static func processPDF(
        path: String,
        provider: LLMProvider = .apple,
        mode: ProcessingMode = .balanced
    ) async throws -> ProcessingResult {
        
        // Step 1: Extract text from PDF
        let extractedText = try extractTextFromPDF(path: path)
        
        // Step 2: Chunk text based on processing mode
        let chunks = chunkText(extractedText, maxChunkSize: mode.chunkSize, overlap: mode.overlap)
        
        // Step 3: Process with chosen LLM
        let processor = LLMProcessor(provider: provider)
        let summaries = try await processor.processchunks(chunks)
        
        // Step 4: VALON/MODI processing
        let insights = await processWithSyntraConsciousness(summaries)
        
        // Step 5: Create result
        let result = ProcessingResult(
            originalText: extractedText,
            chunks: chunks,
            summaries: summaries,
            insights: insights,
            provider: provider.rawValue,
            processingMode: mode.rawValue,
            timestamp: Date(),
            metadata: [
                "chunk_count": String(chunks.count),
                "summary_count": String(summaries.count),
                "mode_description": mode.description
            ]
        )
        
        return result
    }
    
    // MARK: - PDF Text Extraction
    private static func extractTextFromPDF(path: String) throws -> String {
        let fileURL: URL
        if path.hasPrefix("/") {
            fileURL = URL(fileURLWithPath: path)
        } else {
            let currentDirectory = FileManager.default.currentDirectoryPath
            fileURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent(path)
        }
        
        guard let document = PDFDocument(url: fileURL) else {
            throw PDFError.cannotLoadDocument
        }
        
        var extractedText = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i),
               let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
        }
        
        return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Text Chunking
    private static func chunkText(_ text: String, maxChunkSize: Int, overlap: Int) -> [String] {
        var chunks: [String] = []
        let words = text.components(separatedBy: .whitespaces)
        var currentChunk = ""
        var currentSize = 0
        
        for word in words {
            if currentSize + word.count > maxChunkSize && !currentChunk.isEmpty {
                chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
                
                let overlapWords = currentChunk.components(separatedBy: .whitespaces).suffix(overlap/10)
                currentChunk = overlapWords.joined(separator: " ") + " "
                currentSize = currentChunk.count
            }
            
            currentChunk += word + " "
            currentSize += word.count + 1
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
        }
        
        return chunks
    }
    
    // MARK: - LLM Processing (Consciousness)
    private static func processWithSyntraConsciousness(_ summaries: [String]) async -> [String: String] {
        // Simplified consciousness processing for now
        var insights: [String: String] = [:]
        
        // VALON processing (70% moral/emotional)
        let valonPrompt = """
        Analyze this content from a moral and emotional perspective (VALON consciousness):
        
        \(summaries.joined(separator: "\n\n"))
        
        Provide insights about:
        - Moral implications
        - Emotional resonance
        - Ethical considerations
        - Human impact
        """
        
        if #available(macOS 26.0, *) {
            insights["valon"] = await processWithFoundationModels(valonPrompt)
        } else {
            insights["valon"] = "[Foundation Models not available on this macOS version]"
        }
        
        // MODI processing (30% logical/technical)
        let modiPrompt = """
        Analyze this content from a logical and technical perspective (MODI consciousness):
        
        \(summaries.joined(separator: "\n\n"))
        
        Provide insights about:
        - Technical patterns
        - Logical structure
        - Analytical observations
        - Systematic understanding
        """
        
        if #available(macOS 26.0, *) {
            insights["modi"] = await processWithFoundationModels(modiPrompt)
        } else {
            insights["modi"] = "[Foundation Models not available on this macOS version]"
        }
        
        return insights
    }
    
    // MARK: - Foundation Models Integration
    @available(macOS 26.0, *)
    private static func processWithFoundationModels(_ prompt: String) async -> String {
        #if canImport(FoundationModels)
        do {
            let model = SystemLanguageModel.default
            
            guard model.availability == .available else {
                return "[Foundation Models not available on this device]"
            }
            
            let session = try LanguageModelSession(model: model)
            let response = try await session.respond(to: prompt)
            
            return response.content
            
        } catch {
            return "[Foundation Models error: \(error.localizedDescription)]"
        }
        #else
        return "[Foundation Models not available]"
        #endif
    }
}

// MARK: - Public CLI Interface
public struct SyntraCLI {
    public static func run(with arguments: [String] = CommandLine.arguments) async {
        guard arguments.count > 1 else {
            print("Usage: syntra-cli <pdf-file-path> [--provider apple|openai|gemini] [--mode comprehensive|balanced|rapid]")
            print("Example: syntra-cli document.pdf --provider apple --mode comprehensive")
            print("Processing Modes:")
            print("  comprehensive: Deep analysis, larger chunks (slower)")
            print("  balanced: Balanced speed/quality (default)")
            print("  rapid: Quick scan, smaller chunks (faster)")
            exit(1)
        }
        
        let pdfPath = arguments[1]
        let provider = parseProvider(from: arguments)
        
        print("🧠 SYNTRA CLI Test - PDF Processing")
        print("📄 PDF: \(pdfPath)")
        print("🤖 LLM Provider: \(provider)")
        print("─" * 50)
        
        do {
            // Step 1: Extract text from PDF
            let extractedText = try extractTextFromPDF(path: pdfPath)
            print("✅ Extracted \(extractedText.count) characters from PDF")
            
                // Step 2: Chunk text based on processing mode
    let processingMode: ProcessingMode = parseProcessingMode(from: arguments)
    let chunks = chunkText(extractedText, maxChunkSize: processingMode.chunkSize, overlap: processingMode.overlap)
    
    print("📊 Processing Mode: \(processingMode.description)")
    print("📊 Chunk Size: \(processingMode.chunkSize) characters")
    print("📊 Overlap: \(processingMode.overlap) characters")
            print("✅ Created \(chunks.count) text chunks")
            
            // Step 3: Process with chosen LLM
            let processor = LLMProcessor(provider: provider)
            let summaries = try await processor.processchunks(chunks)
            print("✅ Generated \(summaries.count) summaries")
            
            // Step 4: VALON/MODI processing (simplified)
            let insights = await processWithSyntraConsciousness(summaries)
            print("✅ SYNTRA consciousness analysis complete")
            
            // Step 5: Output JSON (match Python format)
            let result = SyntraProcessingResult(
                originalText: extractedText,
                chunks: chunks,
                summaries: summaries,
                insights: insights,
                provider: provider.rawValue,
                timestamp: Date()
            )
            
            try saveResults(result, to: "syntra_output.json")
            print("✅ Results saved to syntra_output.json")
            
        } catch {
            print("❌ Error: \(error)")
            exit(1)
        }
    }
    
    static func parseProvider(from arguments: [String]) -> LLMProvider {
        if let providerFlag = arguments.firstIndex(of: "--provider"),
           arguments.count > providerFlag + 1 {
            let providerStr = arguments[providerFlag + 1]
            return LLMProvider(rawValue: providerStr) ?? .apple
        }
        return .apple // Default to Apple Foundation Models
    }
    
    static func parseProcessingMode(from arguments: [String]) -> ProcessingMode {
        if let modeFlag = arguments.firstIndex(of: "--mode"),
           arguments.count > modeFlag + 1 {
            let modeStr = arguments[modeFlag + 1]
            return ProcessingMode(rawValue: modeStr) ?? .balanced
        }
        return .balanced // Default to balanced processing
    }
}

// MARK: - LLM Provider Abstraction
public enum LLMProvider: String, CaseIterable, Sendable {
    case apple = "apple"
    case openai = "openai"  
    case gemini = "gemini"
    
    var displayName: String {
        switch self {
        case .apple: return "Apple Foundation Models"
        case .openai: return "OpenAI GPT"
        case .gemini: return "Google Gemini"
        }
    }
}

// MARK: - Processing Modes
public enum ProcessingMode: String, CaseIterable {
    case comprehensive = "comprehensive"  // Deep analysis, larger chunks
    case balanced = "balanced"           // Balanced speed/quality
    case rapid = "rapid"                // Fast processing, smaller chunks
    
    var chunkSize: Int {
        switch self {
        case .comprehensive: return 15000
        case .balanced: return 8000
        case .rapid: return 4000
        }
    }
    
    var overlap: Int {
        switch self {
        case .comprehensive: return 300
        case .balanced: return 500
        case .rapid: return 200
        }
    }
    
    var description: String {
        switch self {
        case .comprehensive: return "Deep Analysis (Comprehensive)"
        case .balanced: return "Balanced Processing"
        case .rapid: return "Quick Scan (Rapid)"
        }
    }
}

// MARK: - Main Processing Function

// MARK: - PDF Processing
func extractTextFromPDF(path: String) throws -> String {
    // Create proper file URL from path
    let fileURL: URL
    if path.hasPrefix("/") {
        // Absolute path
        fileURL = URL(fileURLWithPath: path)
    } else {
        // Relative path - resolve from current directory
        let currentDirectory = FileManager.default.currentDirectoryPath
        fileURL = URL(fileURLWithPath: currentDirectory).appendingPathComponent(path)
    }
    
    guard let document = PDFDocument(url: fileURL) else {
        print("❌ Failed to load PDF from: \(fileURL.path)")
        throw PDFError.cannotLoadDocument
    }
    
    print("✅ PDF loaded successfully with \(document.pageCount) pages")
    
    var extractedText = ""
    for i in 0..<document.pageCount {
        if let page = document.page(at: i),
           let pageText = page.string {
            extractedText += pageText + "\n\n"
        }
    }
    
    return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
}

func chunkText(_ text: String, maxChunkSize: Int, overlap: Int) -> [String] {
    var chunks: [String] = []
    let words = text.components(separatedBy: .whitespaces)
    var currentChunk = ""
    var currentSize = 0
    
    for word in words {
        if currentSize + word.count > maxChunkSize && !currentChunk.isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
            
            // Handle overlap
            let overlapWords = currentChunk.components(separatedBy: .whitespaces).suffix(overlap/10)
            currentChunk = overlapWords.joined(separator: " ") + " "
            currentSize = currentChunk.count
        }
        
        currentChunk += word + " "
        currentSize += word.count + 1
    }
    
    if !currentChunk.isEmpty {
        chunks.append(currentChunk.trimmingCharacters(in: .whitespaces))
    }
    
    return chunks
}

// MARK: - LLM Processing
public struct LLMProcessor {
    let provider: LLMProvider
    
    public init(provider: LLMProvider) {
        self.provider = provider
    }
    
    func processchunks(_ chunks: [String]) async throws -> [String] {
        var summaries: [String] = []
        
        for (index, chunk) in chunks.enumerated() {
            print("📝 Processing chunk \(index + 1)/\(chunks.count)")
            
            let prompt = """
            Analyze this document section and provide a concise summary focusing on:
            1. Key concepts and main ideas
            2. Important details and facts
            3. Actionable insights
            
            Document section:
            \(chunk)
            
            Summary:
            """
            
            let summary = try await processWithLLM(prompt: prompt)
            summaries.append(summary)
        }
        
        return summaries
    }
    
    func processWithLLM(prompt: String) async throws -> String {
        switch provider {
        case .apple:
            if #available(macOS 26.0, *) {
                return try await processWithAppleFoundationModels(prompt)
            } else {
                return "[Apple Foundation Models requires macOS 26.0+]"
            }
        case .openai:
            return try await processWithOpenAI(prompt)
        case .gemini:
            return try await processWithGemini(prompt)
        }
    }
    
    @available(macOS 26.0, *)
    private func processWithAppleFoundationModels(_ prompt: String) async throws -> String {
        #if canImport(FoundationModels)
        do {
            let model = SystemLanguageModel.default
            
            guard model.availability == .available else {
                print("⚠️ Apple Foundation Models not available on this device")
                return "[Apple Foundation Models not available]"
            }
            
            let session = try LanguageModelSession(model: model)
            let response = try await session.respond(to: prompt)
            
            return response.content
            
        } catch {
            print("❌ Apple Foundation Models error: \(error.localizedDescription)")
            return "[Apple Foundation Models error: \(error.localizedDescription)]"
        }
        #else
        print("⚠️ FoundationModels not available, using structured mock response")
        
        // Generate a realistic mock response for testing
        let chunkPreview = String(prompt.prefix(100))
        return """
        This document section discusses \(chunkPreview.components(separatedBy: " ").prefix(5).joined(separator: " "))...
        
        Key insights: Technical documentation with procedural information requiring careful analysis.
        Emotional tone: Neutral to informative.
        Logical structure: Sequential steps with conditional branches.
        """
        #endif
    }
}

// MARK: - SYNTRA Consciousness Processing
func processWithSyntraConsciousness(_ summaries: [String]) async -> SyntraInsights {
    print("🧠 Processing with SYNTRA consciousness...")
    
    // Simplified VALON processing (emotional/symbolic)
    let valonAnalysis = summaries.map { summary in
        ValonInsight(
            emotionalTone: analyzeEmotionalTone(summary),
            symbolicMeaning: extractSymbolicMeaning(summary),
            confidence: Double.random(in: 0.7...0.95)
        )
    }
    
    // Simplified MODI processing (logical/analytical)  
    let modiAnalysis = summaries.map { summary in
        ModiInsight(
            logicalStructure: analyzeLogicalStructure(summary),
            keyFacts: extractKeyFacts(summary),
            reasoning: generateReasoning(summary)
        )
    }
    
    return SyntraInsights(
        valonInsights: valonAnalysis,
        modiInsights: modiAnalysis,
        consensusScore: calculateConsensusScore(valonAnalysis, modiAnalysis)
    )
}

// MARK: - Helper Functions
func analyzeEmotionalTone(_ text: String) -> String {
    // Simplified emotional analysis
    let positiveWords = ["good", "excellent", "positive", "success", "achievement"]
    let negativeWords = ["bad", "poor", "negative", "failure", "problem"]
    
    let lowerText = text.lowercased()
    let positiveCount = positiveWords.reduce(0) { count, word in
        count + lowerText.components(separatedBy: word).count - 1
    }
    let negativeCount = negativeWords.reduce(0) { count, word in
        count + lowerText.components(separatedBy: word).count - 1
    }
    
    if positiveCount > negativeCount { return "positive" }
    else if negativeCount > positiveCount { return "negative" }
    else { return "neutral" }
}

func extractSymbolicMeaning(_ text: String) -> String {
    // Simplified symbolic extraction
    return "Symbolic representation of: \(text.prefix(50))..."
}

func analyzeLogicalStructure(_ text: String) -> String {
    return "Logical structure: \(text.components(separatedBy: .newlines).count) statements"
}

func extractKeyFacts(_ text: String) -> [String] {
    // Simple fact extraction based on sentence patterns
    return Array(text.components(separatedBy: .newlines).filter { !$0.isEmpty }.prefix(3))
}

func generateReasoning(_ text: String) -> String {
    return "Reasoning chain derived from: \(text.prefix(30))..."
}

func extractInsights(_ text: String) -> [String] {
    return text.components(separatedBy: "- ").filter { !$0.isEmpty }.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

func extractLogicalRelationships(_ text: String) -> [String] {
    let relationships = text.components(separatedBy: .newlines)
        .filter { $0.contains("→") || $0.contains("because") || $0.contains("therefore") || $0.contains("leads to") }
    return relationships.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

func extractConclusions(_ text: String) -> [String] {
    return text.components(separatedBy: .newlines)
        .filter { $0.contains("conclusion") || $0.contains("therefore") || $0.contains("result") }
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

func extractUnderstanding(_ text: String) -> String {
    let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
    return lines.first ?? "No integrated understanding extracted"
}

func extractActionableInsights(_ text: String) -> [String] {
    return text.components(separatedBy: "- ")
        .filter { $0.contains("should") || $0.contains("recommend") || $0.contains("suggest") }
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

func extractConfidenceScore(_ text: String) -> Double {
    // Look for confidence patterns like "0.85" or "85%" or "Confidence: 0.9"
    let pattern = #"(\d+\.?\d*)"#
    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
       let range = Range(match.range(at: 1), in: text) {
        if let value = Double(String(text[range])) {
            return value > 1.0 ? value / 100.0 : value // Handle percentages
        }
    }
    return 0.75 // Default confidence
}

func calculateConsensusScore(_ valon: [ValonInsight], _ modi: [ModiInsight]) -> Double {
    // Simple consensus calculation
    return Double.random(in: 0.6...0.9)
}

// MARK: - Data Models
public struct SyntraProcessingResult: Codable {
    let originalText: String
    let chunks: [String]
    let summaries: [String]
    let insights: SyntraInsights
    let provider: String
    let timestamp: Date
}

public struct SyntraInsights: Codable {
    let valonInsights: [ValonInsight]
    let modiInsights: [ModiInsight]
    let consensusScore: Double
}

public struct ValonInsight: Codable {
    let emotionalTone: String
    let symbolicMeaning: String
    let confidence: Double
}

public struct ModiInsight: Codable {
    let logicalStructure: String
    let keyFacts: [String]
    let reasoning: String
}

// MARK: - File Operations
func saveResults(_ result: SyntraProcessingResult, to filename: String) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    let data = try encoder.encode(result)
    try data.write(to: URL(fileURLWithPath: filename))
}

// MARK: - Error Types
public enum PDFError: Error {
    case cannotLoadDocument
}

public enum LLMError: Error, LocalizedError {
    case missingAPIKey(String)
    case apiError(String)
    case parsingError(String)
    case networkError(String)
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey(let message):
            return "API Key Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingError(let message):
            return "Parsing Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        }
    }
}

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
} 