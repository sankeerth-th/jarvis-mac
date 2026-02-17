import SwiftUI

struct JarvisPanelView: View {
    @ObservedObject var viewModel: JarvisViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Jarvis")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Text(viewModel.isListening ? "Listening…" : "Idle")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            TextField("Ask me to summarize, find files, set reminders…", text: $viewModel.typedQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit { viewModel.submitTextQuery() }

            HStack(spacing: 10) {
                Button {
                    viewModel.isListening ? viewModel.stopListening() : viewModel.startListening()
                } label: {
                    Label(viewModel.isListening ? "Stop" : "Speak", systemImage: viewModel.isListening ? "stop.circle" : "mic.fill")
                }

                Button("Send") {
                    viewModel.submitTextQuery()
                }
                .keyboardShortcut(.defaultAction)

                Spacer()
            }

            ScrollView {
                Text(viewModel.responseText.isEmpty ? "" : viewModel.responseText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .underPageBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
