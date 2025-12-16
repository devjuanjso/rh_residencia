from rest_framework import generics, viewsets
from .models import Colaborador
from .serializers import ColaboradorSerializer


# Isso aqui é para mostar as rotas na principal
class ColaboradorViewSet(viewsets.ModelViewSet):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer


class ColaboradorListCreateView(generics.ListCreateAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer


class ColaboradorListView(generics.ListAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

class ColaboradorRetrieveView(generics.RetrieveAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

class ColaboradorUpdateView(generics.UpdateAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

# Futuramente implementa Soft Delete
class ColaboradorDeleteView(generics.DestroyAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

class ColaboradorDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

class ColaboradorPartialUpdateView(generics.UpdateAPIView):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer
    http_method_names = ["patch"]