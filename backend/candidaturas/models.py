import uuid
from django.db import models
from accounts.models import User
from colaboradores.models import Colaborador
from vagas.models import Vaga

class Candidatura(models.Model):
    class Status(models.TextChoices):
        PENDENTE  = "pendente",  "Pendente"
        ACEITO    = "aceito",    "Aceito"
        REJEITADO = "rejeitado", "Rejeitado"

    id       = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    usuario  = models.ForeignKey(User, on_delete=models.CASCADE, related_name="candidaturas")
    vaga     = models.ForeignKey(Vaga, on_delete=models.CASCADE, related_name="candidatos")
    status   = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDENTE)
    data     = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ["usuario", "vaga"]