import Vapor
import HTTP
import SwiftyBeaverVapor
import SwiftyBeaver
import Auth
import Foundation

final class AuthController: ResourceRepresentable {
    let drop: Droplet
    let log: SwiftyBeaverVapor
    
    init(droplet: Droplet) {
        self.drop = droplet
        self.log = droplet.log as! SwiftyBeaverVapor
    }

    func login(request: Request) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
    
        guard let credentials = request.auth.header?.basic else {
            throw Abort.badRequest
        }
    
        try request.auth.login(credentials, persist: true)
        
        try request.session().data["timestamp"] = Node(Int(NSDate().timeIntervalSince1970.doubleValue))
        
        return JSON(["message": "Login successful!"])
    }

    func logout(request: Request) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
    
        // workaround for strage cookie set during logout: remove cookies from request 
        try request.session().destroy()
        request.cookies.removeAll()
    
        guard let _ = try request.auth.user() as? User else {
            throw UserError.noSuchUser
        }
    
        try request.auth.logout()
    
        if request.accept.prefers("html") {
            let response = Response(redirect: "/")
            return response
        } else {
            return JSON(["message": "Logout successful!"])
        }
    }

    func register(request: Request) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
    
        guard let credentials = request.auth.header?.basic else {
            throw Abort.badRequest
        }
    
        _ = try User.register(credentials: credentials)
    
        return JSON(["message": "Registration successful!"])    
    }
    
    func makeResource() -> Resource<User> {
        return Resource()
    }
}
