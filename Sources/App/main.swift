import Vapor

let drop = Droplet()

// drop.get { req in
//     let lang = req.headers["Accept-Language"]?.string ?? "en"
//     return try drop.view.make("welcome", [
//     	"message": Node.string(drop.localization[lang, "welcome", "title"])
//     ])
// }

drop.get("greeting") { req in 
    return "Hello World!"
}

drop.resource("posts", PostController())

drop.run()
