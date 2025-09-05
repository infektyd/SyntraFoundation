import Vapor

struct LoggingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        request.logger.info("\(request.method) \(request.url)")
        return try await next.respond(to: request)
    }
}
