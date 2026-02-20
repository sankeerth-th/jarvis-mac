# jarvis-mac

A **local-first, 100% offline** (after install) Siri-style assistant for **Apple Silicon Macs**.

Jarvis focuses on:
- Fast, faithful **note summarization**
- **Text generation** and emoji-enhanced rewrites
- **Reminders planning** (create via EventKit with user approval)
- **Notification triage** (prioritize by selected apps) using on-device intelligence
- **File search by meaning** (OCR + PDF text extraction + local indexing)

> Status: early prototype. UI + local engine scaffolding is in place. Wake word and full file indexing are on the roadmap.

## Why this exists
Siri is great for timers and quick commands, but it’s not a great *notes assistant*. Jarvis is designed to help you:
- turn messy notes into clean summaries
- extract action items
- draft messages
- triage what deserves your attention

All without sending your data to the cloud.

## Key guarantees
- **No cloud APIs**. No OpenAI. No remote inference.
- Local HTTP service binds to `127.0.0.1` only.
- Your data stays on your Mac.

## Repository layout

- `server/python/` — local assistant engine (FastAPI + MLX-LM)
- `apps/macos/Jarvis/` — SwiftUI macOS app (menu bar + floating panel + ⌘J)
- `docs/` — architecture and roadmap

## Install (easy)

### Option 1: DMG (recommended)
If you just want to install Jarvis on a Mac (no Xcode):
- Go to **Releases**
- Download `Jarvis.dmg`
- Open it and drag `Jarvis.app` into `Applications`

> Note: Unsigned DMG (v0). Gatekeeper may require right‑click → **Open** the first time.

### Uninstall
- Quit Jarvis
- Delete `/Applications/Jarvis.app`

Optional cleanup:
```bash
./scripts/uninstall.sh
```

## Quick start (dev)

### 1) Start the local engine

```bash
cd server/python
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m assistant_engine.dev_server
```

Engine runs on: `http://127.0.0.1:8787`

### 2) Run the macOS app

Open `apps/macos/Jarvis` in **Xcode** (required for macOS apps), build and run.

- Press **⌘⌥J** (Cmd+Option+J) to open Jarvis
- v1 behavior: **opens and starts listening immediately**

## Permissions & Safety

### Folder access (v1)
- Jarvis will index **only folders you explicitly choose**.
- iCloud Drive support is deferred to a later release.

### Full Disk Access (optional)
macOS requires the user to grant Full Disk Access in **System Settings → Privacy & Security → Full Disk Access**.

- Jarvis will never ask for your password.
- If you choose to enable Full Disk Access, macOS may prompt you via an OS dialog.

### Accessibility (later)
Controlling other apps requires Accessibility permissions. This will be added with explicit user approvals.

## Voice (offline)
- v1 uses push-to-talk. Wake word is planned.
- The current Swift speech layer is a placeholder; for guaranteed offline voice for all users we will integrate **whisper.cpp**.

## License
Apache-2.0 (see `LICENSE`).
