from django.db import models


class Vaga(models.Model):
    projeto = models.ForeignKey(
        "Projeto",
        on_delete=models.CASCADE,
        related_name="vagas"
    )

    titulo = models.CharField(max_length=120)
    descricao = models.TextField()
    requisitos = models.TextField(blank=True, null=True)

    nivel = models.CharField(
        max_length=20,
        choices=[
            ("junior", "Júnior"),
            ("pleno", "Pleno"),
            ("senior", "Sênior"),
        ],
        default="junior"
    )

    quantidade = models.IntegerField(default=1)

    criado_em = models.DateTimeField(auto_now_add=True)
    atualizado_em = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.titulo} ({self.projeto.nome})"
