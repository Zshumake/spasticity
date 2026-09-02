import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from task_queue import load_parked_ids, select_tasks


class TaskQueueTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        self.tasks = [
            {"id": "first", "output": "output/first.png"},
            {"id": "second", "output": "output/second.png"},
            {"id": "third", "output": "output/third.png"},
            {"id": "approved", "output": "output/approved.png"},
        ]
        self.status = {
            "first": {"status": "pending"},
            "second": {"status": "regenerate"},
            "third": {"status": "pending"},
            "approved": {"status": "approved"},
        }

    def tearDown(self):
        self.temp_dir.cleanup()

    def ids(self, mode="all"):
        return [
            task["id"]
            for task in select_tasks(self.tasks, self.status, self.root, mode=mode)
        ]

    def test_absent_parking_file_means_nothing_is_parked(self):
        self.assertEqual(load_parked_ids(self.root), set())

    def test_empty_parking_file_means_nothing_is_parked(self):
        (self.root / "parked-tasks.json").write_text("")
        self.assertEqual(load_parked_ids(self.root), set())

    def test_parked_task_is_excluded_from_first_pass(self):
        (self.root / "parked-tasks.json").write_text(
            json.dumps({"first": {"reason": "double refusal"}})
        )
        self.assertEqual(self.ids("first-pass"), ["third"])

    def test_parked_task_is_excluded_from_regeneration(self):
        (self.root / "parked-tasks.json").write_text(
            json.dumps([{"id": "second", "reason": "double refusal"}])
        )
        self.assertEqual(self.ids("regeneration"), [])

    def test_regeneration_includes_marked_task_even_when_output_exists(self):
        output = self.root / "output" / "second.png"
        output.parent.mkdir()
        output.touch()
        self.assertEqual(self.ids("regeneration"), ["second"])

    def test_approved_task_is_excluded(self):
        self.assertNotIn("approved", self.ids())

    def test_all_mode_keeps_regenerations_first_and_manifest_order_within_groups(self):
        self.status["third"] = {"status": "regenerate"}
        self.assertEqual(self.ids(), ["second", "third", "first"])

    def test_first_pass_keeps_manifest_order_and_requires_missing_output(self):
        output = self.root / "output" / "first.png"
        output.parent.mkdir()
        output.touch()
        self.assertEqual(self.ids("first-pass"), ["third"])

    def test_only_filter_preserves_selection_rules(self):
        selected = select_tasks(
            self.tasks, self.status, self.root, mode="regeneration", only="second"
        )
        self.assertEqual([task["id"] for task in selected], ["second"])


if __name__ == "__main__":
    unittest.main()
