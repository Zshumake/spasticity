#!/usr/bin/env python3
"""Apply Moderate audit batches 5-6 (Groups B + C).

Group B: Clinical precision (B-M03, B-M05, B-M08, B-M11, B-M16, B-M25)
        — B-M06 FDS intentionally skipped (existing advice defensible)
Group C: Dose decisions with dosageNote tags (C-M01, C-M07, C-M09, C-M15)
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"


def find(muscles, mid):
    for m in muscles:
        if m.get("id") == mid:
            return m
    raise KeyError(f"Muscle not found: {mid}")


def main():
    muscles = json.loads(MUSCLES.read_text())
    changes = 0

    print("Applying Moderate batches 5-6 (Groups B + C)...\n")

    # =======================================================================
    # GROUP B — Clinical precision
    # =======================================================================
    print("--- Group B: Clinical precision ---")

    # B-M03: Brachialis — fix US orientation/viewSteps to match anterior approach
    m = find(muscles, "brachialis")
    m["ultrasound"]["orientation"] = (
        "Transverse across the anterior distal third of the arm, "
        "~4-6 cm proximal to the elbow crease (matching the anterior-through-biceps approach)"
    )
    m["ultrasound"]["viewSteps"] = [
        "Place the probe transversely across the anterior distal third of the arm, ~4-6 cm proximal to the elbow crease.",
        "Identify subcutaneous tissue and the superficial hyperechoic fascia.",
        "The Biceps Brachii is visible as a superficial oval hypoechoic muscle belly with a central tendon distally.",
        "Deep to the Biceps, the Brachialis appears as a flattened hypoechoic muscle directly against the hyperechoic cortex of the distal humerus.",
        "The bright cortical line of the humerus serves as your deep landmark — stop the needle before reaching it.",
        "Scan laterally to identify the radial nerve in the spiral groove (small hyperechoic honeycomb) so you know where it is — your anterior approach should keep you well away from it.",
    ]
    print("  B-M03 brachialis: US orientation/viewSteps rewritten for anterior approach")
    changes += 1

    # B-M05: FCU — proximal-third warning
    m = find(muscles, "fcu")
    proximal_step = ("Inject in the PROXIMAL THIRD of the forearm only — distally, the ulnar "
                     "nerve becomes increasingly superficial as it approaches Guyon's canal "
                     "at the wrist. Avoid the distal half.")
    if proximal_step not in m["placement"]:
        m["placement"].append(proximal_step)
        print("  B-M05 fcu: added proximal-third placement step")
        changes += 1
    proximal_safety = ("The ulnar nerve emerges from beneath FCU in the distal third of the "
                       "forearm and becomes superficial near Guyon's canal. Confine injections "
                       "to the proximal half/third where the nerve is still protected deep to the muscle.")
    if proximal_safety not in m["ultrasound"]["safetyNotes"]:
        m["ultrasound"]["safetyNotes"].append(proximal_safety)
        print("  B-M05 fcu: added Guyon's canal safety note")
        changes += 1

    # B-M08: Adductor pollicis — standardize probe spec
    m = find(muscles, "adductor-pollicis")
    new_probe = ("High-frequency linear (10-15 MHz); a hockey-stick probe is helpful "
                 "in the tight first web space")
    if m["ultrasound"]["probe"] != new_probe:
        m["ultrasound"]["probe"] = new_probe
        print("  B-M08 adductor-pollicis: probe spec standardized")
        changes += 1

    # B-M11: Gluteus maximus — drop the upper-outer quadrant teaching (it's wrong target)
    m = find(muscles, "gluteus-maximus")
    m["placement"] = [
        "Position the patient prone or in lateral decubitus with the affected side up.",
        "Palpate the PSIS (the bony dimple near the sacrum) and the Greater Trochanter (lateral bony prominence).",
        ("⚠️ NOTE: The 'upper-outer quadrant' rule from IM-injection teaching targets gluteus "
         "MEDIUS — it is NOT the gluteus maximus belly. For botulinum toxin into gluteus "
         "maximus, target the thick muscle belly inferior and posterior to that line, between "
         "the sacrum/coccyx and the greater trochanter."),
        ("Under ultrasound, identify the thick muscle belly of gluteus maximus posteriorly "
         "and inferiorly to gluteus medius. Stay superficial-to-mid depth."),
        ("Insert the needle perpendicular to the skin into the muscle bulk at multiple sites "
         "distributed across the belly (3-4 sites for a large muscle)."),
        "Advance 3-5 cm into the large muscle bulk (depth varies with body habitus).",
        "Aspirate before injecting.",
        ("Stay LATERAL to a line drawn from the PSIS to the ischial tuberosity — the sciatic "
         "nerve exits the greater sciatic foramen medial to this line and dives deep beneath "
         "piriformis. Use color Doppler to identify the inferior gluteal vessels."),
    ]
    print("  B-M11 gluteus-maximus: placement rewritten (dropped IM-vaccine landmark)")
    changes += 1

    # B-M16: Tibialis posterior — probe selection
    m = find(muscles, "tibialis-posterior")
    new_probe = ("High-frequency linear (10-15 MHz) in thin patients; lower-frequency linear "
                 "(6-9 MHz) or curvilinear (5-8 MHz) is often required in average/larger "
                 "patients due to muscle depth (3-5+ cm)")
    if m["ultrasound"]["probe"] != new_probe:
        m["ultrasound"]["probe"] = new_probe
        print("  B-M16 tibialis-posterior: probe selection note added")
        changes += 1
    new_supplies = []
    for s in m.get("supplies", []):
        if s == "Ultrasound machine with linear probe":
            new_supplies.append(
                "Ultrasound machine with linear probe (high-frequency for thin patients; "
                "lower-frequency or curvilinear for deeper anatomy)"
            )
        else:
            new_supplies.append(s)
    if new_supplies != m.get("supplies"):
        m["supplies"] = new_supplies
        print("  B-M16 tibialis-posterior: supplies note updated")
        changes += 1

    # B-M25: SCM — pinch-and-lift technique explicit
    m = find(muscles, "scm")
    for i, step in enumerate(m["placement"]):
        if "grasping it between the thumb and ind" in step:
            m["placement"][i] = (
                "Palpate the muscle belly at the mid-cervical level (approximately the level "
                "of the thyroid cartilage). Grasp the muscle between thumb and index finger "
                "and LIFT it anteriorly off the carotid sheath — this 'pinch technique' "
                "physically separates the SCM from the underlying carotid artery and internal "
                "jugular vein during needle insertion."
            )
            print("  B-M25 scm: pinch-and-lift technique made explicit")
            changes += 1
            break

    # =======================================================================
    # GROUP C — Dose decisions
    # =======================================================================
    print("\n--- Group C: Dose decisions ---")

    # C-M01: Pec major — tighten upper bound
    m = find(muscles, "pec-major")
    m["dosage"] = {"botox": "75-150", "xeomin": "75-150", "dysport": "225-450"}
    m["dosageNote"] = ("Total across both heads. Split dose between clavicular and sternal heads "
                       "(e.g. 50-75U each). 200U upper bound exceeds typical consensus.")
    print("  C-M01 pec-major: dose 100-200 → 75-150 + dosageNote")
    changes += 1

    # C-M07: FPL — add dose
    m = find(muscles, "fpl")
    if m.get("dosage") is None:
        m["dosage"] = {"botox": "10-25", "xeomin": "10-25", "dysport": "30-75"}
        m["dosageNote"] = ("Narrow therapeutic window — over-dosing weakens pinch grip. Start low.")
        print("  C-M07 fpl: dose 10-25 added + dosageNote")
        changes += 1

    # C-M09: Subscapularis — add dose
    m = find(muscles, "subscapularis")
    if m.get("dosage") is None:
        m["dosage"] = {"botox": "75-150", "xeomin": "75-150", "dysport": "225-450"}
        m["dosageNote"] = ("Distribute across multiple sites along the muscle belly. "
                           "Deep injection — confirm tip placement before each.")
        print("  C-M09 subscapularis: dose 75-150 added + dosageNote")
        changes += 1

    # C-M15: Rectus femoris — add dose
    m = find(muscles, "rectus-femoris")
    if m.get("dosage") is None:
        m["dosage"] = {"botox": "100-150", "xeomin": "100-150", "dysport": "300-450"}
        m["dosageNote"] = ("Primary stiff-knee gait target. 1-2 sites in proximal-mid muscle belly.")
        print("  C-M15 rectus-femoris: dose 100-150 added + dosageNote")
        changes += 1

    # =======================================================================
    # Write out
    # =======================================================================
    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    print(f"\nDone. {changes} changes written.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
