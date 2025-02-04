import SwiftUI

struct ConversationsView: View {
    @State var viewModel: ConversationsViewModel
    @State var router: Router
    
    var body: some View {
        NavigationStack(path: $router.routePath) {
            List(viewModel.conversations) { conversation in
                Button(action: {
                    router.navigateTo(.messages(conversation: conversation))
                }) {
                    VStack(alignment: .leading) {
                        Text(conversation.name)
                            .font(.headline)
                        Text("Last updated: \(viewModel.format(conversation.lastUpdated))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Conversations")
            .navigationDestination(for: Router.Route.self) { route in
                router.view(for: route)
            }
        }
    }
}

