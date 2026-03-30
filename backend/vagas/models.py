import uuid
from django.conf import settings
from django.db import models
from projetos.models import Projeto


class Vaga(models.Model):

    class Senioridade(models.TextChoices):
        ESTAGIO    = "estagio",    "Estágio"
        JUNIOR     = "junior",     "Júnior"
        PLENO      = "pleno",      "Pleno"
        SENIOR     = "senior",     "Sênior"
        ESPECIALISTA = "especialista", "Especialista"

    class Area(models.TextChoices):
        INOVACAO      = "inovacao",      "Inovação"
        TECNOLOGIA    = "tecnologia",    "Tecnologia"
        DADOS         = "dados",         "Dados"
        DESIGN        = "design",        "Design"
        PRODUTO       = "produto",       "Produto"
        NEGOCIOS      = "negocios",      "Negócios"
        MARKETING     = "marketing",     "Marketing"
        OPERACOES     = "operacoes",     "Operações"

    area = models.CharField(
        max_length=20,
        choices=Area.choices,
        blank=True,
        null=True,
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    projeto = models.ForeignKey(
        Projeto, on_delete=models.CASCADE, related_name="vagas"
    )

    titulo = models.CharField(max_length=120)

    senioridade = models.CharField(
        max_length=20,
        choices=Senioridade.choices,
        default=Senioridade.PLENO,
    )

    habilidades_requeridas = models.JSONField(default=list)
    certificacoes_requeridas = models.JSONField(default=list)
    formacao_desejada = models.CharField(max_length=200, blank=True, null=True)

    criado_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="vagas_criadas",
    )

    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.titulo} ({self.projeto.nome})"