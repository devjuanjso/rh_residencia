from rest_framework import serializers
from .models import Projeto


class ProjetoSerializer(serializers.ModelSerializer):
    criado_por_nome = serializers.SerializerMethodField()

    class Meta:
        model = Projeto
        fields = "__all__"
        read_only_fields = ["criado_por", "criado_em", "atualizado_em"]

    def get_criado_por_nome(self, obj):
        return obj.criado_por.get_full_name() or obj.criado_por.username
