import os
import requests
import numpy as np
from fastembed import TextEmbedding

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
MODELO_TEXTO = os.getenv("MODELO_TEXTO", "llama-3.3-70b-versatile")
MODELO_VISAO = os.getenv(
    "MODELO_VISAO", "meta-llama/llama-4-scout-17b-16e-instruct"
)
MODELO_EMBEDDINGS = os.getenv(
    "MODELO_EMBEDDINGS",
    "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
)
FASTEMBED_CACHE = os.getenv("FASTEMBED_CACHE", "/app/fastembed_models")

_GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

_embedding_model: TextEmbedding | None = None


def _get_embedding_model() -> TextEmbedding:
    global _embedding_model
    if _embedding_model is None:
        _embedding_model = TextEmbedding(
            model_name=MODELO_EMBEDDINGS,
            cache_dir=FASTEMBED_CACHE,
        )
    return _embedding_model


def _check_key():
    if not GROQ_API_KEY:
        raise RuntimeError(
            "GROQ_API_KEY não configurada. Defina no .env do ai-service."
        )


def _build_messages(prompt: str, imagens: list[str] | None) -> list[dict]:
    if not imagens:
        return [{"role": "user", "content": prompt}]

    content: list[dict] = [{"type": "text", "text": prompt}]
    for img_b64 in imagens:
        content.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{img_b64}"},
        })
    return [{"role": "user", "content": content}]


def _gerar(prompt: str, imagens: list[str] | None, json_mode: bool) -> str:
    _check_key()
    modelo = MODELO_VISAO if imagens else MODELO_TEXTO

    payload: dict = {
        "model": modelo,
        "messages": _build_messages(prompt, imagens),
        "temperature": 0.7,
    }
    # JSON mode só funciona com modelos texto na Groq
    if json_mode and not imagens:
        payload["response_format"] = {"type": "json_object"}

    response = requests.post(
        _GROQ_URL,
        json=payload,
        headers={"Authorization": f"Bearer {GROQ_API_KEY}"},
        timeout=600,
    )
    if response.status_code != 200:
        raise Exception(f"Groq error {response.status_code}: {response.text}")

    return response.json()["choices"][0]["message"]["content"]


def gerar_resposta(prompt: str, imagens: list[str] | None = None) -> str:
    return _gerar(prompt, imagens, json_mode=True)


def gerar_resposta_livre(prompt: str) -> str:
    return _gerar(prompt, None, json_mode=False)


def gerar_embedding(texto: str) -> np.ndarray:
    model = _get_embedding_model()
    vetor = next(iter(model.embed([texto])))
    return np.asarray(vetor, dtype=np.float32)
