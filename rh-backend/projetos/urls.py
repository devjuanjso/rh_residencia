from django.urls import path
from .views import ProjetoCreateView, ProjetoListCreateView, ProjetoDetailView

urlpatterns = [
    path('', ProjetoListCreateView.as_view()),
    path('<uuid:pk>/', ProjetoDetailView.as_view()),
     path('criar/', ProjetoCreateView.as_view(), name='projeto-criar'),
]
