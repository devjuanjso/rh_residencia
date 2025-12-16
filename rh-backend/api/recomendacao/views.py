from rest_framework import viewsets, status
from rest_framework.response import Response
from vagas.models import Vaga
from .services import recomendar_por_vaga
from .serializers import RecomendacaoCandidaturaSerializer

class RecomendacaoViewSet(viewsets.ViewSet):
    """
    GET /recomendacoes/?vaga=<uuid>
    """

    def list(self, request):
        vaga_id = request.query_params.get("vaga")

        if not vaga_id:
            return Response(
                {"error": "Parâmetro 'vaga' obrigatório"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            vaga = Vaga.objects.get(id=vaga_id)
        except Vaga.DoesNotExist:
            return Response(
                {"error": "Vaga não encontrada"},
                status=status.HTTP_404_NOT_FOUND,
            )

        resultados = recomendar_por_vaga(vaga)
        serializer = RecomendacaoCandidaturaSerializer(resultados, many=True)
        return Response(serializer.data)
