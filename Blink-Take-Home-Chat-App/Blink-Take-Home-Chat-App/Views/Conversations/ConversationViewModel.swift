import Combine
import Foundation
import SwiftUI

@Observable
final class ConversationsViewModel {
    var conversations: [Conversation] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Exposing the repository for tests, but not for observation
    @ObservationIgnored let repository: ConversationsRepository
    
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

