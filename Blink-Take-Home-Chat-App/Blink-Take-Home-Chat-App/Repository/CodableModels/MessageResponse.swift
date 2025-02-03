import Foundation

struct MessageResponse: Codable {
    let id: String
    let text: String
    let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case id, text
        case lastUpdated = "last_updated"
    }
}


