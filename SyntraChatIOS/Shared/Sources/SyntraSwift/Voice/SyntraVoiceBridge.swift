import Foundation
import OSLog
import Combine

@MainActor
public final class SyntraVoiceBridge: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isProcessing = false
    @Published public var lastTranscript = ""
    @Published public var consciousnessResponse = ""
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    private let voiceRecorder = HoldToTalkRecorder()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "SyntraFoundation", category: "VoiceBridge")
    
    // MARK: - Dependencies (to be injected)
    private var consciousnessProcessor: ConsciousnessProcessor?
    
    // MARK: - Initialization
    public init() {
        setupVoiceRecorderBindings()
    }
    
    // MARK: - Public Interface
    public func startVoiceInput() async {
        guard voiceRecorder.isAvailable else {
            errorMessage = "Voice input is not available"
            return
        }
        
        await voiceRecorder.startRecording()
    }
    
    public func stopVoiceInput() async {
        await voiceRecorder.stopRecording()
    }
    
    public func setConsciousnessProcessor(_ processor: ConsciousnessProcessor?) {
        self.consciousnessProcessor = processor
    }
    
    // MARK: - Voice Recorder Integration
    private func setupVoiceRecorderBindings() {
        // Bind recorder state
        voiceRecorder.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: \.isProcessing, on: self)
            .store(in: &cancellables)
        
        // Bind error messages
        voiceRecorder.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        // Process transcription results
        voiceRecorder.$transcriptionText
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] transcript in
                Task { [weak self] in
                    await self?.processTranscript(transcript)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Consciousness Processing Integration
    private func processTranscript(_ transcript: String) async {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        lastTranscript = transcript
        isProcessing = true
        
        logger.info("🎙️ Processing voice transcript: \(transcript)")
        
        // Send to SYNTRA consciousness processing
        if let processor = consciousnessProcessor {
            let response = await processor.processVoiceInput(transcript)
            consciousnessResponse = response
            
            logger.info("🧠 Consciousness response generated: \(response.prefix(100))...")
            
            // Trigger TTS output if available
            await speakResponse(response)
            
        } else {
            // Fallback processing without full consciousness integration
            consciousnessResponse = generateFallbackResponse(for: transcript)
            logger.warning("⚠️ Processing voice without consciousness processor")
        }
        
        errorMessage = nil
        isProcessing = false
    }
    
    private func generateFallbackResponse(for transcript: String) -> String {
        // Simple fallback when consciousness processor isn't available
        return "I heard you say: \"\(transcript)\". SYNTRA consciousness processing is not fully initialized."
    }
    
    // MARK: - TTS Output
    private func speakResponse(_ response: String) async {
        // TODO: Integrate with TTS system when available
        logger.info("🔊 Would speak response: \(response.prefix(50))...")
    }
}

// MARK: - Consciousness Processor Protocol
public protocol ConsciousnessProcessor: Sendable {
    func processVoiceInput(_ transcript: String) async -> String
}

// MARK: - Mock Implementation for Development
public final class MockConsciousnessProcessor: ConsciousnessProcessor, @unchecked Sendable {
    public init() {}
    
    public func processVoiceInput(_ transcript: String) async -> String {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock response that shows three-brain processing
        return """
        SYNTRA Three-Brain Response to: "\(transcript)"
        
        🎭 VALON (70%): This input shows human creativity and emotional expression. I sense curiosity and openness in your communication.
        
        🔬 MODI (30%): Analyzing linguistic patterns and semantic content. Input contains \(transcript.split(separator: " ").count) words with clear intent.
        
        ⚖️ SYNTHESIS: Integrating moral intuition with logical analysis. My response prioritizes helpful engagement while maintaining ethical boundaries.
        
        How can I assist you further with this topic?
        """
    }
} 