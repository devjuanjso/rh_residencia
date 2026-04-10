from rest_framework import serializers

class RecomendacaoCandidaturaSerializer(serializers.Serializer):
    candidatura_id = serializers.UUIDField()
    usuario_id = serializers.UUIDField()
    compatibilidade = serializers.FloatField()
    status          = serializers.CharField()
    # dados do usuário já embutidos
    nome = serializers.CharField()
    email = serializers.EmailField()
    cargo = serializers.CharField(allow_null=True)
    senioridade = serializers.CharField(allow_null=True)
    area = serializers.CharField(allow_null=True)
    habilidades = serializers.ListField(child=serializers.CharField())
    certificacoes = serializers.ListField(child=serializers.CharField())
    formacao = serializers.CharField(allow_null=True)
    linkedin = serializers.URLField(allow_null=True)
    foto = serializers.CharField(allow_null=True)
    bio = serializers.CharField(allow_null=True)