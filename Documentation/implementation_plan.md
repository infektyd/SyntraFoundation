# SYNTRA API Server — Debug & Instrumentation Agent Playbook

> **Purpose:** Give an AI code agent precise, minimal steps to instrument, isolate, and verify the SYNTRA API server independent from the Syntra core, while making Open WebUI probes succeed. Includes drop‑in files and patch points.

---

## TL;DR (Agent Checklist)

* [ ] Add lightweight tracing: per‑request trace ID + spans for **network → parse → router → backend → encode → send**.
* [ ] Provide **Null** vs **Real** backend seam via `SYNTRA_API_BACKEND={null|real}`.
* [ ] Implement **global CORS preflight** and ensure `Content-Length` for all responses.
* [ ] Implement OpenAI/Ollama probes: `/v1/models` (alias: `/models`), `/api/version`, `/api/tags`, `/api/ps`.
* [ ] Add health/debug endpoints: `/_health`, `/_health/syntra`, `/_debug/trace/{id}`.
* [ ] Downgrade clean EOFs to **debug** (no red ❌) and attach `x-syntra-trace` header to responses.
* [ ] Provide test curls + acceptance criteria.

---

## Background (Context for Agent)

* Server is Swift 6.2, low-level HTTP over `NWConnection`.
* Logs show browser preflight (`OPTIONS /models`), `GET /models`, and Ollama probes (`GET /api/version`, `/api/tags`, `/api/ps`).
* Current issues: missing/stub responses; normal keep‑alive closes logged as errors; unknown endpoints for Ollama probes; occasional stall before send.
* Goal: **observable** pipeline and a **separable** backend boundary so API can run without influencing Syntra core.

**Non-goals:** No refactor of Syntra brains/logic. No persistence changes. Minimal footprint.

---

## Deliverables (What the agent must produce)

1. `DebugTrace.swift` (new): tiny tracing types + in‑memory store.
2. `SyntraBackend.swift` (new): `SyntraBackend` protocol + `NullSyntraBackend` + `RealSyntraBackend` selection via env var.
3. `Main.swift` (patch):

   * Robust `send(_:,on:)` using `.contentProcessed`.
   * `corsHeaders`, `okJSON`, `noContent` helpers (add `x-syntra-trace`).
   * Global `OPTIONS` handler.
   * Routes: `/v1/models` + alias `/models`, `/api/version`, `/api/tags`, `/api/ps`, `/_health`, `/_health/syntra`, `/_debug/trace/{id}`.
   * Timeout helper for backend calls.
   * Spans around receive/parse/backend/encode/send.
   * Catch for `clientClosed` & `noData` → debug log only.

---

## Environment & Run Modes

* **Port:** 8081 (current default).
* **Backend mode:**

  * `SYNTRA_API_BACKEND=null` → returns canned data, proves API path.
  * `SYNTRA_API_BACKEND=real` (default) → calls into Syntra bridge stubs.

---

## File: `DebugTrace.swift` (add to API target)

```swift
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

    private func append(_ s: TraceSpan) {
        lock.lock(); defer { lock.unlock() }
        record.spans.append(s)
    }

    func seal() async { await TraceStore.shared.put(record) }
}
```

---

## File: `SyntraBackend.swift` (add to API target)

```swift
import Foundation

enum BackendMode: String {
    case real, null
    static func current() -> BackendMode {
        if let env = ProcessInfo.processInfo.environment["SYNTRA_API_BACKEND"]?.lowercased(), env == "null" { return .null }
        return .real
    }
}

protocol SyntraBackend {
    func listModels() async throws -> [[String: Any]]
    func ping() async -> String
}

struct NullSyntraBackend: SyntraBackend {
    func ping() async -> String { "pong:null" }
    func listModels() async throws -> [[String: Any]] {
        return [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1", "object": "model", "owned_by": "syntra"]
        ]
    }
}

struct RealSyntraBackend: SyntraBackend {
    func ping() async -> String { "pong:real" } // TODO: wire to BrainEngine/MemoryEngine health
    func listModels() async throws -> [[String: Any]] {
        // TODO: enumerate from real registry if available
        return [
            ["id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"],
            ["id": "syntra-modi-analytic-1", "object": "model", "owned_by": "syntra"]
        ]
    }
}

func makeBackend() -> SyntraBackend {
    switch BackendMode.current() {
    case .null: return NullSyntraBackend()
    case .real: return RealSyntraBackend()
    }
}
```

---

## `Main.swift` — Patch Points (copy-ready snippets)

> The agent should integrate these into the existing API entrypoint. Adjust names if collisions exist.

### Robust `send`

```swift
private func send(_ data: Data, on connection: NWConnection) async throws {
    try await withCheckedThrowingContinuation { cont in
        connection.send(content: data, completion: .contentProcessed { error in
            if let error { cont.resume(throwing: error) } else { cont.resume(returning: ()) }
        })
    }
}
```

