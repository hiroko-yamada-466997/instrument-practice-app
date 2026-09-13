from rest_framework import generics

from .models import PracticeSession, PracticeTarget
from .serializers import PracticeSessionSerializer, PracticeTargetSerializer


class PracticeTargetListView(generics.ListAPIView):
    serializer_class = PracticeTargetSerializer

    def get_queryset(self):
        return PracticeTarget.objects.filter(is_active=True)


class PracticeSessionListCreateView(generics.ListCreateAPIView):
    serializer_class = PracticeSessionSerializer

    def get_queryset(self):
        return PracticeSession.objects.select_related("target")[:50]
