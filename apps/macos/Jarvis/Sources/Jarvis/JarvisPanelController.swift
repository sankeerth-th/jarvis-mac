import Cocoa
import SwiftUI

final class JarvisPanelController {
    private var panel: NSPanel?
    private var hosting: NSHostingView<JarvisPanelView>?
    private let viewModel = JarvisViewModel()

    func showAndListen() {
        if panel == nil {
            let content = JarvisPanelView(viewModel: viewModel)
            let hosting = NSHostingView(rootView: content)
            self.hosting = hosting

            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 260),
                styleMask: [.titled, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.isMovableByWindowBackground = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.center()
            panel.contentView = hosting
            self.panel = panel
        }

        guard let panel else { return }
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Siri-like: start listening immediately when opened.
        viewModel.startListening()
    }

    func hide() {
        panel?.orderOut(nil)
    }
}
