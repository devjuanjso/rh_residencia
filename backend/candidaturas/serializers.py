from rest_framework import serializers
from .models import Candidatura


class CandidaturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Candidatura
        fields = "__all__"
        read_only_fields = ["usuario"]

    def validate(self, attrs):

        request = self.context.get("request")
        usuario = request.user
        vaga = attrs.get("vaga")

        if Candidatura.objects.filter(
            usuario=usuario,
            vaga=vaga
        ).exists():
            raise serializers.ValidationError(
                "Este usuário já se candidatou a esta vaga."
            )

        return attrs