import base64
import fitz  # pymupdf


def extrair_texto_pdf(filepath: str) -> str:
    """Extrai todo o texto do PDF usando PyMuPDF (melhor que pypdf para PDFs complexos)."""
    doc = fitz.open(filepath)
    partes = []
    for page in doc:
        texto = page.get_text("text")
        if texto:
            partes.append(texto)
    doc.close()
    return "\n".join(partes)


def extrair_imagens_pdf(filepath: str, max_imagens: int = 8) -> list[str]:
    """
    Extrai imagens embutidas no PDF (ex: foto de perfil do candidato).
    Retorna lista de strings base64 PNG prontas para enviar ao modelo de visão.
    Ignora imagens muito pequenas (ícones, separadores) — mínimo 50x50 px.
    """
    doc = fitz.open(filepath)
    imagens_b64 = []

    for page in doc:
        for img_info in page.get_images(full=True):
            if len(imagens_b64) >= max_imagens:
                break
            xref = img_info[0]
            largura = img_info[2]
            altura = img_info[3]

            # ignora imagens minúsculas (ícones, bullets, etc.)
            if largura < 50 or altura < 50:
                continue

            try:
                img_dict = doc.extract_image(xref)
                img_bytes = img_dict["image"]
                imagens_b64.append(base64.b64encode(img_bytes).decode("utf-8"))
            except Exception:
                continue

        if len(imagens_b64) >= max_imagens:
            break

    doc.close()
    return imagens_b64


def renderizar_paginas_como_imagens(
    filepath: str, max_paginas: int = 3, dpi: int = 150
) -> list[str]:
    """
    Renderiza páginas do PDF como imagens PNG base64.
    Usado como fallback quando o PDF é escaneado (sem texto extraível).
    DPI 150 oferece boa qualidade para OCR via modelo de visão.
    """
    doc = fitz.open(filepath)
    paginas_b64 = []
    escala = dpi / 72  # fator de zoom (72 DPI = padrão PDF)
    matriz = fitz.Matrix(escala, escala)

    for i in range(min(max_paginas, len(doc))):
        pix = doc[i].get_pixmap(matrix=matriz)
        png_bytes = pix.tobytes("png")
        paginas_b64.append(base64.b64encode(png_bytes).decode("utf-8"))

    doc.close()
    return paginas_b64


def eh_pdf_escaneado(texto: str, min_chars: int = 100) -> bool:
    """Retorna True se o texto extraído for curto demais — indica PDF escaneado."""
    return len(texto.strip()) < min_chars
