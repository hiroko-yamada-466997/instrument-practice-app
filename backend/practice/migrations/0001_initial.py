import django.core.validators
import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [
        migrations.CreateModel(
            name="PracticeTarget",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("name", models.CharField(max_length=200)),
                ("kind", models.CharField(choices=[("piece", "Piece"), ("exercise", "Exercise"), ("technique", "Technique")], max_length=20)),
                ("composer", models.CharField(blank=True, max_length=200)),
                ("is_active", models.BooleanField(default=True)),
                ("sort_order", models.PositiveIntegerField(default=0)),
            ],
            options={"ordering": ["sort_order", "name", "id"]},
        ),
        migrations.CreateModel(
            name="PracticeSession",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("practiced_at", models.DateTimeField(default=django.utils.timezone.now)),
                ("practice_count", models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(1)])),
                ("tempo", models.PositiveIntegerField(blank=True, null=True, validators=[django.core.validators.MinValueValidator(1)])),
                ("notes", models.TextField(blank=True, max_length=2000)),
                ("owner", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name="practice_sessions", to=settings.AUTH_USER_MODEL)),
                ("target", models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name="sessions", to="practice.practicetarget")),
            ],
            options={
                "ordering": ["-practiced_at", "-id"],
                "indexes": [models.Index(fields=["-practiced_at"], name="practice_recorded_idx")],
            },
        ),
    ]
