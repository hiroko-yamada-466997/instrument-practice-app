from django.contrib import admin

from .models import PracticeSession, PracticeTarget


@admin.register(PracticeTarget)
class PracticeTargetAdmin(admin.ModelAdmin):
    list_display = ("name", "kind", "composer", "is_active", "sort_order")
    list_filter = ("kind", "is_active")
    search_fields = ("name", "composer")


@admin.register(PracticeSession)
class PracticeSessionAdmin(admin.ModelAdmin):
    list_display = ("target", "practice_count", "tempo", "owner", "practiced_at")
    list_select_related = ("target", "owner")
