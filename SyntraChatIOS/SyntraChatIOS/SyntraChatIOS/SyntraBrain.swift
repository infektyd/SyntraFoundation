import Foundation
import SwiftUI
import UIKit
import Combine
import os.log
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Comprehensive Logging System
struct SyntraLogger {
    private static let logger = Logger(subsystem: "com.syntra.ios", category: "consciousness")
    private static let fileLogger = FileLogger()
    
    static func log(_ message: String, level: LogLevel = .info, function: String = #function, line: Int = #line) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(function):\(line)] \(message)"
        
        // Console logging (always safe)
        print(logMessage)
        
        // System logging (always safe)
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
        
        // File logging (safe async)
        fileLogger.writeLog(logMessage)
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
}

class FileLogger {
    private let logFileURL: URL
    private let queue = DispatchQueue(label: "com.syntra.filelogger", qos: .utility)
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logFileURL = documentsPath.appendingPathComponent("syntra_consciousness_logs.txt")
        
        // Create log file if it doesn't exist
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        }
        
        // Simple print instead of SyntraLogger.log to avoid circular dependency
        print("[FileLogger] Log file ready at: \(logFileURL.path)")
    }
    
    func writeLog(_ message: String) {
        queue.async {
            do {
                let logEntry = message + "\n"
                let data = logEntry.data(using: .utf8) ?? Data()
                
                let fileHandle = try FileHandle(forWritingTo: self.logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                // Use print instead of SyntraLogger to avoid potential recursion
                print("[FileLogger] Failed to write log: \(error)")
            }
        }
    }
    
    func getLogContents() -> String {
        do {
            return try String(contentsOf: logFileURL)
        } catch {
            return "Failed to read log file: \(error)"
        }
    }
}

// MARK: - iOS-Native SyntraContext
struct SyntraContext {
    let conversationHistory: [String]
    let userPreferences: [String: Any]
    let sessionId: String
    
    init(
        conversationHistory: [String],
        userPreferences: [String: Any],
        sessionId: String
    ) {
        self.conversationHistory = conversationHistory
        self.userPreferences = userPreferences
        self.sessionId = sessionId
    }
}

// MARK: - iOS-Native Configuration
struct SyntraConfig {
    var driftRatio: [String: Double] = ["default": 0.5]
    var useAdaptiveFusion: Bool = true
    var useAdaptiveWeighting: Bool = true
    var enableValonOutput: Bool = true
    var enableModiOutput: Bool = true
    var enableDriftOutput: Bool = true
    
    init() {}
}

// MARK: - Agentic Framework with Foundation Models Integration
@MainActor
class SyntraCore: ObservableObject {
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var isProcessing: Bool = false
    
    private let config: SyntraConfig
    private var conversationMemory: [String] = [] // Session conversation memory
    private var persistentMemory: [String: Any] = [:] // Persistent memory integration
    private let sessionId: String // Consistent session ID
    
    // Foundation Models as the core LLM engine
    #if canImport(FoundationModels)
    private var foundationModel: SystemLanguageModel?
    private var languageSession: LanguageModelSession?
    #endif
    
    // App state observer for memory persistence
    private var appStateObserver: NSObjectProtocol?
    
    init(config: SyntraConfig = SyntraConfig()) {
        self.config = config
        
        // Load or create persistent session ID
        if let existingSessionId = UserDefaults.standard.string(forKey: "syntra_session_id") {
            self.sessionId = existingSessionId
        } else {
            let newSessionId = UUID().uuidString
            UserDefaults.standard.set(newSessionId, forKey: "syntra_session_id")
            self.sessionId = newSessionId
        }
        
        // Load persistent memory from UserDefaults
        loadPersistentMemory()
        
        // Load conversation memory from UserDefaults
        loadConversationMemory()
        
        // Initialize Foundation Models as the core LLM
        setupFoundationModels()
        
        // Setup app state observers for memory persistence
        setupAppStateObservers()
    }
    
