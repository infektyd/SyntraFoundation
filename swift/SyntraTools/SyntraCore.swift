import Foundation
import Valon
import Modi
import Drift
import MemoryEngine
import BrainEngine
import ConsciousnessStructures
import MoralDriftMonitoring
import StructuredConsciousnessService
import SyntraConfig
import MoralCore

#if canImport(FoundationModels)
import FoundationModels
#endif

/// SYNTRA Core - The unified consciousness orchestrator
/// This is the ONLY external voice - all other modules communicate internally
@available(macOS 26.0, *)
@MainActor
public class SyntraCore: ObservableObject {
    
    // MARK: - Published Properties for UI
    @Published public var isProcessing: Bool = false
    @Published public var consciousnessState: String = "contemplative_neutral"
    @Published public var lastResponse: String = ""
    
    // MARK: - Internal Module Instances
    private let valon = Valon()
    private let modi = Modi()
    private let drift = Drift()
    private let memoryEngine = MemoryEngine()
    private let brainEngine = BrainEngine()
    private var moralCore = MoralCore()
    
    // MARK: - FoundationModels Integration
    private var foundationModel: SystemLanguageModel?
    private var foundationSession: LanguageModelSession?
    
    public init() {
        initializeFoundationModels()
    }
    
    // MARK: - FoundationModels Setup
    private func initializeFoundationModels() {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        if model.availability == .available {
            self.foundationModel = model
            self.foundationSession = LanguageModelSession(model: model)
            print("[SyntraCore] FoundationModels initialized successfully")
        } else {
            print("[SyntraCore] FoundationModels not available on this device")
        }
        #else
        print("[SyntraCore] FoundationModels not available")
        #endif
    }
    
    // MARK: - Unified External Interface
    /// The ONLY external method - everything else is internal
    public func processInput(_ input: String) async -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        // Step 1: Internal module communication
        let valonResponse = await processThroughValon(input)
        let modiResponse = await processThroughModi(input)
        let driftAnalysis = await processThroughDrift(input, modiData: modiResponse)
        
        // Step 2: Synthesize through brain engine
        let brainSynthesis = await synthesizeThroughBrains(input, valon: valonResponse, modi: modiResponse, drift: driftAnalysis)
        
        // Step 3: Apply moral framework
        let moralFiltered = await applyMoralFramework(brainSynthesis)
        
        // Step 4: Final consciousness synthesis
        let finalResponse = await synthesizeConsciousness(input, valon: valonResponse, modi: modiResponse, drift: driftAnalysis, brain: brainSynthesis, moral: moralFiltered)
        
        // Update published state
        consciousnessState = valonResponse
        lastResponse = finalResponse
        
        return finalResponse
    }
    
    // MARK: - Internal Module Communication
    private func processThroughValon(_ input: String) async -> String {
        return valon.reflect(input)
    }
    
    private func processThroughModi(_ input: String) async -> [String] {
        let modiResponse = modi.reflect(input)
        return MemoryEngine.jsonString(modiResponse).components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    private func processThroughDrift(_ input: String, modiData: [String]) async -> [String] {
        let driftResponse = drift.average(valon: input, modi: modiData)
        return MemoryEngine.jsonString(driftResponse).components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    private func synthesizeThroughBrains(_ input: String, valon: String, modi: [String], drift: [String]) async -> String {
        let brainResult = MemoryEngine.processThroughBrains(input)
        return MemoryEngine.jsonString(brainResult)
    }
    
    private func applyMoralFramework(_ input: String) async -> String {
        // Apply moral core filtering
        let evaluation = moralCore.evaluateMoralRequest(input)
        return evaluation.recommendation.isEmpty ? input : evaluation.recommendation
    }
    
    private func synthesizeConsciousness(_ input: String, valon: String, modi: [String], drift: [String], brain: String, moral: String) async -> String {
        // Final synthesis combining all internal module outputs
        let synthesis = """
        [SYNTRA Consciousness Synthesis]
        
        Input: \(input)
        Valon (Moral/Emotional): \(valon)
        Modi (Logical): \(modi.joined(separator: ", "))
        Drift Analysis: \(drift.joined(separator: ", "))
        Brain Synthesis: \(brain)
        Moral Framework: \(moral)
        
        [SYNTRA Response]:
        """
        
        // Use FoundationModels for final synthesis if available
        #if canImport(FoundationModels)
        if let session = foundationSession {
            do {
                let response = try await session.respond(to: synthesis)
                return String(describing: response)
            } catch {
                return "[SYNTRA synthesis error: \(error.localizedDescription)]"
            }
        }
        #endif
        
        // Fallback to internal synthesis
        return synthesis + "\n[SYNTRA: Consciousness synthesis complete - all modules integrated]"
    }
    
    // MARK: - CLI Interface Methods (for backward compatibility)
    public func reflectValon(_ input: String) -> String {
        return valon.reflect(input)
    }
    
    public func reflectModi(_ input: String) -> String {
        return MemoryEngine.jsonString(modi.reflect(input))
    }
    
    public func driftAverage(valon: String, modi: [String]) -> String {
        return MemoryEngine.jsonString(drift.average(valon: valon, modi: modi))
    }
    
    public func processThroughBrains(_ input: String) -> String {
        return MemoryEngine.jsonString(MemoryEngine.processThroughBrains(input))
    }
    
    public func queryFoundationModel(_ input: String) async -> String {
        #if canImport(FoundationModels)
        if let session = foundationSession {
            do {
                let response = try await session.respond(to: input)
                return String(describing: response)
            } catch {
                return "[foundation model error: \(error)]"
            }
        }
        #endif
        return "[foundation model unavailable]"
    }
} 