import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Hash
import Auth

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting-error": SightingErrorMiddleware(),
    "user-error": UserErrorMiddleware(),
    "auth-error": AuthErrorMiddleware(),
    "auth": AuthMiddleware(user: User.self),
    "logout": LogoutMiddleware(),
    "validation-error": ValidationErrorMiddleware()
]

// Initialize Droplet
let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self, User.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
var log = drop.log.self

if drop.environment == .production {
    drop.log.enabled = [LogLevel.error]
}

User.database = drop.database
Sighting.database = drop.database

// Register routes
drop.collection(V1RouteCollection(drop))
drop.collection(LoginRouteCollection(drop))
log.info("API registration done!")

drop.get("/") { request in
    try drop.view.make("signup.html")
}
drop.get("/login") { request in
    try drop.view.make("login.html")
}
drop.get("/birds") { request in
    try drop.view.make("birds.html")
}

drop.run()