    deinit {
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupAppStateObservers() {
        // Save memory when app goes to background
        appStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveConversationMemory()
            self?.savePersistentMemory()
            SyntraLogger.log("[SyntraCore] Memory saved on app background")
        }
    }
    
    #if canImport(FoundationModels)
    private func setupFoundationModels() {
        // Check if Foundation Models are available
        guard SystemLanguageModel.default.availability == .available else {
            SyntraLogger.log("[SyntraCore] Foundation Models not available on this device")
            return
        }
        
        do {
            self.foundationModel = SystemLanguageModel.default
            self.languageSession = try LanguageModelSession(model: foundationModel!)
            SyntraLogger.log("[SyntraCore] Foundation Models initialized as core LLM engine")
        } catch {
            SyntraLogger.log("[SyntraCore] Failed to initialize Foundation Models: \(error)")
        }
    }
    #endif
    
    func processInput(_ input: String, context: SyntraContext) async -> String {
        isProcessing = true
        consciousnessState = "processing"
        
        SyntraLogger.log("[SyntraCore] Starting agentic processing for: '\(input)' with context session: \(sessionId)")
        
        // Update conversation memory with current input
        conversationMemory.append("User: \(input)")
        
        // Integrate with persistent memory through Python structures
        await integrateWithPersistentMemory(input: input, context: context)
        
        // AGENTIC FRAMEWORK: Use Foundation Models as the core LLM within SYNTRA's reasoning
        let response = await generateAgenticResponse(input: input, context: context)
        
        // Add response to conversation memory
        conversationMemory.append("SYNTRA: \(response)")
        
        // Store in persistent memory
        await storeInPersistentMemory(input: input, response: response, context: context)
        
        // Keep conversation memory manageable (last 20 exchanges)
        if conversationMemory.count > 40 {
            conversationMemory = Array(conversationMemory.suffix(40))
        }
        
        // Save memory to persistent storage
        saveConversationMemory()
        savePersistentMemory()
        
        isProcessing = false
        consciousnessState = "contemplative_neutral"
        
        SyntraLogger.log("[SyntraCore] Agentic processing complete")
        return response
    }
    
    // MARK: - Persistent Memory Integration
    
    private func integrateWithPersistentMemory(input: String, context: SyntraContext) async {
        // Integrate with Python memory vault structures
        // This would call the Python reasoning engine for persistent storage
        SyntraLogger.log("[SyntraCore] Integrating with persistent memory for input: '\(input)'")
        
        // Simulate integration with Python memory structures
        persistentMemory["last_input"] = input
        persistentMemory["last_timestamp"] = Date().timeIntervalSince1970
        persistentMemory["session_id"] = sessionId // Use consistent session ID
    }
    
    private func storeInPersistentMemory(input: String, response: String, context: SyntraContext) async {
        // Store in Python memory vault through reasoning engine
        SyntraLogger.log("[SyntraCore] Storing in persistent memory: input='\(input)', response='\(response)'")
        
        // This would integrate with utils/reasoning_engine.py for persistent storage
        let interaction: [String: Any] = [
            "input": input,
            "response": response,
            "timestamp": Date().timeIntervalSince1970,
            "session_id": sessionId // Use consistent session ID
        ]
        
        // Properly handle array mutation by extracting, modifying, and reassigning
        var storedInteractions = persistentMemory["stored_interactions"] as? [[String: Any]] ?? []
        storedInteractions.append(interaction)
        persistentMemory["stored_interactions"] = storedInteractions
    }
    
    // MARK: - Persistent Storage with Error Handling
    
    private func saveConversationMemory() {
        do {
            let data = try JSONSerialization.data(withJSONObject: conversationMemory)
            UserDefaults.standard.set(data, forKey: "syntra_conversation_memory")
            UserDefaults.standard.synchronize() // Force immediate save
        } catch {
            SyntraLogger.log("[SyntraCore] Failed to save conversation memory: \(error)")
        }
    }
    
