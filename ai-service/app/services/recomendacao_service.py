import numpy as np
import hashlib
import os
from core.ollama_client import gerar_embedding

CACHE_DIR = "/app/embeddings_cache"


def _cache_path(texto: str) -> str:
    chave = hashlib.md5(texto.encode()).hexdigest()
    return os.path.join(CACHE_DIR, f"{chave}.npy")


def _embedding_com_cache(texto: str) -> np.ndarray:
    os.makedirs(CACHE_DIR, exist_ok=True)
    caminho = _cache_path(texto)
    if os.path.exists(caminho):
        return np.load(caminho)
    vetor = gerar_embedding(texto)
    np.save(caminho, vetor)
    return vetor


def _vaga_para_texto(vaga: dict) -> str:
    partes = [
        vaga.get("titulo", ""),
        " ".join(vaga.get("habilidades_requeridas", []) or []),
        " ".join(vaga.get("certificacoes_requeridas", []) or []),
        vaga.get("formacao_desejada", "") or "",
        vaga.get("descricao", "") or "",
    ]
    return " ".join(p for p in partes if p).lower()


def _candidato_para_texto(candidato: dict) -> str:
    partes = [
        candidato.get("nome", ""),
        " ".join(candidato.get("habilidades", []) or []),
        " ".join(candidato.get("certificacoes", []) or []),
        candidato.get("formacao", "") or "",
        candidato.get("resumo", "") or "",
    ]
    return " ".join(p for p in partes if p).lower()


def _contar_tokens(texto: str) -> int:
    """Conta palavras relevantes (ignora tokens < 2 chars)."""
    return len([t for t in texto.split() if len(t) > 2])


def _habilidades_em_comum(
    habilidades_vaga: list[str],
    habilidades_candidato: list[str]
) -> float:
    """
    Retorna fração de habilidades da vaga que o candidato tem.
    Matching parcial: 'python' bate em 'python 3', 'django' bate em 'django rest'.
    """
    if not habilidades_vaga:
        return 0.0

    vaga_norm = [h.lower().strip() for h in habilidades_vaga]
    cand_norm = [h.lower().strip() for h in habilidades_candidato]

    matches = 0
    for hv in vaga_norm:
        for hc in cand_norm:
            if hv in hc or hc in hv:
                matches += 1
                break

    return matches / len(vaga_norm)


def _fator_riqueza_perfil(texto_candidato: str) -> float:
    """
    Penaliza perfis muito vazios.
    < 3 tokens  → 0.4  (forte penalização)
    3–6 tokens  → 0.7
    7–12 tokens → 0.85
    13+  tokens → 1.0  (sem penalização)
    """
    n = _contar_tokens(texto_candidato)
    if n < 3:
        return 0.4
    if n < 7:
        return 0.7
    if n < 13:
        return 0.85
    return 1.0


def recomendar_candidatos(vaga: dict, candidatos: list[dict]) -> list[dict]:
    texto_vaga = _vaga_para_texto(vaga)
    embedding_vaga = _embedding_com_cache(texto_vaga)
    habilidades_vaga = vaga.get("habilidades_requeridas", []) or []

    # embeddings de todos os candidatos
    textos = [_candidato_para_texto(c) for c in candidatos]
    embeddings = [_embedding_com_cache(t) for t in textos]

    # similaridade cosseno vetorizada
    matriz = np.stack(embeddings)
    normas = np.linalg.norm(matriz, axis=1, keepdims=True)
    normas = np.where(normas == 0, 1e-10, normas)
    query_norm = embedding_vaga / (np.linalg.norm(embedding_vaga) + 1e-10)
    scores_cosseno = (matriz / normas) @ query_norm  # (N,) entre 0 e 1

    resultados = []
    for candidato, texto, score_cos in zip(candidatos, textos, scores_cosseno):
        habilidades_cand = candidato.get("habilidades", []) or []

        # fator de habilidades em comum (0.0 a 1.0)
        overlap = _habilidades_em_comum(habilidades_vaga, habilidades_cand)

        # fator de riqueza do perfil (penaliza perfis vazios)
        riqueza = _fator_riqueza_perfil(texto)

        # score final:
        # 50% embedding semântico
        # 30% overlap de habilidades exatas
        # 20% riqueza do perfil
        score_final = (
            0.50 * float(score_cos) +
            0.30 * overlap +
            0.20 * riqueza
        )

        resultados.append({
            "candidatura_id": candidato.get("candidatura_id"),
            "usuario_id": candidato.get("usuario_id"),
            "compatibilidade": round(score_final, 4),
            # campos de debug — remove quando estiver satisfeito
            "_debug": {
                "cosseno": round(float(score_cos), 4),
                "overlap_habilidades": round(overlap, 4),
                "riqueza_perfil": round(riqueza, 4),
                "tokens_perfil": _contar_tokens(texto),
            }
        })

    resultados.sort(key=lambda x: x["compatibilidade"], reverse=True)
    return resultados