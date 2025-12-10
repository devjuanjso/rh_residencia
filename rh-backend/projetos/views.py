from rest_framework import generics
from .models import Projeto
from .serializers import ProjetoSerializer

class ProjetoCreateView(generics.CreateAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer
    
class ProjetoListCreateView(generics.ListCreateAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer


class ProjetoDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer
