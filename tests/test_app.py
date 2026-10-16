import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from app import app

class ApplicationTests(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_home(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["status"], "running")

    def test_health(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["status"], "healthy")

    def test_info(self):
        response = self.client.get("/info")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["version"], "1.0.0")

if __name__ == "__main__":
    unittest.main()
