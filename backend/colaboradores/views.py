from rest_framework import generics, viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Colaborador
from .serializers import ColaboradorSerializer
import requests


# Isso aqui é para mostar as rotas na principal

class ColaboradorViewSet(viewsets.ModelViewSet):
    queryset = Colaborador.objects.all()
    serializer_class = ColaboradorSerializer

    # POST /colaboradores/analisar-curriculo/
    @action(
        detail=False,
        methods=["post"],
        url_path="analisar-curriculo"
    )
    def analisar_curriculo(self, request):
        file = request.FILES.get("file")

        if not file:
            return Response(
                {"error": "Arquivo PDF é obrigatório"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            response = requests.post(
                "http://ai-service:8001/curriculo/analisar",
                files={"file": file},
                timeout=300
            )

            resultado = response.json()

        except requests.exceptions.ConnectionError:
            return Response(
                {"erro": "Não foi possível conectar ao serviço de IA"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        except requests.exceptions.Timeout:
            return Response(
                {"erro": "Timeout ao chamar serviço de IA"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        if response.status_code != 200:
            return Response(
                resultado,
                status=response.status_code
            )

        return Response(
            {
                "sugestao_ia": resultado
            },
            status=status.HTTP_200_OK
        )

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