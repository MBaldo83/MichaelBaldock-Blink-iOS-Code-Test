import SwiftUI

struct MessagesView: View {
    @State var viewModel: MessagesViewModel
    @State private var replyText: String = ""
    
    var body: some View {
        VStack {
            List(viewModel.messages) { message in
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                    Text("\(viewModel.format(message.lastUpdated))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .listStyle(PlainListStyle())
            
            Divider()
            
            HStack {
                TextField("Type your reply...", text: $replyText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard !replyText.isEmpty else { return }
                    viewModel.sendMessage(text: replyText)
                    replyText = ""
                }) {
                    Text("Send")
                        .bold()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(viewModel.conversationTitle)
    }
}
