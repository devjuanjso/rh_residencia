import os
from joblib import dump, load
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from .utils import perfil_colaborador_para_texto, vaga_para_texto
from colaboradores.models import Colaborador
from vagas.models import Vaga
from candidaturas.models import Candidatura

VETORIZADOR_PATH = "recomendacao/ml_models/vetor_tfidf_vagas.joblib"


def treinar_vetorizador_completo():
    textos = []

    for v in Vaga.objects.all():
        textos.append(vaga_para_texto(v))

    for c in Colaborador.objects.all():
        textos.append(perfil_colaborador_para_texto(c))

    vectorizer = TfidfVectorizer(stop_words=["english", "portuguese"])
    vectorizer.fit(textos)

    os.makedirs(os.path.dirname(VETORIZADOR_PATH), exist_ok=True)
    dump(vectorizer, VETORIZADOR_PATH)

    return vectorizer


def carregar_vetorizador():
    try:
        return load(VETORIZADOR_PATH)
    except FileNotFoundError:
        return None


def recomendar_por_vaga(vaga: Vaga):
    """
    Retorna compatibilidade POR CANDIDATURA
    considerando apenas colaboradores que se candidataram à vaga antes tava trazendo todos as pessoas kkkkk
    """

    candidaturas = (
        Candidatura.objects
        .filter(vaga=vaga)
        .select_related("colaborador")
    )

    if not candidaturas.exists():
        return []

    texto_vaga = vaga_para_texto(vaga)

    vectorizer = carregar_vetorizador()
    if vectorizer is None:
        vectorizer = treinar_vetorizador_completo()

    textos_colaboradores = [
        perfil_colaborador_para_texto(candidatura.colaborador)
        for candidatura in candidaturas
    ]

    vetores = vectorizer.transform([texto_vaga] + textos_colaboradores)
    similaridades = cosine_similarity(vetores[0:1], vetores[1:]).flatten()

    resultados = []
    for candidatura, score in zip(candidaturas, similaridades):
        resultados.append({
            "candidatura_id": str(candidatura.id),
            "colaborador_id": str(candidatura.colaborador.id),
            "compatibilidade": round(float(score), 4),
        })

    resultados.sort(key=lambda x: x["compatibilidade"], reverse=True)
    return resultados
