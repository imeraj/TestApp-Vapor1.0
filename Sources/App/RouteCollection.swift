import Vapor
import HTTP
import Routing
import Auth

final class V1RouteCollection: RouteCollection {
    typealias Wrapped = HTTP.Responder
    let drop: Droplet
    let protect: ProtectMiddleware // protect middleware to protect APIs for authorized usage only

    init(_ droplet: Droplet) {
        self.drop = droplet
        
        let error = Abort.custom(status: .forbidden, message: "Please login first!")
        protect = ProtectMiddleware(error: error)
    }
    
    func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let v1 = builder.grouped("v1")
        
        // Initialize controller
        let sightings = SightingConroller(droplet: drop)
        
        // only post API is protected for now
        v1.grouped(protect).post("sightings", handler: sightings.store)
            
        v1.get("sightings", handler: sightings.index)
        v1.get("sightings", Sighting.self, handler: sightings.show)
        v1.get("sightings", String.self, "count", handler: sightings.count)
    }
}

final class LoginRouteCollection: RouteCollection {
    typealias Wrapped = HTTP.Responder
    let drop: Droplet
   
    init(_ droplet: Droplet) {
        self.drop = droplet
    }
    
    func build<Builder: RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        // Initialize controller
        let auth = AuthController(droplet: drop)
        
        builder.post("login", handler: auth.login)
        builder.get("logout", handler: auth.logout)
        builder.post("register", handler: auth.register)
    }
}
