import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Valon
import Modi
import Drift

// Allow overriding the Apple LLM query for testing
@MainActor
public var queryAppleLLM: (String, String?, String?) -> String = { prompt, key, base in
    performAppleLLMQuery(prompt, apiKey: key, apiBase: base)
}

public struct MemoryEngine {
    public init() {}
}

func logStage(stage: String, output: Any, directory: String) {
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

@MainActor
public func processThroughBrains(_ input: String) -> [String: Any] {
    let cfg: SyntraConfig
    do {
        cfg = try loadConfig()
    } catch {
        cfg = SyntraConfig()
    }
    let valon = reflect_valon(input)
    logStage(stage: "valon_stage", output: valon, directory: "entropy_logs")
    let modi = reflect_modi(input)
    logStage(stage: "modi_stage", output: modi, directory: "entropy_logs")
    let drift = drift_average(valon, modi)
    logStage(stage: "drift_stage", output: drift, directory: "drift_logs")

    var result: [String: Any] = [
        "valon": valon,
        "modi": modi,
        "drift": drift,
    ]
    if cfg.useAppleLLM == true {
        let apple = queryAppleLLM(
            input,
            cfg.appleLLMApiKey,
            cfg.appleLLMApiBase
        )
        result["appleLLM"] = apple
    }
    return result
}

public func jsonString(_ obj: Any) -> String {
    if let data = try? JSONSerialization.data(withJSONObject: obj, options: []),
       let str = String(data: data, encoding: .utf8) {
        return str
    }
    return "{}"
}

public func performAppleLLMQuery(_ prompt: String, apiKey: String? = nil, apiBase: String? = nil) -> String {
    let key = apiKey ?? ProcessInfo.processInfo.environment["APPLE_LLM_API_KEY"]
    let base = apiBase ?? ProcessInfo.processInfo.environment["APPLE_LLM_API_BASE"] ?? "http://localhost:1234"
    guard let url = URL(string: "\(base)/v1/chat/completions") else { return "[apple llm invalid url]" }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if let key = key { request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization") }
    let payload: [String: Any] = [
        "model": "apple",
        "messages": [["role": "user", "content": prompt]],
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
    let sem = DispatchSemaphore(value: 0)
    final class Holder: @unchecked Sendable { var value: String = "" }
    let resultHolder = Holder()
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 10
    let session = URLSession(configuration: config)
    session.dataTask(with: request) { data, _, _ in
        let res: String
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                res = content
            } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let err = json["error"] as? [String: Any],
                      let msg = err["message"] as? String {
                res = msg
            } else {
                res = "[apple llm empty]"
            }
        } else {
            res = "[apple llm error]"
        }
        DispatchQueue.main.sync {
            resultHolder.value = res
        }
        sem.signal()
    }.resume()
    if sem.wait(timeout: .now() + 10) == .timedOut {
        return "[apple llm timeout]"
    }
    return resultHolder.value
}
