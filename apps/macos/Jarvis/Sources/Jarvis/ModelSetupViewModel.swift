import Foundation
import AppKit

@MainActor
final class ModelSetupViewModel: ObservableObject {
    @Published var ollamaInstalled: Bool = false
    @Published var ollamaModels: [String] = []
    @Published var selectedOllamaModel: String? = nil
    @Published var installing: Bool = false
    @Published var status: String = ""

    let recommendedModel = "llama3.1:8b"

    func refresh() {
        status = ""
        ollamaInstalled = (Shell.which("ollama") != nil)
        if ollamaInstalled {
            ollamaModels = Shell.ollamaListModels()
            if selectedOllamaModel == nil {
                selectedOllamaModel = ollamaModels.first
            }
        } else {
            ollamaModels = []
            selectedOllamaModel = nil
        }
    }

    func copyRecommendedCommand() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("ollama pull \(recommendedModel)", forType: .string)
        status = "Copied: ollama pull \(recommendedModel)"
    }

    func installRecommended() {
        guard ollamaInstalled else { return }
        installing = true
        status = "Installing \(recommendedModel)…\n"

        Task {
            do {
                let output = try await Shell.runStreaming(["ollama", "pull", recommendedModel]) { chunk in
                    Task { @MainActor in
                        self.status += chunk
                    }
                }
                _ = output
                status += "\n✅ Install complete."
                installing = false
                refresh()
            } catch {
                status += "\n❌ Install failed: \(error.localizedDescription)"
                installing = false
            }
        }
    }

    func saveSelection() {
        guard let model = selectedOllamaModel else { return }
        UserDefaults.standard.set("ollama", forKey: "jarvis.modelProvider")
        UserDefaults.standard.set(model, forKey: "jarvis.modelName")
        status = "Saved selection: ollama / \(model)"
    }
}
