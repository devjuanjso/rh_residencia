import re

def limpar_texto(texto: str):
    texto = texto.lower()
    texto = re.sub(r"[^a-zA-Z0-9áéíóúâêîôûãõç ]", " ", texto)
    return texto

def vaga_para_texto(vaga):
    partes = [
        vaga.titulo,
        vaga.descricao,
        " ".join(vaga.habilidades_requeridas),
        " ".join(vaga.certificacoes_requeridas),
        vaga.formacao_desejada or ""
    ]
    return limpar_texto(" ".join(str(p) for p in partes if p))

def perfil_colaborador_para_texto(colab):
    partes = [
        colab.nome,
        " ".join(colab.habilidades),
        " ".join(colab.certificacoes),
        colab.formacao or "",
    ]
    return limpar_texto(" ".join(str(p) for p in partes if p))