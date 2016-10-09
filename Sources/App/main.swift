import Vapor
import VaporMySQL
import Foundation

let drop = Droplet(preparations: [Sighting.self], providers: [VaporMySQL.Provider.self])
let sightings = SightingConroller(droplet: drop)

drop.post("sightings", handler: sightings.store)

drop.get("sightings", handler: sightings.index)
drop.get("sightings", Sighting.self, handler: sightings.show)
drop.get("sightings", String.self, "count", handler: sightings.count)

if drop.environment == .development {
    print("API registration done!")
}


drop.run()
