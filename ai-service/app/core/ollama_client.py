import requests
import os
import numpy as np

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")
MODELO_TEXTO = os.getenv("MODELO_TEXTO", "gemma3:4b")
MODELO_EMBEDDINGS = os.getenv("MODELO_EMBEDDINGS", "nomic-embed-text")


def gerar_resposta(prompt: str, imagens: list[str] | None = None) -> str:
    payload = {
        "model": MODELO_TEXTO,
        "prompt": prompt,
        "stream": False,
        "format": "json",
    }
    if imagens:
        payload["images"] = imagens

    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json=payload,
        timeout=600,
    )
    if response.status_code != 200:
        raise Exception(f"Ollama error {response.status_code}: {response.text}")
    return response.json().get("response", "")


def gerar_resposta_livre(prompt: str) -> str:
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={
            "model": MODELO_TEXTO,
            "prompt": prompt,
            "stream": False,
        },
        timeout=600,
    )
    if response.status_code != 200:
        raise Exception(f"Ollama error {response.status_code}: {response.text}")
    return response.json().get("response", "")


def gerar_embedding(texto: str) -> np.ndarray:
    response = requests.post(
        f"{OLLAMA_URL}/api/embeddings",
        json={"model": MODELO_EMBEDDINGS, "prompt": texto},
        timeout=60,
    )
    if response.status_code != 200:
        raise Exception(f"Ollama embeddings error: {response.text}")
    return np.array(response.json()["embedding"], dtype=np.float32)
