import Foundation
import Combine

protocol ConversationsRepository {
    
    /// A publisher that emits the current list of conversations.
    var conversationsPublisher: AnyPublisher<[Conversation], Never> { get }
    
    /// Called when a conversation is updated (for example, when a new message is added).
    func updateConversation(_ conversation: Conversation)
    
    /// This is needed for wrapped implementations to have a mechanism to update the Subject (source of truth)
    var conversations: [Conversation] { get set }
}

final class ImmediateConversationsRepository: ConversationsRepository {
    
    private let conversationsSubject: CurrentValueSubject<[Conversation], Never>
    
    init() {
        conversationsSubject = CurrentValueSubject<[Conversation], Never>([])
    }
    
    var conversations: [Conversation] {
        get {
            conversationsSubject.value
        }
        set {
            conversationsSubject.send(newValue)
        }
    }
    
    var conversationsPublisher: AnyPublisher<[Conversation], Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    // Called by the ConversationUpdatingMessagesRepository to update a
    // conversation’s metadata (such as lastUpdated).
    func updateConversation(_ conversation: Conversation) {
        var conversations = conversationsSubject.value
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
            conversationsSubject.send(conversations)
        }
    }
}
