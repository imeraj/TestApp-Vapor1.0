import Vapor
import HTTP
import SwiftyBeaverVapor
import SwiftyBeaver
import Auth

final class SightingConroller: ResourceRepresentable {
    let drop: Droplet
    let log: SwiftyBeaverVapor
    
    init(droplet: Droplet) {
        self.drop = droplet
        self.log = droplet.log as! SwiftyBeaverVapor
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
       
        return try Sighting.all().makeNode().converted(to: JSON.self)
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")

        guard let bird = request.data["bird"]?.string else {
            throw SightingError.malformedSightingRequest
        }
        
        let find_bird_url = drop.config["app", "birds_apis", 0, "find_bird_url"]?.string ?? ""
        
        let response = try drop.client.get(find_bird_url, query: [
            "q" : bird ])
        
        let birds = response.data["name"]?
            .array?
            .flatMap({ $0.string })
        
        if birds == nil || birds?.count == 0 {
            throw SightingError.noSuchBird
        }
        
        var sighting = Sighting(bird: bird)
        try sighting.save()
        
        return sighting
    }
    
    func show(request: Request, item sighting: Sighting) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
        
        return sighting
    }
    
    func count(request: Request, item bird: String) throws -> ResponseRepresentable {
        log.debug("Request: \(request.headers)")
        
        let sightings = try Sighting.query().filter("bird", bird).all()
        
        return JSON([
            "count": Node(sightings.count)
        ])
    }
    
    func makeResource() -> Resource<Sighting> {
        return Resource(
            index: index,
            store: store,
            show: show
        )
    }
}
