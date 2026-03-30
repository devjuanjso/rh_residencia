from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from services.curriculo_service import analisar_curriculo_texto
from services.recomendacao_service import recomendar_candidatos
from pdf_reader import extrair_texto_pdf
import tempfile, shutil, os

app = FastAPI(title="RH AI Service")

@app.post("/curriculo/analisar")
async def analisar_curriculo(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(400, "Arquivo deve ser um PDF")

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name

        texto = extrair_texto_pdf(tmp_path)
        if not texto or not texto.strip():
            raise HTTPException(400, "PDF sem texto extraível")

        return analisar_curriculo_texto(texto)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(500, f"Erro interno: {str(e)}")
    finally:
        if "tmp_path" in locals() and os.path.exists(tmp_path):
            os.remove(tmp_path)


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


class EmbeddingRequest(BaseModel):
    texto: str


@app.post("/embeddings")
def gerar_embedding_route(req: EmbeddingRequest):
    from core.ollama_client import gerar_embedding
    return {"embedding": gerar_embedding(req.texto).tolist()}


@app.get("/health")
def health():
    return {"status": "ok"}