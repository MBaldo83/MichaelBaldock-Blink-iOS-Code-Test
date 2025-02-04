import Foundation
import Combine

final class APIUpdatingConversationsRepositoryDecorator: ConversationsRepository {
    private let wrapped: ConversationsRepository
    
    init(wrapping wrapped: ConversationsRepository) {
        self.wrapped = wrapped
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
        // Implement your API call logic here.
        // Optionally, when the API responds, you can update the conversation (if the response contains changes).
        print("Updating conversation \(conversation.id) on server")
    }
}

