from rest_framework import viewsets, generics
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth import get_user_model
from .serializers import UserSerializer, RegisterSerializer
from rest_framework.decorators import action
from rest_framework.response import Response

User = get_user_model()


def format_choices(choices):
    """
    Converte choices do Django para formato amigável para frontend
    """
    return [{"value": c[0], "label": c[1]} for c in choices]


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

    @action(detail=False, methods=["get"], url_path="choices", permission_classes=[AllowAny])
    def choices(self, request):
        """
        Retorna todas as opções de selects usadas no User
        """
        return Response({
            "roles": format_choices(User.RoleChoices.choices),
            "cargos": format_choices(User.CargoChoices.choices),
            "senioridades": format_choices(User.SenioridadeChoices.choices),
            "areas": format_choices(User.AreaChoices.choices),
        })


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]