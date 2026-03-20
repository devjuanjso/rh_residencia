import uuid
from django.db import models
from django.conf import settings


class Projeto(models.Model):

    class TipoProjeto(models.TextChoices):
        PRODUTO_DIGITAL = "produto_digital", "Produto digital"
        SERVICO = "servico", "Serviço"
        PESQUISA = "pesquisa", "Pesquisa"
        OUTRO = "outro", "Outro"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    nome = models.CharField(max_length=120)
    descricao = models.TextField()

    imagem = models.ImageField(upload_to="projetos/", blank=True, null=True)

    tipo = models.CharField(
        max_length=30,
        choices=TipoProjeto.choices,
        default=TipoProjeto.PRODUTO_DIGITAL,
    )

    data_inicio = models.DateField(blank=True, null=True)

    criado_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="projetos_criados",
    )

    rascunho = models.BooleanField(default=True)
    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.nome