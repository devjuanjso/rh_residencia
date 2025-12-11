import uuid
from django.db import models

class Colaborador(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    nome = models.CharField(max_length=120)
    email = models.EmailField(unique=True)

    habilidades = models.JSONField(default=list)
    certificacoes = models.JSONField(default=list)
    formacao = models.CharField(max_length=200, blank=True, null=True)
    tempo_empresa_meses = models.IntegerField(default=0)

    def __str__(self):
        return self.nome
