import OSLog
import Foundation

/// SYNTRA Performance Logging System
/// Provides timing, stage tracking, and performance monitoring for the three-brain architecture
/// Moved from ConversationalInterface to resolve circular dependency issues
public struct SyntraPerformanceLogger {
    nonisolated(unsafe) private static var startTimes: [String: Date] = [:]
    nonisolated(unsafe) private static var stageLogs: [String: [String: Any]] = [:]
    
    public static func startTiming(_ stage: String) {
        startTimes[stage] = Date()
        print("[TIMING] 🚀 Started: \(stage)")
    }
    
    public static func endTiming(_ stage: String, details: String = "") {
        guard let startTime = startTimes[stage] else {
            print("[TIMING] ⚠️ No start time found for: \(stage)")
            return
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let durationMs = Int(duration * 1000)
        
        let logEntry: [String: Any] = [
            "stage": stage,
            "duration_ms": durationMs,
            "details": details,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        stageLogs[stage] = logEntry
        print("[TIMING] ✅ Completed: \(stage) (\(durationMs)ms) \(details)")
        
        // Remove from active timings
        startTimes.removeValue(forKey: stage)
    }
    
    private static let logger = Logger(subsystem: "SyntraLogger", category: "Performance")
    private static let maxLogSize: Int = 1_000_000 // 1MB
    private static var logFileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("syntra_logs.txt")
    }
    
    public static func logToDisk(_ message: String) {
        guard let url = logFileURL else { return }
        do {
            let logEntry = "[\(ISO8601DateFormatter().string(from: Date()))] \(message)\n"
            if let data = logEntry.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: url.path) {
                    let handle = try FileHandle(forUpdating: url)
                    try handle.seekToEnd()
                    try handle.write(contentsOf: data)
                    try handle.close()
                    // Check size and rotate if needed
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    if let size = attributes[.size] as? Int, size > maxLogSize {
                        try FileManager.default.removeItem(at: url)
                        logger.info("Log rotated")
                    }
                } else {
                    try data.write(to: url)
                }
            }
        } catch {
            logger.error("Failed to write log: \(error.localizedDescription)")
        }
    }
    
    public static func logStage(_ stage: String, message: String, data: Any? = nil) {
        print("[FLOW] 📍 \(stage): \(message)")
        if let data = data {
            print("[FLOW] 📊 Data: \(data)")
        }
        logToDisk("[FLOW] \(stage): \(message) \(data ?? "")")
    }
    
    public static func logError(_ stage: String, error: String) {
        print("[ERROR] ❌ \(stage): \(error)")
    }
    
    public static func getPerformanceReport() -> [String: Any] {
        return [
            "stage_logs": stageLogs,
            "active_stages": Array(startTimes.keys),
            "total_stages": stageLogs.count
        ]
    }

    // Test helper
    public static func testLogRotation() {
        for _ in 0..<1000 {
            logToDisk("Test log entry for rotation testing")
        }
    }
} 