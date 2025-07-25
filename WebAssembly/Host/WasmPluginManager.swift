import Foundation
import WasmKit

/// WebAssembly Plugin Manager for SYNTRA Foundation
/// Provides secure, sandboxed execution of Wasm plugins with resource limits
/// Based on Cross-Platform Containerization & WebAssembly Blueprint
public class WasmPluginManager {
    
    // MARK: - Configuration
    
    public struct PluginConfig {
        let maxMemoryBytes: UInt32
        let maxExecutionTimeMs: UInt32
        let allowedFunctions: Set<String>
        let allowFileSystem: Bool
        let allowNetwork: Bool
        
        public static let `default` = PluginConfig(
            maxMemoryBytes: 32_000_000,  // 32MB
            maxExecutionTimeMs: 50,      // 50ms
            allowedFunctions: [],
            allowFileSystem: false,
            allowNetwork: false
        )
    }
    
    // MARK: - Properties
    
    private let engine: WasmEngine
    private let pluginConfigs: [String: PluginConfig]
    private var loadedModules: [String: WasmModule] = [:]
    private var activeInstances: [String: WasmInstance] = [:]
    
    // MARK: - Initialization
    
    public init(pluginConfigs: [String: PluginConfig] = [:]) {
        self.engine = WasmEngine()
        self.pluginConfigs = pluginConfigs
    }
    
    // MARK: - Plugin Management
    
    /// Load a WebAssembly plugin from file
    public func loadPlugin(name: String, from path: URL) throws {
        let data = try Data(contentsOf: path)
        try loadPlugin(name: name, from: data)
    }
    
    /// Load a WebAssembly plugin from data
    public func loadPlugin(name: String, from data: Data) throws {
        do {
            let module = try engine.loadWasm(data)
            loadedModules[name] = module
            
            // Create instance with security constraints
            let instance = try createSecureInstance(for: module, config: getConfig(for: name))
            activeInstances[name] = instance
            
            SyntraLogger.logFoundationModels("Loaded Wasm plugin: \(name)", details: "Size: \(data.count) bytes")
        } catch {
            SyntraLogger.logFoundationModels("Failed to load Wasm plugin: \(name)", details: error.localizedDescription)
            throw WasmPluginError.loadFailed(name: name, error: error)
        }
    }
    
    /// Unload a plugin and free resources
    public func unloadPlugin(name: String) {
        activeInstances.removeValue(forKey: name)
        loadedModules.removeValue(forKey: name)
        SyntraLogger.logFoundationModels("Unloaded Wasm plugin: \(name)")
    }
    
    // MARK: - Plugin Execution
    
    /// Execute a function in a loaded plugin with timeout protection
    public func executeFunction<T: WasmValueConvertible>(
        in plugin: String,
        function: String,
        parameters: [WasmValue] = [],
        returning: T.Type
    ) throws -> T {
        guard let instance = activeInstances[plugin] else {
            throw WasmPluginError.pluginNotLoaded(name: plugin)
        }
        
        let config = getConfig(for: plugin)
        
        // Check if function is allowed
        guard config.allowedFunctions.isEmpty || config.allowedFunctions.contains(function) else {
            throw WasmPluginError.functionNotAllowed(function: function, plugin: plugin)
        }
        
        do {
            // Execute with timeout protection
            let result = try executeWithTimeout(timeoutMs: config.maxExecutionTimeMs) {
                try instance.exports[function]?.call(with: parameters, T.self)
            }
            
            guard let result = result else {
                throw WasmPluginError.functionNotFound(function: function, plugin: plugin)
            }
            
            SyntraLogger.logFoundationModels(
                "Executed Wasm function: \(plugin).\(function)",
                details: "Parameters: \(parameters.count), Result type: \(T.self)"
            )
            
            return result
        } catch {
            SyntraLogger.logFoundationModels(
                "Wasm function execution failed: \(plugin).\(function)",
                details: error.localizedDescription
            )
            throw WasmPluginError.executionFailed(function: function, plugin: plugin, error: error)
        }
    }
    
    // MARK: - Consciousness Integration
    
    /// Execute Valon (moral/emotional) processing plugin
    public func processWithValon(input: String, context: [String: Any] = [:]) async throws -> ValonResponse {
        let parameters = [
            WasmValue.from(input),
            WasmValue.from(try JSONSerialization.data(withJSONObject: context))
        ]
        
        let result: String = try executeFunction(
            in: "valon_processor",
            function: "process_moral_input",
            parameters: parameters,
            returning: String.self
        )
        
        return try JSONDecoder().decode(ValonResponse.self, from: result.data(using: .utf8)!)
    }
    
    /// Execute Modi (logical/analytical) processing plugin
    public func processWithModi(input: String, context: [String: Any] = [:]) async throws -> ModiResponse {
        let parameters = [
            WasmValue.from(input),
            WasmValue.from(try JSONSerialization.data(withJSONObject: context))
        ]
        
        let result: String = try executeFunction(
            in: "modi_processor",
            function: "process_logical_input",
            parameters: parameters,
            returning: String.self
        )
        
        return try JSONDecoder().decode(ModiResponse.self, from: result.data(using: .utf8)!)
    }
    