### CORS + Response helpers (include trace header)

```swift
private func corsHeaders(for origin: String?) -> [(String, String)] {
    let allowOrigin = origin ?? "*"
    return [
        ("Access-Control-Allow-Origin", allowOrigin),
        ("Access-Control-Allow-Credentials", "true"),
        ("Access-Control-Allow-Methods", "GET,POST,OPTIONS"),
        ("Access-Control-Allow-Headers", "Authorization,Content-Type,Accept,Origin"),
        ("Vary", "Origin")
    ]
}

private func okJSON(_ obj: Any, origin: String?, extraHeaders: [(String,String)] = []) -> Data {
    let body = (try? JSONSerialization.data(withJSONObject: obj, options: [.withoutEscapingSlashes])) ?? Data("{}".utf8)
    var headers: [(String,String)] = [
        ("Content-Type", "application/json"),
        ("Content-Length", "\(body.count)"),
        ("Connection", "keep-alive"),
        ("Server", "SYNTRA")
    ]
    headers.append(contentsOf: corsHeaders(for: origin))
    headers.append(contentsOf: extraHeaders)
    return httpResponse(status: "200 OK", headers: headers, body: body)
}

private func noContent(origin: String?, extraHeaders: [(String,String)] = []) -> Data {
    var headers: [(String,String)] = [
        ("Content-Length", "0"),
        ("Connection", "keep-alive"),
        ("Server", "SYNTRA")
    ]
    headers.append(contentsOf: corsHeaders(for: origin))
    headers.append(contentsOf: extraHeaders)
    return httpResponse(status: "204 No Content", headers: headers, body: Data())
}
```

### Global CORS preflight

```swift
if request.method == "OPTIONS" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let trace = TraceContext(method: request.method, path: request.path)
    defer { Task { await trace.seal() } }
    let resp = noContent(origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection)
    return
}
```

### Establish trace + timeout helper (per request)

```swift
let trace = TraceContext(method: request.method, path: request.path)

defer { Task { await trace.seal() } }

func withTimeout<T>(_ seconds: Double, _ op: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        struct Timeout: Error {}
        group.addTask { try await op() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw Timeout()
        }
        let v = try await group.next()!
        group.cancelAll()
        return v
    }
}
```

### Backend selection (top-level once)

```swift
let backend: SyntraBackend = makeBackend()
```

### Routes with spans

```swift
// /v1/models + alias /models
if request.method == "GET", request.path == "/v1/models" || request.path == "/models" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let dataArray: [[String: Any]] = try await trace.span("backend:listModels", meta: ["mode": "\(BackendMode.current())"]) {
        try await withTimeout(2.0) { try await backend.listModels() }
    }
    let payload: [String: Any] = ["object": "list", "data": dataArray]
    let resp = try await trace.span("encode:okJSON") { okJSON(payload, origin: origin, extraHeaders: [("x-syntra-trace", trace.id)]) }
    try await trace.span("send") { try await send(resp, on: connection) }
    return
}

// Ollama probes
if request.method == "GET", request.path == "/api/version" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let resp = okJSON(["version": "SYNTRA-API 0.1 (compat)"] as [String:Any], origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection); return
}
if request.method == "GET", request.path == "/api/tags" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let now = ISO8601DateFormatter().string(from: Date())
    let payload: [String: Any] = [
        "models": [[
            "name": "syntra/valon:latest",
            "modified_at": now,
            "size": 0,
            "digest": "sha256:deadbeef",
            "details": [
                "format": "synthetic",
                "family": "syntra",
                "families": ["syntra"],
                "parameter_size": "n/a",
                "quantization_level": "n/a"
            ]
        ]]
    ]
    let resp = okJSON(payload, origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection); return
}
if (request.method == "GET" || request.method == "POST"), request.path == "/api/ps" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let resp = okJSON(["models": []] as [String:Any], origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection); return
}

// Health
if request.method == "GET", request.path == "/_health" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let payload: [String: Any] = ["ok": true, "time": ISO8601DateFormatter().string(from: Date()), "backend": "\(BackendMode.current())"]
    let resp = okJSON(payload, origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection); return
}
if request.method == "GET", request.path == "/_health/syntra" {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let pong = try await trace.span("backend:ping") { try await withTimeout(1.0) { await backend.ping() } }
    let resp = okJSON(["pong": pong, "backend": "\(BackendMode.current())"], origin: origin, extraHeaders: [("x-syntra-trace", trace.id)])
    try await send(resp, on: connection); return
}

// Trace dump
if request.method == "GET", request.path.hasPrefix("/_debug/trace/") {
    let origin = request.headers["Origin"] ?? request.headers["origin"]
    let id = String(request.path.dropFirst("/_debug/trace/".count))
    if let rec = await TraceStore.shared.get(id) {
        let enc = JSONEncoder(); enc.outputFormatting = [.withoutEscapingSlashes]
        let body = (try? enc.encode(rec)) ?? Data("{}".utf8)
        var headers = [("Content-Type","application/json"), ("Content-Length","\(body.count)"), ("x-syntra-trace", id)]
        headers += corsHeaders(for: origin)
        let resp = httpResponse(status: "200 OK", headers: headers, body: body)
        try await send(resp, on: connection)
    } else {
        let resp = httpResponse(status: "404 Not Found", headers: corsHeaders(for: origin), body: Data())
        try await send(resp, on: connection)
    }
    return
}
```

