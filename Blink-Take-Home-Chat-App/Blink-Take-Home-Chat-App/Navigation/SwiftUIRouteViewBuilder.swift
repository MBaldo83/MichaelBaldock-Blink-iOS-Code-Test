import SwiftUI

@MainActor
final class SwiftUIRouteViewBuilder {
    
    let factory: RepositoriesFactory
    
    init(factory: RepositoriesFactory) {
        self.factory = factory
    }
    
    @ViewBuilder func view(for route: Router.Route) -> some View {
        
        switch route {
        case .messages(let conversation):
            MessagesView(
                viewModel: MessagesViewModel(
                    messagesRepository: self.factory.messagesRepository(
                        conversation: conversation
                    ),
                    conversationTitle: conversation.name
                )
            )
        }
    }
}
