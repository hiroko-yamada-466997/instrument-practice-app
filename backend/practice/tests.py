from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import PracticeSession, PracticeTarget


class PracticeApiTests(APITestCase):
    def setUp(self):
        self.target = PracticeTarget.objects.create(
            name="Major scales", kind=PracticeTarget.Kind.TECHNIQUE
        )

    def test_lists_only_active_targets(self):
        PracticeTarget.objects.create(
            name="Archived exercise",
            kind=PracticeTarget.Kind.EXERCISE,
            is_active=False,
        )

        response = self.client.get(reverse("practice-target-list"))

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual([item["name"] for item in response.data], ["Major scales"])

    def test_records_a_practice_session(self):
        response = self.client.post(
            reverse("practice-session-list"),
            {
                "target": self.target.id,
                "practice_count": 5,
                "tempo": 72,
                "notes": "Keep the rhythm even.",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        session = PracticeSession.objects.get()
        self.assertEqual(session.target, self.target)
        self.assertEqual(session.practice_count, 5)
        self.assertEqual(session.tempo, 72)
        self.assertEqual(session.notes, "Keep the rhythm even.")
        self.assertIsNotNone(session.practiced_at)

    def test_multiple_practice_sessions_can_be_recorded(self):
        for count in (3, 7):
            response = self.client.post(
                reverse("practice-session-list"),
                {"target": self.target.id, "practice_count": count},
                format="json",
            )
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        self.assertEqual(PracticeSession.objects.count(), 2)

    def test_rejects_zero_practice_count(self):
        response = self.client.post(
            reverse("practice-session-list"),
            {"target": self.target.id, "practice_count": 0},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_requires_practice_count(self):
        response = self.client.post(
            reverse("practice-session-list"),
            {"target": self.target.id},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_rejects_zero_tempo(self):
        response = self.client.post(
            reverse("practice-session-list"),
            {"target": self.target.id, "practice_count": 1, "tempo": 0},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
