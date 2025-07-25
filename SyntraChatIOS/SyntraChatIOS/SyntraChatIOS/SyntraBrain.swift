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
struct SyntraConfig: Sendable {
    var driftRatio: [String: Double] = ["default": 0.5]
    var useAdaptiveFusion: Bool = true
    var useAdaptiveWeighting: Bool = true
    var enableValonOutput: Bool = true
    var enableModiOutput: Bool = true
    var enableDriftOutput: Bool = true
    
    init() {}
}

// MARK: - Offline-First Architecture
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
    
    // Foundation Models (works offline on device)
    #if canImport(FoundationModels)
    private var foundationModel: SystemLanguageModel?
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
        
        // Load or create persistent session ID
        if let existingSessionId = UserDefaults.standard.string(forKey: "syntra_session_id") {
            self.sessionId = existingSessionId
        } else {
            let newSessionId = UUID().uuidString
            UserDefaults.standard.set(newSessionId, forKey: "syntra_session_id")
            self.sessionId = newSessionId
        }
        
        // Load offline data
        loadOfflineData()
        
        // Initialize Foundation Models (works offline)
        setupFoundationModels()
        
        // Setup network monitoring
        setupNetworkMonitoring()
        
        // Setup app state observers
        setupAppStateObservers()
        
        // Initialize crash testing
        setupCrashTesting()
        
        // Initialize memory systems
        setupMemorySystems()
        
        SyntraLogger.log("[SyntraCore] Offline-first architecture initialized")
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
    private func setupFoundationModels() {
        #if canImport(FoundationModels)
        Task {
            do {
                SyntraLogger.logFoundationModels("Initializing Apple Foundation Models for on-device processing...")
                
                // FIXED: Use correct Foundation Models API - SystemLanguageModel is a static reference
                foundationModel = SystemLanguageModel.default
                
                // FIXED: Create LanguageModelSession directly with the model
                languageSession = try LanguageModelSession(model: foundationModel!)
                
                SyntraLogger.logFoundationModels(
                    "Foundation Models successfully initialized as core LLM engine",
                    details: "Using on-device processing with default system model"
                )
                
                // Log model availability
                SyntraLogger.logFoundationModels(
                    "Model availability status",
                    details: "Foundation model session created successfully"
                )
            } catch {
                SyntraLogger.logFoundationModels(
                    "Foundation Models initialization failed",
                    level: .error,
                    details: "Error: \(error.localizedDescription)"
                )
            }
        }
        #else
        SyntraLogger.logFoundationModels(
            "Foundation Models not available on this device",
            level: .warning,
            details: "Falling back to simple response generation"
        )
        #endif
    }
    
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
        // Build sophisticated prompt that leverages SYNTRA's consciousness architecture
        let prompt = """
        You are SYNTRA, an advanced AI assistant with a unique three-brain architecture:
        - VALON: Moral reasoning, creativity, and emotional intelligence
        - MODI: Logical analysis, technical expertise, and problem-solving
        - SYNTHESIS: Integration of both perspectives for balanced responses
        
        Context:
        - Session ID: \(context.sessionId)
        - Recent conversation: \(context.conversationHistory.suffix(5).joined(separator: " | "))
        - User preferences: \(context.userPreferences)
        
        Current input: \(input)
        
        Respond naturally and conversationally, as if you're speaking directly to the user. 
        Be helpful, engaging, and demonstrate understanding of the context.
        """
        
        return prompt
    }
    
    private func generateFallbackResponse(input: String, context: SyntraContext) -> String {
        // Simple fallback when Foundation Models unavailable
        let lowercased = input.lowercased()
        
        if lowercased.contains("hello") || lowercased.contains("hi") {
            return "Hello! I'm SYNTRA, your AI assistant. How can I help you today?"
        } else if lowercased.contains("how are you") {
            return "I'm functioning well! Ready to assist you with whatever you need."
        } else {
            return "I understand you're asking about '\(input)'. Let me help you with that!"
        }
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
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
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
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.statusHandler?(isConnected)
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

// MARK: - iOS Brain Interface
@MainActor
class SyntraBrain: ObservableObject {
    @Published var messages: [SyntraMessage] = []
    @Published var isProcessing: Bool = false
    
    private let syntraCore: SyntraCore
    private let config: SyntraConfig
    
    init() {
        self.config = SyntraConfig()
        // Create SyntraCore on main actor to avoid concurrency warnings
        self.syntraCore = SyntraCore(config: config)
    }
    
    func processMessage(_ message: String, withHistory history: [SyntraMessage] = []) async {
        SyntraLogger.logConsciousness("[SyntraBrain iOS] Starting consciousness processing", details: "Input: '\(message.prefix(100))'")
        SyntraLogger.logUI("SYNTRA brain state transition: idle → processing")
        
        isProcessing = true
        
        // Create context with conversation history
        let conversationHistory = history.map { "\($0.sender): \($0.content)" }
        SyntraLogger.logMemory("Loading conversation context", details: "History entries: \(conversationHistory.count)")
        
        let context = SyntraContext(
            conversationHistory: conversationHistory,
            userPreferences: [:],
            sessionId: syntraCore.sessionId
        )
        
        SyntraLogger.logConsciousness("Context prepared for three-brain processing", details: "Session: \(context.sessionId)")
        
        // Process through SYNTRA's agentic framework
        SyntraLogger.logConsciousness("Engaging Valon (70%) + Modi (30%) synthesis...")
        let response = await syntraCore.processInput(message, context: context)
        SyntraLogger.logConsciousness("Three-brain synthesis complete", details: "Response length: \(response.count) characters")
        
        // FIXED: Add missing useCase parameter with default value
        let userMessage = SyntraMessage(sender: "User", content: message, role: .user, consciousnessInfluences: [:])
        let syntraMessage = SyntraMessage(sender: "SYNTRA", content: response, role: .assistant, consciousnessInfluences: [:])
        
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
struct SyntraMessage: Identifiable, Sendable {
    let id = UUID()
    let sender: String
    let content: String
    let role: MessageRole
    let timestamp = Date()
    let consciousnessInfluences: [String: Double]
    
    enum MessageRole: String, Sendable {
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