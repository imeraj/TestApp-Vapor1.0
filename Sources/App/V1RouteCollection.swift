import Vapor
import HTTP
import Routing

final class V1RouteCollection: RouteCollection {
    typealias Wrapped = HTTP.Responder
    let drop: Droplet

    init(_ droplet: Droplet) {
        self.drop = droplet
    }
    
    func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let v1 = builder.grouped("v1")
        
        // Initialize controller
        let sightings = SightingConroller(droplet: drop)
            
        v1.post("sightings", handler: sightings.store)
            
        v1.get("sightings", handler: sightings.index)
        v1.get("sightings", Sighting.self, handler: sightings.show)
        v1.get("sightings", String.self, "count", handler: sightings.count)
    }
}
