import SwiftUI

struct SettingsView: View {
    @State private var showModelSetup = false

    var body: some View {
        Form {
            Section("File indexing") {
                Text("v1 indexes only folders you explicitly choose (Desktop/Downloads/Documents recommended).")
                    .font(.callout)
                Text("Full Disk Access is optional and must be enabled in System Settings. The app will never ask for your password.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Model") {
                Button("Open Model Setup") {
                    showModelSetup = true
                }
                .buttonStyle(.bordered)

                let provider = UserDefaults.standard.string(forKey: "jarvis.modelProvider") ?? "(not set)"
                let name = UserDefaults.standard.string(forKey: "jarvis.modelName") ?? ""
                Text("Current: \(provider) \(name)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Voice") {
                Text("v1 uses push-to-talk on open. Wake-word comes later.")
                    .font(.callout)
            }
        }
        .padding(20)
        .frame(width: 520)
        .sheet(isPresented: $showModelSetup) {
            ModelSetupView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openModelSetup)) { _ in
            showModelSetup = true
        }
    }
}
