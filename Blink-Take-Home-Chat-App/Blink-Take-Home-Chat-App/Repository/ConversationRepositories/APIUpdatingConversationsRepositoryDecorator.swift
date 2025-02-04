import Foundation
import Combine

final class APIUpdatingConversationsRepositoryDecorator: ConversationsRepository {
    
    private var wrapped: ConversationsRepository
    
    init(wrapping wrapped: ConversationsRepository) {
        self.wrapped = wrapped
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
        
        // Then, call the API.
        updateOnServer(conversation)
    }
    
    private func updateOnServer(_ conversation: Conversation) {
        // Because this is all based on Combine, it should be convenient
        // to make a Websocket API connection that can publish new values at any time.
        print("Updating conversation \(conversation.id) on server")
    }
}

