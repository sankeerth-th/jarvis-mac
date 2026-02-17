import Cocoa
import SwiftUI
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotkey: GlobalHotKey?
    private let panelController = JarvisPanelController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupHotKey()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "Jarvis"
            button.action = #selector(toggleJarvis)
            button.target = self
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Jarvis (⌘J)", action: #selector(openJarvis), keyEquivalent: "j"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func setupHotKey() {
        hotkey = GlobalHotKey(keyCode: kVK_ANSI_J, modifiers: [.command]) { [weak self] in
            self?.openJarvis()
        }
        hotkey?.register()
    }

    @objc private func toggleJarvis() {
        openJarvis()
    }

    @objc private func openJarvis() {
        panelController.showAndListen()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
