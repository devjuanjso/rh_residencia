import requests as http_requests
from rest_framework import viewsets, serializers as drf_serializers, status
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
        serializer.save(criado_por=self.request.user, status=Projeto.StatusProjeto.RASCUNHO)

    def perform_update(self, serializer):
        instance = serializer.instance
        new_status = serializer.validated_data.get("status", instance.status)
        if new_status == Projeto.StatusProjeto.PUBLICADO and instance.status != Projeto.StatusProjeto.PUBLICADO:
            tem_vaga_ativa = instance.vagas.filter(encerrada=False).exists()
            if not tem_vaga_ativa:
                raise drf_serializers.ValidationError(
                    {"status": "Para publicar o projeto, é necessário ter pelo menos uma vaga ativa."}
                )
        serializer.save()

    @action(detail=False, methods=["get"], url_path="publicados")
    def publicados(self, request):
        projetos = Projeto.objects.filter(status=Projeto.StatusProjeto.PUBLICADO).exclude(criado_por=request.user)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["get"], url_path="meus")
    def meus(self, request):
        projetos = Projeto.objects.filter(criado_por=request.user)
        serializer = self.get_serializer(projetos, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["post"], url_path="sugerir-por-pdf")
    def sugerir_por_pdf(self, request):
        """
        Recebe um PDF e retorna sugestão de projeto gerada pela IA.
        O cliente deve enviar o arquivo no campo 'file' (multipart/form-data).
        """
        file = request.FILES.get("file")
        if not file:
            return Response({"erro": "Arquivo PDF obrigatório"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            ai_response = http_requests.post(
                "http://ai-service:8001/projeto/sugerir-pdf",
                files={"file": (file.name, file.read(), file.content_type or "application/pdf")},
                timeout=300,
            )
            return Response(ai_response.json(), status=ai_response.status_code)
        except http_requests.exceptions.ConnectionError:
            return Response({"erro": "Serviço de IA indisponível"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except http_requests.exceptions.Timeout:
            return Response({"erro": "Timeout do serviço de IA"}, status=status.HTTP_504_GATEWAY_TIMEOUT)

    @action(detail=False, methods=["post"], url_path="sugerir-por-texto")
    def sugerir_por_texto(self, request):
        """
        Recebe uma descrição textual e retorna sugestão de projeto gerada pela IA.
        """
        descricao = request.data.get("descricao", "").strip()
        if not descricao:
            return Response({"erro": "Descrição obrigatória"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            ai_response = http_requests.post(
                "http://ai-service:8001/projeto/sugerir",
                json={"descricao": descricao},
                timeout=300,
            )
            return Response(ai_response.json(), status=ai_response.status_code)
        except http_requests.exceptions.ConnectionError:
            return Response({"erro": "Serviço de IA indisponível"}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except http_requests.exceptions.Timeout:
            return Response({"erro": "Timeout do serviço de IA"}, status=status.HTTP_504_GATEWAY_TIMEOUT)

    @action(detail=False, methods=["get"], url_path="choices", permission_classes=[AllowAny])
    def choices(self, request):
        return Response({
            "tipos": format_choices(Projeto.TipoProjeto.choices),
        })