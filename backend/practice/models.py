from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models
from django.utils import timezone


class PracticeTarget(models.Model):
    class Kind(models.TextChoices):
        PIECE = "piece", "Piece"
        EXERCISE = "exercise", "Exercise"
        TECHNIQUE = "technique", "Technique"

    name = models.CharField(max_length=200)
    kind = models.CharField(max_length=20, choices=Kind.choices)
    composer = models.CharField(max_length=200, blank=True)
    is_active = models.BooleanField(default=True)
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["sort_order", "name", "id"]

    def __str__(self):
        return self.name


class PracticeSession(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        blank=True,
        null=True,
        on_delete=models.CASCADE,
        related_name="practice_sessions",
    )
    target = models.ForeignKey(
        PracticeTarget,
        on_delete=models.PROTECT,
        related_name="sessions",
    )
    practiced_at = models.DateTimeField(default=timezone.now)
    practice_count = models.PositiveIntegerField(validators=[MinValueValidator(1)])
    tempo = models.PositiveIntegerField(
        blank=True, null=True, validators=[MinValueValidator(1)]
    )
    notes = models.TextField(blank=True, max_length=2000)

    class Meta:
        ordering = ["-practiced_at", "-id"]
        indexes = [
            models.Index(fields=["-practiced_at"], name="practice_recorded_idx")
        ]

    def __str__(self):
        return f"{self.target}: {self.practice_count} times"
