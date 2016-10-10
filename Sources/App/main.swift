import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver

let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

var middleware: [String: Middleware]? = [
    "sighting": SightingErrorMiddleware()
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


drop.run()
