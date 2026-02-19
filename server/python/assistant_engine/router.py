import json
from typing import Any, Dict, List, Optional, Tuple

from .providers import generate
from .tools import run_tool

SYSTEM = """You are Jarvis, a local macOS assistant.

You can call tools to:
- find files (Spotlight)
- open apps
- reveal/open files

Rules:
- Never invent file paths.
- Prefer using tools when user asks to find/open something.
- If a tool is needed, respond ONLY with a single line JSON object of the form:
  {"tool": "tool_name", "args": {...}, "explain": "short user-facing reason"}
- If no tool needed, respond with normal text.
"""


def decide(provider: str, model: str, user_text: str) -> str:
    prompt = f"{SYSTEM}\nUSER: {user_text}\n"
    return generate(provider, model, prompt, max_tokens=400, temperature=0.2)


def handle(provider: str, model: str, user_text: str, roots: Optional[List[str]] = None) -> Dict[str, Any]:
    """One-step tool calling loop (v1)."""
    raw = decide(provider, model, user_text)

    raw_stripped = raw.strip()
    if raw_stripped.startswith("{") and "\"tool\"" in raw_stripped:
        try:
            obj = json.loads(raw_stripped)
            tool = obj.get("tool")
            args = obj.get("args") or {}

            # Inject roots if provided and tool supports it.
            if tool == "find_files" and roots is not None and "roots" not in args:
                args["roots"] = roots

            result = run_tool(tool, args)

            if not result.ok:
                return {
                    "type": "tool_error",
                    "tool": tool,
                    "args": args,
                    "error": result.error,
                    "raw": raw,
                }

            # Ask model to summarize results for user.
            followup = (
                "You called a tool and got results. "
                "Respond to the user with the best matches and what you can do next (open/reveal).\n\n"
                f"USER: {user_text}\n"
                f"TOOL: {tool}\nARGS: {json.dumps(args)}\nRESULT: {json.dumps(result.data)}\n"
            )
            final = generate(provider, model, followup, max_tokens=300, temperature=0.3)
            return {
                "type": "tool_result",
                "tool": tool,
                "args": args,
                "result": result.data,
                "answer": final.strip(),
            }
        except Exception:
            # If model produced invalid JSON, fall back to raw.
            return {"type": "text", "answer": raw_stripped, "raw": raw}

    return {"type": "text", "answer": raw_stripped, "raw": raw}
