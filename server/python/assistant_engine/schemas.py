from pydantic import BaseModel, Field
from typing import List, Optional, Literal

class GenerateRequest(BaseModel):
    prompt: str
    max_tokens: int = 256
    temperature: float = 0.7

class GenerateResponse(BaseModel):
    text: str

class SummarizeRequest(BaseModel):
    text: str
    style: Literal["bullets", "meeting", "tldr"] = "bullets"

class SummarizeResponse(BaseModel):
    summary: str

class EmojiRewriteRequest(BaseModel):
    text: str

class EmojiRewriteResponse(BaseModel):
    rewritten: str

class NotificationItem(BaseModel):
    app: str
    title: Optional[str] = None
    body: str
    timestamp_iso: Optional[str] = None

class TriageRequest(BaseModel):
    items: List[NotificationItem]
    priority_apps: List[str] = Field(default_factory=list)

class TriageItem(BaseModel):
    app: str
    title: Optional[str]
    body: str
    priority: Literal["P0", "P1", "P2", "P3"]
    reason: str

class TriageResponse(BaseModel):
    items: List[TriageItem]
