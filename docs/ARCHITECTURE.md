# Architecture

## Components

### 1) Model Runtime (Local)
Two viable options:
- **MLX-LM** (best on Apple Silicon): fast, simple local deployment.
- **llama.cpp**: portable, works on Intel too (slower).

Model candidates (examples):
- Llama 3.2 3B Instruct
- Qwen2.5 3B/7B Instruct
- Phi-3.5 mini

Selection criteria:
- Quality on summarization + instruction following
- Speed on Mac
- Memory footprint

### 2) Assistant Orchestrator (Local)
Responsibilities:
- Prompt templates (summarize, reply drafting, emoji suggestion)
- Tool routing (reminders, calendar, notification triage)
- Guardrails (don’t send messages, don’t spend money, etc.)

Interface:
- Local HTTP API or local IPC.

### 3) macOS App (SwiftUI)
Features:
- Menu bar entry
- Hotkey to open “Summarize” window
- Notes summarization view
- Notification triage view
- Reminder creation UI

Permissions:
- EventKit (Reminders)
- Notifications (to post notifications). Reading system notifications is limited; use user-forwarding or app extensions.

## Notification ingestion options
macOS does not provide a simple universal API to read all notifications.
Pragmatic v1:
- User forwards/exports notifications (or the app captures its own inbox)
- Later: integrate specific apps (Gmail/Slack/Calendar APIs) or use Apple Mail rules + local parsing.

## Training/Fine-tuning (Optional)
- Start with prompt engineering + eval set.
- If needed: LoRA fine-tune on summarization style + reminder extraction.

Evaluation:
- Summary faithfulness
- Brevity control
- Action extraction accuracy (reminders)
- Notification priority classification
