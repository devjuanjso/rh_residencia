import requests
import os
import numpy as np

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")


def gerar_resposta(prompt: str) -> str:
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={
            "model": "llama3.2:3b",
            "prompt": prompt,
            "stream": False,
            "format": "json",
        },
        timeout=300,
    )
    if response.status_code != 200:
        raise Exception(f"Ollama error: {response.text}")
    return response.json().get("response")


def gerar_embedding(texto: str) -> np.ndarray:
    response = requests.post(
        f"{OLLAMA_URL}/api/embeddings",
        json={"model": "nomic-embed-text", "prompt": texto},
        timeout=60,
    )
    if response.status_code != 200:
        raise Exception(f"Ollama embeddings error: {response.text}")
    return np.array(response.json()["embedding"], dtype=np.float32)