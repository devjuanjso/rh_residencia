from rest_framework import serializers
from .models import Candidatura


class CandidaturaSerializer(serializers.ModelSerializer):
    vaga_titulo    = serializers.CharField(source="vaga.titulo", read_only=True)
    vaga_id        = serializers.UUIDField(source="vaga.id", read_only=True)
    projeto_nome   = serializers.CharField(source="vaga.projeto.nome", read_only=True)
    projeto_imagem = serializers.ImageField(source="vaga.projeto.imagem", read_only=True)
    projeto_id     = serializers.UUIDField(source="vaga.projeto.id", read_only=True)

    class Meta:
        model  = Candidatura
        fields = [
            "id", "status", "data",
            "vaga", "vaga_id", "vaga_titulo",
            "projeto_id", "projeto_nome", "projeto_imagem",
        ]
        read_only_fields = ["usuario", "status"]

    def validate(self, attrs):
        request = self.context.get("request")
        usuario = request.user
        vaga = attrs.get("vaga")

        if Candidatura.objects.filter(usuario=usuario, vaga=vaga).exists():
            raise serializers.ValidationError(
                "Este usuário já se candidatou a esta vaga."
            )

        return attrs