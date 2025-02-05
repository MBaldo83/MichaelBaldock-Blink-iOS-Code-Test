import XCTest
import Combine
@testable import Blink_Take_Home_Chat_App

// TODO: There's a lot of repeated boilerplate in here, we could refactor this with generic helper methods
final class ImmediateConversationsRepositoryTests: XCTestCase {
    
    var repository: ImmediateConversationsRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repository = ImmediateConversationsRepository()
        cancellables = []
    }
    
    override func tearDown() {
        repository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialConversationsIsEmpty() {
        XCTAssertEqual(repository.conversations.count, 0)
        
        // Also test that the publisher emits an empty array.
        let exp = expectation(description: "Publisher emits empty array initially")
        repository.conversationsPublisher
            .sink { conversations in
                if conversations.isEmpty {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSettingConversationsPublishesNewValue() {
        let conversation = Conversation(id: "1", name: "Test Conversation", lastUpdated: Date(), messages: [])
        let exp = expectation(description: "Publisher emits updated conversations after setting property")
        
        // The initial emission from the subject is an empty array; we drop that.
        repository.conversationsPublisher
            .dropFirst()
            .sink { conversations in
                XCTAssertEqual(conversations, [conversation])
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        repository.conversations = [conversation]
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdateNonexistentConversationDoesNothing() {
        let conversation = Conversation(id: "1", name: "Test", lastUpdated: Date(), messages: [])
        repository.conversations = [conversation]
        
        let exp = expectation(description: "No update should be published when conversation is not found")
        exp.isInverted = true
        
        repository.conversationsPublisher
            .dropFirst()
            .sink { _ in
                exp.fulfill() // If a new value is published, this will cause a failure (isInverted)
            }
            .store(in: &cancellables)
        
        let nonExistentConversation = Conversation(id: "2", name: "Nonexistent", lastUpdated: Date(), messages: [])
        repository.updateConversation(nonExistentConversation)
        
        wait(for: [exp], timeout: 0.5)
    }
    
    func testUpdateExistingConversationPublishesUpdatedValue() {

        let originalConversation = Conversation(id: "1", name: "Original", lastUpdated: Date(), messages: [])
        repository.conversations = [originalConversation]
        
        let updatedConversation = Conversation(id: "1",
                                               name: "Updated",
                                               lastUpdated: originalConversation.lastUpdated.addingTimeInterval(60),
                                               messages: [])
        
        let exp = expectation(description: "Publisher emits updated conversation after update")
        
        repository.conversationsPublisher
            .dropFirst()
            .sink { conversations in
                if let conversation = conversations.first(where: { $0.id == updatedConversation.id }) {
                    XCTAssertEqual(conversation.name, "Updated")
                    XCTAssertEqual(conversation.lastUpdated, updatedConversation.lastUpdated)
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        repository.updateConversation(updatedConversation)
        wait(for: [exp], timeout: 1.0)
    }
}