    // MARK: - Private Helpers
    
    private func getConfig(for plugin: String) -> PluginConfig {
        return pluginConfigs[plugin] ?? .default
    }
    
    private func createSecureInstance(for module: WasmModule, config: PluginConfig) throws -> WasmInstance {
        // Create instance with memory limits
        var importObject = ImportObject()
        
        // Add security-constrained imports based on config
        if config.allowFileSystem {
            // Add file system imports (WASI subset)
            addFileSystemImports(to: &importObject)
        }
        
        if config.allowNetwork {
            // Add network imports (limited subset)
            addNetworkImports(to: &importObject)
        }
        
        // Add SYNTRA consciousness API imports
        addConsciousnessImports(to: &importObject)
        
        let instance = try module.instantiate(importObject: importObject)
        
        // Validate memory limits
        if let memory = instance.exports.memory,
           memory.limit.max ?? UInt32.max > config.maxMemoryBytes {
            throw WasmPluginError.memoryLimitExceeded(limit: config.maxMemoryBytes)
        }
        
        return instance
    }
    
    private func executeWithTimeout<T>(timeoutMs: UInt32, operation: () throws -> T) throws -> T {
        // Simple timeout implementation - in production, use more sophisticated mechanism
        let startTime = DispatchTime.now()
        let result = try operation()
        let endTime = DispatchTime.now()
        
        let executionTimeMs = UInt32((endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000)
        if executionTimeMs > timeoutMs {
            throw WasmPluginError.executionTimeout(timeoutMs: timeoutMs, actualMs: executionTimeMs)
        }
        
        return result
    }
    
    private func addFileSystemImports(to importObject: inout ImportObject) {
        // Add minimal file system access if allowed
        // Implementation depends on WASI support in WasmKit
    }
    
    private func addNetworkImports(to importObject: inout ImportObject) {
        // Add minimal network access if allowed
        // Implementation depends on WASI support in WasmKit
    }
    
    private func addConsciousnessImports(to importObject: inout ImportObject) {
        // Add SYNTRA-specific consciousness API functions
        importObject.define(module: "syntra") {
            $0.function(name: "log_consciousness") { (message: String) in
                SyntraLogger.logConsciousness("Wasm plugin log: \(message)")
            }
            
            $0.function(name: "get_moral_weight") { () -> Double in
                return 0.7  // Valon default weight
            }
            
            $0.function(name: "get_logical_weight") { () -> Double in
                return 0.3  // Modi default weight
            }
        }
    }
}

// MARK: - Supporting Types

public enum WasmPluginError: Error, LocalizedError {
    case loadFailed(name: String, error: Error)
    case pluginNotLoaded(name: String)
    case functionNotFound(function: String, plugin: String)
    case functionNotAllowed(function: String, plugin: String)
    case executionFailed(function: String, plugin: String, error: Error)
    case executionTimeout(timeoutMs: UInt32, actualMs: UInt32)
    case memoryLimitExceeded(limit: UInt32)
    
    public var errorDescription: String? {
        switch self {
        case .loadFailed(let name, let error):
            return "Failed to load plugin '\(name)': \(error.localizedDescription)"
        case .pluginNotLoaded(let name):
            return "Plugin '\(name)' is not loaded"
        case .functionNotFound(let function, let plugin):
            return "Function '\(function)' not found in plugin '\(plugin)'"
        case .functionNotAllowed(let function, let plugin):
            return "Function '\(function)' not allowed in plugin '\(plugin)'"
        case .executionFailed(let function, let plugin, let error):
            return "Execution failed for '\(plugin).\(function)': \(error.localizedDescription)"
        case .executionTimeout(let timeoutMs, let actualMs):
            return "Execution timeout: \(actualMs)ms exceeded limit of \(timeoutMs)ms"
        case .memoryLimitExceeded(let limit):
            return "Memory limit exceeded: \(limit) bytes"
        }
    }
}

public struct ValonResponse: Codable {
    let moralScore: Double
    let emotionalTone: String
    let reasoning: String
    let confidence: Double
}

public struct ModiResponse: Codable {
    let logicalScore: Double
    let analyticalResult: String
    let reasoning: String
    let confidence: Double
}

// MARK: - WasmValue Extensions

extension WasmValue {
    static func from<T: Codable>(_ value: T) -> WasmValue {
        // Convert Swift types to WasmValue
        // Implementation depends on WasmKit API
        if let string = value as? String {
            return .i32(Int32(string.utf8.count)) // Simplified - actual implementation would handle strings properly
        }
        return .i32(0) // Placeholder
    }
    
    static func from(_ data: Data) -> WasmValue {
        return .i32(Int32(data.count)) // Simplified - actual implementation would handle data properly
    }
} 