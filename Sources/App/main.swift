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
    "sighting": SightingErrorMiddleware(),
    "sessions" : SessionsMiddleware(sessions: MemorySessions()),
    "auth": AuthMiddleware(user: User.self)
]

// Initialize Droplet
let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self, User.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
let log = drop.log.self

// Register routes using RouteCollection and Group
drop.collection(V1RouteCollection(drop))

if drop.environment == .development {
    log.info("API registration done!")
}

// session test api
drop.post("remember") { request in
    guard let name = request.data["name"]?.string else {
        throw Abort.badRequest
    }
    
    try request.session().data["name"] = Node.string(name)
    
    return "Remebered name."
}

drop.get("remember") { request in
    guard let name = try request.session().data["name"]?.string else {
        throw Abort.custom(status: .badRequest, message: "Please POST the name first.")
    }
    
    return name
}

// login API
drop.post("login") { request in
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    try request.auth.login(credentials)
    
    throw Abort.custom(status: .ok, message: "Login successful!")
}

drop.post("register") { request in
    guard let credentials = request.auth.header?.basic else {
        throw Abort.badRequest
    }
    
    _ = try User.register(credentials: credentials)
    
    throw Abort.custom(status: .ok, message: "Registration successful!")
}

drop.run()
