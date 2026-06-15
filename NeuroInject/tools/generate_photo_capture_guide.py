#!/usr/bin/env python3
"""Generate the clinical photo capture guide from muscles.json.

Produces docs/clinical-photo-guide.md — a shot list for the photography
session. For each of the 68 muscles it lists the three standardized photos
(patient position, probe + needle site, ultrasound image), each with its
exact target filename and capture guidance pulled from that muscle's own
data. The probe + needle site is ONE photo, annotated afterward: a blue bar
over the probe footprint and a red dot at the needle insertion point.
Filenames match the app's ClinicalPhotoSlot convention
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
# "probe" is the combined surface shot: blue bar = probe footprint,
# red dot = needle insertion point, annotated on the same image.
SLOTS = [
    ("position", "Patient Position"),
    ("probe", "Probe + Needle Site"),
    ("us", "Ultrasound Image"),
]

PHOTOS_PER_MUSCLE = len(SLOTS)

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
    """One surface photo: probe footprint (blue bar) + needle entry (red dot)."""
    us = m.get("ultrasound") or {}
    parts = []
    hint = m.get("probePlacementHint")
    if hint:
        parts.append(clip(hint))
    if us.get("probe"):
        parts.append(f"Probe: {us['probe']}.")
    if us.get("orientation"):
        parts.append(f"Orientation: {clip(us['orientation'], 160)}.")
    pl = m.get("placement") or []
    hits = [s for s in pl if NEEDLE_RE.search(s)]
    if hits:
        parts.append("Needle: " + clip(hits[0], 200))
    if not us:
        parts.append(
            "Not typically ultrasound-guided — still mark the red needle dot; "
            "the blue probe bar is optional."
        )
    return (" ".join(parts) if parts
            else "Mark the probe footprint and needle entry on the skin.")


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
    "us": us_guidance,
}


def slot_filename(m, key):
    """Target filename for a shot. Patient-position photos are SHARED across
    muscles set up the same way (one `pos-<positionGroup>.jpg`); probe and US
    stay per-muscle (`<id>-<key>.jpg`)."""
    if key == "position" and m.get("positionGroup"):
        return f"pos-{m['positionGroup']}.jpg"
    return f"{m['id']}-{key}.jpg"


def position_groups(muscles):
    """Ordered {group_key: (label, [muscles])}, first-appearance order — the
    set of unique patient-position photos to capture."""
    groups = {}
    for m in muscles:
        key = m.get("positionGroup") or f"{m['id']}-position"
        groups.setdefault(key, (m.get("positionLabel") or m["id"], []))[1].append(m)
    return groups


def main():
    muscles = json.loads(DATA.read_text())
    by_region = {r: [] for r in REGION_ORDER}
    for m in muscles:
        by_region[region_of(m["group"])].append(m)

    total = len(muscles)
    us_guided = sum(1 for m in muscles if m.get("ultrasound"))
    pos_groups = position_groups(muscles)
    n_positions = len(pos_groups)
    # Position photos are shared by group; probe is per-muscle; US per US-guided.
    total_images = n_positions + total + us_guided

    L = []
    L.append("# NeuroInject — Clinical Photo Capture Guide")
    L.append("")
    L.append(
        f"Shot list for the clinical photography session. "
        f"**{n_positions} patient-position photos (shared) + {total} probe + "
        f"{us_guided} ultrasound = {total_images} images** across {total} muscles."
    )
    L.append("")
    L.append(
        "> Auto-generated from `assets/data/muscles.json` by "
        "`tools/generate_photo_capture_guide.py`. Re-run after editing muscle data."
    )
    L.append("")
    L.append("## The three photos per muscle")
    L.append("")
    L.append("| # | Photo | What to capture |")
    L.append("|---|-------|-----------------|")
    L.append("| 1 | **Patient Position** | The patient positioned and the segment "
             "exposed. **Shared** — many muscles use the same position, so this is "
             "shot once and reused (see the table below). |")
    L.append("| 2 | **Probe + Needle Site** | ONE surface photo, annotated: a "
             "**blue bar** over the probe footprint on the skin and a **red dot** "
             "at the needle insertion point. Per-muscle. |")
    L.append("| 3 | **Ultrasound Image** | The US screen of the target muscle (with "
             "the needle in the muscle if you can). Per-muscle. |")
    L.append("")
    L.append("## Naming & where files go")
    L.append("")
    L.append(
        "Save each photo with this **exact** name into "
        "`NeuroInject/assets/images/clinical/`:"
    )
    L.append("")
    L.append("```")
    L.append("pos-<positionGroup>.jpg   (ONE shared patient-position photo)")
    L.append("<muscleId>-probe.jpg      (combined probe + needle site, per muscle)")
    L.append("<muscleId>-us.jpg         (ultrasound, per muscle)")
    L.append("```")
    L.append("")
    L.append("- **Format:** JPG (convert HEIC → JPG first). Landscape preferred.")
    L.append(
        f"- **Patient position is shared.** The {total} muscles need only "
        f"**{n_positions}** position photos — capture each `pos-<group>.jpg` once "
        f"and every muscle in that group reuses it. That's {total - n_positions} "
        "fewer position shots."
    )
    L.append(
        "- **Annotation convention:** blue bar = probe footprint, red dot = "
        "needle insertion point — drawn on the same image."
    )
    L.append(
        "- The app auto-detects each file — the muscle's detail page swaps the "
        f"placeholder for the photo and shows an \"N/{PHOTOS_PER_MUSCLE} "
        "captured\" counter. No code or data edit needed."
    )
    L.append(
        f"- **{us_guided}/{total}** muscles are ultrasound-guided; for the "
        f"{total - us_guided} that are not, the US image is optional and the "
        f"site photo needs only the red needle dot (blue probe bar optional)."
    )
    L.append("")

    # ── Shared patient-position reference ─────────────────────────────
    L.append(f"## Patient positions — {n_positions} photos to capture once")
    L.append("")
    L.append(
        "Each row is **one** photo. Shoot it once; every listed muscle reuses it."
    )
    L.append("")
    L.append("| Position | File | Muscles |")
    L.append("|----------|------|---------|")
    for key, (label, ms) in pos_groups.items():
        names = ", ".join(x["name"] for x in ms)
        L.append(f"| {label} | `pos-{key}.jpg` | {len(ms)} — {names} |")
    L.append("")
    L.append("---")
    L.append("")

    for region in REGION_ORDER:
        group_muscles = by_region[region]
        if not group_muscles:
            continue
        L.append(
            f"## {region}  ·  {len(group_muscles)} muscles  ·  "
            f"{len(group_muscles) * PHOTOS_PER_MUSCLE} photos"
        )
        L.append("")
        for m in group_muscles:
            mid = m["id"]
            flag = "" if m.get("ultrasound") else "  _(not typically US-guided)_"
            L.append(f"### {m['name']}  `{mid}`{flag}")
            L.append(f"*{m['group']} — {m.get('pattern', '')}*")
            L.append("")
            for key, label in SLOTS:
                fn = slot_filename(m, key)
                shared = (" · _shared_" if key == "position"
                          and m.get("positionGroup") else "")
                L.append(f"- [ ] **{label}** — `{fn}`{shared}")
                L.append(f"  {GUIDANCE[key](m)}")
            L.append("")
        L.append("---")
        L.append("")

    L.append("## Appendix — flat filename checklist")
    L.append("")
    L.append(f"All {total_images} files, for ticking off during the shoot:")
    L.append("")
    L.append(f"**Patient position — {n_positions} shared:**")
    for key in pos_groups:
        L.append(f"- [ ] `pos-{key}.jpg`")
    L.append("")
    L.append(f"**Probe + needle site — {total}:**")
    for region in REGION_ORDER:
        for m in by_region[region]:
            L.append(f"- [ ] `{m['id']}-probe.jpg`")
    L.append("")
    L.append(f"**Ultrasound — {us_guided}:**")
    for region in REGION_ORDER:
        for m in by_region[region]:
            if m.get("ultrasound"):
                L.append(f"- [ ] `{m['id']}-us.jpg`")
    L.append("")

    OUT.write_text("\n".join(L) + "\n")
    print(f"Wrote {OUT.relative_to(ROOT)} — {total} muscles, {total_images} images.")


if __name__ == "__main__":
    main()
