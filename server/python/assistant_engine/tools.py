import json
import os
import subprocess
from dataclasses import dataclass
from typing import Any, Dict, List, Optional


@dataclass
class ToolResult:
    ok: bool
    data: Any = None
    error: Optional[str] = None


def _run(cmd: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True)


def open_app(app_name: str) -> ToolResult:
    if not app_name:
        return ToolResult(ok=False, error="app_name required")
    p = _run(["open", "-a", app_name])
    if p.returncode != 0:
        return ToolResult(ok=False, error=p.stderr.strip() or p.stdout.strip() or "open -a failed")
    return ToolResult(ok=True, data={"app": app_name})


def reveal_in_finder(path: str) -> ToolResult:
    if not path:
        return ToolResult(ok=False, error="path required")
    p = _run(["open", "-R", path])
    if p.returncode != 0:
        return ToolResult(ok=False, error=p.stderr.strip() or p.stdout.strip() or "open -R failed")
    return ToolResult(ok=True, data={"path": path})


def open_file(path: str) -> ToolResult:
    if not path:
        return ToolResult(ok=False, error="path required")
    p = _run(["open", path])
    if p.returncode != 0:
        return ToolResult(ok=False, error=p.stderr.strip() or p.stdout.strip() or "open failed")
    return ToolResult(ok=True, data={"path": path})


def find_files(query: str, roots: Optional[List[str]] = None, limit: int = 20) -> ToolResult:
    """Use Spotlight metadata search (mdfind). This is fast and leverages macOS indexing.

    query: human query like "driving license" or "resume ui developer".
    roots: optional list of directories to constrain search (user-selected folders).
    """
    if not query:
        return ToolResult(ok=False, error="query required")

    # Search both filename and content.
    # kMDItemTextContent is indexed for many file types (PDF, docx, txt, etc.).
    # The 'c' suffix means case-insensitive.
    md_query = (
        f"(kMDItemFSName == '*{query}*'c) || (kMDItemTextContent == '*{query}*'c)"
    )

    cmd = ["mdfind"]
    if roots:
        for r in roots:
            cmd += ["-onlyin", r]
    cmd += [md_query]

    p = _run(cmd)
    if p.returncode != 0:
        return ToolResult(ok=False, error=p.stderr.strip() or "mdfind failed")

    paths = [line.strip() for line in p.stdout.splitlines() if line.strip()]

    # Basic filtering: prefer user files over system.
    paths = [x for x in paths if not x.startswith("/System/") and not x.startswith("/Library/")]

    out = []
    for path in paths[: max(limit, 1)]:
        out.append({
            "path": path,
            "name": os.path.basename(path),
        })

    return ToolResult(ok=True, data={"results": out, "count": len(out)})


TOOL_REGISTRY = {
    "open_app": open_app,
    "reveal_in_finder": reveal_in_finder,
    "open_file": open_file,
    "find_files": find_files,
}


def run_tool(name: str, args: Dict[str, Any]) -> ToolResult:
    fn = TOOL_REGISTRY.get(name)
    if not fn:
        return ToolResult(ok=False, error=f"Unknown tool: {name}")
    try:
        return fn(**args)
    except TypeError as e:
        return ToolResult(ok=False, error=f"Bad args for {name}: {e}")
    except Exception as e:
        return ToolResult(ok=False, error=str(e))
