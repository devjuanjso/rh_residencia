from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Projeto
from .serializers import ProjetoSerializer


class ProjetoViewSet(viewsets.ModelViewSet):

    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(criado_por=self.request.user)

    # Retorna apenas projetos publicados
    @action(detail=False, methods=["get"], url_path="publicados")
    def publicados(self, request):
        projetos = Projeto.objects.filter(rascunho=False)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)

    # Retorna projetos criados pelo usuário logado
    @action(
        detail=False,
        methods=["get"],
        permission_classes=[IsAuthenticated],
        url_path="meus"
    )
    def meus(self, request):
        projetos = Projeto.objects.filter(criado_por=request.user)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)