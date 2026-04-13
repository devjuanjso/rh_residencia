from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import Candidatura
from .serializers import CandidaturaSerializer


class CandidaturaViewSet(viewsets.ModelViewSet):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

    @action(detail=False, methods=["get"], url_path="minhas")
    def minhas_candidaturas(self, request):
        candidaturas = Candidatura.objects.filter(
            usuario=request.user
        ).select_related("vaga", "vaga__projeto")
        serializer = CandidaturaSerializer(candidaturas, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=["patch"], url_path="decidir")
    def decidir(self, request, pk=None):
        candidatura = self.get_object()
        decisao = request.data.get("status")

        if decisao not in ("aceito", "rejeitado"):
            return Response(
                {"detail": "Status inválido. Use 'aceito' ou 'rejeitado'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if candidatura.vaga.projeto.criado_por != request.user:
            return Response(
                {"detail": "Sem permissão."},
                status=status.HTTP_403_FORBIDDEN,
            )

        if candidatura.status != "pendente":
            return Response(
                {"detail": f"Candidatura já foi '{candidatura.status}'."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        candidatura.status = decisao
        candidatura.save(update_fields=["status"])

        return Response({
            "candidatura_id": str(candidatura.id),
            "status": candidatura.status,
        })