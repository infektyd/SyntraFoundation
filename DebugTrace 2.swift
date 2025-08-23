import Foundation
import Dispatch

struct TraceSpan: Codable {
    let name: String
    let startNs: UInt64
    var endNs: UInt64?
    var ok: Bool?
    var error: String?
    var meta: [String: String]?

    var durationMs: Double? {
        guard let endNs else { return nil }
        return Double(endNs - startNs) / 1_000_000.0
    }
}

struct TraceRecord: Codable {
    let id: String
    let startedAt: Date
    let method: String
    let path: String
    var spans: [TraceSpan] = []
}

@inline(__always)
func monotonicNowNs() -> UInt64 { DispatchTime.now().uptimeNanoseconds }

actor TraceStore {
    static let shared = TraceStore(max: 512)
    private let max: Int
    private var ring: [String: TraceRecord] = [:]
    private var order: [String] = []

    init(max: Int) { self.max = max }

    func put(_ rec: TraceRecord) {
        ring[rec.id] = rec
        order.append(rec.id)
        if order.count > max {
            let drop = order.removeFirst()
            ring.removeValue(forKey: drop)
        }
    }
    func get(_ id: String) -> TraceRecord? { ring[id] }
}

func makeTraceID() -> String {
    let ts = UInt64(Date().timeIntervalSince1970 * 1000)
    let rand = UInt64.random(in: 0..<UInt64.max)
    return String(ts, radix: 36) + "-" + String(rand, radix: 36)
}

final class TraceContext {
    let id: String
    let method: String
    let path: String
    private(set) var record: TraceRecord
    private let lock = NSLock()

    init(method: String, path: String) {
        self.id = makeTraceID()
        self.method = method
        self.path = path
        self.record = TraceRecord(id: id, startedAt: Date(), method: method, path: path, spans: [])
    }

    @discardableResult
    func span<T>(_ name: String, meta: [String:String] = [:], _ op: () async throws -> T) async throws -> T {
        let start = monotonicNowNs()
        var span = TraceSpan(name: name, startNs: start, meta: meta.isEmpty ? nil : meta)
        do {
            let value = try await op()
            span.ok = true
            span.endNs = monotonicNowNs()
            append(span)
            return value
        } catch {
            span.ok = false
            span.error = String(describing: error)
            span.endNs = monotonicNowNs()
            append(span)
            throw error
        }
    }
    
    // Non-throwing version of span
    func span<T>(_ name: String, meta: [String:String] = [:], _ op: () async -> T) async -> T {
        let start = monotonicNowNs()
        var span = TraceSpan(name: name, startNs: start, meta: meta.isEmpty ? nil : meta)
        let value = await op()
        span.ok = true
        span.endNs = monotonicNowNs()
        append(span)
        return value
    }


    private func append(_ s: TraceSpan) {
        lock.lock(); defer { lock.unlock() }
        record.spans.append(s)
    }

    func seal() async { await TraceStore.shared.put(record) }
}
