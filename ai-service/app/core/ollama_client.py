import requests
import os

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")

def gerar_resposta(prompt: str) -> dict:
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={
            "model": "llama3.2:3b",
            "prompt": prompt,
            "stream": False,
            "format": "json" 
        },
        timeout=300
    )

    if response.status_code != 200:
        raise Exception(f"Ollama error: {response.text}")

    data = response.json()

    # Quando format=json, o campo response já é JSON string válido
    return data.get("response")
