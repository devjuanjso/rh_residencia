import os
import requests
import numpy as np

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
MODELO_TEXTO = os.getenv("MODELO_TEXTO", "gemini-2.0-flash")
MODELO_EMBEDDINGS = os.getenv("MODELO_EMBEDDINGS", "text-embedding-004")

_BASE_URL = "https://generativelanguage.googleapis.com/v1beta"


def _check_key():
    if not GEMINI_API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY não configurada. Defina no .env do ai-service."
        )


def _build_parts(prompt: str, imagens: list[str] | None = None) -> list[dict]:
    parts: list[dict] = [{"text": prompt}]
    if imagens:
        for img_b64 in imagens:
            parts.append({
                "inline_data": {
                    "mime_type": "image/png",
                    "data": img_b64,
                }
            })
    return parts


def _gerar(prompt: str, imagens: list[str] | None, json_mode: bool) -> str:
    _check_key()
    url = f"{_BASE_URL}/models/{MODELO_TEXTO}:generateContent?key={GEMINI_API_KEY}"
    payload: dict = {
        "contents": [{"parts": _build_parts(prompt, imagens)}],
    }
    if json_mode:
        payload["generationConfig"] = {"response_mime_type": "application/json"}

    response = requests.post(url, json=payload, timeout=600)
    if response.status_code != 200:
        raise Exception(f"Gemini error {response.status_code}: {response.text}")

    data = response.json()
    candidates = data.get("candidates", [])
    if not candidates:
        return ""
    parts = candidates[0].get("content", {}).get("parts", [])
    return "".join(p.get("text", "") for p in parts)


def gerar_resposta(prompt: str, imagens: list[str] | None = None) -> str:
    """Gera resposta JSON-formatada (usado para extrações estruturadas)."""
    return _gerar(prompt, imagens, json_mode=True)


def gerar_resposta_livre(prompt: str) -> str:
    """Gera resposta em texto livre."""
    return _gerar(prompt, None, json_mode=False)


def gerar_embedding(texto: str) -> np.ndarray:
    _check_key()
    url = (
        f"{_BASE_URL}/models/{MODELO_EMBEDDINGS}:embedContent"
        f"?key={GEMINI_API_KEY}"
    )
    payload = {
        "model": f"models/{MODELO_EMBEDDINGS}",
        "content": {"parts": [{"text": texto}]},
    }
    response = requests.post(url, json=payload, timeout=60)
    if response.status_code != 200:
        raise Exception(f"Gemini embeddings error: {response.text}")
    valores = response.json()["embedding"]["values"]
    return np.array(valores, dtype=np.float32)
