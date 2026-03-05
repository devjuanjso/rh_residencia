from rest_framework import viewsets, generics
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import get_user_model
from .serializers import UserSerializer, RegisterSerializer
from rest_framework.decorators import action
from rest_framework.response import Response

User = get_user_model()


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=["get", "patch"], url_path="me")
    def me(self, request):
        """
        GET  -> Retorna usuário autenticado
        PATCH -> Atualiza usuário autenticado
        """

        if request.method == "GET":
            serializer = self.get_serializer(request.user)
            return Response(serializer.data)

        if request.method == "PATCH":
            serializer = self.get_serializer(
                request.user,
                data=request.data,
                partial=True  # Permite atualizar parcialmente
            )

            serializer.is_valid(raise_exception=True)
            serializer.save()

            return Response(serializer.data)

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]