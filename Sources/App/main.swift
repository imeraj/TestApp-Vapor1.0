import Vapor
import VaporMySQL

let drop = Droplet()

drop.post("sightings") { request in
    let bird = request.data["bird"]?.string
    
    let sighting = Sighting(bird: bird!)
    
    return sighting
}

drop.run()
