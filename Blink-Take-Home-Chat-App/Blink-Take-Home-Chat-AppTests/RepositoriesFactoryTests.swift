import XCTest
import Combine
@testable import Blink_Take_Home_Chat_App

final class RepositoriesFactoryTests: XCTestCase {
    
    var factory: RepositoriesFactory!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        factory = RepositoriesFactory()
        cancellables = []
    }
    
    override func tearDown() {
        factory = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testConversationsRepository_IsSingleton() {
        let repo1 = factory.conversationsRepository() as! APIUpdatingConversationsRepositoryDecorator
        let repo2 = factory.conversationsRepository() as! APIUpdatingConversationsRepositoryDecorator
        // We expect that calling the factory method twice returns the same instance.
        XCTAssertTrue(repo1 === repo2, "conversationsRepository should be a singleton")
    }
    
    func testConversationsRepository_HasExpectedDecorators() {
        let repo = factory.conversationsRepository()
        
        // The factory wraps the base repository as follows:
        // ImmediateConversationsRepository --> DiskSavingConversationsRepositoryDecorator --> APIUpdatingConversationsRepositoryDecorator
        
        guard let apiRepo = repo as? APIUpdatingConversationsRepositoryDecorator,
              let diskSaving = apiRepo.wrapped as? DiskSavingConversationsRepositoryDecorator else {
            XCTFail("incorrect decorated stack of Repositories")
            return
        }
        XCTAssertTrue(diskSaving.wrapped is ImmediateConversationsRepository,
                      "Expect final layer to be ImmediateConversationsRepository")
    }
    
    func testMessagesRepository_ReturnsCorrectType() {
        
        let conversation = Conversation(id: "test", name: "Test Conversation", lastUpdated: Date(), messages: [])
        let messagesRepo = factory.messagesRepository(conversation: conversation)
        
        // Expect that the messages repository is the decorated type that updates the conversation.
        XCTAssertTrue(messagesRepo is ConversationUpdatingMessagesRepository,
                      "Expected messagesRepository to be an instance of ConversationUpdatingMessagesRepository")
    }
}
