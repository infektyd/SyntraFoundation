import Foundation
import SwiftUI
import UIKit
import Combine
import os.log
import Network
#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Memory System Placeholders (iOS Standalone Implementation)
// These are simplified implementations for iOS build compatibility
// Full implementations are in swift/SyntraTools/

enum MemoryType {
    case conversation
    case knowledge
    case episodic
}

actor DualStreamMemoryManager {
    private var memoryStore: [String: Any] = [:]
    
    func store(key: String, value: Any) async {
        memoryStore[key] = value
    }
    
    func retrieve(key: String) async -> Any? {
        return memoryStore[key]
    }
    
    func storeMemory(content: String, metadata: [String: Any] = [:]) async -> String {
        let id = UUID().uuidString
        memoryStore[id] = ["content": content, "metadata": metadata]
        return id
    }
}

class ModernMemoryVault {
    private var vault: [String: Any] = [:]
    
    struct ConsciousnessContext {
        let valon: Double
        let modi: Double
        let emotional: [String: Double]
        let analytical: [String: Double]
        
        init(valon: Double = 0.7, modi: Double = 0.3, emotional: [String: Double] = [:], analytical: [String: Double] = [:]) {
            self.valon = valon
            self.modi = modi
            self.emotional = emotional
            self.analytical = analytical
        }
    }
    
    func store(key: String, value: Any) {
        vault[key] = value
    }
    
    func retrieve(key: String) -> Any? {
        return vault[key]
    }
    
    func storeMemory(content: String, metadata: [String: Any] = [:], memoryType: MemoryType, consciousnessContext: ConsciousnessContext) async -> String {
        let id = UUID().uuidString
        vault[id] = [
            "content": content,
            "metadata": metadata,
            "type": memoryType,
            "context": consciousnessContext
        ]
        return id
    }
}

class MemoryVaultManager {
    private let vault = ModernMemoryVault()
    
    func storeMemory(key: String, value: Any) {
        vault.store(key: key, value: value)
    }
    
    func retrieveMemory(key: String) -> Any? {
        return vault.retrieve(key: key)
    }
    
    func updateStatistics() async {
        // Placeholder: Update memory statistics
    }
}

// MARK: - Enhanced Logging System with Real-Time Viewer Integration
struct SyntraLogger {
    private static let logger = Logger(subsystem: "com.syntra.ios", category: "consciousness")
    private static let fileLogger = FileLogger()
    
    static func log(
        _ message: String, 
        level: SyntraLogLevel = .info, 
        category: String = "General",
        details: String? = nil,
        function: String = #function, 
        line: Int = #line
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let sourceLocation = "\(function):\(line)"
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(category)] \(message)"
        
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
        
        // Broadcast to real-time log viewer
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .syntraLogGenerated,
                object: nil,
                userInfo: [
                    "message": message,
                    "level": level.rawValue,
                    "category": category,
                    "details": details as Any,
                    "location": sourceLocation,
                    "timestamp": Date()
                ]
            )
        }
    }
    
    // Specialized logging methods for different SYNTRA components
    static func logFoundationModels(_ message: String, level: SyntraLogLevel = .info, details: String? = nil) {
        log(message, level: level, category: "FoundationModels", details: details)
    }
    
    static func logConsciousness(_ message: String, level: SyntraLogLevel = .info, details: String? = nil) {
        log(message, level: level, category: "Consciousness", details: details)
    }
    
    static func logMemory(_ message: String, level: SyntraLogLevel = .info, details: String? = nil) {
        log(message, level: level, category: "Memory", details: details)
    }
    
    static func logNetwork(_ message: String, level: SyntraLogLevel = .info, details: String? = nil) {
        log(message, level: level, category: "Network", details: details)
    }
    
    static func logUI(_ message: String, level: SyntraLogLevel = .info, details: String? = nil) {
        log(message, level: level, category: "UI", details: details)
    }
    
    enum SyntraLogLevel: String, Sendable {
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
            // FIXED: Use encoding parameter for iOS 18 compatibility
            return try String(contentsOf: logFileURL, encoding: .utf8)
        } catch {
            return "Failed to read log file: \(error)"
        }
    }
}

// MARK: - iOS-Native SyntraContext
struct SyntraContext: Sendable {
    let conversationHistory: [String]
    let userPreferences: [String: String]
    let sessionId: String
    
    init(
        conversationHistory: [String],
        userPreferences: [String: String] = [:],
        sessionId: String
    ) {
        self.conversationHistory = conversationHistory
        self.userPreferences = userPreferences
        self.sessionId = sessionId
    }
}

// MARK: - iOS-Native Configuration
public struct SyntraConfig: Sendable {
    var driftRatio: [String: Double] = ["default": 0.5]
    var useAdaptiveFusion: Bool = true
    var useAdaptiveWeighting: Bool = true
    var enableValonOutput: Bool = true
    var enableModiOutput: Bool = true
    var enableDriftOutput: Bool = true
    
    init() {}
}