### Downgrade clean EOFs

```swift
} catch HTTPError.clientClosed, HTTPError.noData {
    log("🔌 Client closed connection (normal). trace=\(trace.id)")
    return
} catch {
    log("❌ Request failed: \(error) trace=\(trace.id)")
}
```

---

## Acceptance Tests (Agent must run all)

### 1) API without Syntra (Null backend)

```bash
SYNTRA_API_BACKEND=null swift run syntra-api-server
```

```bash
curl -i http://localhost:8081/_health
curl -i http://localhost:8081/_health/syntra
curl -i http://localhost:8081/v1/models
curl -i -X OPTIONS http://localhost:8081/models \
  -H 'Origin: http://localhost:8080' \
  -H 'Access-Control-Request-Method: GET'
```

**Expect:** HTTP 200/204 responses within 100ms; `x-syntra-trace` header present; logs show spans for `encode:okJSON` and `send`.

### 2) Real backend smoke

```bash
SYNTRA_API_BACKEND=real swift run syntra-api-server
curl -i http://localhost:8081/_health/syntra
```

**Expect:** 200 with `pong:real`. If timeout occurs, `backend:ping` span shows error and total time \~1s.

### 3) Ollama probes (Open WebUI sidecar)

```bash
curl -i http://localhost:8081/api/version
curl -i http://localhost:8081/api/tags
curl -i http://localhost:8081/api/ps
```

**Expect:** 200 JSON; WebUI model list should populate; no repeated "Unknown endpoint" logs.

### 4) Trace retrieval

* Copy `x-syntra-trace` from any response.

```bash
curl -s http://localhost:8081/_debug/trace/<TRACE_ID> | jq
```

**Expect:** JSON with spans showing durations and any errors.

---

## Troubleshooting Flow (for the agent)

1. **/\_health fast, /\_health/syntra timeout** → Syntra bridge issue. Inspect `backend:ping` span. Keep API in `null` while fixing core.
2. **/v1/models fast but WebUI fails** → check CORS preflight and that `/models` alias is present. Verify `Content-Length` headers.
3. **Long `send` span** → check connection lifecycle; ensure using `.contentProcessed` and not canceling early.
4. **Frequent EOF logs** → ensure `clientClosed`/`noData` are caught and downgraded.
5. **Empty request bodies** → if behind a proxy, implement `Transfer-Encoding: chunked` reader; for now prefer direct client with `Content-Length`.

---

## Security & Hygiene

* Do **not** log `Authorization` or request bodies over \~8KB (truncate with suffix `… (+N bytes)`).
* CORS: In production pin `Access-Control-Allow-Origin` to the WebUI host and set `Allow-Credentials: false` if not needed.
* Ensure `x-syntra-trace` contains no sensitive data (it doesn’t; it’s a synthetic ID).

---

## Appendix A: Example JSON payloads

### `/v1/models`

```json
{
  "object": "list",
  "data": [
    {"id": "syntra-valon-creative-1", "object": "model", "owned_by": "syntra"},
    {"id": "syntra-modi-analytic-1",  "object": "model", "owned_by": "syntra"}
  ]
}
```

### `/api/version`

```json
{"version": "SYNTRA-API 0.1 (compat)"}
```

### `/api/tags`

```json
{
  "models": [
    {
      "name": "syntra/valon:latest",
      "modified_at": "2025-08-22T00:00:00Z",
      "size": 0,
      "digest": "sha256:deadbeef",
      "details": {
        "format": "synthetic",
        "family": "syntra",
        "families": ["syntra"],
        "parameter_size": "n/a",
        "quantization_level": "n/a"
      }
    }
  ]
}
```

### `/api/ps`

```json
{"models": []}
```

---

## Appendix B: Notes for Real Syntra Wiring (future tasks)

* Replace `RealSyntraBackend.ping()` with a genuinely cheap core signal, e.g., `BrainEngine.healthCheck()` or `MemoryEngine.ping()`.
* Replace `listModels()` with actual registry enumeration (map to OpenAI model schema).
* Consider adding `/v1/chat/completions` and Ollama `/api/chat` translators guarded by the same backend seam and traced spans.

---

**End of Playbook**

