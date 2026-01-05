from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter
from django.http import JsonResponse

from projetos.views import ProjetoViewSet
from vagas.views import VagaViewSet
from colaboradores.views import ColaboradorViewSet
from candidaturas.views import CandidaturaViewSet
from recomendacao.views import RecomendacaoViewSet

router = DefaultRouter()
router.register(r'projetos', ProjetoViewSet, basename='projeto')
router.register(r'vagas', VagaViewSet, basename='vaga')
router.register(r'colaboadores', ColaboradorViewSet, basename='colaboador')
router.register(r'candidaturas', CandidaturaViewSet, basename='candidatura')
router.register(r'recomendacoes', RecomendacaoViewSet, basename='recomendacao')

def ping(request):
    print('🔥 PING RECEBIDO DO FLUTTER')
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
    path('ping/', ping),
]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
