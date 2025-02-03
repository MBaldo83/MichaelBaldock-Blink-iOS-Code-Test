import Foundation

struct DebugDataSeed {
    // Loads the JSON data from a local file.
    static func loadInitialConversations() -> [Conversation] {
        
        // Replace with your actual loading code.
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure a consistent locale.
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)     // Set a timezone if needed.
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"       // Set the format matching your string.

        
        if let url = Bundle.main.url(forResource: "testJson", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            do {
                let loadedConversations = try decoder.decode([ConversationResponse].self, from: data)
                return loadedConversations.map { $0.mapToDomain() }
                
            } catch {
                print("\(error)")
            }
        }
        
        return []
    }
}
