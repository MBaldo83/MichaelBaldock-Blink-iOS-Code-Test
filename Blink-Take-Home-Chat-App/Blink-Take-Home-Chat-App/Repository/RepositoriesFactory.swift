import Foundation

final class RepositoriesFactory {
    
    private lazy var sharedConversationsRepository = {
        
        // Base Publisher provides immediate subject for UI
        let base = ImmediateConversationsRepository(
            initialChats: DebugDataSeed.loadInitialConversations()
        )
        
        // Wrap with the disk-saving behavior.
        let withDisk = DiskSavingConversationsRepositoryDecorator(
            wrapping: base
        )
        
        // Wrap that with the API-updating behavior.
        let withAPI = APIUpdatingConversationsRepositoryDecorator(
            wrapping: withDisk
        )
        
        return withAPI
    }()
    
    func conversationsRepository() -> ConversationsRepository {
        sharedConversationsRepository
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
