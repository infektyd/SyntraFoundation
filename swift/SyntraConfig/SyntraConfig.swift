import Foundation

public struct SyntraConfig: Codable {
    public var openaiApiKey: String?
    public var openaiApiBase: String?
    public var openaiModel: String?
    public var elevenlabsApiKey: String?
    public var appleLLMApiKey: String?
    public var appleLLMApiBase: String?
    public var useAppleLLM: Bool?
    public var useMistralForValon: Bool?
    public var preferredVoice: String?
    public var driftRatio: [String: Double]?
    /// Whether to use trainable FusionMLP instead of static averaging
    public var useAdaptiveFusion: Bool?
    /// Whether to use dynamic drift weighting based on Valon/Modi similarity
    public var useAdaptiveWeighting: Bool?
    public var enableValonOutput: Bool?
    public var enableModiOutput: Bool?
    public var enableDriftOutput: Bool?
    public var logSymbolicDrift: Bool?
    public var memoryMode: String?
    public var interpreterOutput: Bool?
    public var telemetryCsvPath: String?
    public var enableTwoPassLoop: Bool?
    
    public init() {}
    
    enum CodingKeys: String, CodingKey {
        case openaiApiKey = "openai_api_key"
        case openaiApiBase = "openai_api_base"
        case openaiModel = "openai_model"
        case elevenlabsApiKey = "elevenlabs_api_key"
        case appleLLMApiKey = "apple_llm_api_key"
        case appleLLMApiBase = "apple_llm_api_base"
        case useAppleLLM = "use_apple_llm"
        case useMistralForValon = "use_mistral_for_valon"
        case preferredVoice = "preferred_voice"
        case driftRatio = "drift_ratio"
        case useAdaptiveFusion = "use_adaptive_fusion"
        case useAdaptiveWeighting = "use_adaptive_weighting"
        case enableValonOutput = "enable_valon_output"
        case enableModiOutput = "enable_modi_output"
        case enableDriftOutput = "enable_drift_output"
        case logSymbolicDrift = "log_symbolic_drift"
        case memoryMode = "memory_mode"
        case interpreterOutput = "interpreter_output"
        case telemetryCsvPath = "telemetry_csv_path"
        case enableTwoPassLoop = "enable_two_pass_loop"
    }
    
    public static func loadConfig(path: String = "config.json") throws -> SyntraConfig {
    let searchPaths = [
        "config/config.local.json",
        "config.local.json",
        path
    ]
    var configURL: URL?
    let fm = FileManager.default
    for p in searchPaths {
        if fm.fileExists(atPath: p) {
            configURL = URL(fileURLWithPath: p)
            break
        }
    }
    if configURL == nil {
        configURL = URL(fileURLWithPath: path)
    }
    guard let url = configURL, fm.fileExists(atPath: url.path) else {
        throw ConfigError.notFound
    }
    let data = try Data(contentsOf: url)
    var cfg = try JSONDecoder().decode(SyntraConfig.self, from: data)
    let env = ProcessInfo.processInfo.environment
    if let val = env["OPENAI_API_KEY"] { cfg.openaiApiKey = val }
    if let val = env["ELEVENLABS_API_KEY"] { cfg.elevenlabsApiKey = val }
    if let val = env["APPLE_LLM_API_KEY"] { cfg.appleLLMApiKey = val }
    if let val = env["USE_ADAPTIVE_FUSION"] { cfg.useAdaptiveFusion = (val as NSString).boolValue }
    if let val = env["USE_ADAPTIVE_WEIGHTING"] { cfg.useAdaptiveWeighting = (val as NSString).boolValue }
    return cfg
    }
}

public enum ConfigError: Error {
    case notFound
    case invalid
}

// Global function for backward compatibility
public func loadConfig(path: String = "config.json") throws -> SyntraConfig {
    return try SyntraConfig.loadConfig(path: path)
}
