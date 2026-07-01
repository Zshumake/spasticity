#!/usr/bin/env python3
"""Validate the clinical photos in assets/images/clinical/ before a build.

Derives the EXACT set of expected filenames from muscles.json using the same
helpers the capture guide is generated from (so the checker can never drift
from the guide):

  - Patient position:  pos-<positionGroup>.jpg   (one per shared position group)
  - Probe + needle:    <muscleId>-probe.jpg       (every muscle)
  - Ultrasound:        <muscleId>-us.jpg          (ultrasound-guided muscles only)

Then it scans the folder and reports three things:
  1. Coverage — how many expected photos are present, per region.
  2. Missing — expected photos not yet added (normal while you shoot; not an error).
  3. Misnamed / unexpected — files present that match NO expected name. These are
     the silent failures (a typo, a wrong extension, a stale id): the app just
     keeps showing the placeholder. For each, the closest expected name is
     suggested.

Exit code: 0 if there are no misnamed/unexpected files (missing is fine); 1 if
any unexpected file is found — so a release build can gate on it.

Run: python3 tools/validate_clinical_photos.py
"""

import difflib
import json
import sys
from collections import defaultdict
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
ROOT = TOOLS.parent
sys.path.insert(0, str(TOOLS))

# Single source of truth — the same helpers the guide generator uses.
from generate_photo_capture_guide import (  # noqa: E402
    DATA,
    REGION_ORDER,
    position_groups,
    region_of,
    slot_filename,
)

CLINICAL = ROOT / "assets" / "images" / "clinical"
POSITION_BUCKET = "Patient positions (shared)"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".heic", ".webp"}


def expected_photos(muscles):
    """{filename: (bucket, slot)} for every photo the app will look for."""
    exp = {}
    for key, (_label, _ms) in position_groups(muscles).items():
        exp[f"pos-{key}.jpg"] = (POSITION_BUCKET, "position")
    for m in muscles:
        bucket = region_of(m["group"])
        exp[slot_filename(m, "probe")] = (bucket, "probe")
        if m.get("ultrasound"):
            exp[slot_filename(m, "us")] = (bucket, "us")
    return exp


def present_files():
    """Every image-ish file actually in the clinical folder (name -> path)."""
    if not CLINICAL.exists():
        return {}
    return {
        p.name: p
        for p in CLINICAL.iterdir()
        if p.is_file() and p.suffix.lower() in IMAGE_EXTS
    }


def main():
    muscles = json.loads(DATA.read_text())
    expected = expected_photos(muscles)
    present = present_files()

    expected_names = set(expected)
    present_names = set(present)
    have = expected_names & present_names
    missing = expected_names - present_names
    unexpected = present_names - expected_names

    buckets = [POSITION_BUCKET] + REGION_ORDER

    # ── Coverage, per bucket × slot ──────────────────────────────
    print("NeuroInject — clinical photo validation")
    print("=" * 52)
    print(f"Folder: {CLINICAL.relative_to(ROOT)}")
    print(f"Expected {len(expected_names)} photos · "
          f"{len(have)} present · {len(missing)} missing · "
          f"{len(unexpected)} unexpected\n")

    def counts(bucket, slot):
        exp = {n for n, (b, s) in expected.items() if b == bucket and s == slot}
        return len(exp & have), len(exp)

    print(f"{'Region':<28}{'position':>10}{'probe':>10}{'ultrasound':>13}")
    print("-" * 61)
    for b in buckets:
        cells = []
        for slot in ("position", "probe", "us"):
            got, tot = counts(b, slot)
            cells.append(f"{got}/{tot}" if tot else "—")
        print(f"{b:<28}{cells[0]:>10}{cells[1]:>10}{cells[2]:>13}")
    pct = (100 * len(have) / len(expected_names)) if expected_names else 100
    print("-" * 61)
    print(f"{'TOTAL':<28}{len(have)}/{len(expected_names)} ({pct:.0f}%)\n")

    # ── Misnamed / unexpected — the silent-failure catcher ───────
    if unexpected:
        print("⚠  UNEXPECTED / MISNAMED FILES "
              "(present but the app will ignore them):")
        for name in sorted(unexpected):
            near = difflib.get_close_matches(name, expected_names, n=1, cutoff=0.6)
            hint = f"  → did you mean  {near[0]}?" if near else ""
            print(f"   ✗ {name}{hint}")
        print()

    # ── Missing (grouped, not an error) ──────────────────────────
    if missing:
        by_bucket = defaultdict(list)
        for n in missing:
            by_bucket[expected[n][0]].append(n)
        print(f"Missing ({len(missing)}) — still to shoot:")
        for b in buckets:
            names = sorted(by_bucket.get(b, []))
            if names:
                print(f"  {b} ({len(names)}):")
                for n in names:
                    print(f"     · {n}")
        print()

    if not unexpected and not missing:
        print("✓ Complete — every expected clinical photo is present.")
    elif not unexpected:
        print("✓ No misnamed files. Remaining items are just not-yet-shot.")

    return 1 if unexpected else 0


if __name__ == "__main__":
    raise SystemExit(main())
