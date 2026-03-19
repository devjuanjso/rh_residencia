from rest_framework import serializers
from .models import Vaga


class VagaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vaga
        fields = "__all__"
        read_only_fields = ["criado_por", "criado_em", "atualizado_em"]