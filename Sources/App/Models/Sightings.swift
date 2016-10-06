import Vapor
import HTTP
import Node
import Foundation

final class Sighting: ResponseRepresentable {
    var bird: String
    var time: Int
    
    init(bird: String, time: Double) {
        self.bird = bird;
        self.time = Int(time)
    }
    
    convenience init(bird: String) {
        self.init(bird:bird, time: NSDate().timeIntervalSince1970.doubleValue)
    }
    
    func makeResponse() throws -> Response {
        let json = try JSON(
            [
                "bird": Node.string(bird),
                "time": Node.string(String(time))
            ]
        )
        return try json.makeResponse()
    }
}

