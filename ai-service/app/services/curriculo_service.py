import json
import re
from core.ollama_client import gerar_resposta

_PROMPT_EXTRACAO = """Você é um extrator especializado em currículos profissionais.

Analise o currículo abaixo e retorne SOMENTE um JSON válido, sem nenhum texto antes ou depois.

Extraia apenas os campos abaixo. Não invente nada que não esteja explícito no texto.

Formato obrigatório:
{{
  "nome": "Nome completo ou null",
  "email": "email@exemplo.com ou null",
  "formacao": "Grau + Curso + Instituição da graduação mais recente, ex: Bacharelado em Ciência da Computação - USP, ou null",
  "habilidades": ["tecnologia1", "framework2", "ferramenta3"],
  "certificacoes": ["Certificação A", "Curso com certificado B"]
}}

Regras:
- formacao: apenas graduação (bacharelado, licenciatura, tecnólogo). Ignore cursos livres, MBA, pós, certificações.
- habilidades: tecnologias, linguagens, frameworks, ferramentas, metodologias
- certificacoes: apenas cursos com certificado ou certificações técnicas reconhecidas
- Se um campo não existir no currículo, use null ou lista vazia []

Currículo:
\"\"\"
{texto}
\"\"\"
"""

_PROMPT_VISAO = """Você é um extrator especializado em currículos profissionais.

As imagens fornecidas são páginas de um currículo escaneado. Leia todo o conteúdo visível
e retorne SOMENTE um JSON válido, sem nenhum texto antes ou depois.

Extraia apenas os campos abaixo. Não invente nada que não esteja visível.

Formato obrigatório:
{{
  "nome": "Nome completo ou null",
  "email": "email@exemplo.com ou null",
  "formacao": "Grau + Curso + Instituição da graduação mais recente ou null",
  "habilidades": ["tecnologia1", "framework2"],
  "certificacoes": ["Certificação A"]
}}

Regras:
- formacao: apenas graduação. Ignore cursos livres, MBA, pós, certificações.
- habilidades: tecnologias, linguagens, frameworks, ferramentas, metodologias
- certificacoes: apenas cursos com certificado ou certificações técnicas
- Se um campo não for legível ou não existir, use null ou []
"""


def _extrair_json(resposta: str) -> dict:
    """Extrai JSON da resposta mesmo que o modelo adicione texto ao redor."""
    if not resposta:
        return {"erro": "Resposta vazia do modelo"}

    try:
        return json.loads(resposta)
    except json.JSONDecodeError:
        pass

    match = re.search(r"\{.*\}", resposta, re.DOTALL)
    if match:
        try:
            return json.loads(match.group())
        except json.JSONDecodeError:
            pass

    return {"erro": "Modelo não retornou JSON válido", "raw": resposta[:500]}


def analisar_curriculo_texto(
    texto: str,
    imagens_embutidas: list[str] | None = None,
    paginas_escaneadas: list[str] | None = None,
) -> dict:
    """
    Analisa um currículo e retorna dados estruturados mapeados para o model User.

    Campos retornados: nome, email, formacao, habilidades, certificacoes
    Foto é ignorada (upload separado). Demais campos não existem no model.

    - texto: texto extraído do PDF (tem prioridade)
    - imagens_embutidas: opcionais, ignoradas na análise (não são do currículo)
    - paginas_escaneadas: páginas renderizadas quando o PDF é escaneado (sem texto)
    """

    # PDF escaneado → usa visão para ler as páginas
    if paginas_escaneadas:
        resposta = gerar_resposta(_PROMPT_VISAO, imagens=paginas_escaneadas)
        resultado = _extrair_json(resposta)
        resultado["_modo"] = "visao_ocr"
        return resultado

    # PDF com texto → extração textual
    # imagens embutidas (ex: foto de perfil) são ignoradas — não agregam à extração
    prompt = _PROMPT_EXTRACAO.format(texto=texto[:8000])
    resposta = gerar_resposta(prompt)
    resultado = _extrair_json(resposta)
    resultado["_modo"] = "texto"
    return resultado