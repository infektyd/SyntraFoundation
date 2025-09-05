//
//  DebugTrace.swift
//  SyntraFoundation
//
//  Created by Hans Axelsson on 8/22/25.
//
import Foundation

struct TraceSpan: Codable {
    var name: String
    var startNs: UInt64
    var endNs: UInt64?
    var ok: Bool?
    var error: String?
    var meta: [String:String]?
}
struct TraceRecord: Codable { var spans: [TraceSpan] = [] }

final class TraceContext {
    let id = UUID().uuidString
    let method: String, path: String
    var record = TraceRecord()
    init(method: String, path: String) { self.method = method; self.path = path }

    @discardableResult
    func span<T>(_ name: String, meta: [String:String] = [:], _ op: () async throws -> T) async throws -> T {
        let start = DispatchTime.now().uptimeNanoseconds
        var s = TraceSpan(name: name, startNs: start, endNs: nil, ok: nil, error: nil, meta: meta.isEmpty ? nil : meta)
        do {
            let v = try await op()
            s.ok = true; s.endNs = DispatchTime.now().uptimeNanoseconds
            record.spans.append(s); return v
        } catch {
            s.ok = false; s.error = String(describing: error); s.endNs = DispatchTime.now().uptimeNanoseconds
            record.spans.append(s); throw error
        }
    }
}
