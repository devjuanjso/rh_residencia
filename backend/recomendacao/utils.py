import re


def limpar_texto(texto: str):
    texto = texto.lower()
    texto = re.sub(r"[^a-zA-Z0-9áéíóúâêîôûãõç ]", " ", texto)
    return texto


def vaga_para_texto(vaga):
    partes = [
        vaga.titulo,
        vaga.descricao,
        " ".join(vaga.habilidades_requeridas or []),
        " ".join(vaga.certificacoes_requeridas or []),
        vaga.formacao_desejada or "",
    ]
    return limpar_texto(" ".join(str(p) for p in partes if p))


def perfil_usuario_para_texto(user):
    partes = [
        user.first_name,
        user.last_name,
        user.email,
        " ".join(user.habilidades or []),
        " ".join(user.certificacoes or []),
        getattr(user, "formacao", "") or "",
    ]
    return limpar_texto(" ".join(str(p) for p in partes if p))