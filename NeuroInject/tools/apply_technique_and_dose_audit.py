#!/usr/bin/env python3
"""Apply all technique audit fixes (15 findings) + dose corrections (16 findings).

Technique audit: 4 Critical + 7 Moderate + 4 Minor
Dose audit: 2 Wrong + 8 Upper-end-too-high + 6 Fixed-values-to-ranges
"""
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


def main():
    muscles = json.loads(MUSCLES.read_text())
    patterns = json.loads(PATTERNS.read_text())
    changes = 0

    print("=== TECHNIQUE AUDIT FIXES (15) ===\n")

    # --- CRITICAL 1: gluteus-maximus setup contradiction ---
    m = find(muscles, "gluteus-maximus")
    new_setup = []
    for s in m["setup"]:
        if "upper-outer quadrant" in s.lower() or "upper outer quadrant" in s.lower():
            new_setup.append(
                "The sciatic nerve runs deep to this muscle inferiorly and medially — "
                "target the thick mid-belly of gluteus maximus between the sacrum/coccyx "
                "and greater trochanter (NOT the upper-outer quadrant, which targets "
                "gluteus medius). Stay lateral to a line from the PSIS to the ischial tuberosity."
            )
            print("  C1 gluteus-maximus: fixed setup upper-outer-quadrant contradiction")
            changes += 1
        else:
            new_setup.append(s)
    m["setup"] = new_setup

    # --- CRITICAL 2: fhl pearl conflates hitchhiker's toe ---
    m = find(muscles, "fhl")
    for i, p in enumerate(m.get("pearls", [])):
        if "hitchhiker" in p.lower():
            m["pearls"][i] = (
                "Key target for great toe hyperflexion (claw hallux) pattern — "
                "do NOT confuse with hitchhiker's toe (striatal toe), which is "
                "caused by EHL spasticity."
            )
            print("  C2 fhl: fixed hitchhiker's toe conflation in pearl")
            changes += 1
            break

    # --- CRITICAL 3: adductor-longus vessel direction ---
    m = find(muscles, "adductor-longus")
    for i, p in enumerate(m.get("pearls", [])):
        if "femoral vessels" in p.lower() and "medial" in p.lower():
            m["pearls"][i] = (
                "Femoral vessels lie LATERAL to the adductor longus in the femoral "
                "triangle — identify them with color Doppler and keep the needle "
                "medial to these structures."
            )
            print("  C3 adductor-longus: fixed vessel direction (medial→lateral)")
            changes += 1
            break

    # --- CRITICAL 4: peroneus-longus pattern + warning ---
    m = find(muscles, "peroneus-longus")
    # Remove from equinus pattern
    if "equinus" in m.get("spasticityPatterns", []):
        m["spasticityPatterns"] = [
            p for p in m["spasticityPatterns"] if p != "equinus"
        ]
        print("  C4 peroneus-longus: removed from equinus pattern")
        changes += 1
    # Also remove from patterns.json equinus entry
    for p in patterns:
        if p["id"] == "equinus" and "peroneus-longus" in p.get("muscles", []):
            p["muscles"] = [x for x in p["muscles"] if x != "peroneus-longus"]
            print("  C4 equinus pattern: removed peroneus-longus")
            changes += 1
    # Add warning pearl
    warning = (
        "⚠️ This muscle is an EVERTOR — injecting it in equinovarus (the most common "
        "spastic foot pattern) will WORSEN the varus deformity. Only inject peroneus "
        "longus when clinical exam confirms spastic EVERSION contributing to the "
        "deformity (equinovalgus or equinus with eversion component)."
    )
    if not any("evertor" in p.lower() for p in m.get("pearls", [])):
        m["pearls"].insert(0, warning)
        print("  C4 peroneus-longus: added eversion warning pearl")
        changes += 1

    # --- MODERATE 5: lat-dorsi missing dosage ---
    m = find(muscles, "lat-dorsi")
    if not m.get("dosage"):
        m["dosage"] = {"botox": "100-150", "xeomin": "100-150", "dysport": "300-450"}
        m["dosageNote"] = "Large muscle — distribute across 2-3 sites along the posterior axillary fold."
        print("  M5 lat-dorsi: added dosage 100-150 + dosageNote")
        changes += 1

    # --- MODERATE 6: brachialis safetyNotes contradiction ---
    m = find(muscles, "brachialis")
    for i, s in enumerate(m["ultrasound"]["safetyNotes"]):
        if "lateral approach minimizes risk" in s.lower():
            m["ultrasound"]["safetyNotes"][i] = (
                "The brachial artery and median nerve lie medially — the ANTERIOR "
                "approach through the biceps (as described in placement) keeps the "
                "needle medial to the radial nerve and lateral to the brachial "
                "vessels, providing the safest corridor."
            )
            print("  M6 brachialis: fixed safetyNote lateral→anterior")
            changes += 1
            break

    # --- MODERATE 7: brachialis probePlacementHint ---
    m = find(muscles, "brachialis")
    if "lateral distal arm" in m.get("probePlacementHint", ""):
        m["probePlacementHint"] = (
            "Patient supine, elbow slightly flexed. Place probe transversely on "
            "anterior distal arm, 4-6 cm above elbow crease. Photo showing probe "
            "on anterior distal arm."
        )
        print("  M7 brachialis: fixed probePlacementHint lateral→anterior")
        changes += 1

    # --- MODERATE 8: gluteus-maximus ultrasound orientation ---
    m = find(muscles, "gluteus-maximus")
    if "upper-outer quadrant" in m.get("ultrasound", {}).get("orientation", "").lower():
        m["ultrasound"]["orientation"] = (
            "Transverse across the mid-buttock, centered on the gluteus maximus "
            "belly between the sacrum and the greater trochanter"
        )
        print("  M8 gluteus-maximus: fixed US orientation")
        changes += 1

    # --- MODERATE 9: semimembranosus pearl direction error ---
    m = find(muscles, "semimembranosus")
    for i, p in enumerate(m.get("pearls", [])):
        if "more lateral" in p.lower() and "semitendinosus" in p.lower():
            m["pearls"][i] = (
                "Broader, flatter muscle — differentiate from semitendinosus by "
                "its deeper position and membranous aponeurosis on ultrasound."
            )
            print("  M9 semimembranosus: fixed lateral→deeper pearl")
            changes += 1
            break

    # --- MODERATE 10: gastrocnemius-lateral placement too close to fibular head ---
    m = find(muscles, "gastrocnemius-lateral")
    for i, s in enumerate(m["placement"]):
        if "just medial to the fibular head" in s.lower():
            m["placement"][i] = (
                "The injection site is in the center of the lateral gastrocnemius "
                "belly, 2-3 cm distal to the popliteal crease, well medial to the "
                "fibular head. Maintain at least 2 cm of clearance from the fibular "
                "head to avoid the common peroneal nerve."
            )
            print("  M10 gastrocnemius-lateral: fixed placement distance from fibular head")
            changes += 1
            break

    # --- MODERATE 11: pec-major pectoral nerve naming ---
    m = find(muscles, "pec-major")
    for i, s in enumerate(m["ultrasound"]["viewSteps"]):
        if "Lateral Pectoral Nerve" in s and "fascial plane between" in s:
            m["ultrasound"]["viewSteps"][i] = (
                "CRITICAL: The Medial Pectoral Nerve (from the medial cord — "
                "confusingly named) passes through or between Pectoralis Major and "
                "Minor in the inter-fascial plane. The Lateral Pectoral Nerve (from "
                "the lateral cord) pierces the clavipectoral fascia to reach Pec "
                "Major directly. Both may be visible as hyperechoic dots with "
                "adjacent vessels."
            )
            print("  M11 pec-major: fixed pectoral nerve naming (lateral→medial)")
            changes += 1
            break

    # --- MINOR 12: pec-major pearl dose framing ---
    m = find(muscles, "pec-major")
    for i, p in enumerate(m.get("pearls", [])):
        if "25-50U Botox per site" in p:
            m["pearls"][i] = (
                "Use 25-50U Botox per injection site, distributed across 2-3 sites "
                "per head, for a total session dose as listed in the dosage field."
            )
            print("  m12 pec-major: clarified per-site vs total dosing pearl")
            changes += 1
            break

    # --- MINOR 13: piriformis EMG pearl ---
    m = find(muscles, "piriformis")
    for i, p in enumerate(m.get("pearls", [])):
        if "emg" in p.lower() and "recommend" in p.lower():
            m["pearls"][i] = (
                "Sciatic nerve runs immediately inferior to (or through) this muscle — "
                "USG is essential, and EMG can be a useful adjunct to confirm you are "
                "in piriformis rather than adjacent muscles."
            )
            print("  m13 piriformis: clarified EMG as adjunct not standalone")
            changes += 1
            break

    # --- MINOR 14: scm sternal head dysphagia note ---
    m = find(muscles, "scm")
    dysphagia_note = (
        "When bilateral injection is necessary, preferentially dose the clavicular "
        "head over the sternal head — the sternal head is deeper and closer to "
        "pharyngeal muscles, carrying higher dysphagia risk."
    )
    if not any("sternal head" in s.lower() and "dysphagia" in s.lower() for s in m["setup"]):
        m["setup"].append(dysphagia_note)
        print("  m14 scm: added sternal-head dysphagia note to setup")
        changes += 1

    # --- MINOR 15: peroneus-longus pearl re equinus ---
    # (already handled in C4 — warning pearl added above)

    # ============================================================
    print("\n=== DOSE CORRECTIONS (16) ===\n")

    # Helper to set typed dose
    def set_dose(mid, botox_range, note=None):
        m = find(muscles, mid)
        parts = botox_range.split("-")
        if len(parts) == 2:
            lo, hi = int(parts[0]), int(parts[1])
            d = {
                "botox": f"{lo}-{hi}",
                "xeomin": f"{lo}-{hi}",
                "dysport": f"{lo*3}-{hi*3}",
            }
        else:
            n = int(parts[0])
            d = {"botox": str(n), "xeomin": str(n), "dysport": str(n * 3)}
        old = m.get("dosage", {})
        old_b = old.get("botox") if isinstance(old, dict) else str(old)
        m["dosage"] = d
        if note:
            m["dosageNote"] = note
        print(f"  {mid:28s}  B:{old_b} → B:{d['botox']}")
        return 1

    # WRONG (2)
    changes += set_dose("soleus-lateral", "50-75")
    changes += set_dose("tibialis-posterior", "50-100")

    # Upper end too high (8)
    changes += set_dose("pec-major", "50-100",
        "Total across both heads. Split dose between clavicular and sternal heads (e.g. 25-50U each).")
    changes += set_dose("soleus-medial", "50-100")
    changes += set_dose("fdl", "25-50")
    changes += set_dose("subscapularis", "50-100",
        "Distribute across multiple sites along the muscle belly. Deep injection — confirm tip placement before each.")
    changes += set_dose("adductor-magnus", "75-150")
    changes += set_dose("biceps-femoris", "50-150")
    changes += set_dose("iliopsoas", "50-100")
    changes += set_dose("edl", "25-50")

    # Fixed values → ranges (6)
    changes += set_dose("gluteus-maximus", "100-200",
        "One of the largest muscles in the body — distribute across 3-4 sites.")
    changes += set_dose("vastus-lateralis", "50-100")
    changes += set_dose("vastus-intermedius", "50-100")
    changes += set_dose("semimembranosus", "50-100")
    changes += set_dose("semitendinosus", "50-100")
    changes += set_dose("ehl", "25-50")

    # ============================================================
    # Write
    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    PATTERNS.write_text(json.dumps(patterns, indent=2, ensure_ascii=False) + "\n")
    print(f"\nDone. {changes} total changes.")


if __name__ == "__main__":
    main()
