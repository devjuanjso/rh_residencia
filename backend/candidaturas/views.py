from rest_framework import generics, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from .models import Candidatura
from .serializers import CandidaturaSerializer


class CandidaturaViewSet(viewsets.ModelViewSet):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

    @action(detail=False, methods=["get"], url_path="minhas")
    def minhas_candidaturas(self, request):
        vagas = Candidatura.objects.filter(
            usuario=request.user
        ).values_list("vaga", flat=True)

        return Response([str(v) for v in vagas])


class CandidaturaListCreateView(generics.ListCreateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)


class CandidaturaListView(generics.ListAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]


class CandidaturaRetrieveView(generics.RetrieveAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]


class CandidaturaUpdateView(generics.UpdateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]


class CandidaturaDeleteView(generics.DestroyAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]


class CandidaturaDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]


class CandidaturaPartialUpdateView(generics.UpdateAPIView):
    queryset = Candidatura.objects.all()
    serializer_class = CandidaturaSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ["patch"]