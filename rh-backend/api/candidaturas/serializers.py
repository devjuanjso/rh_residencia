from rest_framework import serializers
from .models import Candidatura


class CandidaturaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Candidatura
        fields = "__all__"
