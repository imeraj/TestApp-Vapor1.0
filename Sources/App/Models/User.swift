import Vapor
import Node
import HTTP
import Foundation
import Auth
import Hash

final class User: Model {
    var id: Node?
    var username: String
    var password: String
    var timestamp: Int
    var exists: Bool = false
    
    init(username: String, password: String, timestamp: Double) {
        self.username = username
        self.password = password
        self.timestamp = Int(timestamp)
    }
    
    convenience init(username: String, password: String) {
        self.init(username: username, password: password, timestamp: NSDate().timeIntervalSince1970.doubleValue)
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        password = try node.extract("password")
        timestamp = try node.extract("timestamp")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password,
            "timestamp": timestamp
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("Users") { users in
            users.id()
            users.string("username")
            users.string("password", length: 512)
            users.int("timestamp")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("Users")
    }
}

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?
        
        switch credentials {
        case let id as Identifier:
            user = try User.find(id.id)
            // process here
        case let accessToken as AccessToken:
            user = try User.query().filter("access_token", accessToken.string).first()
            // process here
        case let apiKey as APIKey:
            let hashedSecret = try Hash.make(Hash.Method.sha512, Array(apiKey.secret.utf8))
            let hashedPassword = String(describing: (hashedSecret, encoding: String.Encoding.utf8))
            user = try User.query().filter("username", apiKey.id).filter("password", hashedPassword).first()
        default:
            throw Abort.custom(status: .badRequest, message: "Invalid credentials!")
        }
        
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "User not found!")
        }
        
        return u
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        var registeredUser: User?
        
        switch credentials {
        case let apiKey as APIKey:
            let username = apiKey.id
            let password = apiKey.secret
            
            let hashedPassword = try Hash.make(Hash.Method.sha512, Array(password.utf8))
            var user = User(username: username, password: String(describing: (hashedPassword, encoding: String.Encoding.utf8)))
            
            let tempUser = try User.query().filter("username", username).first()
            
            if var u = tempUser {
                u.password = user.password
                try u.save()
                throw Abort.custom(status: .ok, message: "User exists - password updated!")
            } else {
                try user.save()
                registeredUser = user
            }
        
        default:
                throw Abort.custom(status: .badRequest, message: "Registration failed!")
        }
    
       return registeredUser!
    }
}
