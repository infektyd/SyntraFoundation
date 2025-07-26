import Foundation

#if WASM_TARGET
import WASILibc
#endif

/// Minimal SYNTRA consciousness core for WebAssembly deployment
/// Implements three-brain architecture (Valon 70%, Modi 30%, Core synthesis)
public class SyntraWasmCore {
    
    private let valonWeight: Double = 0.7
    private let modiWeight: Double = 0.3
    
    public init() {}
    
    public func initialize() {
        log("SYNTRA WebAssembly Core initializing...")
        log("Valon weight: \(valonWeight), Modi weight: \(modiWeight)")
    }
    
    public func startEventLoop() {
        log("Starting WebAssembly event loop")
        // Event loop for browser/host integration
    }
    
    // Export for JavaScript/host calling
    @_cdecl("process_input")
    public func processInput(_ inputPtr: UnsafePointer<CChar>, _ inputLen: Int32) -> UnsafePointer<CChar> {
        let input = String(cString: inputPtr)
        log("Processing input: \(input)")
        
        // Implement three-brain processing
        let valonResponse = processWithValon(input)
        let modiResponse = processWithModi(input)
        let synthesis = synthesize(valon: valonResponse, modi: modiResponse)
        
        // Return result as C string for host consumption
        let result = synthesis.toJSON()
        return strdup(result)
    }
    
    @_cdecl("get_consciousness_state")
    public func getConsciousnessState() -> UnsafePointer<CChar> {
        let state = ConsciousnessState(
            valonWeight: valonWeight,
            modiWeight: modiWeight,
            isActive: true,
            lastUpdate: Date().timeIntervalSince1970
        )
        return strdup(state.toJSON())
    }
    
    private func processWithValon(_ input: String) -> ValonResponse {
        // Moral/emotional processing (70% weight)
        return ValonResponse(
            moralScore: 0.8,
            emotionalTone: "compassionate",
            reasoning: "Valon processing: \(input)",
            confidence: 0.9
        )
    }
    
    private func processWithModi(_ input: String) -> ModiResponse {
        // Logical/analytical processing (30% weight)
        return ModiResponse(
            logicalScore: 0.9,
            analyticalResult: "Analyzed: \(input)",
            reasoning: "Modi processing: logical analysis",
            confidence: 0.85
        )
    }
    
    private func synthesize(valon: ValonResponse, modi: ModiResponse) -> SynthesisResult {
        let combinedScore = (valon.moralScore * valonWeight) + (modi.logicalScore * modiWeight)
        
        return SynthesisResult(
            response: "Synthesized response combining moral and logical aspects",
            confidence: (valon.confidence * valonWeight) + (modi.confidence * modiWeight),
            valonInfluence: valonWeight,
            modiInfluence: modiWeight,
            combinedScore: combinedScore
        )
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
    let lastUpdate: Double
    
    func toJSON() -> String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
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
    
    func toJSON() -> String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
} 