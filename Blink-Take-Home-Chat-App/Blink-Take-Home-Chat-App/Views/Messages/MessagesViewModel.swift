import Combine
import Foundation

class MessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []
    let conversation: Conversation
    private var cancellables = Set<AnyCancellable>()
    
    // Now using the dedicated messages repository.
    private let messagesRepository: MessagesRepository
    
    init(conversation: Conversation,
         messagesRepository: MessagesRepository) {
        self.conversation = conversation
        self.messagesRepository = messagesRepository
        
        messagesRepository.messagesPublisher
            .map { messages in
                // Sort messages with the oldest first.
                messages.sorted { $0.lastUpdated < $1.lastUpdated }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.messages, on: self)
            .store(in: &cancellables)
    }
    
    func sendMessage(text: String) {
        let newMessage = Message(
            id: UUID().uuidString,  // Generate a unique id.
            text: text,
            lastUpdated: Date()
        )
        messagesRepository.addMessage(newMessage)
    }
}
