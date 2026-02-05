from pypdf import PdfReader

def extrair_texto_pdf(file):
    reader = PdfReader(file)
    texto = ""

    for page in reader.pages:
        texto += page.extract_text() or ""

    return texto
