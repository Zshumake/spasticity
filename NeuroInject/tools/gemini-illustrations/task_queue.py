"""Shared task eligibility and ordering for illustration generators."""

import json
from pathlib import Path


def load_parked_ids(root):
    """Return IDs recorded in parked-tasks.json, or an empty set if absent/empty."""
    path = Path(root) / "parked-tasks.json"
    if not path.exists() or not path.read_text().strip():
        return set()

    parked = json.loads(path.read_text())
    if isinstance(parked, list):
        return {
            item if isinstance(item, str) else item["id"]
            for item in parked
            if isinstance(item, str) or (isinstance(item, dict) and "id" in item)
        }
    if isinstance(parked, dict) and isinstance(parked.get("tasks"), list):
        return {
            item if isinstance(item, str) else item["id"]
            for item in parked["tasks"]
            if isinstance(item, str) or (isinstance(item, dict) and "id" in item)
        }
    if isinstance(parked, dict):
        return set(parked)
    return set()


def select_tasks(tasks, status, root, mode="all", only=None):
    """Select eligible tasks, preserving manifest order within each queue group."""
    if mode not in {"all", "first-pass", "regeneration"}:
        raise ValueError(f"unknown queue mode: {mode}")

    root = Path(root)
    parked = load_parked_ids(root)
    eligible = [
        task for task in tasks
        if task["id"] not in parked and (not only or task["id"] == only)
    ]
    regenerations = [
        task for task in eligible
        if status.get(task["id"], {}).get("status", "pending") == "regenerate"
    ]
    first_pass = [
        task for task in eligible
        if status.get(task["id"], {}).get("status", "pending") == "pending"
        and not (root / task["output"]).exists()
    ]

    if mode == "regeneration":
        return regenerations
    if mode == "first-pass":
        return first_pass
    return regenerations + first_pass
