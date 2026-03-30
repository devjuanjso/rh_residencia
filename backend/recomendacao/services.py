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
                "nome": f"{c.usuario.first_name} {c.usuario.last_name}",
                "habilidades": c.usuario.habilidades or [],
                "certificacoes": c.usuario.certificacoes or [],
                "formacao": getattr(c.usuario, "formacao", "") or "",
                "resumo": getattr(c.usuario, "resumo", "") or "",
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
    return response.json()