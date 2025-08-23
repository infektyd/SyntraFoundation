import Foundation

enum BackendMode: String {
    case real, null
    static func current() -> BackendMode {
        if let env = ProcessInfo.processInfo.environment["SYNTRA_API_BACKEND"]?.lowercased(), env == "null" { return .null }
        return .real
    }
}

protocol SyntraBackend {
    func listModels() async throws -> [[String: Any]]
    func ping() async -> String
}

struct NullSyntraBackend: SyntraBackend {
    func ping() async -> String { "pong:null" }
    func listModels() async throws -> [[String: Any]] {
        return [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1", "object": "model", "owned_by": "syntra"]
        ]
    }
}

struct RealSyntraBackend: SyntraBackend {
    func ping() async -> String { "pong:real" } // TODO: wire to BrainEngine/MemoryEngine health
    func listModels() async throws -> [[String: Any]] {
        // TODO: enumerate from real registry if available
        return [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1", "object": "model", "owned_by": "syntra"]
        ]
    }
}

func makeBackend() -> SyntraBackend {
    switch BackendMode.current() {
    case .null: return NullSyntraBackend()
    case .real: return RealSyntraBackend()
    }
}
