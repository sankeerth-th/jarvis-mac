# Assistant Engine (Local)

Local-only LLM orchestration service.

## Why a local service?
- Keeps model + data on-device
- Allows macOS app (SwiftUI) to call a stable API locally
- Easy to swap runtimes (MLX-LM now, others later)

## Runtime target
- Apple Silicon + 16GB RAM baseline
- MLX-LM for inference

## Quick start (dev)

```bash
cd server/python
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m assistant_engine.dev_server
```

This binds **localhost only**.

## Notes
- No cloud calls.
- Model weights must be available locally (download once; then offline).
