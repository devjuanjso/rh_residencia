from rest_framework import generics, viewsets
from .models import Vaga
from .serializers import VagaSerializer
from rest_framework.decorators import action
from rest_framework.response import Response

# Isso aqui é para mostar as rotas na principal
class VagaViewSet(viewsets.ModelViewSet):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

    @action(detail=False, url_path="por-projeto/(?P<projeto_id>[^/.]+)")
    def por_projeto(self, request, projeto_id=None):
        vagas = Vaga.objects.filter(projeto_id=projeto_id)
        serializer = self.get_serializer(vagas, many=True)
        return Response(serializer.data)

class VagaListCreateView(generics.ListCreateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

class VagaListView(generics.ListAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

class VagaRetrieveView(generics.RetrieveAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

class VagaUpdateView(generics.UpdateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

# Futuramente implementa Soft Delete
class VagaDeleteView(generics.DestroyAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

class VagaDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer

class VagaPartialUpdateView(generics.UpdateAPIView):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer
    http_method_names = ["patch"]