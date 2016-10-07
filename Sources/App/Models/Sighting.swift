import Vapor
import HTTP
import Node
import Foundation

final class Sighting: Model {
    var id: Node?
    var bird: String
    var time: Int
    var exists: Bool = false
    
    init(bird: String, time: Double) {
        self.bird = bird;
        self.time = Int(time)
    }
    
    convenience init(bird: String) {
        self.init(bird:bird, time: NSDate().timeIntervalSince1970.doubleValue)
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        bird = try node.extract("bird")
        time = try node.extract("time")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "bird": bird,
            "time": time
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("sightings") { sightings in
            sightings.id()
            sightings.string("bird", optional: false)
            sightings.int("time")
        }
    }
        
    static func revert(_ database: Database) throws {
        try database.delete("sightings")
    }
}

