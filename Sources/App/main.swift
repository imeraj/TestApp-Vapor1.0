import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Sessions

let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting": SightingErrorMiddleware(),
    "sessions" : SessionsMiddleware(sessions: MemorySessions())
]

let drop = Droplet(availableMiddleware: middleware, preparations: [Sighting.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])
let log = drop.log.self


let sightings = SightingConroller(droplet: drop)

drop.post("sightings", handler: sightings.store)

drop.get("sightings", handler: sightings.index)
drop.get("sightings", Sighting.self, handler: sightings.show)
drop.get("sightings", String.self, "count", handler: sightings.count)

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
