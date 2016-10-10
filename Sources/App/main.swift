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

// Initialize default user and passowrd
let username = drop.config["dbseeds", "User", 0, "username"]?.string
let password = drop.config["dbseeds", "User", 0, "password"]?.string

let hashedPassword = try Hash.make(Hash.Method.sha512, Array(password!.utf8))
var user = User(username: username!, password: String(describing: (hashedPassword, encoding: String.Encoding.utf8)))

var adminUser = try User.query().filter("username", username!).first()

if var admin = adminUser {
    admin.password = user.password
    try admin.save()
} else {
    try user.save()
}

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
    throw Abort.custom(status: .ok, message: "Logged in successfully!")
}

drop.run()