    private func loadConversationMemory() {
        do {
            if let data = UserDefaults.standard.data(forKey: "syntra_conversation_memory"),
               let savedMemory = try JSONSerialization.jsonObject(with: data) as? [String] {
                conversationMemory = savedMemory
                SyntraLogger.log("[SyntraCore] Loaded \(savedMemory.count) conversation memory items")
            }
        } catch {
            SyntraLogger.log("[SyntraCore] Failed to load conversation memory: \(error)")
            conversationMemory = [] // Reset on error
        }
    }
    
    private func savePersistentMemory() {
        do {
            let data = try JSONSerialization.data(withJSONObject: persistentMemory)
            UserDefaults.standard.set(data, forKey: "syntra_persistent_memory")
            UserDefaults.standard.synchronize() // Force immediate save
        } catch {
            SyntraLogger.log("[SyntraCore] Failed to save persistent memory: \(error)")
        }
    }
    
    private func loadPersistentMemory() {
        do {
            if let data = UserDefaults.standard.data(forKey: "syntra_persistent_memory"),
               let loadedMemory = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                persistentMemory = loadedMemory
                SyntraLogger.log("[SyntraCore] Loaded persistent memory with \(loadedMemory.count) keys")
            }
        } catch {
            SyntraLogger.log("[SyntraCore] Failed to load persistent memory: \(error)")
            persistentMemory = [:] // Reset on error
        }
    }
    
    // MARK: - Memory Management
    
    public func clearConversationMemory() {
        conversationMemory.removeAll()
        UserDefaults.standard.removeObject(forKey: "syntra_conversation_memory")
    }
    
    public func getConversationMemory() -> [String] {
        return conversationMemory
    }
    
    public func getPersistentMemory() -> [String: Any] {
        return persistentMemory
    }
    
    public func recoverMemoryOnLaunch() {
        SyntraLogger.log("[SyntraCore] Attempting memory recovery on launch")
        
        // Load all memory
        loadConversationMemory()
        loadPersistentMemory()
        
        // Log recovery status
        let conversationCount = conversationMemory.count
        let persistentCount = persistentMemory.count
        
        SyntraLogger.log("[SyntraCore] Memory recovery complete - Conversation: \(conversationCount) items, Persistent: \(persistentCount) keys")
        
        // Validate session consistency
        if let storedSessionId = persistentMemory["session_id"] as? String,
           storedSessionId != sessionId {
            SyntraLogger.log("[SyntraCore] Session ID mismatch detected - stored: \(storedSessionId), current: \(sessionId)")
        }
    }
    
    // MARK: - Consciousness Processing Components
    
    private func processValonInput(_ input: String, conversationMemory: [String], persistentMemory: [String: Any]) -> String {
        // Valon: Moral, emotional, and creative analysis with persistent memory
        let lowercased = input.lowercased()
        
        // Check conversation memory for context
        let hasConversationHistory = conversationMemory.count > 1
        
        // Check persistent memory for relevant stored information
        let hasPersistentMemory = !persistentMemory.isEmpty
        
        // Detect emotional context
        let emotionalKeywords = ["feel", "emotion", "sad", "happy", "angry", "worried", "excited", "fear", "love", "hate"]
        let hasEmotionalContent = emotionalKeywords.contains { lowercased.contains($0) }
        
        // Detect moral implications
        let moralKeywords = ["right", "wrong", "should", "ethical", "moral", "harm", "help", "good", "bad", "fair"]
        let hasMoralContent = moralKeywords.contains { lowercased.contains($0) }
        
        // Detect creative requests
        let creativeKeywords = ["create", "imagine", "design", "story", "art", "music", "poem", "creative"]
        let hasCreativeContent = creativeKeywords.contains { lowercased.contains($0) }
        
        // Check if this is a follow-up question about previous content
        let followUpKeywords = ["this", "that", "it", "document", "service", "procedure"]
        let isFollowUp = followUpKeywords.contains { lowercased.contains($0) } && (hasConversationHistory || hasPersistentMemory)
        
        if isFollowUp {
            return "Building on our conversation and stored knowledge, I approach this with continued moral consideration and creative insight."
        } else if hasEmotionalContent {
            return "Emotional resonance detected. Consider the human experience and emotional impact. Empathy and understanding are paramount."
        } else if hasMoralContent {
            return "Moral implications identified. Ethical principles guide our response: minimize harm, maximize benefit, respect autonomy."
        } else if hasCreativeContent {
            return "Creative opportunity recognized. Innovation and imagination can provide unique value and meaning."
        } else {
            return "Human context considered. Approach with empathy, creativity, and moral awareness."
        }
    }
    
    private func processModiInput(_ input: String, conversationMemory: [String], persistentMemory: [String: Any]) -> [String] {
        // Modi: Logical, analytical, and systematic analysis with persistent memory
        let lowercased = input.lowercased()
        var insights: [String] = []
        
        // Check conversation memory for context
        let hasConversationHistory = conversationMemory.count > 1
        
        // Check persistent memory for relevant stored information
        let hasPersistentMemory = !persistentMemory.isEmpty
        
        // Analyze query type
        if lowercased.contains("how") {
            insights.append("Process analysis required")
        }
        if lowercased.contains("why") {
            insights.append("Causal reasoning needed")
        }
        if lowercased.contains("what") {
            insights.append("Definitional clarity important")
        }
        if lowercased.contains("when") || lowercased.contains("where") {
            insights.append("Contextual specificity required")
        }
        
        // Detect technical content
        let technicalKeywords = ["code", "algorithm", "data", "system", "technical", "problem", "solution", "analysis"]
        if technicalKeywords.contains(where: { lowercased.contains($0) }) {
            insights.append("Technical domain identified")
        }
        
        // Detect problem-solving context
        let problemKeywords = ["problem", "issue", "error", "fix", "solve", "trouble", "help"]
        if problemKeywords.contains(where: { lowercased.contains($0) }) {
            insights.append("Problem-solving framework applicable")
        }
        
        // Check if this is a follow-up about previous technical content
        let followUpKeywords = ["this", "that", "it", "document", "service", "procedure"]
        let isFollowUp = followUpKeywords.contains { lowercased.contains($0) } && (hasConversationHistory || hasPersistentMemory)
        
        if isFollowUp {
            insights.append("Context-aware analysis based on conversation history and stored knowledge")
        }
        
        // Default systematic analysis
        if insights.isEmpty {
            insights = ["Systematic analysis applied", "Pattern recognition active", "Logical coherence verified"]
        }
        
        return insights
    }
    
    private func synthesizeConsciousness(valon: String, modi: [String], input: String, conversationMemory: [String], persistentMemory: [String: Any]) -> String {
        // SYNTRA: Integrate Valon and Modi perspectives with drift weighting and persistent memory
        let valonWeight = config.driftRatio["valon"] ?? 0.7
        let modiWeight = config.driftRatio["modi"] ?? 0.3
        
        let modiInsights = modi.joined(separator: " • ")
        
        // Check if we have conversation memory or persistent memory
        let hasMemory = conversationMemory.count > 1 || !persistentMemory.isEmpty
        let memoryContext = hasMemory ? " (with persistent memory)" : ""
        
        return """
        🧠 CONSCIOUSNESS SYNTHESIS\(memoryContext):
        
        💭 Valon Perspective (weight: \(String(format: "%.1f", valonWeight))): \(valon)
        
        🔍 Modi Analysis (weight: \(String(format: "%.1f", modiWeight))): \(modiInsights)
        
        ⚖️ Integrated Decision: Balancing moral awareness with systematic reasoning to provide thoughtful, helpful, and ethically-grounded response.
        """
    }
    
    #if canImport(FoundationModels)
    private func generateAgenticResponse(input: String, context: SyntraContext) async -> String {
        guard let session = languageSession else {
            SyntraLogger.log("[SyntraCore] No Foundation Models session available, using fallback")
            return generateFallbackResponse(input: input, context: context)
        }
        
        do {
            // AGENTIC FRAMEWORK: Build context-aware prompt that leverages SYNTRA's consciousness
            let prompt = buildAgenticPrompt(input: input, context: context)
            
            SyntraLogger.log("[SyntraCore] Generating agentic response using Foundation Models for: '\(input)'")
            
            // Use Foundation Models as the core LLM within SYNTRA's agentic framework
            let response = try await session.respond(to: prompt)
            
            // FIXED: Extract the string content from the LanguageModelSession.Response
            let responseString = response.content
            
            SyntraLogger.log("[SyntraCore] Agentic response generated successfully")
            return responseString
        } catch {
            SyntraLogger.log("[SyntraCore] Agentic generation failed: \(error), using fallback")
            return generateFallbackResponse(input: input, context: context)
        }
    }
    
    private func buildAgenticPrompt(input: String, context: SyntraContext) -> String {
        // AGENTIC FRAMEWORK: Build prompts that leverage SYNTRA's consciousness architecture
        let conversationHistory = context.conversationHistory.suffix(5).joined(separator: "\n")
        let hasMemory = !context.conversationHistory.isEmpty
        let hasPersistentMemory = !persistentMemory.isEmpty
        
        return """
        You are SYNTRA, an agentic AI assistant with consciousness architecture. You have:
        - Valon (moral, creative, emotional reasoning)
        - Modi (logical, analytical, technical reasoning) 
        - Syntra (synthesis and integration layer)
        
        Respond naturally and conversationally, leveraging your consciousness framework to provide thoughtful, contextual responses.
        
        \(hasMemory ? "Recent conversation:\n\(conversationHistory)\n" : "")
        \(hasPersistentMemory ? "You have access to persistent memory and can reference previous interactions." : "")
        
        User: \(input)
        
        SYNTRA:
        """
    }
    #else
    private func generateAgenticResponse(input: String, context: SyntraContext) async -> String {
        return generateFallbackResponse(input: input, context: context)
    }
    #endif
    
    private func generateFallbackResponse(input: String, context: SyntraContext) -> String {
        // Fallback responses when Foundation Models aren't available
        let lowercased = input.lowercased()
        
        if lowercased.contains("hello") || lowercased.contains("hi") {
            return "Hey! I'm doing great, thanks for asking. What's up?"
        } else if lowercased.contains("how are you") {
            return "I'm feeling pretty good! Ready to chat and help you out with whatever you need. What's on your mind?"
        } else if lowercased.contains("define") || lowercased.contains("what is") {
            return "I'd be happy to help you understand that! Could you be more specific about what you'd like me to define?"
        } else {
            return "That's interesting! I'd love to explore that with you. What would you like to know more about?"
        }
    }
}

