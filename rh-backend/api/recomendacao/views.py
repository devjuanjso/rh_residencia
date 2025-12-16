from rest_framework import viewsets, status
from rest_framework.response import Response
from vagas.models import Vaga
from .services import recomendar_por_vaga
from .serializers import RecomendacaoCandidaturaSerializer


class RecomendacaoViewSet(viewsets.ViewSet):
    """
    GET /recomendacoes/<uuid>
    """

    def list(self, request):
        return Response(
            {
                "detail": "Use /recomendacoes/<uuid-da-vaga>/ para obter recomendações."
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    def retrieve(self, request, pk=None):
        try:
            vaga = Vaga.objects.get(id=pk)
        except Vaga.DoesNotExist:
            return Response(
                {"error": "Vaga não encontrada"},
                status=status.HTTP_404_NOT_FOUND,
            )

        resultados = recomendar_por_vaga(vaga)
        serializer = RecomendacaoCandidaturaSerializer(resultados, many=True)
        return Response(serializer.data)
