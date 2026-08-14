from django.contrib import admin
from django.db import connection
from django.http import JsonResponse
from django.urls import path
from rest_framework.decorators import api_view


@api_view(["GET"])
def health_check(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT 1")
        cursor.fetchone()

    return JsonResponse({"status": "ok", "database": "ok"})


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health_check, name="health-check"),
]

