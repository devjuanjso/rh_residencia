from rest_framework import serializers
from .models import Projeto


class ProjetoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Projeto
        fields = "__all__"
        read_only_fields = ["criado_por", "criado_em", "atualizado_em"]
