import SwiftUI

struct ModelSetupView: View {
    @StateObject private var vm = ModelSetupViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Model Setup")
                .font(.system(size: 18, weight: .semibold))

            Text("Jarvis runs locally. Choose an on-device model runtime.")
                .foregroundStyle(.secondary)

            GroupBox("Detected") {
                VStack(alignment: .leading, spacing: 10) {
                    if vm.ollamaInstalled {
                        Text("✅ Ollama found")
                    } else {
                        Text("⚠️ Ollama not found")
                    }

                    if vm.ollamaInstalled {
                        if vm.ollamaModels.isEmpty {
                            Text("No Ollama models found. You can install a recommended model.")
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("Installed models", selection: $vm.selectedOllamaModel) {
                                ForEach(vm.ollamaModels, id: \.self) { model in
                                    Text(model).tag(Optional(model))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    Divider()

                    HStack {
                        Button("Refresh") { vm.refresh() }
                        Spacer()
                    }
                }
                .padding(.top, 4)
            }

            GroupBox("Recommended") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recommended model: \(vm.recommendedModel)")
                    Text("This downloads once. After that, Jarvis works offline.")
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Button("Install recommended") {
                            vm.installRecommended()
                        }
                        .disabled(!vm.ollamaInstalled || vm.installing)

                        Button("Copy install command") {
                            vm.copyRecommendedCommand()
                        }
                        .disabled(!vm.ollamaInstalled)

                        Spacer()
                    }

                    if !vm.status.isEmpty {
                        Text(vm.status)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }

                    if !vm.ollamaInstalled {
                        Divider()
                        Text("To install Ollama (local runtime):")
                        Text("brew install ollama")
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .padding(.top, 4)
            }

            Divider()

            HStack {
                Button("Use selected model") {
                    vm.saveSelection()
                }
                .disabled(vm.selectedOllamaModel == nil)

                Spacer()

                Button("Close") {
                    NSApp.keyWindow?.close()
                }
            }
        }
        .padding(18)
        .frame(width: 560)
        .onAppear { vm.refresh() }
    }
}
