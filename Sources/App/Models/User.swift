import Vapor
import Node
import HTTP
import Foundation
import Auth

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
        throw Abort.custom(status: .badRequest, message: "Authentication not supported.")
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Register not supported.")
    }
}