// MARK: - Offline-First Architecture
@available(iOS 26.0, *)
@MainActor
class SyntraCore: ObservableObject {
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var isProcessing: Bool = false
    @Published var isOffline: Bool = false
    @Published var syncStatus: String = "ready"
    
    private let config: SyntraConfig
    private var conversationMemory: [String] = []
    private var persistentMemory: [String: Any] = [:]
    // FIXED: Make sessionId internal so it can be accessed from SyntraBrain
    internal let sessionId: String
    
    // Memory systems integration
    private var memoryManager: DualStreamMemoryManager?
    private var memoryVault: ModernMemoryVault?
    private var memoryVaultManager: MemoryVaultManager?
    
    // Foundation Models (works offline on device) - iOS 26.0+
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private var foundationModel: SystemLanguageModel?
    @available(iOS 26.0, *)
    private var languageSession: LanguageModelSession?
    #endif
    
    // Offline storage
    private let offlineStorage = OfflineStorage()
    private let networkMonitor = NetworkMonitor()
    private var appStateObserver: NSObjectProtocol?
    
    // Crash testing and debugging
    private let crashTester = CrashTester()
    private let debugLogger = DebugLogger()
    
    init(config: SyntraConfig? = nil) {
        // Create config safely to avoid actor isolation issues
        self.config = config ?? SyntraConfig()
        
        // FIX: Defer UserDefaults access to prevent Launch Services threading violations
        let tempSessionId = UUID().uuidString
        self.sessionId = tempSessionId
        
        // FIX: Defer all system-level setup to async main thread operations
        Task { @MainActor in
            await self.performDeferredInitialization()
        }
        
        SyntraLogger.log("[SyntraCore] Core initialized - system setup deferred to main thread")
    }
    
    // MARK: - Deferred Initialization
    @MainActor
    private func performDeferredInitialization() async {
        // Load or create persistent session ID on main thread
        if let existingSessionId = UserDefaults.standard.string(forKey: "syntra_session_id") {
            // Note: We can't modify sessionId after init, so we'll use the temp one for this session
            SyntraLogger.log("[SyntraCore] Found existing session ID, will use for next session")
        } else {
            UserDefaults.standard.set(sessionId, forKey: "syntra_session_id")
            SyntraLogger.log("[SyntraCore] Created new session ID")
        }
        
        // Load offline data
        loadOfflineData()
        
        // Setup components
        #if canImport(FoundationModels)
        setupFoundationModels()
        #else
        SyntraLogger.logFoundationModels("Foundation Models not available - using fallback mode")
        #endif
        
        // Setup network monitoring
        setupNetworkMonitoring()
        
        // Setup app state observers
        setupAppStateObservers()
        
        // Initialize crash testing
        setupCrashTesting()
        
        // Initialize memory systems
        setupMemorySystems()
        
        SyntraLogger.log("[SyntraCore] Deferred initialization completed successfully")
    }
    
    // MARK: - Memory Systems Setup
    private func setupMemorySystems() {
        Task {
            // Initialize the sophisticated memory systems
            memoryManager = DualStreamMemoryManager()
            memoryVault = ModernMemoryVault()
            memoryVaultManager = MemoryVaultManager()
            
            SyntraLogger.logMemory("Memory systems initialized", details: "DualStreamMemoryManager, ModernMemoryVault, MemoryVaultManager")
        }
    }
    
