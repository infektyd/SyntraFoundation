import Foundation

// AGENTS.md: Three-brain architecture preservation
public struct SyntraResponse: Sendable {
    public let content: String
    public let valonInfluence: Double    // 70% default
    public let modiInfluence: Double     // 30% default
    public let driftScore: Double
    public let timestamp: Date
    
    public init(
        content: String,
        valonInfluence: Double,
        modiInfluence: Double,
        driftScore: Double,
        timestamp: Date
    ) {
        self.content = content
        self.valonInfluence = valonInfluence
        self.modiInfluence = modiInfluence
        self.driftScore = driftScore
        self.timestamp = timestamp
    }
}

public struct SyntraMessage: Identifiable, Codable, Sendable {
    public let id: UUID
    public let content: String
    public let role: MessageRole
    public let timestamp: Date
    
    // AGENTS.md: Consciousness tracking - NO STUBS
    public let valonInfluence: Double?
    public let modiInfluence: Double?
    public let driftScore: Double?
    
    public init(
        id: UUID = UUID(),
        content: String,
        role: MessageRole,
        timestamp: Date = Date(),
        valonInfluence: Double? = nil,
        modiInfluence: Double? = nil,
        driftScore: Double? = nil
    ) {
        self.id = id
        self.content = content
        self.role = role
        self.timestamp = timestamp
        self.valonInfluence = valonInfluence
        self.modiInfluence = modiInfluence
        self.driftScore = driftScore
    }
}

public enum MessageRole: String, Codable, CaseIterable, Sendable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .user: return "You"
        case .assistant: return "SYNTRA"
        case .system: return "System"
        }
    }
}

public struct SyntraContext: Sendable {
    public let conversationHistory: [String]
    public let userPreferences: [String: String] // FIXED: Make Sendable
    public let sessionId: String
    
    public init(
        conversationHistory: [String],
        userPreferences: [String: String] = [:], // FIXED: Default to Sendable type
        sessionId: String
    ) {
        self.conversationHistory = conversationHistory
        self.userPreferences = userPreferences
        self.sessionId = sessionId
    }
}

public struct SyntraConfig: Sendable {
    public let driftRatio: [String: Double]
    public let userPreferences: [String: String] // FIXED: Make Sendable
    public let moralCore: MoralFramework  // AGENTS.md: Immutable
    
    public init(
        driftRatio: [String: Double] = ["valon": 0.7, "modi": 0.3],
        userPreferences: [String: String] = [:], // FIXED: Default to Sendable type
        moralCore: MoralFramework = .default
    ) {
        self.driftRatio = driftRatio
        self.userPreferences = userPreferences
        self.moralCore = moralCore
    }
}

// AGENTS.md: Immutable moral framework - NEVER modify
public struct MoralFramework: Sendable {
    public static let `default` = MoralFramework()
    private init() {} // Prevent external modification
} 

public struct SyntraPersistentState: Codable {
    var memorySnapshot: [SyntraMessage]
    var brainState: String // e.g., "idle", "processing", "ready"
    var uiState: String    // e.g., "chat", "settings", "voice"
} 