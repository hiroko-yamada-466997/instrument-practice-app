from django.urls import path

from .views import PracticeSessionListCreateView, PracticeTargetListView


urlpatterns = [
    path("practice-targets/", PracticeTargetListView.as_view(), name="practice-target-list"),
    path("practice-sessions/", PracticeSessionListCreateView.as_view(), name="practice-session-list"),
]
