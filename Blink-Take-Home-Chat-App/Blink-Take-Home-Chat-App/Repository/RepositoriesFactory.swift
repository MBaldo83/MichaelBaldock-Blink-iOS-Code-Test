import Foundation

class RepositoriesFactory {
    
    private lazy var sharedConversationsRepository = {
        
        // Base Publisher provides immediate subject for UI
        let base = ImmediateConversationsRepository()
        
        // Wrap with the disk-saving behavior.
        let withDisk = DiskSavingConversationsRepositoryDecorator(
            initialChats: DebugDataSeed.loadInitialConversations(),
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
        // decorating it like we have done the conversationsRepository
        return ConversationUpdatingMessagesRepository(
            conversation: conversation,
            // Pass in a closure so that when the conversation is updated,
            // the ConversationsRepository is notified.
            onConversationUpdate: conversationsRepository().updateConversation
        )
    }
}
