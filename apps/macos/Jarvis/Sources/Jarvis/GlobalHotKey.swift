import Cocoa
import Carbon

/// Minimal Carbon global hotkey wrapper.
/// Works for ⌘J even when the app is not focused.
final class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private let keyCode: UInt32
    private let modifiers: UInt32
    private let handler: () -> Void

    private static var handlers: [UInt32: () -> Void] = [:]
    private static var nextId: UInt32 = 1

    private let id: UInt32

    init(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        self.keyCode = keyCode
        self.modifiers = GlobalHotKey.carbonFlags(from: modifiers)
        self.handler = handler
        self.id = GlobalHotKey.nextId
        GlobalHotKey.nextId += 1
        GlobalHotKey.handlers[self.id] = handler
    }

    @discardableResult
    func register() -> Bool {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            var hotKeyId = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout.size(ofValue: hotKeyId), nil, &hotKeyId)
            let id = hotKeyId.id
            if let h = GlobalHotKey.handlers[id] { h() }
            return noErr
        }, 1, &eventType, nil, nil)

        var hotKeyID = EventHotKeyID(signature: OSType(UInt32(truncatingIfNeeded: 0x4A525653)), id: id) // 'JRVS'
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        return status == noErr
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        GlobalHotKey.handlers[id] = nil
    }

    deinit {
        unregister()
    }

    private static func carbonFlags(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        if flags.contains(.option) { carbon |= UInt32(optionKey) }
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        if flags.contains(.shift) { carbon |= UInt32(shiftKey) }
        return carbon
    }
}
