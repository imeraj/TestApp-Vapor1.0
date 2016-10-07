import Vapor
import VaporMySQL
import Foundation

let drop = Droplet(preparations: [Sighting.self], providers: [VaporMySQL.Provider.self])

let sightings = SightingConroller(droplet: drop)
drop.resource("sightings", sightings)

drop.post("sightings") { request in
    return try sightings.store(request: request)
}

drop.get("sightings") { request in
    return try sightings.index(request: request)
}

drop.get("sightings", Sighting.self) { request, sighting in
    return try sightings.show(request: request, item: sighting)
}

drop.run()
