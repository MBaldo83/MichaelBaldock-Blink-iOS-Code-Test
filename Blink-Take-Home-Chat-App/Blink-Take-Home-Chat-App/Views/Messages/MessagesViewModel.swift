import Combine
import Foundation
import SwiftUI

@Observable
final class MessagesViewModel {
    var messages: [Message] = []
    var conversationTitle: String
    private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored let messagesRepository: MessagesRepository
    
    init(messagesRepository: MessagesRepository,
         conversationTitle: String) {
        
        self.messagesRepository = messagesRepository
        self.conversationTitle = conversationTitle
        
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
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
