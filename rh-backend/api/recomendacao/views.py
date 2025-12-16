from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status
from vagas.models import Vaga
from .services import recomendar_colaboradores
from .serializers import RecomendacaoSerializer

class RecomendacaoViewSet(viewsets.ViewSet):
    """
    Recomendação por vaga.
    Ex: GET /recomendacoes/?vaga=<uuid>
    """

    def list(self, request):
        vaga_id = request.query_params.get("vaga")

        if not vaga_id:
            return Response(
                {"error": "Parâmetro 'vaga' obrigatório"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        vaga_id = vaga_id.strip().replace("/", "")

        try:
            vaga = Vaga.objects.get(id=vaga_id)
        except Vaga.DoesNotExist:
            return Response(
                {"error": "Vaga não encontrada"},
                status=status.HTTP_404_NOT_FOUND,
            )

        resultados = recomendar_colaboradores(vaga)
        serializer = RecomendacaoSerializer(resultados, many=True)
        return Response(serializer.data)
