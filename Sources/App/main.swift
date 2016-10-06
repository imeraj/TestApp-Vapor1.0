import Vapor
import VaporMySQL

let drop = Droplet()

drop.post("sightings") { request in
    guard let bird = request.data["bird"]?.string else {
        throw Abort.badRequest
    }
    
    let sighting = Sighting(bird: bird)
    
    return sighting
}

drop.run()
