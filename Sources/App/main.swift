import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Sessions

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting": SightingErrorMiddleware(),
    "sessions" : SessionsMiddleware(sessions: MemorySessions())
]

// Initialize Droplet
let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
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

drop.run()
