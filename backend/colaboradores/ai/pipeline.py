import requests
import json
import os
import re

from .pdf_reader import extrair_texto_pdf

# URL do Ollama dentro do docker-compose
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama:11434")


def analisar_curriculo(file):
    # Extrai texto do PDF
    texto = extrair_texto_pdf(file)

    if not texto or not texto.strip():
        return {
            "erro": "PDF sem texto extraível"
        }

    prompt = f"""
Você é um extrator de informações.
NÃO analise, NÃO interprete, NÃO faça suposições.

Extraia APENAS informações que estejam EXPLICITAMENTE escritas no currículo.
Se algo não existir, use null, lista vazia ou 0.

Retorne SOMENTE um JSON VÁLIDO, sem texto extra.

Formato:
{{
  "habilidades": [],
  "certificacoes": [],
  "formacao": null,
  "tempo_experiencia_meses": 0
}}

Currículo:
\"\"\"
{texto}
\"\"\"
"""

    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/generate",
            headers={
                "Content-Type": "application/json"
            },
            json={
                "model": "llama3.2:3b",
                "prompt": prompt,
                "stream": False
            },
            timeout=300
        )
    except requests.exceptions.Timeout:
        return {
            "erro": "Timeout ao comunicar com o Ollama"
        }
    except requests.exceptions.ConnectionError:
        return {
            "erro": "Não foi possível conectar ao Ollama"
        }
    except Exception as e:
        return {
            "erro": "Erro inesperado ao chamar o Ollama",
            "detail": str(e)
        }

    if response.status_code != 200:
        return {
            "erro": "Erro ao comunicar com o Ollama",
            "status": response.status_code,
            "raw": response.text
        }

    try:
        result = response.json()
    except ValueError:
        return {
            "erro": "Resposta não é JSON válido",
            "raw": response.text
        }

    texto_resposta = result.get("response")

    if not texto_resposta:
        return {
            "erro": "Resposta vazia do Ollama",
            "raw": result
        }

    # 🧼 Extrai somente o JSON da resposta
    match = re.search(r"\{[\s\S]*\}", texto_resposta)
    if not match:
        return {
            "erro": "Nenhum JSON encontrado na resposta",
            "raw": texto_resposta
        }

    json_limpo = match.group()

    try:
        return json.loads(json_limpo)
    except json.JSONDecodeError:
        return {
            "erro": "JSON inválido retornado pelo modelo",
            "raw": json_limpo
        }