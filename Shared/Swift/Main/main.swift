import Foundation
import SyntraConfig
import ConversationalInterface
import BrainEngine

@main
struct SyntraSwiftCLI {
    static func main() async throws {
        print("🚀 SYNTRA Foundation CLI - macOS 26 (Tahoe) Ready!")
        
        let config = SyntraConfig()
        print("✅ SyntraConfig initialized")
        
        // Test the three-brain system
        let testResult = await BrainEngine.processThroughBrains("Hello, SYNTRA consciousness!")
        print("🧠 Brain processing result keys: \(testResult.keys.sorted())")
        
        print("🎯 SYNTRA Foundation is operational and ready for development!")
    }
}
