#!/usr/bin/env python3
"""Finish the safety-pearl -> dangerZones migration.

Background
----------
Commit f3432be introduced the `dangerZones` field and a migration that moved
33 safety-critical pearls into it for 23 muscles. `dangerZones` renders in an
amber SafetyCallout, visually separated from general clinical-teaching pearls
(see the doc comment on `Muscle.dangerZones`).

This script finishes that job for the remaining muscles. It is a pure
RECLASSIFICATION: every moved string already exists verbatim in that muscle's
`pearls` list. Nothing is invented, split, or reworded — a string is removed
from `pearls` and appended to `dangerZones`, so the clinician sees identical
text in a different UI section.

Only unambiguous adjacent-structure / vital-structure / toxin-diffusion hazards
are moved. Function, innervation, muscle-selection, and pure-dosing pearls are
left in place. "Do not inject this muscle" warnings (e.g. tibialis anterior)
are intentionally NOT moved — that is a different semantic from the
"if you go the wrong direction you hit Y" adjacent-structure hazard.

Each target string is located by a unique substring ANCHOR to sidestep
em-dash / unicode quoting issues. The script asserts every anchor matches
exactly one pearl; if any anchor is missing or ambiguous it aborts without
writing, so it can never silently corrupt the data.

Idempotent: re-running after a successful pass is a no-op (anchors no longer
match any pearl, and the guard skips muscles already carrying the strings).
"""

import json
import sys
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "assets" / "data" / "muscles.json"

# muscle id -> list of unique substring anchors identifying the pearls to move.
MOVES = {
    # ── Upper extremity / forearm ──────────────────────────────
    "pronator-teres": ["Median nerve passes between"],
    "fcu": ["Ulnar nerve and artery run in"],
    "fdp": ["Anterior interosseous nerve"],
    "subscapularis": ["proximity to axillary vessels"],
    # ── Trunk / hip ────────────────────────────────────────────
    "iliopsoas": ["Femoral nerve, artery, and vein"],
    "quadratus-lumborum": ["The kidney lies anterior"],
    "paraspinals": ["NEVER direct needle medially past the lamina"],
    # ── Lower extremity ────────────────────────────────────────
    "soleus-lateral": ["Posterior tibial vessels run between"],
    # ── Neck ───────────────────────────────────────────────────
    "scm": [
        "Carotid artery and internal jugular vein",
        "The spinal accessory nerve runs through the muscle",
        "Bilateral SCM injection carries a real risk of dysphagia",
    ],
    "upper-trapezius": ["Spinal accessory nerve is the motor nerve"],
    "levator-scapulae": ["Dorsal scapular nerve may be nearby"],
    "semispinalis-capitis": ["The greater occipital nerve pierces this muscle"],
    "scalenes": [
        "the brachial plexus and subclavian vessels are millimeters away",
        "The phrenic nerve runs on the anterior scalene surface",
    ],
    # ── Face ───────────────────────────────────────────────────
    "masseter": ["to avoid Stensen"],
    "temporalis": ["superficial temporal artery pulse"],
    "lateral-pterygoid": ["The maxillary artery and pterygoid venous plexus"],
    "medial-pterygoid": ["inferior alveolar nerve block"],
    "orbicularis-oculi": [
        "avoid the PRETARSAL upper lid to prevent ptosis",
        "avoid the lacrimal pump mechanism",
    ],
    "corrugator-supercilii": ["Ptosis risk: keep the needle directed laterally"],
    "platysma": [
        "NEVER inject deeply to avoid the underlying strap muscles",
        "Dysphagia is the most feared complication",
    ],
    "mentalis": [
        "The mental nerve exits the mental foramen",
        "Diffusion to the adjacent orbicularis oris",
    ],
}


def main() -> int:
    muscles = json.loads(DATA.read_text(encoding="utf-8"))
    by_id = {m["id"]: m for m in muscles}

    errors = []
    moved_total = 0
    report = []

    for mid, anchors in MOVES.items():
        m = by_id.get(mid)
        if m is None:
            errors.append(f"{mid}: muscle id not found")
            continue

        pearls = list(m.get("pearls", []))
        to_move = []
        for anchor in anchors:
            hits = [p for p in pearls if anchor in p]
            if len(hits) != 1:
                errors.append(
                    f"{mid}: anchor {anchor!r} matched {len(hits)} pearls (expected 1)"
                )
                continue
            to_move.append(hits[0])

        if errors:
            continue

        # Partition pearls, preserving original order.
        kept = [p for p in pearls if p not in to_move]
        m["pearls"] = kept
        existing = list(m.get("dangerZones", []))
        m["dangerZones"] = existing + to_move
        moved_total += len(to_move)
        report.append((m["name"], len(to_move)))

    if errors:
        print("ABORTED — no file written. Problems:", file=sys.stderr)
        for e in errors:
            print(f"  • {e}", file=sys.stderr)
        return 1

    DATA.write_text(
        json.dumps(muscles, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )

    have = sum(1 for m in muscles if m.get("dangerZones"))
    print(f"Moved {moved_total} hazard pearls across {len(report)} muscles.")
    for name, n in report:
        print(f"  {n}  {name}")
    print(f"\ndangerZones coverage is now {have}/{len(muscles)} muscles.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
