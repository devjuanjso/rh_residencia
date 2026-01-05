from rest_framework import serializers
from .models import Candidatura
from colaboradores.models import Colaborador


class CandidaturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Candidatura
        fields = "__all__"

    def validate(self, attrs):
        colaborador = attrs.get("colaborador")
        vaga = attrs.get("vaga")

        if Candidatura.objects.filter(
            colaborador=colaborador,
            vaga=vaga
        ).exists():
            raise serializers.ValidationError(
                "Este colaborador já se candidatou a esta vaga."
            )

        return attrs