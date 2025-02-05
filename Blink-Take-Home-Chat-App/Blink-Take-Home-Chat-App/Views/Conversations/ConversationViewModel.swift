import Combine
import Foundation
import SwiftUI

final class ConversationsViewModel: ObservableObject {
    
    @Published var conversations: [Conversation] = []
    
    private var cancellables = Set<AnyCancellable>()
    let repository: ConversationsRepository
    
    init(repository: ConversationsRepository) {
        self.repository = repository
        repository.conversationsPublisher
            .map { conversations in
                // Sort conversations (newest updated first)
                conversations.sorted { $0.lastUpdated > $1.lastUpdated }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.conversations, on: self)
            .store(in: &cancellables)
    }
    
    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

