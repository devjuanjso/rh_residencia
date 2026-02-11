from core.ollama_client import gerar_resposta
import json


def analisar_curriculo_texto(texto: str):
    prompt = f"""
Você é um extrator de informações.

NÃO analise.
NÃO interprete.
NÃO explique nada.

Retorne APENAS JSON válido no formato:

{{
  "habilidades": [],
  "certificacoes": [],
  "formacao": null
}}

Se algo não existir, use lista vazia ou null.

Currículo:
\"\"\" 
{texto}
\"\"\"
"""

    resposta = gerar_resposta(prompt)

    if not resposta:
        return {"erro": "Resposta vazia do modelo"}

    try:
        return json.loads(resposta)
    except json.JSONDecodeError:
        return {
            "erro": "Modelo não retornou JSON válido",
            "raw": resposta
        }
