import SwiftUI

struct MessagesView: View {
    @StateObject var viewModel: MessagesViewModel
    @State private var replyText: String = ""
    
    var body: some View {
        VStack {
            List(viewModel.messages) { message in
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                    Text("\(message.lastUpdated, formatter: dateFormatter)")
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
        .navigationTitle(viewModel.conversation.name)
    }
}
