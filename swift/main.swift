import Foundation
import Valon
import Modi
import Drift
import MemoryEngine

#if canImport(FoundationModels)
import FoundationModels
#endif

@main
struct SyntraSwiftCLI {
    static func main() async {
        let args = CommandLine.arguments
        guard args.count >= 3 else {
            print("Usage: SyntraSwiftCLI <command> <input> [additional_args]")
            exit(1)
        }

        let command = args[1]
        let input = args[2]

        switch command {
        case "reflect_valon":
            let valon = Valon()
            print(valon.reflect(input))

        case "reflect_modi":
            let modi = Modi()
            print(MemoryEngine.jsonString(modi.reflect(input)))

        case "drift_average":
            if args.count >= 4,
               let modiData = args[3].data(using: .utf8),
               let modiArr = try? JSONSerialization.jsonObject(with: modiData) as? [String] {
                let drift = Drift()
                print(MemoryEngine.jsonString(drift.average(valon: input, modi: modiArr)))
            } else {
                print("Error: Need valid JSON array for modi data")
            }

        case "processThroughBrains":
            let result = MemoryEngine.processThroughBrains(input)
            print(MemoryEngine.jsonString(result))

        case "foundation_model":
            #if canImport(FoundationModels)
            if #available(macOS 26.0, *) {
                let response = await queryFoundationModel(input)
                print(response)
            } else {
                print("[foundation model unavailable - requires macOS 26+]")
            }
            #else
            print("[foundation model unavailable]")
            #endif

        case "structured_consciousness":
            print("[structured consciousness processing: \(input)]")

        default:
            break
        }
    }

    // Removed processAllBrains and jsonString - now using MemoryEngine static methods

    #if canImport(FoundationModels)
    @available(macOS 26.0, *)
    static func queryFoundationModel(_ input: String) async -> String {
        do {
            let model = SystemLanguageModel.default
            guard model.availability == .available else {
                return "[foundation model unavailable]"
            }
            
            let session = LanguageModelSession(model: model)
            let response = try await session.respond(to: input)
            return String(describing: response)
        } catch {
            return "[foundation model error: \(error)]"
        }
    }
    #else
    static func queryFoundationModel(_ input: String) async -> String {
        "[foundation model unavailable]"
    }
    #endif
}
