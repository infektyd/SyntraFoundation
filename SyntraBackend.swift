import Foundation

// MARK: – Backend mode selector
public enum BackendMode: String {
    case real, null
    public static func current() -> BackendMode {
        if let env = ProcessInfo.processInfo.environment["SYNTRA_API_BACKEND"]?.lowercased(),
           env == "null" {
            return .null
        }
        return .real
    }
}

// MARK: – Backend protocol
public protocol SyntraBackend {
    /// Returns a list of model dictionaries (OpenAI‑compatible format).
    func listModels() async throws -> [[String: Any]]
    /// Simple health‑check; returns a short string.
    func ping() async -> String
}

// MARK: – Null (stub) backend
public struct NullSyntraBackend: SyntraBackend {
    public func ping() async -> String { "pong:null" }
    public func listModels() async throws -> [[String: Any]] {
        [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1",   "object": "model", "owned_by": "syntra"]
        ]
    }
}

// MARK: – Real backend (placeholder for future integration)
public struct RealSyntraBackend: SyntraBackend {
    public func ping() async -> String { "pong:real" }   // TODO: wire to BrainEngine/MemoryEngine health
    public func listModels() async throws -> [[String: Any]] {
        // TODO: enumerate from real registry if available
        [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1",   "object": "model", "owned_by": "syntra"]
        ]
    }
}

// MARK: – Factory
public func makeBackend() -> SyntraBackend {
    switch BackendMode.current() {
    case .null: return NullSyntraBackend()
    case .real: return RealSyntraBackend()
    }
}
