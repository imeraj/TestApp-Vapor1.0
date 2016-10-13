import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Sessions
import Hash
import Auth
import Cookies

// Create authentication middleware
let auth = AuthMiddleware(user: User.self) { value in
    return Cookie(
        name: "vapor-auth",
        value: value,
        expires: Date().addingTimeInterval(60 * 60 * 5), // 5 hours
        secure: true,
        httpOnly: true
    )
}

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting_error": SightingErrorMiddleware(),
    "user_error": UserErrorMiddleware(),
    "auth_error": AuthErrorMiddleware(),
    "auth": AuthMiddleware(user: User.self)
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
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    try request.auth.login(credentials)
    
    throw Abort.custom(status: .ok, message: "Login successful!")
}

drop.get("logout") { request in
    guard let user = try request.auth.user() as? User else {
        throw UserError.noSuchUser
    }
    
    try request.auth.logout()
    
    throw Abort.custom(status: .ok, message: "Logout successful!")
}

drop.post("register") { request in
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    _ = try User.register(credentials: credentials)
    
    throw Abort.custom(status: .ok, message: "Registration successful!")
}

drop.run()
