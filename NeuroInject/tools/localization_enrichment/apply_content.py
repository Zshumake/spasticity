"""Merge per-muscle localization content from content.py into assets/data/muscles.json.

Rules:
  - ADDITIVE: existing list items are preserved; new items are appended.
  - DEDUPLICATED: case-insensitive substring match prevents adding an item
    that is already represented in the existing list.
  - FIELDS TOUCHED: landmarks, placement, setup, pearls. No other fields are
    modified. No schema changes. No dose-related fields are touched.
  - SAFETY: writes to a temp file and atomic-renames. Verifies JSON parses
    before replacing the original.

Usage:
  python3 tools/localization_enrichment/apply_content.py --dry-run   # preview
  python3 tools/localization_enrichment/apply_content.py --apply     # apply
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
MUSCLES_JSON = os.path.join(REPO_ROOT, "assets", "data", "muscles.json")

sys.path.insert(0, HERE)
from content import MUSCLE_CONTENT  # noqa: E402


FIELDS = ("landmarks", "placement", "setup", "pearls")


def normalize(s: str) -> str:
    """Lowercase + collapse whitespace for duplicate detection."""
    return " ".join(s.lower().split())


def is_duplicate(new_item: str, existing_items: list[str]) -> bool:
    """Skip adding if new_item is substantially represented in an existing item.

    Uses a conservative overlap check: duplicate if the first ~40 characters
    of the new item appear in any existing item, or vice versa.
    """
    new_norm = normalize(new_item)
    key = new_norm[: min(40, len(new_norm))]
    for existing in existing_items:
        existing_norm = normalize(existing)
        if key and key in existing_norm:
            return True
        # Also check the reverse (existing fully-contained in new)
        existing_key = existing_norm[: min(40, len(existing_norm))]
        if existing_key and existing_key in new_norm:
            return True
    return False


def append_content(muscle: dict, field: str, new_items: list[str]) -> list[str]:
    """Return (updated_field_value, list_of_added_items)."""
    current = muscle.get(field, [])
    if not isinstance(current, list):
        # The schema tolerates string-or-list here; normalize to list.
        current = [current] if current else []
    added: list[str] = []
    for item in new_items:
        if not is_duplicate(item, current):
            current.append(item)
            added.append(item)
    return current, added


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Print diff without writing")
    parser.add_argument("--apply", action="store_true", help="Apply the patch")
    args = parser.parse_args()

    if not (args.dry_run or args.apply):
        parser.error("pass --dry-run or --apply")

    with open(MUSCLES_JSON) as f:
        data = json.load(f)

    if isinstance(data, list):
        muscles = data
        root_is_list = True
    elif isinstance(data, dict) and "muscles" in data:
        muscles = data["muscles"]
        root_is_list = False
    else:
        raise SystemExit(f"Unexpected muscles.json shape: {type(data)}")

    by_name = {m["name"]: m for m in muscles}

    # Validate all muscle names in content.py exist in muscles.json
    missing = [name for name in MUSCLE_CONTENT if name not in by_name]
    if missing:
        print("Muscles in content.py NOT found in muscles.json:")
        for m in missing:
            print(f"  - {m}")
        print("\nFix the names in content.py before proceeding.")
        return 1

    total_added = 0
    per_muscle_summary = []

    for name, content in MUSCLE_CONTENT.items():
        muscle = by_name[name]
        added_this_muscle = {}
        for field in FIELDS:
            new_items = content.get(field, [])
            if not new_items:
                continue
            updated, added = append_content(muscle, field, new_items)
            if added:
                muscle[field] = updated
                added_this_muscle[field] = added
                total_added += len(added)
        confidence = content.get("confidence", "ocr")
        per_muscle_summary.append((name, confidence, added_this_muscle))

    # Report
    print(f"Proposed additions across {len(MUSCLE_CONTENT)} muscles:\n")
    for name, confidence, adds in per_muscle_summary:
        count = sum(len(v) for v in adds.values())
        tag = {"full": "●●●", "ocr": "●●○", "ocr-imageread": "●●○", "partial": "●○○"}.get(confidence, "???")
        print(f"  {tag} [{confidence:16s}] {name}: +{count} items")
        if count == 0:
            continue
        for field, items in adds.items():
            for item in items:
                preview = item[:90] + ("…" if len(item) > 90 else "")
                print(f"      .{field}: {preview}")
        print()

    print(f"\n=== Total new items: {total_added} ===\n")

    if args.dry_run:
        print("Dry run only. Pass --apply to write.")
        return 0

    # --apply path: write atomically
    tmp_fd, tmp_path = tempfile.mkstemp(
        prefix="muscles.", suffix=".json.tmp", dir=os.path.dirname(MUSCLES_JSON)
    )
    try:
        with os.fdopen(tmp_fd, "w") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
            f.flush()
            os.fsync(f.fileno())
        # Verify the temp file parses
        with open(tmp_path) as f:
            json.load(f)
        # Atomic replace
        os.replace(tmp_path, MUSCLES_JSON)
        print(f"Wrote {MUSCLES_JSON} ({total_added} items added).")
    except Exception as e:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        print(f"FAILED: {e}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
