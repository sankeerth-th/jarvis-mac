import Foundation
import Combine

@MainActor
final class JarvisViewModel: ObservableObject {
    @Published var typedQuery: String = ""
    @Published var responseText: String = ""
    @Published var isListening: Bool = false

    private let engine = LocalAssistantEngineClient(baseURL: URL(string: "http://127.0.0.1:8787")!)
    private let stt = SpeechToTextController()

    func startListening() {
        guard !isListening else { return }
        isListening = true
        responseText = ""

        // v1: We start recording and return text when done.
        // In v1 we use Apple's Speech framework as a placeholder.
        // For strict offline reliability for all users, we will replace with whisper.cpp.
        stt.start { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isListening = false
                switch result {
                case .success(let text):
                    self.typedQuery = text
                    await self.submitTextQuery()
                case .failure(let err):
                    self.responseText = "Speech error: \(err.localizedDescription)"
                }
            }
        }
    }

    func stopListening() {
        guard isListening else { return }
        stt.stop()
        isListening = false
    }

    func submitTextQuery() async {
        let q = typedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        responseText = "Thinking…"

        do {
            // Simple routing v1: if user says summarize, hit summarize; else generate.
            if q.lowercased().hasPrefix("summarize") {
                let text = q.replacingOccurrences(of: "summarize", with: "", options: .caseInsensitive)
                let summary = try await engine.summarize(text: text)
                responseText = summary
            } else if q.lowercased().contains("emoji") {
                let rewritten = try await engine.emojiRewrite(text: q)
                responseText = rewritten
            } else {
                let out = try await engine.generate(prompt: q)
                responseText = out
            }
        } catch {
            responseText = "Engine error: \(error.localizedDescription)"
        }
    }

    func submitTextQuery() {
        Task { await submitTextQuery() }
    }
}
