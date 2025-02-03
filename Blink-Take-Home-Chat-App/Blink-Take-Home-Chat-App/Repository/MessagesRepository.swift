import Foundation
import Combine

protocol MessagesRepository {
    /// A publisher that emits the current list of messages for this conversation.
    var messagesPublisher: AnyPublisher<[Message], Never> { get }
    
    /// Add a new message to the conversation.
    func addMessage(_ message: Message)
}

class ConversationUpdatingMessagesRepository: MessagesRepository {
    // The conversation we are working with.
    private var conversation: Conversation
    private let messagesSubject: CurrentValueSubject<[Message], Never>
    
    // This closure is called when the conversation is updated (for example, after a new message is added).
    private let onConversationUpdate: (Conversation) -> Void
    
    var messagesPublisher: AnyPublisher<[Message], Never> {
        messagesSubject.eraseToAnyPublisher()
    }
    
    init(
        conversation: Conversation,
        onConversationUpdate: @escaping (Conversation) -> Void
    ) {
        self.conversation = conversation
        self.onConversationUpdate = onConversationUpdate
        // Initialize the subject with the conversation's current messages.
        self.messagesSubject = CurrentValueSubject(conversation.messages)
    }
    
    func addMessage(_ message: Message) {
        // Append the new message.
        conversation.messages.append(message)
        // Optionally update the conversation's metadata.
        conversation.lastUpdated = message.lastUpdated
        
        // Send the updated messages to subscribers.
        messagesSubject.send(conversation.messages)
        
        // Notify the conversation repository (or any other listener) that the conversation has been updated.
        onConversationUpdate(conversation)
    }
}

