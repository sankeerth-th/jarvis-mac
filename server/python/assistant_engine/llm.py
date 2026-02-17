import os
from functools import lru_cache

# MLX-LM loads a model from a local path or HF cache.
# For strict offline mode, ship weights locally and point MODEL_PATH to that folder.

DEFAULT_MODEL = os.environ.get("MODEL_ID", "mlx-community/Meta-Llama-3.1-8B-Instruct-4bit")

@lru_cache(maxsize=1)
def get_model_and_tokenizer():
    from mlx_lm import load

    model_id = os.environ.get("MODEL_ID", DEFAULT_MODEL)
    model, tokenizer = load(model_id)
    return model, tokenizer


def generate_text(prompt: str, max_tokens: int = 256, temperature: float = 0.7) -> str:
    from mlx_lm import generate

    model, tokenizer = get_model_and_tokenizer()
    return generate(model, tokenizer, prompt=prompt, max_tokens=max_tokens, temp=temperature)
