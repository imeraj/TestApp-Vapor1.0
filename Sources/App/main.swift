import Vapor

let drop = Droplet()

drop.get("greeting") { req in 
    return "Hello World!"
}

drop.run()
