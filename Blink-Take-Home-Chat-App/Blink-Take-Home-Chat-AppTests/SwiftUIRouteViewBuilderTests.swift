import XCTest
import SwiftUI
import Combine
@testable import Blink_Take_Home_Chat_App

final class MockRepositoriesFactory: RepositoriesFactory {
    var messagesRepositoryCalledWith: Conversation?
    var stubRepository: MessagesRepository!
    
    override func messagesRepository(conversation: Conversation) -> MessagesRepository {
        messagesRepositoryCalledWith = conversation
        return stubRepository
    }
}

final class SwiftUIRouteViewBuilderTests: XCTestCase {
    
    func testViewForMessagesRoute_callsFactoryWithExpectedConversation() async throws {
        // Arrange: Create a mock conversation and a mock factory.
        let testConversation = Conversation(id: "testID", name: "Test", lastUpdated: Date(), messages: [])
        let mockFactory = MockRepositoriesFactory()
        
        // Set up a stub repository (could be a dummy implementation).
        mockFactory.stubRepository = DummyMessagesRepository() // your simple stub
        
        let routeBuilder = await SwiftUIRouteViewBuilder(factory: mockFactory)
        
        // Act: Call the view builder.
        let view = await routeBuilder.view(for: .messages(conversation: testConversation))
        
        // Assert: Verify that the factory was called with the test conversation.
        XCTAssertEqual(mockFactory.messagesRepositoryCalledWith?.id, testConversation.id)
        
        //TODO: We're not fully able to test that SwiftUIRouteViewBuilder returns the correct view
        // or assigns it to the view model due to @ViewBuilder, and the opaque return type some view
        // We should cover this with UI integration tests, or use a libary like ViewInspetor
    }
    
    struct DummyMessagesRepository: MessagesRepository {
        var messagesPublisher: AnyPublisher<[Message], Never> = Just([]).eraseToAnyPublisher()
        
        func addMessage(_ message: Message) {
            // No Operation (test only)
        }
    }
}
