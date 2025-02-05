import Foundation
import Combine

final class DiskSavingConversationsRepositoryDecorator: ConversationsRepository {
    
    var wrapped: ConversationsRepository
    private let fileName = "conversations"
    
    init(
        initialChats: [Conversation],
        wrapping wrapped: ConversationsRepository
    ) {
        self.wrapped = wrapped
        conversations = []
        backgroundLoadFromDisk(replaceNullWith: initialChats)
    }
    
    var conversations: [Conversation] {
        get {
            wrapped.conversations
        }
        set {
            wrapped.conversations = newValue
        }
    }
    
    var conversationsPublisher: AnyPublisher<[Conversation], Never> {
        wrapped.conversationsPublisher
    }
    
    func updateConversation(_ conversation: Conversation) {
        // First, publish immediately.
        wrapped.updateConversation(conversation)
        
        // Then, perform disk saving.
        backgroundSaveToDisk(conversations)
    }

    private func backgroundSaveToDisk(_ conversations: [Conversation]) {
        
        Task.detached(priority: .background) { [weak self] in
            
            guard let self = self else { return }
            
            // Convert Conversation to ConversationResponse.
            let conversationsEncodable = conversations.map { $0.mapToCodable() }
            
            // Encode to JSON.
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            do {
                let jsonData = try encoder.encode(conversationsEncodable)
                let fileURL = self.getFileURL(for: self.fileName)
                try jsonData.write(to: fileURL)
                print("Successfully saved conversations to disk at \(fileURL.path)")
            } catch {
                print("Error saving conversations to disk: \(error)")
            }
        }
    }
    
    private func backgroundLoadFromDisk(replaceNullWith initial: [Conversation]) {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            guard let loaded = self.loadFromDisk() else {
                self.conversations = initial
                return
            }
            self.conversations = loaded
        }
    }
    
    private func loadFromDisk() -> [Conversation]? {
        // Determine the file URL for the saved conversations.
        let fileURL = getFileURL(for: fileName)
        
        // Attempt to read data from the file. If it fails, log and return an empty array.
        guard let data = try? Data(contentsOf: fileURL) else {
            print("No saved conversations found at \(fileURL.path)")
            return nil
        }
        
        // Create a JSONDecoder and set the expected date decoding strategy to match the encoder.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            // Decode the JSON data into an array of ConversationResponse objects.
            let conversationResponses = try decoder.decode([ConversationResponse].self, from: data)
            
            // Map the decoded responses back to your Conversation model.
            let conversations = conversationResponses.map { $0.mapToDomain() }
            return conversations
        } catch {
            print("Error loading conversations from disk: \(error)")
            return nil
        }
    }
    
    private func getFileURL(for fileName: String) -> URL {
        let fileManager = FileManager.default
        // Save the file in the documents directory.
        let docsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docsDirectory.appendingPathComponent("\(fileName).json")
    }
}


extension ConversationResponse {
    func mapToDomain() -> Conversation {
        Conversation(
            id: id,
            name: name,
            lastUpdated: lastUpdated,
            messages: messages.map { $0.mapToDomain() }
        )
    }
}

extension MessageResponse {
    func mapToDomain() -> Message {
        Message(
            id: id,
            text: text,
            lastUpdated: lastUpdated
        )
    }
}

extension Conversation {
    func mapToCodable() -> ConversationResponse {
        return ConversationResponse(
            id: self.id,
            name: self.name,
            lastUpdated: self.lastUpdated,
            messages: self.messages.map { $0.mapToCodable() }
        )
    }
}

extension Message {
    func mapToCodable() -> MessageResponse {
        return MessageResponse(
            id: self.id,
            text: self.text,
            lastUpdated: self.lastUpdated
        )
    }
}
