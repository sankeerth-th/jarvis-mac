# Jarvis (macOS)

Siri-like local assistant UI.

## v1 goals
- Menu bar app
- Global hotkey: **⌘J**
- On hotkey: show floating panel **and start listening immediately** (push-to-talk v1 = hotkey initiates recording)
- User-selected folders indexing (Desktop/Downloads/Documents) **only**
- No iCloud Drive in v1

## Permissions (later)
- Accessibility (to control apps)
- Full Disk Access (optional, user grants via System Settings — the app must NEVER request passwords)

## Build
This is a SwiftUI macOS app. Open in Xcode to build/run.

> Note: We keep development in VS Code for editing, but Xcode is required to run macOS apps.
