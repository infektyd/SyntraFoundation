import Foundation
import SyntraSwift

@main
struct SyntraSwiftCLI {
    static func main() async throws {
        print("SyntraSwiftCLI running...")
        
        let config = SyntraConfig()
        _ = SyntraChatView(config: config)
        
        print("SyntraChatView initialized. Exiting.")
    }
}
