from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

from .models import Projeto
from .serializers import ProjetoSerializer


def format_choices(choices):
    return [{"value": c[0], "label": c[1]} for c in choices]


class ProjetoViewSet(viewsets.ModelViewSet):

    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(criado_por=self.request.user)

    @action(detail=False, methods=["get"], url_path="publicados")
    def publicados(self, request):
        projetos = Projeto.objects.filter(rascunho=False).exclude(criado_por=request.user)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["get"], url_path="meus")
    def meus(self, request):
        projetos = Projeto.objects.filter(criado_por=request.user)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["get"], url_path="choices", permission_classes=[AllowAny])
    def choices(self, request):
        return Response({
            "tipos": format_choices(Projeto.TipoProjeto.choices),
        })