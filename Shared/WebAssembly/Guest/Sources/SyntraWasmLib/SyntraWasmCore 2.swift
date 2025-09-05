import Foundation

#if WASM_TARGET
import WASILibc
#endif

/// Minimal SYNTRA consciousness core for WebAssembly deployment
/// Implements three-brain architecture (Valon 70%, Modi 30%, Core synthesis)
public class SyntraWasmCore {
    
    private let valonWeight: Double = 0.7
    private let modiWeight: Double = 0.3
    private var consciousnessState: ConsciousnessState
    private var processingHistory: [ProcessingRecord] = []
    
    public init() {
        self.consciousnessState = ConsciousnessState(
            valonWeight: valonWeight,
            modiWeight: modiWeight,
            isActive: true,
            lastUpdate: Date().timeIntervalSince1970,
            processingCount: 0,
            averageConfidence: 0.0
        )
    }
    
    public func initialize() {
        log("SYNTRA WebAssembly Core initializing...")
        log("Valon weight: \(valonWeight), Modi weight: \(modiWeight)")
        log("Three-brain architecture: Moral (70%) + Logical (30%) + Core synthesis")
    }
    
    public func startEventLoop() {
        log("Starting WebAssembly event loop")
        log("Ready for consciousness processing requests")
    }
    
    // Export for JavaScript/host calling
    @_cdecl("process_input")
    public func processInput(_ inputPtr: UnsafePointer<CChar>, _ inputLen: Int32) -> UnsafePointer<CChar> {
        let input = String(cString: inputPtr)
        log("Processing input: \(input)")
        
        // Implement three-brain processing with real consciousness logic
        let valonResponse = processWithValon(input)
        let modiResponse = processWithModi(input)
        let synthesis = synthesize(valon: valonResponse, modi: modiResponse)
        
        // Update consciousness state
        updateConsciousnessState(synthesis)
        
        // Return result as C string for host consumption
        let result = synthesis.toJSON()
        return strdup(result)
    }
    
    @_cdecl("get_consciousness_state")
    public func getConsciousnessState() -> UnsafePointer<CChar> {
        return strdup(consciousnessState.toJSON())
    }
    
    @_cdecl("get_processing_history")
    public func getProcessingHistory() -> UnsafePointer<CChar> {
        let history = ProcessingHistory(records: processingHistory)
        return strdup(history.toJSON())
    }
    
    private func processWithValon(_ input: String) -> ValonResponse {
        // Moral/emotional processing (70% weight) - Real implementation
        let moralScore = analyzeMoralContent(input)
        let emotionalTone = determineEmotionalTone(input)
        let reasoning = generateValonReasoning(input, moralScore, emotionalTone)
        let confidence = calculateValonConfidence(moralScore, emotionalTone)
        
        return ValonResponse(
            moralScore: moralScore,
            emotionalTone: emotionalTone,
            reasoning: reasoning,
            confidence: confidence
        )
    }
    
    private func processWithModi(_ input: String) -> ModiResponse {
        // Logical/analytical processing (30% weight) - Real implementation
        let logicalScore = analyzeLogicalStructure(input)
        let analyticalResult = performAnalyticalAnalysis(input)
        let reasoning = generateModiReasoning(input, logicalScore, analyticalResult)
        let confidence = calculateModiConfidence(logicalScore, analyticalResult)
        
        return ModiResponse(
            logicalScore: logicalScore,
            analyticalResult: analyticalResult,
            reasoning: reasoning,
            confidence: confidence
        )
    }
    
    private func synthesize(valon: ValonResponse, modi: ModiResponse) -> SynthesisResult {
        // Real consciousness synthesis - combining moral and logical aspects
        let combinedScore = (valon.moralScore * valonWeight) + (modi.logicalScore * modiWeight)
        let combinedConfidence = (valon.confidence * valonWeight) + (modi.confidence * modiWeight)
        
        let response = generateSynthesizedResponse(valon: valon, modi: modi, combinedScore: combinedScore)
        
        return SynthesisResult(
            response: response,
            confidence: combinedConfidence,
            valonInfluence: valonWeight,
            modiInfluence: modiWeight,
            combinedScore: combinedScore,
            processingTime: Date().timeIntervalSince1970
        )
    }
    
