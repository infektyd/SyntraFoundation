import Foundation
import SwiftUI
import UIKit
import Combine
import os.log
import Network
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
            // FIXED: Use encoding parameter for iOS 18 compatibility
            return try String(contentsOf: logFileURL, encoding: .utf8)
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
    private let sessionId: String
    
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
        
        SyntraLogger.log("[SyntraCore] Offline-first architecture initialized")
    }
    
    // MARK: - Foundation Models Setup
    private func setupFoundationModels() {
        #if canImport(FoundationModels)
        Task {
            do {
                // Initialize Foundation Models (works offline)
                foundationModel = try await SystemLanguageModel()
                languageSession = try await foundationModel?.createSession()
                
                SyntraLogger.log("[SyntraCore] Foundation Models initialized as core LLM engine")
            } catch {
                SyntraLogger.log("[SyntraCore] Foundation Models initialization failed: \(error)", level: .warning)
            }
        }
        #else
        SyntraLogger.log("[SyntraCore] Foundation Models not available, using fallback")
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
                self?.saveAllData()
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
    
    private func saveAllData() {
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
        SyntraLogger.log("[SyntraCore] Generating agentic response using Foundation Models for: '\(input)'")
        
        #if canImport(FoundationModels)
        guard let session = languageSession else {
            return generateFallbackResponse(input: input, context: context)
        }
        
        do {
            // Build agentic prompt using SYNTRA's consciousness architecture
            let prompt = buildAgenticPrompt(input: input, context: context)
            
            // Generate response using Foundation Models
            let response = try await session.generateResponse(prompt)
            
            // FIXED: Extract text from LanguageModelSession.Response
            let responseText = response.text
            
            SyntraLogger.log("[SyntraCore] Agentic response generated successfully")
            return responseText
        } catch {
            SyntraLogger.log("[SyntraCore] Foundation Models error: \(error)", level: .error)
            return generateFallbackResponse(input: input, context: context)
        }
        #else
        return generateFallbackResponse(input: input, context: context)
        #endif
    }
    
    private func buildAgenticPrompt(input: String, context: SyntraContext) -> String {
        // Build sophisticated prompt that leverages SYNTRA's consciousness architecture
        var prompt = """
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
        saveAllData()
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
        self.syntraCore = SyntraCore(config: config)
    }
    
    func processMessage(_ message: String, withHistory history: [SyntraMessage] = []) async {
        SyntraLogger.log("[SyntraBrain iOS] Processing message: '\(message)'")
        
        isProcessing = true
        
        // Create context with conversation history
        let conversationHistory = history.map { "\($0.sender): \($0.content)" }
        let context = SyntraContext(
            conversationHistory: conversationHistory,
            userPreferences: [:],
            sessionId: syntraCore.sessionId
        )
        
        // Process through SYNTRA's agentic framework
        let response = await syntraCore.processInput(message, context: context)
        
        // Add to messages
        let userMessage = SyntraMessage(sender: "User", content: message, role: .user)
        let syntraMessage = SyntraMessage(sender: "SYNTRA", content: response, role: .assistant)
        
        messages.append(userMessage)
        messages.append(syntraMessage)
        
        isProcessing = false
        SyntraLogger.log("[SyntraBrain iOS] Response: '\(response)'")
    }
}

// MARK: - Message Model
struct SyntraMessage: Identifiable {
    let id = UUID()
    let sender: String
    let content: String
    let role: MessageRole
    let timestamp = Date()
    let consciousnessInfluences: [String: Double] = [:]
    
    enum MessageRole {
        case user
        case assistant
        case system
    }
}

// Extension to access sessionId
extension SyntraCore {
    var sessionId: String { return sessionId }
} 