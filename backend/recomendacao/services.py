import requests
import os
from vagas.models import Vaga
from candidaturas.models import Candidatura

AI_SERVICE_URL = os.getenv("AI_SERVICE_URL", "http://ai-service:8001")


def recomendar_por_vaga(vaga: Vaga) -> list[dict]:
    candidaturas = (
        Candidatura.objects
        .filter(vaga=vaga)
        .select_related("usuario")
    )

    if not candidaturas.exists():
        return []

    candidatos_map = {str(c.id): c for c in candidaturas}

    payload = {
        "vaga": {
            "titulo": vaga.titulo,
            "habilidades_requeridas": vaga.habilidades_requeridas or [],
            "certificacoes_requeridas": vaga.certificacoes_requeridas or [],
            "formacao_desejada": vaga.formacao_desejada or "",
            "descricao": getattr(vaga, "descricao", "") or "",
        },
        "candidatos": [
            {
                "candidatura_id": str(c.id),
                "usuario_id": str(c.usuario.id),
                "nome": c.usuario.get_full_name() or c.usuario.username,
                "habilidades": c.usuario.habilidades or [],
                "certificacoes": c.usuario.certificacoes or [],
                "formacao": c.usuario.formacao or "",
                "bio": c.usuario.bio or "",
            }
            for c in candidaturas
        ],
    }

    response = requests.post(
        f"{AI_SERVICE_URL}/recomendacao/vaga",
        json=payload,
        timeout=120,
    )
    response.raise_for_status()
    resultados_ia = response.json()

    enriquecidos = []
    for item in resultados_ia:
        candidatura = candidatos_map.get(item["candidatura_id"])
        if not candidatura:
            continue

        u = candidatura.usuario
        enriquecidos.append({
            **item,
            "nome": u.get_full_name() or u.username,
            "email": u.email,
            "cargo": u.cargo,
            "senioridade": u.senioridade,
            "area": u.area,
            "habilidades": u.habilidades or [],
            "certificacoes": u.certificacoes or [],
            "formacao": u.formacao,
            "linkedin": u.linkedin,
            "foto": u.foto.url if u.foto else None,
            "bio": u.bio,
        })

    return enriquecidos