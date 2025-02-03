import Foundation

struct ConversationResponse: Codable {
    let id: String
    var name: String
    var lastUpdated: Date
    var messages: [MessageResponse]
    
    // If the JSON keys don’t match our property names, add a CodingKeys enum.
    enum CodingKeys: String, CodingKey {
        case id, name
        case lastUpdated = "last_updated"
        case messages
    }
}
