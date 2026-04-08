#!/usr/bin/env python3
"""Apply Moderate audit batches 1-4 (Groups A, D, E, F).

Group A: Internal inconsistencies (supplies, missing/wrong dosages)
Group D: Cross-reference gaps (relatedMuscles)
Group E: Orphan muscles (spasticityPatterns / pearls)
Group F: Pattern-level fixes
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"
PATTERNS = ROOT / "assets" / "data" / "patterns.json"


def find(muscles, mid):
    for m in muscles:
        if m.get("id") == mid:
            return m
    raise KeyError(f"Muscle not found: {mid}")


def replace_supply_probe(supplies):
    """Swap 'linear probe' line with curvilinear note for deep muscles."""
    out = []
    swapped = False
    for s in supplies:
        if "linear probe" in s.lower() and not swapped:
            out.append("Ultrasound machine with curvilinear probe (5-8 MHz, for deep muscles)")
            swapped = True
        else:
            out.append(s)
    return out


def main():
    muscles = json.loads(MUSCLES.read_text())
    patterns = json.loads(PATTERNS.read_text())
    changes = 0

    print("Applying Moderate batches 1-4...\n")

    # =======================================================================
    # GROUP A — Internal inconsistencies
    # =======================================================================
    print("--- Group A: Internal inconsistencies ---")

    # M14: deep-muscle supplies should mention curvilinear probe
    deep_muscles = ["quadratus-lumborum", "gluteus-maximus", "piriformis",
                    "adductor-magnus", "iliopsoas"]
    for mid in deep_muscles:
        m = find(muscles, mid)
        old = list(m.get("supplies", []))
        m["supplies"] = replace_supply_probe(old)
        if m["supplies"] != old:
            print(f"  M14 {mid}: supplies probe → curvilinear")
            changes += 1

    # M17: soleus-medial — mirror soleus-lateral dose
    m = find(muscles, "soleus-medial")
    if m.get("dosage") is None:
        m["dosage"] = {"botox": "100-200", "xeomin": "100-200", "dysport": "300-600"}
        print("  M17 soleus-medial: added dose mirroring soleus-lateral")
        changes += 1

    # M18: gastrocnemius-lateral — add dose (lateral head smaller than medial)
    m = find(muscles, "gastrocnemius-lateral")
    if m.get("dosage") is None:
        m["dosage"] = {"botox": "50-75", "xeomin": "50-75", "dysport": "150-225"}
        print("  M18 gastrocnemius-lateral: added dose")
        changes += 1

    # M19: fhl — convert fixed 50 → range 25-75
    m = find(muscles, "fhl")
    cur = m.get("dosage")
    if cur and cur.get("botox") == "50":
        m["dosage"] = {"botox": "25-75", "xeomin": "25-75", "dysport": "75-225"}
        print("  M19 fhl: dose 50 → 25-75 range")
        changes += 1

    # M20: fdl — drop from 200 to 50-100 (matches its own pearls)
    m = find(muscles, "fdl")
    cur = m.get("dosage")
    if cur and cur.get("botox") == "200":
        m["dosage"] = {"botox": "50-100", "xeomin": "50-100", "dysport": "150-300"}
        print("  M20 fdl: dose 200 → 50-100 (matches pearls)")
        changes += 1

    # M24: edl marker body
    m = find(muscles, "edl")
    if m.get("marker") and m["marker"].get("body") == "lower_leg_lateral":
        m["marker"]["body"] = "lower_leg_anterior"
        print("  M24 edl: marker body lateral → anterior")
        changes += 1

    # =======================================================================
    # GROUP D — Cross-reference gaps
    # =======================================================================
    print("\n--- Group D: relatedMuscles cross-references ---")

    def ensure_related(mid, additions):
        m = find(muscles, mid)
        cur = list(m.get("relatedMuscles", []))
        added = [a for a in additions if a not in cur]
        if added:
            m["relatedMuscles"] = cur + added
            print(f"  {mid}: added {added}")
            return 1
        return 0

    changes += ensure_related("biceps-brachii", ["pronator-teres", "fcr"])  # M02
    changes += ensure_related("pronator-teres", ["pronator-quadratus", "fcr", "fcu"])  # M10
    changes += ensure_related("piriformis", ["gluteus-maximus"])  # M13
    changes += ensure_related("iliopsoas", ["adductor-longus"])  # M21

    # =======================================================================
    # GROUP E — Orphan muscles + TFL pearl
    # =======================================================================
    print("\n--- Group E: Orphans + TFL pearl ---")

    # M04: triceps — populate relatedMuscles for cross-ref
    m = find(muscles, "triceps")
    if not m.get("relatedMuscles"):
        m["relatedMuscles"] = ["biceps-brachii", "brachialis"]
        print("  M04 triceps: added cross-refs to elbow flexors")
        changes += 1

    # M23: peroneus-longus — add to equinus pattern + relatedMuscles
    m = find(muscles, "peroneus-longus")
    cur_pat = list(m.get("spasticityPatterns", []))
    if "equinus" not in cur_pat:
        m["spasticityPatterns"] = cur_pat + ["equinus"]
        print("  M23 peroneus-longus: added to equinus pattern")
        changes += 1
    if not m.get("relatedMuscles"):
        m["relatedMuscles"] = ["gastrocnemius-medial", "gastrocnemius-lateral",
                                "soleus-medial", "soleus-lateral"]
        print("  M23 peroneus-longus: added related plantarflexors")
        changes += 1
    # Also add peroneus-longus to the equinus pattern muscle list
    for p in patterns:
        if p["id"] == "equinus" and "peroneus-longus" not in p["muscles"]:
            p["muscles"].append("peroneus-longus")
            print("  M23 equinus pattern: added peroneus-longus")
            changes += 1

    # M22: tfl — replace platitude pearl with actionable one
    m = find(muscles, "tfl")
    pearls = list(m.get("pearls", []))
    new_pearl = ("Spastic TFL presents with combined hip flexion + internal rotation "
                 "and resists passive hip extension — assess in supine with the Thomas test")
    replaced = False
    for i, p in enumerate(pearls):
        if "leg length" in p.lower() or "pelvic tilt" in p.lower():
            pearls[i] = new_pearl
            replaced = True
            break
    if not replaced and new_pearl not in pearls:
        pearls.append(new_pearl)
        replaced = True
    if replaced:
        m["pearls"] = pearls
        print("  M22 tfl: pearl → Thomas test guidance")
        changes += 1

    # =======================================================================
    # GROUP F — Pattern-level fixes
    # =======================================================================
    print("\n--- Group F: Pattern-level fixes ---")

    def get_pattern(pid):
        for p in patterns:
            if p["id"] == pid:
                return p
        raise KeyError(pid)

    # P01: flexed-wrist — reorder so wrist flexors come first
    p = get_pattern("flexed-wrist")
    desired = ["fcr", "fcu", "fds", "fdp"]
    if p["muscles"] != desired:
        p["muscles"] = desired
        print("  P01 flexed-wrist: reordered (FCR/FCU first)")
        changes += 1

    # P02: flexed-elbow — add pronator-teres (secondary elbow flexor)
    p = get_pattern("flexed-elbow")
    if "pronator-teres" not in p["muscles"]:
        p["muscles"].append("pronator-teres")
        print("  P02 flexed-elbow: added pronator-teres (secondary)")
        changes += 1

    # P03: flexed-hip — add adductor-longus (secondary hip flexor)
    p = get_pattern("flexed-hip")
    if "adductor-longus" not in p["muscles"]:
        p["muscles"].append("adductor-longus")
        print("  P03 flexed-hip: added adductor-longus (secondary)")
        changes += 1

    # P04: equinovarus — note TA weakness in description
    p = get_pattern("equinovarus")
    if "tibialis anterior" not in p["description"].lower():
        p["description"] = (p["description"] +
            ". Note: tibialis anterior is typically WEAK in this pattern (not spastic) "
            "— its weakness is a diagnostic feature; do not inject it.")
        print("  P04 equinovarus: added TA-weakness teaching note")
        changes += 1

    # P05: cervical-dystonia — flag missing splenius capitis in description
    p = get_pattern("cervical-dystonia")
    if "splenius" not in p["description"].lower():
        p["description"] = (p["description"] +
            ". ⚠️ This dataset covers a subset of cervical muscles; "
            "splenius capitis (the most common rotational torticollis target), "
            "semispinalis capitis, and scalenes are not yet included.")
        print("  P05 cervical-dystonia: flagged splenius gap")
        changes += 1

    # P06: stiff-knee — add vastus-intermedius back as secondary + note
    p = get_pattern("stiff-knee")
    if "vastus-intermedius" not in p["muscles"]:
        p["muscles"].append("vastus-intermedius")
        print("  P06 stiff-knee: added vastus-intermedius (secondary)")
        changes += 1
    if "rectus femoris is the primary" not in p["description"].lower():
        p["description"] = ("Knee held in extension during swing phase, difficulty with "
                            "clearance. Rectus femoris is the primary target (it's biarticular "
                            "and active in swing-phase knee flexion). Vastus intermedius may "
                            "contribute as a secondary target. Avoid the other vasti — they "
                            "stabilize the knee in stance phase and weakening them collapses "
                            "weight-bearing.")
        print("  P06 stiff-knee: clarified description")
        changes += 1

    # P07: thumb-in-palm — note missing FPB / opponens
    p = get_pattern("thumb-in-palm")
    if "fpb" not in p["description"].lower() and "opponens" not in p["description"].lower():
        p["description"] = (p["description"] +
            ". Note: refractory cases may also need flexor pollicis brevis and opponens pollicis "
            "(not yet in this dataset).")
        print("  P07 thumb-in-palm: noted FPB/OP gap")
        changes += 1

    # P08: adducted-hip — note missing gracilis / adductor brevis
    p = get_pattern("adducted-hip")
    if "gracilis" not in p["description"].lower():
        p["description"] = (p["description"] +
            ". Note: gracilis and adductor brevis are also standard adductor injection "
            "targets (not yet in this dataset).")
        print("  P08 adducted-hip: noted gracilis/brevis gap")
        changes += 1

    # =======================================================================
    # Write out
    # =======================================================================
    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    PATTERNS.write_text(json.dumps(patterns, indent=2, ensure_ascii=False) + "\n")
    print(f"\nDone. {changes} changes written.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
