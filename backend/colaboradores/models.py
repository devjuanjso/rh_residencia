import uuid
from django.db import models

class Colaborador(models.Model):

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

    nome = models.CharField(max_length=120)
    email = models.EmailField(unique=True)

    cargo = models.CharField(
        max_length=30,
        choices=CargoChoices.choices
    )

    senioridade = models.CharField(
        max_length=20,
        choices=SenioridadeChoices.choices
    )

    area = models.CharField(
        max_length=30,
        choices=AreaChoices.choices
    )

    habilidades = models.JSONField(default=list)
    certificacoes = models.JSONField(default=list)
    formacao = models.CharField(max_length=200, blank=True, null=True)

    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.nome} - {self.cargo} ({self.senioridade})"
