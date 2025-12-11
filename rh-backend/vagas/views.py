from rest_framework import generics, viewsets
from .models import Vaga
from .serializers import VagaSerializer


# Isso aqui é para mostar as rotas na principal
class VagaViewSet(viewsets.ModelViewSet):
    queryset = Vaga.objects.all()
    serializer_class = VagaSerializer


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