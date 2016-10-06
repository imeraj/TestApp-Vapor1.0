import Vapor
import VaporMySQL

let drop = Droplet(preparations: [Sighting.self], providers: [VaporMySQL.Provider.self])

drop.post("sightings") { request in
    guard let bird = request.data["bird"]?.string else {
        throw Abort.badRequest
    }
    
    print(request.headers)
    
    var sighting = Sighting(bird: bird)
    try sighting.save()
    
    return sighting
}

drop.run()
