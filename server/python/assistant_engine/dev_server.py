import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .schemas import (
    GenerateRequest,
    GenerateResponse,
    SummarizeRequest,
    SummarizeResponse,
    EmojiRewriteRequest,
    EmojiRewriteResponse,
    TriageRequest,
    TriageResponse,
    TriageItem,
)
from .providers import generate
from .router import handle

app = FastAPI(title="Mac LLM Assistant Engine", version="0.1.0")

# Local-only usage. SwiftUI app can call http://127.0.0.1:<port>
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://127.0.0.1"],
    allow_credentials=False,
    allow_methods=["*"] ,
    allow_headers=["*"] ,
)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/generate", response_model=GenerateResponse)
def generate(req: GenerateRequest):
    text = generate(req.provider, req.model, req.prompt, max_tokens=req.max_tokens, temperature=req.temperature)
    return {"text": text}

@app.post("/summarize", response_model=SummarizeResponse)
def summarize(req: SummarizeRequest):
    prompt = (
        "Summarize the following text. Be faithful and concise. "
        "Prefer bullet points. If there are action items, include an 'Action Items' section.\n\n"
        f"TEXT:\n{req.text}\n"
    )
    summary = generate(req.provider, req.model, prompt, max_tokens=300, temperature=0.2)
    return {"summary": summary}

@app.post("/emoji-rewrite", response_model=EmojiRewriteResponse)
def emoji_rewrite(req: EmojiRewriteRequest):
    prompt = (
        "Rewrite the text to be clearer and friendlier. Add 0-6 appropriate emojis max. "
        "Do not change meaning.\n\n"
        f"TEXT:\n{req.text}\n"
    )
    rewritten = generate(req.provider, req.model, prompt, max_tokens=300, temperature=0.5)
    return {"rewritten": rewritten}

@app.post("/triage", response_model=TriageResponse)
def triage(req: TriageRequest):
    # v0: simple heuristic stub; later we will use model classification.
    prioritized = set([a.lower() for a in req.priority_apps])

    out = []
    for item in req.items:
        appname = (item.app or "").lower()
        if appname in prioritized:
            priority = "P1"
            reason = "From prioritized app"
        else:
            priority = "P2"
            reason = "Default priority"
        out.append(
            TriageItem(
                app=item.app,
                title=item.title,
                body=item.body,
                priority=priority,
                reason=reason,
            )
        )

    return TriageResponse(items=out)


@app.post("/chat")
def chat(req: GenerateRequest):
    # Reuse GenerateRequest for now (prompt + provider + model). We'll evolve schema later.
    roots = os.environ.get("JARVIS_ROOTS")
    root_list = [r for r in (roots.split(":" ) if roots else []) if r]
    return handle(req.provider, req.model, req.prompt, roots=root_list or None)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("assistant_engine.dev_server:app", host="127.0.0.1", port=8787, reload=True)