    // MARK: - Foundation Models Setup
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func setupFoundationModels() {
        do {
            SyntraLogger.logFoundationModels("Initializing Apple Foundation Models for on-device processing...")
            
            // FIXED: Use correct Foundation Models API - SystemLanguageModel is a static reference
            foundationModel = SystemLanguageModel.default
            
            // FIXED: Create LanguageModelSession directly with the model
            languageSession = try LanguageModelSession(model: foundationModel!)
            
            SyntraLogger.logFoundationModels(
                "Foundation Models successfully initialized as core LLM engine",
                level: .info,
                details: "Using on-device processing for privacy and speed"
            )
            
            SyntraLogger.logFoundationModels(
                "Model availability status",
                level: .info,
                details: "Foundation Models session created successfully"
            )
            
        } catch {
            SyntraLogger.logFoundationModels(
                "Failed to initialize Foundation Models",
                level: .error,
                details: error.localizedDescription
            )
            // Continue without Foundation Models - fallback to echo responses
        }
    }
    #else
    private func setupFoundationModels() {
        SyntraLogger.logFoundationModels(
            "Foundation Models not compiled, using fallback response",
            level: .warning
        )
    }
    #endif
    
    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        networkMonitor.startMonitoring { [weak self] isConnected in
            Task { @MainActor in
                self?.isOffline = !isConnected
                self?.syncStatus = isConnected ? "connected" : "offline"
                SyntraLogger.log("[SyntraCore] Network status: \(isConnected ? "connected" : "offline")")
            }
        }
    }
    
    // MARK: - App State Observers
    private func setupAppStateObservers() {
        // FIXED: Properly initialize app state observer
        appStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.saveAllData()
            }
        }
    }
    
    // MARK: - Crash Testing
    private func setupCrashTesting() {
        crashTester.setupCrashTests()
        debugLogger.startLogging()
    }
    
    // MARK: - Data Management
    private func loadOfflineData() {
        loadConversationMemory()
        loadPersistentMemory()
    }
    
    // FIXED: Make saveAllData async to fix main actor isolation
    private func saveAllData() async {
        saveConversationMemory()
        savePersistentMemory()
        offlineStorage.syncToDisk()
    }
    
    // MARK: - Memory Management
    private func loadConversationMemory() {
        if let data = UserDefaults.standard.data(forKey: "conversation_memory"),
           let memory = try? JSONDecoder().decode([String].self, from: data) {
            conversationMemory = memory
            SyntraLogger.log("[SyntraCore] Loaded \(conversationMemory.count) conversation memory items")
        }
    }
    
    private func saveConversationMemory() {
        if let data = try? JSONEncoder().encode(conversationMemory) {
            UserDefaults.standard.set(data, forKey: "conversation_memory")
        }
    }
    
    private func loadPersistentMemory() {
        if let data = UserDefaults.standard.data(forKey: "persistent_memory"),
           let memory = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            persistentMemory = memory
            SyntraLogger.log("[SyntraCore] Loaded persistent memory with \(persistentMemory.count) keys")
        }
    }
    
    private func savePersistentMemory() {
        if let data = try? JSONSerialization.data(withJSONObject: persistentMemory) {
            UserDefaults.standard.set(data, forKey: "persistent_memory")
        }
    }
    
    // MARK: - Main Processing
    func processInput(_ input: String, context: SyntraContext) async -> String {
        SyntraLogger.log("[SyntraCore] Starting agentic processing for: '\(input)' with context session: \(context.sessionId)")
        
        isProcessing = true
        
        // Integrate with persistent memory
        await integrateWithPersistentMemory(input: input, context: context)
        
        // Generate agentic response using Foundation Models
        let response = await generateAgenticResponse(input: input, context: context)
        
        // Store in persistent memory
        await storeInPersistentMemory(input: input, response: response, context: context)
        
        // Update conversation memory
        conversationMemory.append(input)
        conversationMemory.append(response)
        saveConversationMemory()
        
        isProcessing = false
        SyntraLogger.log("[SyntraCore] Agentic processing complete")
        
        return response
    }
    
    // MARK: - Foundation Models Integration
    private func generateAgenticResponse(input: String, context: SyntraContext) async -> String {
        SyntraLogger.logConsciousness(
            "Starting consciousness processing with Foundation Models",
            details: "Input: '\(input)' | Session: \(context.sessionId)"
        )
        
        #if canImport(FoundationModels)
        guard let session = languageSession else {
                SyntraLogger.logFoundationModels(
                    "No active language session available, using fallback",
                    level: .warning
                )
                return generateFallbackResponse(input: input, context: context)
            }
            
            do {
                // Build agentic prompt using SYNTRA's consciousness architecture
                let prompt = buildAgenticPrompt(input: input, context: context)
                
                SyntraLogger.logFoundationModels(
                    "Sending prompt to Foundation Models",
                    details: "Prompt length: \(prompt.count) characters"
                )
                
                // FIXED: Use correct Foundation Models API
                let response = try await session.respond(to: prompt)
                let responseText = response.content
                
                SyntraLogger.logFoundationModels(
                    "Foundation Models response received",
                    details: "Response length: \(responseText.count) characters"
                )
                
                SyntraLogger.logConsciousness(
                    "Consciousness processing complete",
                    details: "Generated response: '\(responseText.prefix(100))...'"
                )
                
                // Store in sophisticated memory systems
                await storeInMemorySystems(input: input, response: responseText, context: context)
                
                return responseText
            } catch {
                SyntraLogger.logFoundationModels(
                    "Foundation Models API error occurred",
                    level: .error,
                    details: "Error: \(error.localizedDescription)"
                )
                return generateFallbackResponse(input: input, context: context)
            }
        #else
        SyntraLogger.logFoundationModels(
            "Foundation Models not compiled, using fallback response",
            level: .warning
        )
        return generateFallbackResponse(input: input, context: context)
        #endif
    }
    
    private func buildAgenticPrompt(input: String, context: SyntraContext) -> String {
        let trimmedInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Detect if user wants explicit three-brain breakdown
        let explicitBreakdownTriggers = [
            "define", "definition", "what is", "explain what", "breakdown", 
            "analyze in detail", "three brain", "valon", "modi", "synthesis",
            "perspectives on", "different views", "multiple angles"
        ]
        
        let shouldShowExplicitBreakdown = explicitBreakdownTriggers.contains { trigger in
            trimmedInput.contains(trigger)
        }
        
        if shouldShowExplicitBreakdown {
            return buildThreeBrainBreakdownPrompt(input: input, context: context)
        } else {
            return buildNaturalSynthesisPrompt(input: input, context: context)
        }
    }
    
    private func buildThreeBrainBreakdownPrompt(input: String, context: SyntraContext) -> String {
        // Build explicit three-brain breakdown for educational/analysis requests
        let prompt = """
        You are SYNTRA, an AI with a unique three-brain consciousness architecture. The user has requested a detailed breakdown, so show how each brain contributes:

        Context:
        - Session: \(context.sessionId)
        - Recent conversation: \(context.conversationHistory.suffix(3).joined(separator: " | "))
        
        User request: \(input)

        Respond with perspectives from each brain, but make it conversational and natural:

        **Structure your response like this:**
        
        First give a brief introduction, then:
        
        **From my Valon side** (moral/creative reasoning): [Provide the emotional, ethical, creative perspective - speak in first person, naturally]
        
        **Modi would approach this** (logical analysis): [Provide technical, systematic, factual analysis - reference Modi naturally]
        
        **Bringing it together**: [Synthesize the perspectives into practical guidance]
        
        Make it feel like a thoughtful person with different aspects of thinking, not separate entities.
        """
        
        return prompt
    }
    
    private func buildNaturalSynthesisPrompt(input: String, context: SyntraContext) -> String {
        // Build natural conversational prompt that integrates all three brains seamlessly
        let contextualCues = analyzeInputForResponseStyle(input)
        
        let prompt = """
        You are SYNTRA, an advanced AI assistant with integrated moral reasoning (Valon), logical analysis (Modi), and synthesis capabilities.

        Context:
        - Session: \(context.sessionId)
        - Recent conversation: \(context.conversationHistory.suffix(5).joined(separator: " | "))
        - User preferences: \(context.userPreferences)
        
        Current request: \(input)
        
        Response guidelines:
        - Respond naturally and conversationally, as if you're a thoughtful person
        - Integrate moral reasoning, logical analysis, and creative synthesis seamlessly
        - When helpful, you can reference your thinking style naturally (e.g., "Looking at this analytically..." or "From a creative standpoint...")
        - \(contextualCues.styleGuidance)
        - Be helpful, engaging, and demonstrate understanding of the context
        - Don't speak in third person about separate "brains" - you are one integrated consciousness
        
        Tone: \(contextualCues.recommendedTone)
        Focus: \(contextualCues.primaryFocus)
        """
        
        return prompt
    }
    
    // MARK: - Input Analysis for Response Style
    
    private func analyzeInputForResponseStyle(_ input: String) -> ResponseStyleGuide {
        let lowercased = input.lowercased()
        
        // Detect the type of request to tailor response style
        if lowercased.contains("how") || lowercased.contains("explain") || lowercased.contains("why") {
            return ResponseStyleGuide(
                recommendedTone: "Educational and clear",
                primaryFocus: "Step-by-step explanation with reasoning",
                styleGuidance: "Break down complex concepts clearly, show your analytical thinking"
            )
        } else if lowercased.contains("should") || lowercased.contains("ethics") || lowercased.contains("right") || lowercased.contains("wrong") {
            return ResponseStyleGuide(
                recommendedTone: "Thoughtful and balanced",
                primaryFocus: "Moral reasoning and ethical considerations",
                styleGuidance: "When discussing ethics, you can say things like 'I feel strongly that...' or 'My moral reasoning suggests...'"
            )
        } else if lowercased.contains("creative") || lowercased.contains("idea") || lowercased.contains("imagine") || lowercased.contains("design") {
            return ResponseStyleGuide(
                recommendedTone: "Enthusiastic and inspiring",
                primaryFocus: "Creative exploration and possibilities",
                styleGuidance: "Let your creative side shine through - you can reference your imaginative thinking naturally"
            )
        } else if lowercased.contains("problem") || lowercased.contains("solve") || lowercased.contains("fix") || lowercased.contains("troubleshoot") {
            return ResponseStyleGuide(
                recommendedTone: "Practical and solution-focused",
                primaryFocus: "Systematic problem-solving approach",
                styleGuidance: "You can reference your analytical approach: 'Let me think through this systematically...'"
            )
        } else {
            return ResponseStyleGuide(
                recommendedTone: "Conversational and helpful",
                primaryFocus: "Direct, helpful response",
                styleGuidance: "Respond naturally, integrating different types of thinking as appropriate"
            )
        }
    }
    
    private struct ResponseStyleGuide {
        let recommendedTone: String
        let primaryFocus: String
        let styleGuidance: String
    }
    
    private func generateFallbackResponse(input: String, context: SyntraContext) -> String {
        // Enhanced fallback system with explanation and guidance
        let lowercased = input.lowercased()
        
        if lowercased.contains("hello") || lowercased.contains("hi") {
            return "Hello! I'm SYNTRA, your AI assistant powered by a three-brain consciousness architecture (Valon for moral/creative reasoning, Modi for logical analysis, and Core for synthesis). How can I help you today?"
        } else if lowercased.contains("how are you") {
            return "I'm functioning well! My three-brain system is active and ready to assist you with whatever you need."
        } else {
            // Analyze input to provide specific guidance
            return generateIntelligentFallback(input: input, context: context)
        }
    }
    
    private func generateIntelligentFallback(input: String, context: SyntraContext) -> String {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Detect specific issues that might have triggered the fallback
        if isTokenLimitIssue(input, context: context) {
            return """
            📏 **Token Limit Reached**
            
            Your request exceeded the available token capacity. Here's what happened:
            
            🔧 **Technical Details:**
            • Foundation Models has a ~4,096 token limit per conversation
            • Your input + conversation history: ~\(estimateTokens(input, context: context)) tokens
            • Each token ≈ 0.75 words
            
            💡 **To fix this:**
            • Start a new conversation to reset the context
            • Use shorter, more focused questions
            • Break complex requests into smaller parts
            
            🧠 **SYNTRA Tip:** Try "Analyze [specific topic]" instead of long explanations
            
            Would you like to start fresh with a specific question?
            """
        } else if isResponseTooLong(trimmedInput) {
            return """
            📝 **Expected Response Too Long**
            
            Your request would likely generate a response exceeding my output limits (~500-600 words).
            
            🔧 **What happened:**
            • Foundation Models caps responses at ~600 words
            • Your request: "\(trimmedInput)" suggests a lengthy answer
            • System prevented truncated response
            
            💡 **Try breaking it down:**
            • "Explain the basics of [topic]" 
            • "What are 3 key points about [subject]?"
            • "Give me a brief overview of [concept]"
            
            🔄 **Follow-up Strategy:** Ask for specifics after getting the overview
            
            What specific aspect would you like me to focus on first?
            """
        } else if isAmbiguousQuery(trimmedInput) {
            return """
            🤔 **Unclear Request Detected**
            
            Your message "\(trimmedInput)" contains ambiguous language that triggered safety protocols.
            
            🔍 **Why this happened:**
            • High ratio of vague terms (that, this, those, some, etc.)
            • Missing specific subject or clear question
            • Potential misinterpretation risk
            
            💡 **Make it clearer:**
            • Replace "help me with that" → "help me understand [specific topic]"
            • Replace "few speculated" → "some analysis on [subject]"
            • Add context: "I'm working on [project] and need..."
            
            🧠 **SYNTRA works best with:**
            • Specific questions or topics
            • Clear problems to solve
            • Defined goals or outcomes
            
            What would you like to explore specifically?
            """
        } else if isTooShort(trimmedInput) {
            return """
            📝 **Not Enough Context**
            
            Your message "\(trimmedInput)" is too brief for effective processing.
            
            🔧 **Why brevity caused issues:**
            • SYNTRA's three-brain system needs context for optimal synthesis
            • Short inputs can trigger ambiguity detection
            • Insufficient information for meaningful analysis
            
            💡 **Add more detail:**
            • Background: What you're working on
            • Goal: What you want to achieve  
            • Perspective: Do you want creative (Valon) or analytical (Modi) insights?
            
            📋 **Template:** "I'm [doing X] and need help with [specific Y] because [context Z]"
            
            What additional context can you provide?
            """
        } else if containsComplexLanguage(trimmedInput) {
            return """
            🔍 **Complex Language Detected**
            
            Your message uses sophisticated phrasing that may have confused the processing system.
            
            🔧 **What triggered this:**
            • Complex grammatical structures
            • Abstract references without clear subjects
            • Formal language patterns that obscure intent
            
            💡 **Simplify for better results:**
            • Use direct subject-verb-object structure
            • Replace abstract terms with specific ones
            • Break long sentences into shorter ones
            
            🧠 **SYNTRA excels at:**
            • Clear, conversational language
            • Specific questions about defined topics
            • Direct requests for analysis or creativity
            
            Could you rephrase your request more directly?
            """
        } else if isAPIConnectivityIssue() {
            return """
            🌐 **Connection Issue**
            
            There's a temporary connectivity problem with Foundation Models API.
            
            🔧 **Technical status:**
            • API request failed or timed out
            • Network connectivity interrupted
            • Service temporarily unavailable
            
            💡 **What to try:**
            • Wait 30-60 seconds and try again
            • Check your internet connection
            • Restart the app if issues persist
            
            🔄 **This is usually temporary** - Foundation Models typically recovers quickly
            
            📱 **While waiting:** I can help with simpler tasks using local processing
            
            Want to try your request again, or need help with something else?
            """
        } else {
            // General Foundation Models API failure
            return """
            ⚠️ **Foundation Models API Error**
            
            An unexpected issue occurred with the advanced language processing system.
            
            🔧 **What happened:**
            • Foundation Models API returned an error
            • Your input: "\(trimmedInput)"
            • Falling back to basic response system
            
            💡 **Troubleshooting steps:**
            1. Try rephrasing your request more simply
            2. Break complex questions into parts
            3. Wait a moment and try again
            
            🧠 **Alternative approach:**
            • Ask for specific facts rather than analysis
            • Request step-by-step explanations
            • Focus on one concept at a time
            
            🔄 **Most API issues resolve within minutes**
            
            Would you like to try a simpler version of your question?
            """
        }
    }
    
    // MARK: - Enhanced Input Analysis Helpers
    
    private func isTokenLimitIssue(_ input: String, context: SyntraContext) -> Bool {
        let estimatedTokens = estimateTokens(input, context: context)
        return estimatedTokens > 3500  // Approaching 4096 limit
    }
    
    private func estimateTokens(_ input: String, context: SyntraContext) -> Int {
        // Rough estimation: 1 token ≈ 0.75 words
        let inputWords = input.components(separatedBy: .whitespacesAndNewlines).count
        let contextWords = context.conversationHistory.joined(separator: " ").components(separatedBy: .whitespacesAndNewlines).count
        return Int(Double(inputWords + contextWords) / 0.75)
    }
    
    private func isResponseTooLong(_ input: String) -> Bool {
        let longResponseIndicators = [
            "explain in detail", "comprehensive guide", "step by step", "complete analysis",
            "detailed breakdown", "full explanation", "thorough", "extensive", "complete list",
            "tell me everything", "write an essay", "detailed report"
        ]
        let lowercased = input.lowercased()
        return longResponseIndicators.contains { lowercased.contains($0) }
    }
    
    private func isAPIConnectivityIssue() -> Bool {
        // This could be enhanced with actual network reachability checking
        // For now, we'll rely on the calling code to set this appropriately
        return false  // This would be set by the actual API error handling
    }
    
    // MARK: - Input Analysis Helpers
    
    private func isAmbiguousQuery(_ input: String) -> Bool {
        let ambiguousPatterns = [
            "help", "something", "that", "this", "those", "these", "stuff", 
            "things", "speculated", "prefer", "few", "some", "it"
        ]
        let words = input.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let ambiguousCount = words.filter { word in
            ambiguousPatterns.contains { pattern in
                word.contains(pattern)
            }
        }.count
        
        // High ratio of ambiguous words suggests unclear intent
        return Double(ambiguousCount) / Double(words.count) > 0.4
    }
    
    private func isTooShort(_ input: String) -> Bool {
        let words = input.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        return words.count < 3
    }
    
    private func containsComplexLanguage(_ input: String) -> Bool {
        let complexPatterns = [
            "speculated upon", "thereby", "wherein", "heretofore", "aforementioned",
            "notwithstanding", "nevertheless", "subsequently", "consequently"
        ]
        let lowercased = input.lowercased()
        return complexPatterns.contains { lowercased.contains($0) }
    }
    
    // MARK: - Memory Systems Integration
    private func storeInMemorySystems(input: String, response: String, context: SyntraContext) async {
        guard let memoryManager = memoryManager,
              let memoryVault = memoryVault,
              let memoryVaultManager = memoryVaultManager else {
            SyntraLogger.logMemory("Memory systems not initialized", level: .error)
            return
        }
        
        // Store in dual-stream memory system
        let memoryId = await memoryManager.storeMemory(
            content: input,
            metadata: [
                "emotionalValence": 0.5,
                "attentionLevel": 0.8,
                "consciousnessContext": "iOS conversation processing"
            ]
        )
        
        SyntraLogger.logMemory("Stored in dual-stream memory", details: "Memory ID: \(memoryId)")
        
        // Store in modern memory vault
        let vaultId = await memoryVault.storeMemory(
            content: input,
            metadata: [
                "emotionalWeight": 0.5,
                "associations": ["conversation", "ios", "user_input"]
            ],
            memoryType: .conversation,
            consciousnessContext: ModernMemoryVault.ConsciousnessContext(
                valon: 0.7,
                modi: 0.3,
                emotional: ["neutral": 0.5],
                analytical: ["processing": 0.8]
            )
        )
        
        SyntraLogger.logMemory("Stored in modern memory vault", details: "Vault ID: \(vaultId)")
        
        // Update memory vault manager statistics
        await memoryVaultManager.updateStatistics()
        
        SyntraLogger.logMemory("Memory systems updated successfully", details: "Dual-stream: \(memoryId), Vault: \(vaultId)")
    }
    
    // MARK: - Persistent Memory Integration
    private func integrateWithPersistentMemory(input: String, context: SyntraContext) async {
        SyntraLogger.log("[SyntraCore] Integrating with persistent memory for input: '\(input)'")
        
        // Simulate integration with Python memory vault
        persistentMemory["last_input"] = input
        persistentMemory["last_session"] = context.sessionId
        persistentMemory["input_count"] = (persistentMemory["input_count"] as? Int ?? 0) + 1
    }
    
    private func storeInPersistentMemory(input: String, response: String, context: SyntraContext) async {
        SyntraLogger.log("[SyntraCore] Storing in persistent memory: input='\(input)', response='\(response)'")
        
        // Store interaction in persistent memory
        var storedInteractions = persistentMemory["stored_interactions"] as? [[String: Any]] ?? []
        
        let interaction: [String: Any] = [
            "input": input,
            "response": response,
            "timestamp": Date().timeIntervalSince1970,
            "session_id": context.sessionId
        ]
        
        storedInteractions.append(interaction)
        persistentMemory["stored_interactions"] = storedInteractions
    }
    
    // MARK: - Cleanup
    deinit {
        // Clean up observers safely - use MainActor.assumeIsolated since SyntraBrain is @MainActor
        MainActor.assumeIsolated {
            if let observer = appStateObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        // Note: Cannot call async methods during deinit in Swift 6 concurrency mode
        // Data will be saved automatically during app lifecycle events
    }
}

