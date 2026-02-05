from rest_framework import generics, viewsets
from .models import Candidatura
from .serializers import CandidaturaSerializer


# Isso aqui é para mostar as rotas na principal
class CandidaturaViewSet(viewsets.ModelViewSet):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer


class CandidaturaListCreateView(generics.ListCreateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

class CandidaturaListView(generics.ListAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

class CandidaturaRetrieveView(generics.RetrieveAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

class CandidaturaUpdateView(generics.UpdateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

# Futuramente implementa Soft Delete
class CandidaturaDeleteView(generics.DestroyAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

class CandidaturaDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer

class CandidaturaPartialUpdateView(generics.UpdateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    http_method_names = ["patch"]