import uuid
from django.db import models
from accounts.models import User
from colaboradores.models import Colaborador
from vagas.models import Vaga

class Candidatura(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name="candidaturas")    
    vaga = models.ForeignKey(Vaga, on_delete=models.CASCADE, related_name="candidatos")

    data = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.usuario.nome} → {self.vaga.titulo}"
    class Meta:
            unique_together = ["usuario", "vaga"]