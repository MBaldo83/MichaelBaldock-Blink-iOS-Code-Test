import Combine
import Foundation

final class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Exposing the repository in case it is needed for navigation.
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
}

