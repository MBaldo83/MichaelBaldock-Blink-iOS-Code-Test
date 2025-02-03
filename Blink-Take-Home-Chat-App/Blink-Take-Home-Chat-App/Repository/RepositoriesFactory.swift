import Foundation

class RepositoriesFactory {
    
    private let deviceStorageConversations = DeviceStorageConversationsRepository(
        initialChats: DebugDataSeed.loadInitialConversations()
    )
    
    func conversationsRepository() -> ConversationsRepository {
        
        // This is where we could extend the functionality of the Conversations Repository
        // for example by decorating it with network capabilities
        deviceStorageConversations
    }
    
    func messagesRepository(conversation: Conversation) -> MessagesRepository {
        // This is where we could extend the functionality of the Messages Repository
        return ConversationUpdatingMessagesRepository(
            conversation: conversation,
            // Pass in a closure so that when the conversation is updated,
            // the ConversationsRepository is notified.
            onConversationUpdate: { updatedConversation in
                self.conversationsRepository().updateConversation(updatedConversation)
            }
        )
    }
}
