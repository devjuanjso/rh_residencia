from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from .models import Candidatura
from .serializers import CandidaturaSerializer, CandidaturaComUsuarioSerializer
from vagas.models import Vaga


class CandidaturaViewSet(viewsets.ModelViewSet):
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # decidir precisa acessar candidaturas de outros usuários (dono do projeto decide)
        if self.action == "decidir":
            return Candidatura.objects.select_related("vaga", "vaga__projeto")
        return Candidatura.objects.filter(usuario=self.request.user).select_related("vaga", "vaga__projeto")

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

    @action(detail=False, methods=["get"], url_path="por-vaga/(?P<vaga_id>[^/.]+)")
    def por_vaga(self, request, vaga_id=None):
        try:
            vaga = Vaga.objects.select_related("projeto").get(pk=vaga_id)
        except Vaga.DoesNotExist:
            return Response({"detail": "Vaga não encontrada."}, status=status.HTTP_404_NOT_FOUND)

        if vaga.projeto.criado_por != request.user:
            return Response({"detail": "Sem permissão."}, status=status.HTTP_403_FORBIDDEN)

        candidaturas = Candidatura.objects.filter(vaga=vaga).select_related("usuario", "vaga", "vaga__projeto")
        serializer = CandidaturaComUsuarioSerializer(candidaturas, many=True, context={"request": request})
        return Response(serializer.data)