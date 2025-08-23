import Foundation
import Valon
import Modi  
import Drift

/// Memory engine for SYNTRA consciousness architecture
/// Refactored July 2025 to eliminate top-level functions and ensure SwiftPM compliance
public struct MemoryEngine {
    public init() {}
    
    /// Log processing stage to entropy/drift logs
    static func logStage(stage: String, output: Any, directory: String) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: directory) {
            try? fm.createDirectory(atPath: directory, withIntermediateDirectories: true)
        }
        let path = URL(fileURLWithPath: directory).appendingPathComponent("\(stage).json")
        var data: [[String: Any]] = []
        if let d = try? Data(contentsOf: path),
           let j = try? JSONSerialization.jsonObject(with: d) as? [[String: Any]] {
            data = j
        }
        let entry: [String: Any] = ["timestamp": ISO8601DateFormatter().string(from: Date()),
                                    "output": output]
        data.append(entry)
        if let out = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]) {
            try? out.write(to: path)
        }
    }
    
    /// Process input through Valon, Modi, and Drift consciousness components
    public static func processThroughBrains(_ input: String) -> [String: Any] {
        let valonModule = Valon()
        let modiModule = Modi()
        let driftModule = Drift()
        
        let valon = valonModule.reflect(input)
        Self.logStage(stage: "valon_stage", output: valon, directory: "entropy_logs")
        let modi = modiModule.reflect(input)
        Self.logStage(stage: "modi_stage", output: modi, directory: "entropy_logs")
        let drift = driftModule.average(valon: valon, modi: modi)
        Self.logStage(stage: "drift_stage", output: drift, directory: "drift_logs")
        return ["valon": valon, "modi": modi, "drift": drift]
    }
    
    /// Convert object to JSON string representation
    public static func jsonString(_ obj: Any) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }
}
