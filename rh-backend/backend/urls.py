from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.routers import DefaultRouter

from projetos.views import ProjetoViewSet
from vagas.views import VagaViewSet

router = DefaultRouter()
router.register(r'projetos', ProjetoViewSet, basename='projeto')
router.register(r'vagas', VagaViewSet, basename='vaga')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include(router.urls)),
]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
