import SwiftUI

@main
struct Blink_Take_Home_Chat_App: App {
    
    let repositoryFactory = RepositoriesFactory()
    
    var body: some Scene {
        WindowGroup {
            ConversationsView(
                viewModel: ConversationsViewModel(
                    repository: repositoryFactory.conversationsRepository()
                ),
                router: Router(
                    routeViewBuilder: SwiftUIRouteViewBuilder(
                        messagesRepository: repositoryFactory.messagesRepository(conversation:)
                    )
                )
            )
        }
    }
}
