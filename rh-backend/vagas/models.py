import uuid
from django.db import models
from projetos.models import Projeto

class Vaga(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    projeto = models.ForeignKey(Projeto, on_delete=models.CASCADE, related_name="vagas")

    titulo = models.CharField(max_length=120)
    descricao = models.TextField()

    habilidades_requeridas = models.JSONField(default=list)
    certificacoes_requeridas = models.JSONField(default=list)
    formacao_desejada = models.CharField(max_length=200, blank=True, null=True)

    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.titulo} ({self.projeto.nome})"
