import json
import re
from core.ollama_client import gerar_resposta

_PROMPT_SUGESTAO = """Você é um consultor especializado em estruturar projetos de inovação e tecnologia.

Um usuário quer criar um projeto com a seguinte ideia:
\"\"\"{descricao}\"\"\"

Com base nisso, retorne SOMENTE um JSON válido, sem texto antes ou depois:

{{
  "nome": "Nome curto e atrativo para o projeto (máx 60 chars)",
  "descricao": "Descrição clara do projeto em 2-4 frases explicando o objetivo e o impacto",
  "tipo": "<um de: produto_digital | servico | pesquisa | outro>",
  "vagas_sugeridas": [
    {{
      "titulo": "Título da vaga",
      "area": "<um de: tecnologia | design | dados | produto | inovacao | negocios | marketing | operacoes>",
      "senioridade": "<um de: estagio | junior | pleno | senior | especialista>",
      "habilidades_requeridas": ["habilidade1", "habilidade2", "habilidade3"],
      "formacao_desejada": "Descrição da formação desejada ou null"
    }}
  ]
}}

Regras:
- Sugira entre 2 e 5 vagas que façam sentido para o projeto descrito
- As habilidades devem ser específicas e relevantes para cada vaga (de 2 a 6 por vaga)
- O tipo deve refletir a natureza do projeto
- Se a ideia for vaga, interprete da forma mais útil possível
"""

_PROMPT_MELHORIA = """Você é um consultor especializado em projetos de inovação.

Um usuário tem o seguinte projeto e quer melhorar sua descrição e estrutura:

Nome atual: {nome}
Descrição atual: {descricao}
Tipo: {tipo}

Retorne SOMENTE um JSON válido:

{{
  "nome": "Nome melhorado (ou o mesmo se já estiver bom)",
  "descricao": "Descrição aprimorada, mais clara e atrativa, em 2-4 frases",
  "sugestoes_vagas": [
    {{
      "titulo": "Vaga sugerida",
      "area": "<tecnologia | design | dados | produto | inovacao | negocios | marketing | operacoes>",
      "senioridade": "<estagio | junior | pleno | senior | especialista>",
      "habilidades_requeridas": ["habilidade1", "habilidade2"],
      "formacao_desejada": null
    }}
  ],
  "dicas": ["dica1 para melhorar o projeto", "dica2"]
}}
"""


def _extrair_json(resposta: str) -> dict:
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


_PROMPT_SUGESTAO_VISAO = """Você é um consultor especializado em projetos de inovação e tecnologia.

As imagens mostram um documento (proposta, briefing ou especificação de projeto).
Leia o conteúdo e retorne SOMENTE um JSON válido:

{
  "nome": "Nome curto e atrativo para o projeto (máx 60 chars)",
  "descricao": "Descrição clara em 2-4 frases explicando o objetivo e o impacto",
  "tipo": "<produto_digital | servico | pesquisa | outro>",
  "vagas_sugeridas": [
    {
      "titulo": "Título da vaga",
      "area": "<tecnologia | design | dados | produto | inovacao | negocios | marketing | operacoes>",
      "senioridade": "<estagio | junior | pleno | senior | especialista>",
      "habilidades_requeridas": ["habilidade1", "habilidade2"],
      "formacao_desejada": null
    }
  ]
}
"""


def sugerir_projeto_visao(paginas: list[str]) -> dict:
    """Sugere projeto a partir de páginas de PDF escaneado (base64)."""
    resposta = gerar_resposta(_PROMPT_SUGESTAO_VISAO, imagens=paginas)
    return _extrair_json(resposta)


def sugerir_projeto(descricao: str) -> dict:
    """
    Dado uma ideia do usuário, sugere nome, descrição, tipo e vagas para o projeto.
    """
    prompt = _PROMPT_SUGESTAO.format(descricao=descricao[:2000])
    resposta = gerar_resposta(prompt)
    return _extrair_json(resposta)


def melhorar_projeto(nome: str, descricao: str, tipo: str) -> dict:
    """
    Dado um projeto existente, sugere melhorias na descrição e novas vagas.
    """
    prompt = _PROMPT_MELHORIA.format(
        nome=nome, descricao=descricao, tipo=tipo or "outro"
    )
    resposta = gerar_resposta(prompt)
    return _extrair_json(resposta)
