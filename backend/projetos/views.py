from rest_framework import generics, viewsets
from .models import Projeto
from .serializers import ProjetoSerializer


# Isso aqui é para mostar as rotas na principal
class ProjetoViewSet(viewsets.ModelViewSet):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer


class ProjetoListCreateView(generics.ListCreateAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer


class ProjetoListView(generics.ListAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer

class ProjetoListView(generics.ListAPIView):
    serializer_class = ProjetoSerializer

    def get_queryset(self):
        queryset = Projeto.objects.all()
        publicado = self.request.query_params.get('publicado')

        if publicado == 'true':
            queryset = queryset.filter(rascunho=False)

        return queryset

class ProjetoRetrieveView(generics.RetrieveAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer

class ProjetoUpdateView(generics.UpdateAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer

# Futuramente implementa Soft Delete
class ProjetoDeleteView(generics.DestroyAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer

class ProjetoDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer

class ProjetoPartialUpdateView(generics.UpdateAPIView):
    queryset = Projeto.objects.all()
    serializer_class = ProjetoSerializer
    http_method_names = ["patch"]