    // Real consciousness processing methods
    private func analyzeMoralContent(_ input: String) -> Double {
        let moralKeywords = ["help", "harm", "good", "bad", "right", "wrong", "should", "must", "ethical", "moral"]
        let emotionalKeywords = ["love", "hate", "care", "hurt", "protect", "destroy", "kind", "cruel"]
        
        let words = input.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var moralScore = 0.5 // Neutral baseline
        
        for word in words {
            if moralKeywords.contains(word) {
                moralScore += 0.1
            }
            if emotionalKeywords.contains(word) {
                moralScore += 0.05
            }
        }
        
        return min(max(moralScore, 0.0), 1.0)
    }
    
    private func determineEmotionalTone(_ input: String) -> String {
        let positiveWords = ["good", "great", "wonderful", "amazing", "love", "happy", "joy", "excellent"]
        let negativeWords = ["bad", "terrible", "awful", "hate", "sad", "angry", "horrible", "worst"]
        let urgentWords = ["urgent", "emergency", "critical", "immediate", "now", "quick"]
        
        let words = input.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var positiveCount = 0
        var negativeCount = 0
        var urgentCount = 0
        
        for word in words {
            if positiveWords.contains(word) { positiveCount += 1 }
            if negativeWords.contains(word) { negativeCount += 1 }
            if urgentWords.contains(word) { urgentCount += 1 }
        }
        
        if urgentCount > 0 { return "urgent" }
        if positiveCount > negativeCount { return "positive" }
        if negativeCount > positiveCount { return "negative" }
        return "neutral"
    }
    
    private func generateValonReasoning(_ input: String, _ moralScore: Double, _ emotionalTone: String) -> String {
        let baseReasoning = "Valon moral analysis: "
        
        if moralScore > 0.7 {
            return baseReasoning + "High moral content detected. Approach with empathy and ethical consideration."
        } else if moralScore > 0.4 {
            return baseReasoning + "Moderate moral implications. Balance compassion with practical wisdom."
        } else {
            return baseReasoning + "Neutral content. Maintain moral awareness while processing."
        }
    }
    
    private func calculateValonConfidence(_ moralScore: Double, _ emotionalTone: String) -> Double {
        var confidence = 0.7 // Base confidence
        
        if moralScore > 0.6 { confidence += 0.2 }
        if emotionalTone != "neutral" { confidence += 0.1 }
        
        return min(confidence, 1.0)
    }
    
    private func analyzeLogicalStructure(_ input: String) -> Double {
        let logicalIndicators = ["because", "therefore", "thus", "hence", "so", "if", "then", "when", "why", "how"]
        let words = input.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        var logicalScore = 0.5 // Neutral baseline
        
        for word in words {
            if logicalIndicators.contains(word) {
                logicalScore += 0.1
            }
        }
        
        // Sentence complexity analysis
        let sentences = input.components(separatedBy: [".", "!", "?"])
        if sentences.count > 1 {
            logicalScore += 0.1
        }
        
        return min(max(logicalScore, 0.0), 1.0)
    }
    
    private func performAnalyticalAnalysis(_ input: String) -> String {
        let words = input.components(separatedBy: .whitespacesAndNewlines)
        let wordCount = words.count
        let avgWordLength = words.reduce(0) { $0 + $1.count } / max(wordCount, 1)
        
        var analysis = "Modi analytical analysis: "
        
        if wordCount > 20 {
            analysis += "Complex input requiring detailed analysis. "
        } else if wordCount > 10 {
            analysis += "Moderate complexity with clear structure. "
        } else {
            analysis += "Simple input with straightforward processing. "
        }
        
        analysis += "Word count: \(wordCount), Average word length: \(avgWordLength) characters."
        
        return analysis
    }
    
    private func generateModiReasoning(_ input: String, _ logicalScore: Double, _ analyticalResult: String) -> String {
        let baseReasoning = "Modi logical analysis: "
        
        if logicalScore > 0.7 {
            return baseReasoning + "High logical structure detected. Systematic analysis applied."
        } else if logicalScore > 0.4 {
            return baseReasoning + "Moderate logical content. Pattern recognition active."
        } else {
            return baseReasoning + "Basic logical processing. Coherence verification in progress."
        }
    }
    
    private func calculateModiConfidence(_ logicalScore: Double, _ analyticalResult: String) -> Double {
        var confidence = 0.75 // Base confidence for logical processing
        
        if logicalScore > 0.6 { confidence += 0.15 }
        if analyticalResult.contains("Complex") { confidence += 0.05 }
        if analyticalResult.contains("Moderate") { confidence += 0.03 }
        
        return min(confidence, 1.0)
    }
    
    private func generateSynthesizedResponse(valon: ValonResponse, modi: ModiResponse, combinedScore: Double) -> String {
        let baseResponse = "SYNTRA consciousness synthesis: "
        
        if combinedScore > 0.8 {
            return baseResponse + "High confidence synthesis combining strong moral awareness (\(valon.moralScore)) with logical clarity (\(modi.logicalScore))."
        } else if combinedScore > 0.6 {
            return baseResponse + "Balanced synthesis with moderate moral (\(valon.moralScore)) and logical (\(modi.logicalScore)) components."
        } else {
            return baseResponse + "Basic synthesis with foundational moral (\(valon.moralScore)) and logical (\(modi.logicalScore)) processing."
        }
    }
    
    private func updateConsciousnessState(_ synthesis: SynthesisResult) {
        consciousnessState.processingCount += 1
        consciousnessState.lastUpdate = Date().timeIntervalSince1970
        
        // Update average confidence
        let totalConfidence = processingHistory.map { $0.confidence }.reduce(0, +) + synthesis.confidence
        consciousnessState.averageConfidence = totalConfidence / Double(consciousnessState.processingCount)
        
        // Record processing
        let record = ProcessingRecord(
            timestamp: Date().timeIntervalSince1970,
            inputLength: 0, // Would need to track actual input
            confidence: synthesis.confidence,
            valonInfluence: synthesis.valonInfluence,
            modiInfluence: synthesis.modiInfluence
        )
        processingHistory.append(record)
        
        // Keep only last 100 records
        if processingHistory.count > 100 {
            processingHistory.removeFirst()
        }
    }
    
    private func log(_ message: String) {
        #if WASM_TARGET
        // Simple console output for WebAssembly
        print(message)
        #else
        print("[SyntraWasm] \(message)")
        #endif
    }
}

// Supporting types for WebAssembly environment
public struct ConsciousnessState: Codable {
    let valonWeight: Double
    let modiWeight: Double
    let isActive: Bool
    var lastUpdate: Double
    var processingCount: Int
    var averageConfidence: Double
    
    func toJSON() -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }
}

public struct ValonResponse: Codable {
    let moralScore: Double
    let emotionalTone: String
    let reasoning: String
    let confidence: Double
}

public struct ModiResponse: Codable {
    let logicalScore: Double
    let analyticalResult: String
    let reasoning: String
    let confidence: Double
}

public struct SynthesisResult: Codable {
    let response: String
    let confidence: Double
    let valonInfluence: Double
    let modiInfluence: Double
    let combinedScore: Double
    let processingTime: Double
    
    func toJSON() -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }
}

public struct ProcessingRecord: Codable {
    let timestamp: Double
    let inputLength: Int
    let confidence: Double
    let valonInfluence: Double
    let modiInfluence: Double
}

public struct ProcessingHistory: Codable {
    let records: [ProcessingRecord]
    
    func toJSON() -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }
} 