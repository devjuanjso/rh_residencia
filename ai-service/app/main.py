import os
import shutil
import tempfile

from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel

from core.ollama_client import gerar_embedding
from pdf_reader import (
    extrair_texto_pdf,
    extrair_imagens_pdf,
    renderizar_paginas_como_imagens,
    eh_pdf_escaneado,
)
from services.curriculo_service import analisar_curriculo_texto
from services.recomendacao_service import recomendar_candidatos
from services.projeto_service import sugerir_projeto, melhorar_projeto

app = FastAPI(title="RH AI Service")


# ─────────────────────────────────────────────
# Currículo
# ─────────────────────────────────────────────

@app.post("/curriculo/analisar")
async def analisar_curriculo(file: UploadFile = File(...)):
    """
    Analisa um currículo em PDF e retorna dados estruturados.

    - Se o PDF contiver texto: extrai e analisa via LLM.
    - Se o PDF for escaneado (sem texto): renderiza páginas e usa visão do LLM.
    - Imagens embutidas no PDF (ex: foto de perfil) são extraídas e enviadas
      ao modelo multimodal para enriquecer a análise.
    """
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(400, "Arquivo deve ser um PDF")

    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name

        texto = extrair_texto_pdf(tmp_path)
        imagens_embutidas = extrair_imagens_pdf(tmp_path, max_imagens=5)

        if eh_pdf_escaneado(texto):
            # PDF escaneado → renderiza páginas para OCR via visão
            paginas = renderizar_paginas_como_imagens(tmp_path, max_paginas=3)
            if not paginas:
                raise HTTPException(
                    400, "PDF sem conteúdo extraível (nem texto nem imagens)"
                )
            return analisar_curriculo_texto(
                texto="", paginas_escaneadas=paginas
            )

        return analisar_curriculo_texto(
            texto=texto,
            imagens_embutidas=imagens_embutidas or None,
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)


# ─────────────────────────────────────────────
# Projeto
# ─────────────────────────────────────────────

class SugestaoProjetoRequest(BaseModel):
    descricao: str


class MelhoriaProjetoRequest(BaseModel):
    nome: str
    descricao: str
    tipo: str | None = None


@app.post("/projeto/sugerir-pdf")
async def sugerir_projeto_pdf_route(file: UploadFile = File(...)):
    """
    Recebe um PDF (proposta, briefing, documento de projeto) e retorna
    sugestão estruturada com nome, descrição, tipo e vagas.
    """
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(400, "Arquivo deve ser um PDF")

    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name

        texto = extrair_texto_pdf(tmp_path)

        if eh_pdf_escaneado(texto):
            paginas = renderizar_paginas_como_imagens(tmp_path, max_paginas=3)
            if not paginas:
                raise HTTPException(400, "PDF sem conteúdo extraível")
            from services.projeto_service import sugerir_projeto_visao
            return sugerir_projeto_visao(paginas)

        return sugerir_projeto(texto[:4000])

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)


@app.post("/projeto/sugerir")
async def sugerir_projeto_route(req: SugestaoProjetoRequest):
    """
    Recebe uma ideia de projeto em linguagem natural e retorna sugestão
    estruturada com nome, descrição, tipo e vagas recomendadas.
    """
    if not req.descricao or not req.descricao.strip():
        raise HTTPException(400, "Descrição não pode estar vazia")
    try:
        return sugerir_projeto(req.descricao.strip())
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")


@app.post("/projeto/melhorar")
async def melhorar_projeto_route(req: MelhoriaProjetoRequest):
    """
    Recebe um projeto existente e retorna sugestões de melhoria na descrição,
    novas vagas e dicas gerais.
    """
    if not req.nome or not req.descricao:
        raise HTTPException(400, "Nome e descrição são obrigatórios")
    try:
        return melhorar_projeto(req.nome, req.descricao, req.tipo or "outro")
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")


# ─────────────────────────────────────────────
# Recomendação
# ─────────────────────────────────────────────

class RecomendacaoRequest(BaseModel):
    vaga: dict
    candidatos: list[dict]


@app.post("/recomendacao/vaga")
async def recomendar_por_vaga(req: RecomendacaoRequest):
    if not req.candidatos:
        return []
    try:
        return recomendar_candidatos(req.vaga, req.candidatos)
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")


# ─────────────────────────────────────────────
# Utilitários
# ─────────────────────────────────────────────

class EmbeddingRequest(BaseModel):
    texto: str


@app.post("/embeddings")
def gerar_embedding_route(req: EmbeddingRequest):
    return {"embedding": gerar_embedding(req.texto).tolist()}


@app.get("/health")
def health():
    return {"status": "ok"}