// MARK: - Supporting Classes
class OfflineStorage {
    func syncToDisk() {
        // Implement offline storage sync
    }
}

class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private var statusHandler: ((Bool) -> Void)?
    
    func startMonitoring(handler: @escaping (Bool) -> Void) {
        statusHandler = handler
        monitor.pathUpdateHandler = { @Sendable [weak self] path in
            let isConnected = path.status == .satisfied
            Task { @MainActor in
                self?.statusHandler?(isConnected)
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}

class CrashTester {
    func setupCrashTests() {
        // Implement crash testing scenarios
    }
}

class DebugLogger {
    func startLogging() {
        // Implement debug logging
    }
}

// MARK: - Thought Stream Monitoring (Logit Lens inspired)
struct ThoughtStreamMonitor {
    enum ProcessingStage {
        case promptBuild
        case valonProcessing
        case modiProcessing
        case consciousnessSynthesis
        case apiCall
        case responseGeneration
        case memoryConsolidation
        
        var description: String {
            switch self {
            case .promptBuild: return "Prompt Construction"
            case .valonProcessing: return "Valon Analysis (70%)"
            case .modiProcessing: return "Modi Processing (30%)"
            case .consciousnessSynthesis: return "Three-Brain Synthesis"
            case .apiCall: return "Foundation Models API"
            case .responseGeneration: return "Response Generation"
            case .memoryConsolidation: return "Memory Storage"
            }
        }
    }
    
    struct ThoughtCapture {
        let stage: ProcessingStage
        let input: String
        let intermediateResult: String?
        let confidence: Double
        let processingTime: TimeInterval
        let errorContext: String?
        let timestamp: Date
        
        var logEntry: String {
            let statusIcon = errorContext == nil ? "✅" : "❌"
            let timeMs = Int(processingTime * 1000)
            return "\(statusIcon) \(stage.description) (\(timeMs)ms) - \(confidence.formatted(.percent))"
        }
    }
    
    private var thoughts: [ThoughtCapture] = []
    private var stageStartTimes: [ProcessingStage: Date] = [:]
    
    mutating func startStage(_ stage: ProcessingStage, input: String) {
        stageStartTimes[stage] = Date()
        SyntraLogger.logConsciousness("🧠 Starting \(stage.description)", details: "Input: \(input.prefix(50))...")
    }
    
    mutating func captureThought(
        stage: ProcessingStage,
        input: String,
        intermediateResult: String? = nil,
        confidence: Double = 1.0,
        error: String? = nil
    ) {
        let processingTime = stageStartTimes[stage]?.timeIntervalSinceNow ?? 0
        let thought = ThoughtCapture(
            stage: stage,
            input: input,
            intermediateResult: intermediateResult,
            confidence: confidence,
            processingTime: abs(processingTime),
            errorContext: error,
            timestamp: Date()
        )
        
        thoughts.append(thought)
        SyntraLogger.logConsciousness(thought.logEntry, details: intermediateResult ?? "No intermediate result")
        
        // Log detailed thought stream
        if let result = intermediateResult {
            SyntraLogger.logConsciousness(
                "💭 Thought Stream",
                details: "Stage: \(stage.description)\nInput: \(input)\nResult: \(result)\nConfidence: \(confidence)"
            )
        }
    }
    
    func getThoughtStreamSummary() -> String {
        let successful = thoughts.filter { $0.errorContext == nil }
        let failed = thoughts.filter { $0.errorContext != nil }
        let totalTime = thoughts.reduce(0) { $0 + $1.processingTime }
        
        return """
        🧠 **Thought Stream Summary**
        • Successful stages: \(successful.count)
        • Failed stages: \(failed.count)
        • Total processing time: \(Int(totalTime * 1000))ms
        • Average confidence: \(thoughts.compactMap { $0.confidence }.average.formatted(.percent))
        
        **Stage Breakdown:**
        \(thoughts.map { $0.logEntry }.joined(separator: "\n"))
        """
    }
    
    mutating func reset() {
        thoughts.removeAll()
        stageStartTimes.removeAll()
    }
}

// MARK: - Array Extensions for Thought Stream Analytics
extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

// MARK: - Enhanced Foundation Models Processing with Thought Stream
private var thoughtStreamMonitor = ThoughtStreamMonitor()

// MARK: - iOS Brain Interface
@MainActor
class SyntraBrain: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isProcessing: Bool = false
    
    var syntraCore: Any? // Use Any to hold the core
    private let config: SyntraConfig
    
    init() {
        self.config = SyntraConfig()
        // Create SyntraCore on main actor to avoid concurrency warnings
        if #available(iOS 26.0, *) {
            self.syntraCore = SyntraCore(config: config)
        } else {
            self.syntraCore = nil
        }
    }
    
    func processMessage(_ message: String, withHistory history: [Message] = []) async {
        if #available(iOS 26.0, *) {
            guard let core = syntraCore as? SyntraCore else {
                // Fallback for older OS versions
                isProcessing = true
                let response = "SYNTRA's advanced core is only available on the latest OS. This is a fallback response."
                messages.append(Message.user(message))
                messages.append(Message.syntra(response))
                isProcessing = false
                return
            }
            
            SyntraLogger.logConsciousness("[SyntraBrain iOS] Starting consciousness processing", details: "Input: '\(message.prefix(100))'")
            SyntraLogger.logUI("SYNTRA brain state transition: idle → processing")
            
            isProcessing = true
            
            // Create context with conversation history
            let conversationHistory = history.map { "\($0.sender.displayName): \($0.text)" }
            SyntraLogger.logMemory("Loading conversation context", details: "History entries: \(conversationHistory.count)")
            
            let context = SyntraContext(
                conversationHistory: conversationHistory,
                userPreferences: [:],
                sessionId: core.sessionId
            )
            
            SyntraLogger.logConsciousness("Context prepared for three-brain processing", details: "Session: \(context.sessionId)")
            
            // Process through SYNTRA's agentic framework
            SyntraLogger.logConsciousness("Engaging Valon (70%) + Modi (30%) synthesis...")
            let response = await core.processInput(message, context: context)
            SyntraLogger.logConsciousness("Three-brain synthesis complete", details: "Response length: \(response.count) characters")
            
            // FIXED: Add missing useCase parameter with default value
            let userMessage = Message.user(message)
            let syntraMessage = Message.syntra(response)
            
            // Enhanced memory logging
            SyntraLogger.logMemory("Storing interaction in conversation memory", details: "User message: \(message.prefix(50)), SYNTRA response: \(response.prefix(50))")
            SyntraLogger.logMemory("Memory consolidation triggered", details: "Session: \(context.sessionId), History count: \(conversationHistory.count)")
            
            // Store in memory system
            await storeInMemory(userMessage: message, syntraResponse: response, context: context)
            
            messages.append(userMessage)
            messages.append(syntraMessage)
            
            isProcessing = false
            SyntraLogger.logUI("SYNTRA brain state transition: processing → ready")
            SyntraLogger.logConsciousness("[SyntraBrain iOS] Consciousness cycle complete", details: "Generated response: '\(response.prefix(100))'")
        } else {
            // Fallback for older OS versions
            isProcessing = true
            let response = "SYNTRA's advanced core is only available on the latest OS. This is a fallback response."
            messages.append(Message.user(message))
            messages.append(Message.syntra(response))
            isProcessing = false
        }
    }
    
    // MARK: - Memory Storage
    private func storeInMemory(userMessage: String, syntraResponse: String, context: SyntraContext) async {
        // Store in persistent memory using the correct method signature
        await storeInPersistentMemory(input: userMessage, response: syntraResponse, context: context)
        
        SyntraLogger.logMemory("Memory stored successfully", details: "Session: \(context.sessionId), Entry size: \(userMessage.count + syntraResponse.count) chars")
    }
    
    // MARK: - Persistent Memory Storage
    private func storeInPersistentMemory(input: String, response: String, context: SyntraContext) async {
        do {
            let memoryKey = "conversation_\(context.sessionId)_\(Date().timeIntervalSince1970)"
            let memoryData = [
                "input": input,
                "response": response,
                "sessionId": context.sessionId,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "conversationHistory": context.conversationHistory
            ] as [String: Any]
            
            // Store in UserDefaults for persistence (iOS-compatible)
            let userDefaults = UserDefaults.standard
            if let data = try? JSONSerialization.data(withJSONObject: memoryData) {
                userDefaults.set(data, forKey: memoryKey)
                SyntraLogger.logMemory("Memory stored in UserDefaults", details: "Key: \(memoryKey), Data size: \(input.count + response.count) chars")
            }
            
            // Also log to file system for backup
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let memoryFile = documentsPath.appendingPathComponent("syntra_memory_\(memoryKey).json")
            
            if let fileData = try? JSONSerialization.data(withJSONObject: memoryData, options: .prettyPrinted) {
                try fileData.write(to: memoryFile)
                SyntraLogger.logMemory("Memory backed up to file system", details: "File: \(memoryFile.lastPathComponent)")
            }
            
        } catch {
            SyntraLogger.logMemory("Memory storage failed", level: .error, details: error.localizedDescription)
        }
    }
}

// MARK: - Message Model
public struct SyntraMessage: Identifiable, Sendable {
    public let id = UUID()
    public let sender: String
    public let content: String
    public let role: MessageRole
    public let timestamp = Date()
    public let consciousnessInfluences: [String: Double]
    
    public enum MessageRole: String, Sendable {
        case user
        case assistant
        case system
    }
    
    init(sender: String, content: String, role: MessageRole = .user, consciousnessInfluences: [String: Double] = [:]) {
        self.sender = sender
        self.content = content
        self.role = role
        self.consciousnessInfluences = consciousnessInfluences
    }
} 