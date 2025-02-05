import XCTest
import Combine
@testable import Blink_Take_Home_Chat_App

final class MockMessagesRepository: MessagesRepository {
    let messagesSubject = PassthroughSubject<[Message], Never>()
    var addedMessages: [Message] = []
    
    var messagesPublisher: AnyPublisher<[Message], Never> {
        messagesSubject.eraseToAnyPublisher()
    }
    
    func addMessage(_ message: Message) {
        addedMessages.append(message)
    }
}

final class MessagesViewModelTests: XCTestCase {
    
    var viewModel: MessagesViewModel!
    var mockRepository: MockMessagesRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMessagesRepository()
        // Create the view model using the mock repository.
        viewModel = MessagesViewModel(
            messagesRepository: mockRepository,
            conversationTitle: "Test Conversation"
        )
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testConversationTitle_IsSetCorrectly() {
        XCTAssertEqual(viewModel.conversationTitle, "Test Conversation")
    }
    
    func testMessagesAreSortedAndUpdated() {
        
        let message1 = Message(id: "1", text: "Hello", lastUpdated: Date(timeIntervalSince1970: 1000))
        let message2 = Message(id: "2", text: "World", lastUpdated: Date(timeIntervalSince1970: 500))
        let message3 = Message(id: "3", text: "Test", lastUpdated: Date(timeIntervalSince1970: 1500))
        
        // The expected sorted order is by lastUpdated ascending
        let expectedSortedMessages = [message2, message1, message3]
        
        let expectation = self.expectation(description: "Messages should be updated and sorted")
        viewModel.$messages
            .dropFirst() // Skip the initial value.
            .sink { messages in
                if messages == expectedSortedMessages {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
    
        mockRepository.messagesSubject.send([message1, message2, message3])
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSendMessage_CallsRepositoryAddMessage() {
        
        viewModel.sendMessage(text: "Test message")
        XCTAssertEqual(mockRepository.addedMessages.count, 1)
        XCTAssertEqual(mockRepository.addedMessages.first?.text, "Test message")
    }
    
    func testFormat_ReturnsNonEmptyString() {
        let testDate = Date(timeIntervalSince1970: 1000)
        let formatted = viewModel.format(testDate)
        XCTAssertFalse(formatted.isEmpty, "Formatted date string should not be empty")
    }
}
