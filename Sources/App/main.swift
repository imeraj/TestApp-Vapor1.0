import Vapor
import VaporMySQL
import Foundation

let drop = Droplet(preparations: [Sighting.self], providers: [VaporMySQL.Provider.self])

drop.post("sightings") { request in
    guard let bird = request.data["bird"]?.string else {
        throw Abort.badRequest
    }
    
    let response = try drop.client.get("http://ebird.org/ws1.1/ref/taxon/find", query: [
        "q" : bird ])
    
    let birds = response.data["name"]?
            .array?
            .flatMap({ $0.string })
    
    if birds == nil || birds?.count == 0 {
            throw Abort.custom(
                status: .badRequest,
                message: "Bird \(bird) was not found")
    }

    var sighting = Sighting(bird: bird)
    try sighting.save()
    
    return sighting
}

drop.get("sightings", Sighting.self) { request, sighting in
    return sighting
}

drop.get("sightings", String.self, "count") { request, bird in
    let sightings = try Sighting.query().filter("bird", bird).all()
    
    return JSON([
            "count": Node(sightings.count)
        ])
}

drop.run()
