import Foundation

struct Message: Identifiable, Hashable {
    let id: String
    let text: String
    let lastUpdated: Date
}
