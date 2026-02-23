from rest_framework import serializers

class RecomendacaoCandidaturaSerializer(serializers.Serializer):
    candidatura_id = serializers.UUIDField()
    usuario_id = serializers.UUIDField()
    compatibilidade = serializers.FloatField()