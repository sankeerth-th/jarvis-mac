import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("File indexing") {
                Text("v1 indexes only folders you explicitly choose (Desktop/Downloads/Documents recommended).")
                    .font(.callout)
                Text("Full Disk Access is optional and must be enabled in System Settings. The app will never ask for your password.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Voice") {
                Text("v1 uses push-to-talk on ⌘J open. Wake-word comes later.")
                    .font(.callout)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}
