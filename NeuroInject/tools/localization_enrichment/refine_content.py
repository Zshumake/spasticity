"""Refinement pass over muscles.json:

  1. REPLACEMENTS — soften or rewrite specific items that are too opinionated
     or too didactic for a resident audience. Changes a single existing item
     rather than adding a new one. Match is on the first N characters of the
     existing item (prefix match) so minor typo drift still applies.

  2. ADDITIONS — additive content for the 3 muscles that were 'partial'
     confidence in the previous pass. Now filled in from high-DPI image
     reads of the book pages.

Run:
  python3 tools/localization_enrichment/refine_content.py --dry-run
  python3 tools/localization_enrichment/refine_content.py --apply
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
MUSCLES_JSON = os.path.join(REPO_ROOT, "assets", "data", "muscles.json")

# ------------------------------------------------------------------
# 1. REPLACEMENTS — soften opinionated or didactic pearls
# ------------------------------------------------------------------
# Structure: { muscle_name: { field: [(old_prefix, new_text), ...] } }
# Prefix match is case-sensitive on the first ~50 chars to locate the item.
REPLACEMENTS: dict[str, dict[str, list[tuple[str, str]]]] = {
    "Biceps Brachii": {
        "pearls": [
            (
                "Exclusive biceps injection is rarely indicated",
                "When treating elbow-flexion spasticity, consider distributing dose across biceps, brachialis, and brachioradialis rather than concentrating in biceps alone — the three work as a functional group.",
            ),
        ],
    },
    "Brachialis": {
        "pearls": [
            (
                "Brachialis is unjustifiably neglected",
                "Brachialis is often under-treated in elbow-flexor spasticity; it contributes substantial force to elbow flexion and is worth including when planning the distribution of dose across the elbow-flexor group.",
            ),
        ],
    },
    "Subscapularis": {
        "pearls": [
            (
                "Frequently involved in upper-limb spasticity but treated only seldom",
                "Commonly involved in upper-limb spasticity with internal-rotation posture; worth considering when pec-major and biceps injections alone don't address the contracture.",
            ),
        ],
    },
    "Triceps": {
        "pearls": [
            (
                "Rarely treated in spasticity — flexor spasticity is far more common",
                "Extensor spasticity is less common than flexor; triceps injection is reserved for cases where the extension posture clearly contributes to function loss, positioning difficulty, or hygiene.",
            ),
        ],
    },
    "Vastus Intermedius": {
        "pearls": [
            (
                "Cannot be palpated or clinically differentiated from the other vasti — US guidance is not optional",
                "Vastus intermedius cannot be reliably palpated or clinically differentiated from the other vasti — US guidance is strongly recommended for accurate targeting.",
            ),
        ],
    },
    "Sternocleidomastoid (SCM)": {
        "pearls": [
            (
                "Dysphagia is the most feared complication",
                "Bilateral SCM injection carries a real risk of dysphagia — reduce dose bilaterally and avoid deep or medial injection near the pharynx when treating both sides.",
            ),
        ],
    },
}

# ------------------------------------------------------------------
# 2. ADDITIONS — fill in the 3 partial-confidence muscles
# ------------------------------------------------------------------
# Sourced from high-DPI image reads of the book pages (300 DPI).
# Paraphrased — no verbatim book text.
ADDITIONS: dict[str, dict[str, list[str]]] = {
    "Pronator Quadratus": {
        "landmarks": [
            "Distal anterior forearm, just proximal to the wrist crease — pronator quadratus is the deep square muscle between the distal radius and ulna.",
            "Ulnar border of the distal forearm — the preferred approach is from the medial (ulnar) side at a right angle, slightly above the ulna.",
        ],
        "placement": [
            "Ventral approach (preferred): needle enters from the medial (ulnar) side of the distal anterior forearm, at a right angle to the forearm and slightly above the ulna.",
            "Dorsal approach (alternative): possible but NOT preferred — the extensor tendons are in the way and the interosseous membrane must be penetrated. If used, the hand must be in supination.",
            "Sites: typically 1.",
        ],
        "setup": [
            "Patient position: forearm supinated, hand slightly open and relaxed.",
            "US guidance strongly recommended — pronator quadratus cannot be palpated and lies deep to the superficial flexors.",
        ],
        "pearls": [
            "Works in synergy with pronator teres; injecting both muscles is uncommon — consider pronator teres alone first for most pronation patterns.",
            "The ventral (medial/ulnar) approach is preferred; the dorsal approach is difficult due to extensor tendons + interosseous membrane.",
        ],
    },

    "Hand Lumbricals": {
        "landmarks": [
            "Upper half of the palm, radial to each respective flexor tendon (lumbricals 1-4 each sit radial to the flexor digitorum profundus tendon of their respective finger).",
            "For the 1st lumbrical: directly above the distal border of the 2nd metacarpal.",
            "For the 2nd-4th lumbricals: slightly distal and radial to the head of the respective metacarpal (3rd, 4th, 5th).",
        ],
        "placement": [
            "Primary approach (palmar): needle enters from the palmar side, radial to each respective tendon at the specified landmarks.",
            "Alternative approach (dorsal): possible from the dorsum of the hand. Place the US probe in the palm and inject from the dorsum so the needle enters the image from below the screen.",
            "Injection direction: toward the bones (metacarpals).",
            "Sites: 1 per lumbrical, as many lumbricals as clinically indicated.",
        ],
        "setup": [
            "Patient position: elbow in supination, wrist and fingers comfortably extended.",
            "US guidance strongly recommended — the lumbricals cannot be palpated, and injection errors or diffusion into adjacent muscles occur easily.",
        ],
        "pearls": [
            "The lumbricals cannot be palpated; injection errors and toxin diffusion into adjacent muscles occur easily without US.",
            "The 1st lumbrical must be distinguished from adductor pollicis and the 1st dorsal interosseous — US shows this clearly.",
            "Lumbrical spasticity contributes to the 'lumbrical hand' deformity (MCP flexion + IP extension). Reserve treatment for this clear pattern.",
            "Effect of lumbrical injection is debated — many clinicians report only modest benefit. Set patient expectations accordingly.",
        ],
    },

    "Flexor Digitorum Superficialis": {
        "landmarks": [
            "Medial epicondyle of the humerus (humeroulnar head) and anterior shaft of the radius (radial head).",
            "Ulnar side of the mid-forearm, halfway between the elbow fold and the wrist crease — here FDS lies most superficially and is the safest target.",
        ],
        "placement": [
            "Preferred site: middle of the ulnar side of the forearm, halfway between elbow and wrist, where the muscle lies superficially.",
            "Injection direction: vertical (perpendicular to skin).",
            "Injection depth: 10-20 mm.",
            "Sites: 1-4. For multiple sites near the elbow, consider BOTH heads — inject on ulnar AND radial sides of the proximal forearm.",
        ],
        "setup": [
            "Patient position: elbow supinated, wrist and fingers comfortably extended.",
            "US or EMG guidance is recommended — FDS and FDP lie side by side and cannot be reliably distinguished by palpation alone.",
            "During clinical exam, keep the wrist in neutral — FDS becomes insufficient (can't generate force) if the wrist is flexed, so you can't test its action properly with the wrist down.",
        ],
        "pearls": [
            "Treated in most patients presenting with finger-flexor spasticity; for finger-flexion pattern, the other forearm flexors typically need treatment too.",
            "The muscle bellies of the individual finger-specific FDS slips are arranged on TWO levels (superficial and deep), not side by side — which is why US is helpful when targeting a specific finger.",
            "PIP-joint flexion is generated synergistically by FDS and FDP together — inject both for full effect on PIP spasticity.",
        ],
    },
}


def apply_replacements(muscles: list, dry_run: bool) -> list[tuple[str, str, str, str]]:
    """Return list of (muscle, field, old_prefix, new_text_preview) tuples
    describing what changed (or would change)."""
    by_name = {m["name"]: m for m in muscles}
    changes = []
    for muscle_name, fields in REPLACEMENTS.items():
        muscle = by_name.get(muscle_name)
        if not muscle:
            print(f"WARNING: {muscle_name} not in muscles.json — skipping replacement")
            continue
        for field, swaps in fields.items():
            items = muscle.get(field) or []
            if not isinstance(items, list):
                continue
            for old_prefix, new_text in swaps:
                matched_idx = None
                for i, item in enumerate(items):
                    if item.startswith(old_prefix):
                        matched_idx = i
                        break
                if matched_idx is None:
                    print(
                        f"WARNING: {muscle_name}.{field}: no item starts with "
                        f"'{old_prefix[:40]}…' — skipping"
                    )
                    continue
                old_text = items[matched_idx]
                if not dry_run:
                    items[matched_idx] = new_text
                changes.append((muscle_name, field, old_text[:80], new_text[:80]))
    return changes


def apply_additions(muscles: list, dry_run: bool) -> list[tuple[str, str, str]]:
    """Return list of (muscle, field, new_item_preview) tuples."""
    by_name = {m["name"]: m for m in muscles}
    added = []
    for muscle_name, fields in ADDITIONS.items():
        muscle = by_name.get(muscle_name)
        if not muscle:
            print(f"WARNING: {muscle_name} not in muscles.json — skipping addition")
            continue
        for field, new_items in fields.items():
            current = muscle.get(field) or []
            if not isinstance(current, list):
                current = [current] if current else []
            for item in new_items:
                # Simple duplicate check: skip if first 40 chars already present
                key = item[:40].lower()
                already = any(key in (existing or "").lower() for existing in current)
                if already:
                    continue
                if not dry_run:
                    current.append(item)
                added.append((muscle_name, field, item[:80]))
            if not dry_run:
                muscle[field] = current
    return added


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

    print("=== Pearl refinements (replacements) ===\n")
    replacement_changes = apply_replacements(muscles, args.dry_run)
    for muscle, field, old, new in replacement_changes:
        print(f"  {muscle}.{field}:")
        print(f"    OLD: {old}…")
        print(f"    NEW: {new}…\n")

    print(f"\n=== Additions for partial-confidence muscles ===\n")
    addition_changes = apply_additions(muscles, args.dry_run)
    per_muscle_counts: dict[str, int] = {}
    for muscle, field, preview in addition_changes:
        per_muscle_counts[muscle] = per_muscle_counts.get(muscle, 0) + 1
    for muscle, count in per_muscle_counts.items():
        print(f"  {muscle}: +{count} items")
    for muscle, field, preview in addition_changes:
        print(f"      .{field}: {preview}…")

    print(
        f"\n=== Summary: {len(replacement_changes)} replacements, "
        f"{len(addition_changes)} additions ==="
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
        print(f"\nWrote {MUSCLES_JSON}.")
    except Exception as e:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        print(f"FAILED: {e}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
