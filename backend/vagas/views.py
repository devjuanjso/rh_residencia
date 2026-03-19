from rest_framework import generics, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Vaga
from .serializers import VagaSerializer


class VagaViewSet(viewsets.ModelViewSet):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(criado_por=self.request.user)

    @action(detail=False, url_path="por-projeto/(?P<projeto_id>[^/.]+)")
    def por_projeto(self, request, projeto_id=None):
        vagas = Vaga.objects.filter(projeto_id=projeto_id)
        serializer = self.get_serializer(vagas, many=True)
        return Response(serializer.data)


class VagaListCreateView(generics.ListCreateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(criado_por=self.request.user)


class VagaListView(generics.ListAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]


class VagaRetrieveView(generics.RetrieveAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]


class VagaUpdateView(generics.UpdateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]


class VagaDeleteView(generics.DestroyAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]


class VagaDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]


class VagaPartialUpdateView(generics.UpdateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ["patch"]