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
            print(reflect_valon(input))

        case "reflect_modi":
            print(jsonString(reflect_modi(input)))

        case "drift_average":
            if args.count >= 4,
               let modiData = args[3].data(using: .utf8),
               let modiArr = try? JSONSerialization.jsonObject(with: modiData) as? [String] {
                print(jsonString(drift_average(input, modiArr)))
            } else {
                print("Error: Need valid JSON array for modi data")
            }

        case "processThroughBrains":
            print(jsonString(processThroughBrains(input)))

        case "foundation_model":
            #if canImport(FoundationModels)
            if #available(macOS 26.0, *) {
                do {
                    let response = try await queryFoundationModel(input)
                    print(response)
                } catch {
                    print("[foundation model error: \(error)]")
                }
            } else {
                print("[foundation model unavailable - requires macOS 26+]")
            }
            #else
            print("[foundation model unavailable]")
            #endif

        default:
            break
        }
    }
}

func reflect_valon(_ input: String) -> String {
    return Valon().reflect(input)
}

func reflect_modi(_ input: String) -> [String] {
    return Modi().reflect(input)
}

func drift_average(_ valonInput: String, _ modiData: [String]) -> [String: Any] {
    return Drift().average(valon: valonInput, modi: modiData)
}

func processThroughBrains(_ input: String) -> [String: Any] {
    let valonResult = reflect_valon(input)
    let modiResult = reflect_modi(input)
    let driftResult = drift_average(valonResult, modiResult)
    return [
        "valon": valonResult,
        "modi": modiResult,
        "drift": driftResult,
        "input": input
    ]
}

func jsonString<T>(_ object: T) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
       let str = String(data: data, encoding: .utf8) {
        return str
    }
    return "\(object)"
}

#if canImport(FoundationModels)
@available(macOS 26.0, *)
func queryFoundationModel(_ input: String) async throws -> String {
    let model = SystemLanguageModel.default
    guard model.availability == .available else {
        return "[Apple LLM unavailable]"
    }
    let session = try LanguageModelSession(model: model)
    let response = try await session.respond(to: input)
    return response
}
#endif

