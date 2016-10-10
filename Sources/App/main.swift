import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Sessions
import Hash

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting": SightingErrorMiddleware(),
    "sessions" : SessionsMiddleware(sessions: MemorySessions())
]

// Initialize Droplet
let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self, User.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
let log = drop.log.self

// Initialize admin user and passowrd
//let hashedPassword = try Hash.make(Hash.Method.sha512, Array("password".utf8))
let username = drop.config["dbseeds", "User", 0, "username"]?.string
let password = drop.config["dbseeds", "User", 0, "password"]?.string

//let password = drop.config["dbseeds", "User", 0, "password"]?.string

let hashedPassword = try Hash.make(Hash.Method.sha512, Array(password!.utf8))
var user = User(username: username!, password: String(describing: (hashedPassword, encoding: String.Encoding.utf8)))

var adminUSer = try User.query().filter("username", username!).first()

if var admin = adminUSer {
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

drop.run()
