from rest_framework import serializers

from .models import PracticeSession, PracticeTarget


class PracticeTargetSerializer(serializers.ModelSerializer):
    class Meta:
        model = PracticeTarget
        fields = ["id", "name", "kind", "composer"]


class PracticeSessionSerializer(serializers.ModelSerializer):
    target_detail = PracticeTargetSerializer(source="target", read_only=True)

    class Meta:
        model = PracticeSession
        fields = [
            "id",
            "target",
            "target_detail",
            "practiced_at",
            "practice_count",
            "tempo",
            "notes",
        ]
        read_only_fields = ["practiced_at"]

    def validate_target(self, target):
        if not target.is_active:
            raise serializers.ValidationError("This practice target is inactive.")
        return target
