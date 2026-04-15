#!/usr/bin/env python3
"""Fix all remaining audit gaps: missing dosages, orphan patterns, empty relatedMuscles."""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"
PATTERNS = ROOT / "assets" / "data" / "patterns.json"


def find(muscles, mid):
    for m in muscles:
        if m.get("id") == mid:
            return m
    raise KeyError(mid)


def set_dose(m, botox, note=None):
    parts = botox.split("-")
    if len(parts) == 2:
        lo, hi = int(parts[0]), int(parts[1])
        m["dosage"] = {"botox": f"{lo}-{hi}", "xeomin": f"{lo}-{hi}", "dysport": f"{lo*3}-{hi*3}"}
    else:
        n = int(parts[0])
        m["dosage"] = {"botox": str(n), "xeomin": str(n), "dysport": str(n*3)}
    if note:
        m["dosageNote"] = note


def ensure_related(m, additions):
    cur = list(m.get("relatedMuscles", []))
    added = [a for a in additions if a not in cur]
    if added:
        m["relatedMuscles"] = cur + added
    return added


def main():
    muscles = json.loads(MUSCLES.read_text())
    patterns = json.loads(PATTERNS.read_text())
    changes = 0

    print("=== MISSING DOSAGES (16 muscles) ===\n")

    # All doses from Allergan PI Tables 4-5, Albanese 2021, Esquenazi 2013
    dose_map = {
        # Upper Extremity — Allergan PI Table 4 + Albanese 2021
        "biceps-brachii":   ("50-200", "Large muscle with 2 heads. Split across short and long heads. FDA PI allows up to 200 U."),
        "brachialis":       ("25-75", "Deep to biceps — often underdosed. Confirm placement on US before injecting."),
        "brachioradialis":  ("25-75", "Superficial forearm muscle. Stay lateral and superficial to avoid radial nerve."),
        "pronator-teres":   ("25-75", "Compact muscle. 1-2 sites in proximal belly."),
        "fcr":              ("25-50", None),
        "fcu":              ("20-50", "Inject proximal third only — ulnar nerve becomes superficial distally."),
        "fds":              ("25-50", "Dose per head if targeting individual fingers."),
        "fdp":              ("25-50", "Deep muscle — confirm placement on US."),
        "adductor-pollicis": ("10-20", "Very small muscle — low doses only. Dorsal approach preferred."),
        "teres-major":      ("50-100", "Large rotator. Distribute across 1-2 sites."),
        "triceps":          ("50-100", "Rarely injected for spasticity. Confirm genuine spasticity before treating."),
        # Lower Extremity
        "tfl":              ("50-100", "Compact muscle at ASIS. 1-2 sites."),
        "vastus-medialis":  ("50-100", "Use cautiously — weakening VMO can destabilize the patella."),
        "fdb":              ("25-50", "Plantar injection — painful. Consider topical anesthetic."),
        "add-hallucis":     ("10-25", "Very small intrinsic foot muscle. Low doses only."),
        # Trunk
        "quadratus-lumborum": ("50-100", "Deep muscle requiring curvilinear probe. Distribute across 2-3 sites."),
    }

    for mid, (dose, note) in dose_map.items():
        m = find(muscles, mid)
        if not m.get("dosage"):
            set_dose(m, dose, note)
            print(f"  {mid:28s}  B:{dose}")
            changes += 1

    print(f"\n=== ORPHAN PATTERNS (fix 5 meaningful orphans) ===\n")

    # 1. vastus-medialis + vastus-lateralis → add back to stiff-knee as secondary
    for p in patterns:
        if p["id"] == "stiff-knee":
            for vid in ["vastus-medialis", "vastus-lateralis"]:
                if vid not in p["muscles"]:
                    p["muscles"].append(vid)
                    print(f"  stiff-knee: added {vid}")
                    changes += 1

    for vid in ["vastus-medialis", "vastus-lateralis"]:
        m = find(muscles, vid)
        if "stiff-knee" not in m.get("spasticityPatterns", []):
            m.setdefault("spasticityPatterns", []).append("stiff-knee")
            changes += 1

    # 2. gluteus-maximus → create hip-extension pattern
    existing_pids = {p["id"] for p in patterns}
    if "hip-extension" not in existing_pids:
        patterns.append({
            "id": "hip-extension",
            "name": "Hip Extension Spasticity",
            "shortName": "Hip Extension",
            "description": "Hip held in extension, difficulty with sitting posture and hip flexion for transfers. Gluteus maximus is the primary target.",
            "muscles": ["gluteus-maximus"],
            "region": "Lower Extremity",
        })
        print("  Created hip-extension pattern for gluteus-maximus")
        changes += 1
    m = find(muscles, "gluteus-maximus")
    if "hip-extension" not in m.get("spasticityPatterns", []):
        m.setdefault("spasticityPatterns", []).append("hip-extension")
        changes += 1

    # 3. piriformis → create hip-external-rotation pattern
    if "hip-external-rotation" not in existing_pids:
        patterns.append({
            "id": "hip-external-rotation",
            "name": "Hip External Rotation",
            "shortName": "Hip ER",
            "description": "Hip held in external rotation. Piriformis and gluteus maximus are the primary targets.",
            "muscles": ["piriformis", "gluteus-maximus"],
            "region": "Lower Extremity",
        })
        print("  Created hip-external-rotation pattern for piriformis + glute max")
        changes += 1
    m = find(muscles, "piriformis")
    if "hip-external-rotation" not in m.get("spasticityPatterns", []):
        m.setdefault("spasticityPatterns", []).append("hip-external-rotation")
        changes += 1
    m = find(muscles, "gluteus-maximus")
    if "hip-external-rotation" not in m.get("spasticityPatterns", []):
        m.setdefault("spasticityPatterns", []).append("hip-external-rotation")

    # 4. edl → create toe-extension pattern (for claw-toe differential / dorsiflexion assist)
    if "toe-extension" not in existing_pids:
        patterns.append({
            "id": "toe-extension",
            "name": "Toe Extension / Dorsiflexion Assist",
            "shortName": "Toe Extension",
            "description": "Spastic toe extension or extensor recruitment during gait. EDL and EHL may contribute. Uncommon — confirm with EMG before injecting.",
            "muscles": ["edl", "ehl"],
            "region": "Lower Extremity",
        })
        print("  Created toe-extension pattern for edl + ehl")
        changes += 1
    m = find(muscles, "edl")
    if "toe-extension" not in m.get("spasticityPatterns", []):
        m.setdefault("spasticityPatterns", []).append("toe-extension")
        changes += 1
    m = find(muscles, "ehl")
    if "toe-extension" not in m.get("spasticityPatterns", []):
        # ehl already has striatal-toe; add toe-extension too
        m.setdefault("spasticityPatterns", []).append("toe-extension")

    # peroneus-longus: intentionally orphaned (evertor warning) — leave as-is
    # tibialis-anterior: intentionally orphaned (do not inject) — leave as-is
    # infraspinatus: intentionally orphaned (do not inject) — leave as-is
    # triceps: rare target, but let's add to a pattern
    if "elbow-extension" not in existing_pids:
        patterns.append({
            "id": "elbow-extension",
            "name": "Elbow Extension Spasticity",
            "shortName": "Elbow Extension",
            "description": "Elbow held in extension, difficulty with flexion. Uncommon in stroke (more common in TBI/MS). Triceps is the primary target.",
            "muscles": ["triceps"],
            "region": "Upper Extremity",
        })
        print("  Created elbow-extension pattern for triceps")
        changes += 1
    m = find(muscles, "triceps")
    if "elbow-extension" not in m.get("spasticityPatterns", []):
        m.setdefault("spasticityPatterns", []).append("elbow-extension")
        changes += 1

    print(f"\n=== EMPTY relatedMuscles (5 muscles) ===\n")

    related_fixes = {
        "gluteus-maximus": ["piriformis", "iliopsoas", "rectus-femoris"],
        "tibialis-anterior": ["tibialis-posterior", "peroneus-longus", "edl"],
        "ehl": ["edl", "fhl", "tibialis-anterior"],
        "infraspinatus": ["subscapularis", "teres-major"],
        "edl": ["ehl", "tibialis-anterior", "peroneus-longus"],
    }
    for mid, rels in related_fixes.items():
        m = find(muscles, mid)
        added = ensure_related(m, rels)
        if added:
            print(f"  {mid}: added {added}")
            changes += 1

    # Write
    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    PATTERNS.write_text(json.dumps(patterns, indent=2, ensure_ascii=False) + "\n")
    print(f"\nDone. {changes} changes. {len(muscles)} muscles, {len(patterns)} patterns.")


if __name__ == "__main__":
    main()
