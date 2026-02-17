# Roadmap

## Phase 0 — Define scope (today)
- Decide model runtime: MLX-LM vs llama.cpp
- Pick 1–2 target Macs (M1/M2/M3?)
- Define "done" for v1

## Phase 1 — Local text assistant (1–2 days)
- Local model runner
- Summarization endpoint
- Emoji-enhanced rewrite endpoint
- Basic macOS UI: paste text → summary

## Phase 2 — Reminders (2–4 days)
- Extract reminder candidates from text
- Create reminders via EventKit
- UI approval flow

## Phase 3 — Notification triage (time varies)
- Define notification schema
- Priority classifier + grouping
- Practical ingestion approach (app-specific connectors or user-forward)

## Phase 4 — Personalization (later)
- Local preferences
- Optional LoRA fine-tune
- On-device embeddings for your notes (RAG)
