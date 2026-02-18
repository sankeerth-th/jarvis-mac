import subprocess
from .llm import generate_text


def generate(provider: str, model: str, prompt: str, max_tokens: int, temperature: float) -> str:
    provider = (provider or "mlx").lower()

    if provider == "ollama":
        if not model:
            raise ValueError("Ollama provider requires 'model'")
        # ollama run <model> <prompt>
        # Note: this uses local ollama daemon; still fully offline after the model is present.
        result = subprocess.run(
            ["ollama", "run", model, prompt],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise RuntimeError(result.stderr.strip() or "ollama run failed")
        return result.stdout.strip()

    # default: MLX
    return generate_text(prompt, max_tokens=max_tokens, temperature=temperature)
