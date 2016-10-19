import Vapor
import HTTP
import VaporMySQL
import Foundation
import SwiftyBeaverVapor
import SwiftyBeaver
import Hash
import Auth
import Sessions

// Initialize middlewares/providers
let console = ConsoleDestination()
let sbProvider = SwiftyBeaverProvider(destinations: [console])

// Initialize Droplet
let drop = Droplet(preparations: [Sighting.self, User.self], providers: [VaporMySQL.Provider.self], initializedProviders: [sbProvider])

// as workaround of framework bug, we add all middlewares here
drop.addConfigurable(middleware: SessionsMiddleware(sessions: MemorySessions()), name: "sessions")
drop.addConfigurable(middleware: AbortMiddleware(), name: "abort")
drop.addConfigurable(middleware: DateMiddleware(), name: "date")
drop.addConfigurable(middleware: TypeSafeErrorMiddleware(), name: "type-safe")
drop.addConfigurable(middleware: ValidationMiddleware(), name: "validation")
drop.addConfigurable(middleware: FileMiddleware(publicDir: drop.workDir + "Public/"), name: "file")
drop.addConfigurable(middleware: SightingErrorMiddleware(), name: "sighting-error")
drop.addConfigurable(middleware: UserErrorMiddleware(), name: "user-error")
drop.addConfigurable(middleware: AuthMiddleware(user: User.self), name: "auth")
drop.addConfigurable(middleware: ValidationErrorMiddleware(), name: "validation-error")
drop.addConfigurable(middleware: LogoutMiddleware(), name: "logout")

var log = drop.log.self

if drop.environment == .production {
    drop.log.enabled = [LogLevel.error]
}

User.database = drop.database
Sighting.database = drop.database

// Register routes 
drop.collection(V1RouteCollection(drop))
drop.collection(LoginRouteCollection(drop))
log.info("API registration done!")

drop.get("/") { request in
    return try drop.view.make("welcome")
}

drop.run()
