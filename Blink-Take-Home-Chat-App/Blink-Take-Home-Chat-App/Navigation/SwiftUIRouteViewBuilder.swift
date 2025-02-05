import SwiftUI

@MainActor
final class SwiftUIRouteViewBuilder {
    
    let messagesRepository: (Conversation) -> MessagesRepository
    
    init(messagesRepository: @escaping (Conversation) -> MessagesRepository) {
        self.messagesRepository = messagesRepository
    }
    
    func view(for route: Router.Route) -> some View {
        
        switch route {
        case .messages(let conversation):
            MessagesView(
                viewModel: MessagesViewModel(
                    messagesRepository: self.messagesRepository(
                        conversation
                    ),
                    conversationTitle: conversation.name
                )
            )
        }
    }
}
