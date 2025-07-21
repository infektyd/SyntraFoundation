import Foundation
import SyntraTools

@main
struct SyntraSwiftCLI {
    static func main() async {
        let args = CommandLine.arguments
        guard args.count >= 3 else {
            print("Usage: SyntraSwiftCLI <command> <input> [additional_args]")
            print("\nAvailable commands:")
            print("  process_input <input>     - Process through unified SYNTRA consciousness")
            print("  reflect_valon <input>     - Valon moral/emotional reflection")
            print("  reflect_modi <input>      - Modi logical analysis")
            print("  drift_average <input> <modi_data> - Drift analysis")
            print("  processThroughBrains <input> - Full brain synthesis")
            print("  foundation_model <input>  - FoundationModels query")
            exit(1)
        }

        let command = args[1]
        let input = args[2]

        // Initialize SyntraCore (unified consciousness)
        let syntraCore = SyntraCore()

        switch command {
        case "process_input":
            // Unified consciousness processing - the main interface
            let response = await syntraCore.processInput(input)
            print(response)

        case "reflect_valon":
            let response = syntraCore.reflectValon(input)
            print(response)

        case "reflect_modi":
            let response = syntraCore.reflectModi(input)
            print(response)

        case "drift_average":
            if args.count >= 4,
               let modiData = args[3].data(using: .utf8),
               let modiArr = try? JSONSerialization.jsonObject(with: modiData) as? [String] {
                let response = syntraCore.driftAverage(valon: input, modi: modiArr)
                print(response)
            } else {
                print("Error: Need valid JSON array for modi data")
            }

        case "processThroughBrains":
            let response = syntraCore.processThroughBrains(input)
            print(response)

        case "foundation_model":
            let response = await syntraCore.queryFoundationModel(input)
            print(response)

        default:
            print("Unknown command: \(command)")
            print("Use 'process_input <input>' for unified SYNTRA consciousness")
        }
    }
}
