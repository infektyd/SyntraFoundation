import Foundation

struct AppState: Codable {
    let messages: [Message]
    let consciousnessState: String
    let sessionId: String
}

class AppStateManager {
    
    static let shared = AppStateManager()
    
    private let fileURL: URL
    
    private init() {
        do {
            let directory = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            fileURL = directory.appendingPathComponent("syntra_app_state.json")
        } catch {
            fatalError("Could not create application support directory.")
        }
    }
    
    func saveState(appState: AppState) {
        do {
            let data = try JSONEncoder().encode(appState)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save app state: \(error)")
        }
    }
    
    func loadState() -> AppState? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let appState = try JSONDecoder().decode(AppState.self, from: data)
            return appState
        } catch {
            print("Failed to load app state: \(error)")
            return nil
        }
    }
} 