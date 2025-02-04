import Foundation
import Combine

protocol ConversationsRepository {
    /// A publisher that emits the current list of conversations.
    var conversationsPublisher: AnyPublisher<[Conversation], Never> { get }
    
    /// Called when a conversation is updated (for example, when a new message is added).
    func updateConversation(_ conversation: Conversation)
}

final class ImmediateConversationsRepository: ConversationsRepository {
    private let conversationsSubject: CurrentValueSubject<[Conversation], Never>
    
    var conversationsPublisher: AnyPublisher<[Conversation], Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    init(initialChats: [Conversation]) {
        conversationsSubject = CurrentValueSubject<[Conversation], Never>(initialChats)
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

