import Combine

final class DiskSavingConversationsRepositoryDecorator: ConversationsRepository {
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
        
        // Then, perform disk saving.
        saveToDisk(conversation)
    }
    
    private func saveToDisk(_ conversation: Conversation) {
        // Implement your disk saving logic here.
        // This might be asynchronous.
        print("Saving conversation \(conversation.id) to disk")
    }
}
