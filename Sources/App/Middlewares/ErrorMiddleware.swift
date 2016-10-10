import Vapor
import HTTP

enum SightingError: Error {
    case noSuchBird
    case malformedSightingRequest
}

enum UserError: Error {
    case userExists
    case invalidCredentials
}

final class SightingErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch SightingError.malformedSightingRequest {
            return Response(
                status: .serviceUnavailable,
                body: "Sorry, we did not understand your request!"
            )
        } catch SightingError.noSuchBird {
            return Response(
                status: .badRequest,
                body: "Bird \((request.data["bird"]?.string)!) does not exist!"
            )
        }
    }
}

final class UserErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch UserError.userExists {
            return Response(
                status: .ok,
                body: "User exists - password updated!"
            )
        } catch UserError.invalidCredentials {
            return Response(
                status: .badRequest,
                body: "Invalid credentials!"
            )
        }
    }
}
