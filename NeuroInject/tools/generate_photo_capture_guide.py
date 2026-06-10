#!/usr/bin/env python3
"""Generate the clinical photo capture guide from muscles.json.

Produces docs/clinical-photo-guide.md — a shot list for the photography
session. For each of the 68 muscles it lists the four standardized photos
(patient position, probe placement, needle insertion, ultrasound image), each
with its exact target filename and capture guidance pulled from that muscle's
own data. Filenames match the app's ClinicalPhotoSlot convention
(lib/models/clinical_photo.dart), so a photo dropped into
assets/images/clinical/ appears automatically.

Re-run after editing muscle data: python3 tools/generate_photo_capture_guide.py
"""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "assets" / "data" / "muscles.json"
OUT = ROOT / "docs" / "clinical-photo-guide.md"

# (key, label) — key matches ClinicalPhotoSlot.key and the filename suffix.
SLOTS = [
    ("position", "Patient Position"),
    ("probe", "Probe Placement"),
    ("needle", "Needle Insertion"),
    ("us", "Ultrasound Image"),
]

REGION_ORDER = ["Upper Extremity", "Lower Extremity", "Cervical / Neck", "Face / Neck"]

NEEDLE_RE = re.compile(
    r"\b(insert|needle|advance|angle|perpendicular|tangential|aim|direct|inject)\b",
    re.I,
)


def region_of(group):
    g = group.lower()
    if "upper" in g:
        return "Upper Extremity"
    if "lower" in g:
        return "Lower Extremity"
    if "cervical" in g:
        return "Cervical / Neck"
    return "Face / Neck"


def clip(text, maxlen=240):
    t = " ".join(text.split())
    return t if len(t) <= maxlen else t[:maxlen].rsplit(" ", 1)[0] + "…"


def position_guidance(m):
    pl = m.get("placement") or []
    return clip(pl[0]) if pl else "Position per the placement steps in the app."


def probe_guidance(m):
    us = m.get("ultrasound") or {}
    parts = []
    hint = m.get("probePlacementHint")
    if hint:
        parts.append(clip(hint))
    if us.get("probe"):
        parts.append(f"Probe: {us['probe']}.")
    if us.get("orientation"):
        parts.append(f"Orientation: {clip(us['orientation'], 160)}.")
    if not us:
        parts.append("Not typically ultrasound-guided — probe shot optional.")
    return " ".join(parts) if parts else "Show the probe position on the skin."


def needle_guidance(m):
    pl = m.get("placement") or []
    hits = [s for s in pl if NEEDLE_RE.search(s)]
    if hits:
        return " ".join(clip(h) for h in hits[:2])
    return (
        "Show the needle entry point and angle — see the placement steps "
        "in the app."
    )


def us_guidance(m):
    us = m.get("ultrasound") or {}
    if not us:
        return "Not typically ultrasound-guided — US image optional."
    parts = []
    vs = us.get("viewSteps") or []
    if vs:
        parts.append("You should see: " + " ".join(clip(v, 180) for v in vs[:2]))
    if us.get("depth"):
        parts.append(f"Depth ≈ {us['depth']}.")
    sn = us.get("safetyNotes") or []
    if sn:
        parts.append("⚠ " + clip(sn[0], 180))
    return " ".join(parts)


GUIDANCE = {
    "position": position_guidance,
    "probe": probe_guidance,
    "needle": needle_guidance,
    "us": us_guidance,
}


def main():
    muscles = json.loads(DATA.read_text())
    by_region = {r: [] for r in REGION_ORDER}
    for m in muscles:
        by_region[region_of(m["group"])].append(m)

    total = len(muscles)
    us_guided = sum(1 for m in muscles if m.get("ultrasound"))
    total_images = total * 4

    L = []
    L.append("# NeuroInject — Clinical Photo Capture Guide")
    L.append("")
    L.append(
        f"Shot list for the clinical photography session. "
        f"**{total} muscles × 4 photos = {total_images} images.**"
    )
    L.append("")
    L.append(
        "> Auto-generated from `assets/data/muscles.json` by "
        "`tools/generate_photo_capture_guide.py`. Re-run after editing muscle data."
    )
    L.append("")
    L.append("## The four photos per muscle")
    L.append("")
    L.append("| # | Photo | What to capture |")
    L.append("|---|-------|-----------------|")
    L.append("| 1 | **Patient Position** | The patient positioned and the segment "
             "exposed, as you set up to inject. |")
    L.append("| 2 | **Probe Placement** | The ultrasound probe held on the skin at "
             "the injection site. |")
    L.append("| 3 | **Needle Insertion** | The needle entry point and angle at the "
             "surface. |")
    L.append("| 4 | **Ultrasound Image** | The US screen of the target muscle (with "
             "the needle in the muscle if you can). |")
    L.append("")
    L.append("## Naming & where files go")
    L.append("")
    L.append(
        "Save each photo with this **exact** name into "
        "`NeuroInject/assets/images/clinical/`:"
    )
    L.append("")
    L.append("```")
    L.append("<muscleId>-position.jpg")
    L.append("<muscleId>-probe.jpg")
    L.append("<muscleId>-needle.jpg")
    L.append("<muscleId>-us.jpg")
    L.append("```")
    L.append("")
    L.append("- **Format:** JPG (convert HEIC → JPG first). Landscape preferred.")
    L.append(
        "- The app auto-detects each file — the muscle's detail page swaps the "
        "placeholder for the photo and shows an \"N/4 captured\" counter. No code "
        "or data edit needed."
    )
    L.append(
        f"- **{us_guided}/{total}** muscles are ultrasound-guided; for the "
        f"{total - us_guided} that are not, the probe/US shots are marked optional."
    )
    L.append("")
    L.append("---")
    L.append("")

    for region in REGION_ORDER:
        group_muscles = by_region[region]
        if not group_muscles:
            continue
        L.append(
            f"## {region}  ·  {len(group_muscles)} muscles  ·  "
            f"{len(group_muscles) * 4} photos"
        )
        L.append("")
        for m in group_muscles:
            mid = m["id"]
            flag = "" if m.get("ultrasound") else "  _(not typically US-guided)_"
            L.append(f"### {m['name']}  `{mid}`{flag}")
            L.append(f"*{m['group']} — {m.get('pattern', '')}*")
            L.append("")
            for key, label in SLOTS:
                L.append(f"- [ ] **{label}** — `{mid}-{key}.jpg`")
                L.append(f"  {GUIDANCE[key](m)}")
            L.append("")
        L.append("---")
        L.append("")

    L.append("## Appendix — flat filename checklist")
    L.append("")
    L.append(f"All {total_images} files, for ticking off during the shoot:")
    L.append("")
    for region in REGION_ORDER:
        for m in by_region[region]:
            for key, _ in SLOTS:
                L.append(f"- [ ] `{m['id']}-{key}.jpg`")
    L.append("")

    OUT.write_text("\n".join(L) + "\n")
    print(f"Wrote {OUT.relative_to(ROOT)} — {total} muscles, {total_images} images.")


if __name__ == "__main__":
    main()
