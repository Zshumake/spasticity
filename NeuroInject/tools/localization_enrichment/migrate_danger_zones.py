"""Move safety-style pearls into the new `dangerZones` field.

Identifies items in each muscle's `pearls` list that match the book's
"Topographical indication" style — adjacent-structure hazards — and
moves them to a dedicated `dangerZones` list. Pearls that don't match a
danger-zone pattern stay in `pearls`.

Why a moved list rather than a flagged list: once `dangerZones` is a
typed field, the UI can render it with an amber callout that says
"Adjacent structures — what to avoid" rather than visually equating
safety info with general clinical pearls.

Matching patterns (case-insensitive; must match at least one):
  - "going too <direction>"
  - "too <direction>, the <muscle>"
  - "risks hitting <muscle>"
  - "risks penetrating <muscle>"
  - "risks <noun> of <muscle>"
  - "avoid <muscle>"
  - "avoid the <muscle>"
  - "pneumothorax"  — the ribs/thorax cautions
  - "transperitoneal"  — abdominal-wall cautions
  - "neurovascular"
  - "<muscle> can be <action>ed" (pierced / infiltrated / punctured)
  - "lies close to" / "proximity to" for nerves/vessels

Usage:
  python3 tools/localization_enrichment/migrate_danger_zones.py --dry-run
  python3 tools/localization_enrichment/migrate_danger_zones.py --apply
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MUSCLES_JSON = os.path.join(REPO_ROOT, "assets", "data", "muscles.json")


DANGER_PATTERNS = [
    re.compile(r"\bgoing\s+too\s+\w+", re.I),
    re.compile(r"\btoo\s+(?:far\s+)?\w+(?:ly)?,?\s+(?:the\s+)?\w+\s+(?:can|will|risks|is)\b", re.I),
    re.compile(r"\btoo\s+(?:far\s+)?(?:medial|lateral|deep|superficial|proximal|distal|dorsal|ventral|anterior|posterior|dorsomedial|superiorly|inferiorly)", re.I),
    re.compile(r"\brisks?\s+(?:hitting|penetrating|infiltrating|puncturing|injecting|injection)", re.I),
    re.compile(r"\bavoid\s+(?:the\s+)?\w+\s+(?:nerve|artery|vein|vessel|bundle|tendon)", re.I),
    re.compile(r"\bpneumothorax\b", re.I),
    re.compile(r"\btransperitoneal\b", re.I),
    re.compile(r"\bperitoneal\s+puncture\b", re.I),
    re.compile(r"\bneurovascular\b", re.I),
    re.compile(r"\b(?:nerve|artery|vein)\s+(?:runs|lies|sits|wraps)\s+(?:alongside|next to|beside|deep|superficial|medial|lateral)", re.I),
    re.compile(r"\bcan\s+be\s+(?:infiltrated|pierced|penetrated|punctured|injected)\b", re.I),
    re.compile(r"\b(?:sciatic|femoral|median|ulnar|radial|axillary|peroneal)\s+nerve\s+(?:proximity|runs|wraps|is\s+nearby)", re.I),
    # First-person directional warnings ("Stay X to avoid Y")
    re.compile(r"\bstay\s+\w+\s+to\s+avoid\b", re.I),
]

# Per-muscle explicit overrides. Use when automatic matching misses something
# we want moved, or catches something we want to keep in pearls.
# Key: muscle name. Value: { "force_move": [prefix, ...], "force_keep": [prefix, ...] }
PER_MUSCLE_OVERRIDES: dict[str, dict[str, list[str]]] = {
    # Keep "most commonly injected" as a pearl (not a danger)
    "Gastrocnemius (Medial)": {
        "force_keep": ["Most commonly injected muscle for equinovarus"],
    },
}


def is_danger_item(text: str) -> bool:
    """Return True if the item reads like a danger-zone warning."""
    for pat in DANGER_PATTERNS:
        if pat.search(text):
            return True
    return False


def classify(muscle_name: str, pearls: list[str]) -> tuple[list[str], list[str]]:
    """Split pearls into (keep_as_pearls, move_to_dangerZones).
    Respects per-muscle force_keep / force_move overrides.
    """
    overrides = PER_MUSCLE_OVERRIDES.get(muscle_name, {})
    force_keep = overrides.get("force_keep", [])
    force_move = overrides.get("force_move", [])
    keep, danger = [], []
    for pearl in pearls:
        # Force-keep wins
        if any(pearl.startswith(prefix) for prefix in force_keep):
            keep.append(pearl)
            continue
        if any(pearl.startswith(prefix) for prefix in force_move):
            danger.append(pearl)
            continue
        if is_danger_item(pearl):
            danger.append(pearl)
        else:
            keep.append(pearl)
    return keep, danger


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if not (args.dry_run or args.apply):
        parser.error("pass --dry-run or --apply")

    with open(MUSCLES_JSON) as f:
        data = json.load(f)
    muscles = data if isinstance(data, list) else data.get("muscles", list(data.values())[0])

    total_muscles_changed = 0
    total_moved = 0

    print(
        "=== Migration: pearls → dangerZones ===\n"
        "Rule: items matching adjacent-structure hazard patterns move; others stay.\n"
    )

    for muscle in muscles:
        pearls = muscle.get("pearls") or []
        if not isinstance(pearls, list) or not pearls:
            continue
        keep, danger = classify(muscle["name"], pearls)
        if not danger:
            continue
        # Preserve any pre-existing dangerZones and add to them
        existing_danger = muscle.get("dangerZones") or []
        if not isinstance(existing_danger, list):
            existing_danger = [existing_danger] if existing_danger else []
        # Dedup
        seen = {item.lower() for item in existing_danger}
        for d in danger:
            if d.lower() not in seen:
                existing_danger.append(d)
                seen.add(d.lower())
        total_muscles_changed += 1
        total_moved += len(danger)
        print(f"  {muscle['name']}: +{len(danger)} moved to dangerZones")
        for d in danger:
            preview = d[:110] + ("…" if len(d) > 110 else "")
            print(f"    → {preview}")
        if not args.dry_run:
            muscle["pearls"] = keep
            muscle["dangerZones"] = existing_danger

    print(
        f"\n=== Summary: {total_muscles_changed} muscles changed, "
        f"{total_moved} items moved ==="
    )
    if args.dry_run:
        print("\nDry run. Pass --apply to write.")
        return 0

    tmp_fd, tmp_path = tempfile.mkstemp(
        prefix="muscles.", suffix=".json.tmp", dir=os.path.dirname(MUSCLES_JSON)
    )
    try:
        with os.fdopen(tmp_fd, "w") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")
            f.flush()
            os.fsync(f.fileno())
        with open(tmp_path) as f:
            json.load(f)
        os.replace(tmp_path, MUSCLES_JSON)
        print(f"Wrote {MUSCLES_JSON}.")
    except Exception as e:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        print(f"FAILED: {e}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
