import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Hash
import Auth
import Cookies

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting_error": SightingErrorMiddleware(),
    "user_error": UserErrorMiddleware(),
    "auth_error": AuthErrorMiddleware(),
    "auth": AuthMiddleware(user: User.self),
    "logout": LogoutMiddleware()
]

// Initialize Droplet
let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self, User.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
let log = drop.log.self

User.database = drop.database
Sighting.database = drop.database

// Register routes using RouteCollection and Group
drop.collection(V1RouteCollection(drop))

if drop.environment == .development {
    log.info("API registration done!")
}

// login API
drop.post("login") { request in
    log.debug("Request: \(request.headers)")
    
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    try request.auth.login(credentials, persist: true)
    
    return JSON(["message": "Login successful!"])
}

drop.get("logout") { request in
    log.debug("Request: \(request.headers)")
    
    // workaround for strage cookie set during logout: remove cookies from request 
    request.cookies.removeAll()
    
    guard let user = try request.auth.user() as? User else {
        throw UserError.noSuchUser
    }
    
    try request.auth.logout()
    
    return JSON(["message": "Logout successful!"])
}

drop.post("register") { request in
    log.debug("Request: \(request.headers)")
    
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    _ = try User.register(credentials: credentials)
    
    return JSON(["message": "Registration successful!"])
}

drop.run()
