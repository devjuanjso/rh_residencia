from rest_framework import serializers

class RecomendacaoSerializer(serializers.Serializer):
    colaborador_id = serializers.UUIDField()
    compatibilidade = serializers.FloatField()
