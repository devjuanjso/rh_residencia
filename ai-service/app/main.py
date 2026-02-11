from fastapi import FastAPI, UploadFile, File, HTTPException
from services.curriculo_service import analisar_curriculo_texto
from pdf_reader import extrair_texto_pdf
import tempfile
import shutil
import os

app = FastAPI(title="RH AI Service")


@app.post("/curriculo/analisar")
async def analisar_curriculo(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(
            status_code=400,
            detail="Arquivo deve ser um PDF"
        )

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            shutil.copyfileobj(file.file, tmp)
            tmp_path = tmp.name

        texto = extrair_texto_pdf(tmp_path)

        if not texto or not texto.strip():
            raise HTTPException(
                status_code=400,
                detail="PDF sem texto extraível"
            )

        resultado = analisar_curriculo_texto(texto)

        return resultado

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro interno: {str(e)}"
        )

    finally:
        if "tmp_path" in locals() and os.path.exists(tmp_path):
            os.remove(tmp_path)
