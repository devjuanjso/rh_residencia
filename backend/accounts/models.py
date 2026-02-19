import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):

    class RoleChoices(models.TextChoices):
        ADMIN = "ADMIN", "Administrador"
        RH = "RH", "Recursos Humanos"
        COLABORADOR = "COLABORADOR", "Colaborador"

    class CargoChoices(models.TextChoices):
        DESENVOLVEDOR = "DESENVOLVEDOR", "Desenvolvedor"
        DESIGNER = "DESIGNER", "Designer"
        QA = "QA", "QA"
        PRODUCT_MANAGER = "PM", "Product Manager"
        ANALISTA = "ANALISTA", "Analista"

    class SenioridadeChoices(models.TextChoices):
        ESTAGIO = "ESTAGIO", "Estágio"
        JUNIOR = "JUNIOR", "Júnior"
        PLENO = "PLENO", "Pleno"
        SENIOR = "SENIOR", "Sênior"
        ESPECIALISTA = "ESPECIALISTA", "Especialista"

    class AreaChoices(models.TextChoices):
        TI = "TI", "Tecnologia da Informação"
        RH = "RH", "Recursos Humanos"
        DESIGN = "DESIGN", "Design"
        PRODUTO = "PRODUTO", "Produto"
        DADOS = "DADOS", "Dados"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    role = models.CharField(
        max_length=20,
        choices=RoleChoices.choices,
        default=RoleChoices.COLABORADOR
    )

    cargo = models.CharField(
        max_length=30,
        choices=CargoChoices.choices,
        blank=True,
        null=True
    )

    senioridade = models.CharField(
        max_length=20,
        choices=SenioridadeChoices.choices,
        blank=True,
        null=True
    )

    area = models.CharField(
        max_length=30,
        choices=AreaChoices.choices,
        blank=True,
        null=True
    )

    habilidades = models.JSONField(default=list, blank=True)
    certificacoes = models.JSONField(default=list, blank=True)
    formacao = models.CharField(max_length=200, blank=True, null=True)

    foto = models.ImageField(upload_to="usuarios/", blank=True, null=True)
    bio = models.TextField(blank=True, null=True)

    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.username} - {self.role}"
