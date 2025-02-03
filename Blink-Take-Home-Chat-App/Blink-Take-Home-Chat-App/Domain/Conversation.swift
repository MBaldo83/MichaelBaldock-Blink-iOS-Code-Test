import Foundation

struct Conversation: Identifiable, Hashable {
    let id: String
    var name: String
    var lastUpdated: Date
    var messages: [Message]
}
