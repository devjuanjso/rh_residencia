import uuid
from django.db import models
from colaboradores.models import Colaborador
from vagas.models import Vaga

class Candidatura(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    colaborador = models.ForeignKey(Colaborador, on_delete=models.CASCADE, related_name="candidaturas")
    vaga = models.ForeignKey(Vaga, on_delete=models.CASCADE, related_name="candidatos")

    data = models.DateTimeField(auto_now_add=True)

    status = models.CharField(
        max_length=20,
        choices=[
            ("pendente", "Pendente"),
            ("aprovado", "Aprovado"),
            ("reprovado", "Reprovado"),
        ],
        default="pendente"
    )

    def __str__(self):
        return f"{self.colaborador.nome} → {self.vaga.titulo}"
