from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from accounts.views import RegisterView, UserViewSet
from projetos.views import ProjetoViewSet
from vagas.views import VagaViewSet
from colaboradores.views import ColaboradorViewSet
from candidaturas.views import CandidaturaViewSet
from recomendacao.views import RecomendacaoViewSet

router = DefaultRouter()
router.register(r'projetos', ProjetoViewSet, basename='projeto')
router.register(r'vagas', VagaViewSet, basename='vaga')
router.register(r'colaboradores', ColaboradorViewSet, basename='colaborador')
router.register(r'candidaturas', CandidaturaViewSet, basename='candidatura')
router.register(r'recomendacoes', RecomendacaoViewSet, basename='recomendacao')
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api-auth/', include('rest_framework.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)