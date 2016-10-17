import Vapor
import HTTP
import Auth

final class LogoutMiddleware : Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
            let response = try next.respond(to: request)
        
            if response.headers.index(forKey: "Set-Cookie") != nil {
                if (response.headers["Set-Cookie"]?.isEmpty)! {
                    response.headers.removeValue(forKey: "Set-Cookie")
                }
            }
        
            print("\(response)")
            return response
    }
}