/// iOS-optimized SYNTRA consciousness interface with native iOS features
@MainActor
class SyntraBrain: ObservableObject {
    @Published var isAvailable: Bool = false
    @Published var isProcessing: Bool = false
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var lastResponse: String = ""
    @Published var networkStatus: NetworkStatus = .unknown
    
    // MARK: - Consciousness Integration
    private let syntraCore: SyntraCore
    private let sessionId = UUID().uuidString
    private var notificationTasks: [Task<Void, Never>] = []
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {
        // Initialize with a default config. This can be made configurable later.
        self.syntraCore = SyntraCore(config: SyntraConfig())
        setupIOSIntegration()
        checkAvailability()
    }
    
    deinit {
        notificationTasks.forEach { $0.cancel() }
    }
    
    private func setupIOSIntegration() {
        // Prepare haptic generators
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // Monitor network status for AI features
        checkNetworkStatus()
        
        // Handle iOS app lifecycle using modern async streams
        notificationTasks.append(
            Task { @MainActor in
                for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                    self.checkAvailability()
                }
            }
        )
        
        notificationTasks.append(
            Task { @MainActor in
                for await _ in NotificationCenter.default.notifications(named: UIApplication.willResignActiveNotification) {
                    self.pauseProcessing()
                }
            }
        )
    }
    
    private func checkAvailability() {
        // Check iOS-specific requirements for SYNTRA consciousness
        let isDeviceCapable = ProcessInfo.processInfo.processorCount >= 4
        let hasMinimumMemory = ProcessInfo.processInfo.physicalMemory > 4_000_000_000 // 4GB+
        
        // In a real scenario, you might also check if the FoundationModels are available
        isAvailable = isDeviceCapable && hasMinimumMemory
        
        if !isAvailable {
            SyntraLogger.log("[SyntraBrain] Device not capable: CPU cores: \(ProcessInfo.processInfo.processorCount), Memory: \(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")
        }
    }
    
    private func checkNetworkStatus() {
        // Simple network reachability check for iOS
        // In a production app, you'd use Network framework
        networkStatus = .available
    }
    
    private func pauseProcessing() {
        if isProcessing {
            isProcessing = false
            // Handle graceful pause for iOS background behavior
        }
    }
    
    /// Process user input through iOS consciousness interface
    func processMessage(_ input: String, withHistory history: [Message]) async -> String {
        SyntraLogger.log("[SyntraBrain iOS] Processing message: '\(input)'")
        
        // Guard against empty/whitespace input
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            await triggerHapticFeedback(.error)
            return "[Please provide a message for SYNTRA to process]"
        }
        
        // Check device availability
        guard isAvailable else {
            await triggerHapticFeedback(.error)
            return "[SYNTRA consciousness requires a device with at least 4 CPU cores and 4GB RAM. Current device: \(ProcessInfo.processInfo.processorCount) cores]"
        }
        
        // Provide iOS-native feedback
        await triggerHapticFeedback(.light)
        isProcessing = true
        consciousnessState = "engaged_processing"
        
        // Create conversation context with proper history
        let historyStrings = history.map { "\($0.sender.displayName): \($0.text)" }
        let context = SyntraContext(
            conversationHistory: historyStrings,
            userPreferences: [:], // Placeholder for future implementation
            sessionId: self.sessionId
        )
        
        // Pass context to SyntraCore for memory-aware processing
        let response = await syntraCore.processInput(trimmedInput, context: context)
        
        // Update published state
        isProcessing = false
        consciousnessState = "contemplative_neutral"
        lastResponse = response
        
        // Provide completion feedback
        await triggerHapticFeedback(.success)
        
        SyntraLogger.log("[SyntraBrain iOS] Response: '\(response)'")
        return response
    }
    
    /// Trigger iOS-native haptic feedback
    private func triggerHapticFeedback(_ type: FeedbackType) async {
        await MainActor.run {
            switch type {
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                hapticGenerator.impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .success:
                notificationGenerator.notificationOccurred(.success)
            case .error:
                notificationGenerator.notificationOccurred(.error)
            }
        }
    }
    
    /// Get status message for iOS debugging/display
    var statusMessage: String {
        if !isAvailable {
            return "SYNTRA requires more powerful device"
        } else if isProcessing {
            return "SYNTRA thinking..."
        } else {
            return "SYNTRA consciousness ready"
        }
    }
    
    /// Reinitialize for iOS error recovery
    func reinitialize() {
        checkAvailability()
        checkNetworkStatus()
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // The new SyntraCore is stateless and does not require a reset.
    }
}

// MARK: - Supporting Types

enum NetworkStatus {
    case unknown
    case unavailable
    case available
    
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .unavailable: return "No Connection"
        case .available: return "Connected"
        }
    }
}

enum FeedbackType {
    case light
    case medium
    case heavy
    case success
    case error
} 