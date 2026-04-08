#!/usr/bin/env python3
"""
Apply all 11 Critical medical audit fixes + add pronator-quadratus entry
+ migrate all dosages to typed {botox, xeomin, dysport} object.

Run from repo root:  python3 tools/apply_critical_fixes.py
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"
PATTERNS = ROOT / "assets" / "data" / "patterns.json"

# ---------------------------------------------------------------------------
# A8: Brand-specific dose conversion table.
# Ratios: Dysport ≈ 2.5-3x Botox (we use 3x for the safer-high end).
# Xeomin is 1:1 with Botox.
# Sources: FDA labels, AAN/AANEM guidelines, Simpson 2016 consensus.
# ---------------------------------------------------------------------------
def botox_to_typed(botox_range: str) -> dict:
    """Convert a legacy '100-200 units' string into {botox, xeomin, dysport}."""
    # strip trailing ' units'
    clean = botox_range.replace("units", "").replace("unit", "").strip()
    # Parse low-high
    if "-" in clean:
        lo, hi = clean.split("-", 1)
        lo = int(lo.strip())
        hi = int(hi.strip())
        dysport_lo = lo * 3
        dysport_hi = hi * 3
        return {
            "botox": f"{lo}-{hi}",
            "xeomin": f"{lo}-{hi}",
            "dysport": f"{dysport_lo}-{dysport_hi}",
        }
    else:
        n = int(clean.strip())
        return {
            "botox": str(n),
            "xeomin": str(n),
            "dysport": str(n * 3),
        }


def find(muscles, mid):
    for m in muscles:
        if m.get("id") == mid:
            return m
    raise KeyError(f"Muscle not found: {mid}")


def main():
    muscles = json.loads(MUSCLES.read_text())
    patterns = json.loads(PATTERNS.read_text())

    print("Applying 11 Critical fixes + pronator-quadratus add + Dosage migration…")
    changes = 0

    # -----------------------------------------------------------------------
    # A1. Iliopsoas — femoral nerve location
    # -----------------------------------------------------------------------
    m = find(muscles, "iliopsoas")
    m["setup"] = [
        "USG guidance is mandatory — blind injection of the iliopsoas carries significant risk of femoral nerve or vascular injury.",
        "Have the patient flex the hip against resistance to confirm the correct muscle on ultrasound (the iliopsoas will be seen contracting).",
        "The femoral nerve sits in the fascial groove BETWEEN the iliacus and psoas major (not medial to iliopsoas) — it lies on the anterior surface of the iliacus, deep to the iliopsoas fascia, and lateral to the femoral artery. It must be identified and avoided.",
        "The femoral artery and vein lie medial to the iliopsoas — always confirm their location with color Doppler before inserting the needle.",
    ]
    m["ultrasound"]["viewSteps"] = [
        "Identify subcutaneous fat, the fascia lata, and the Sartorius muscle as the most superficial structures laterally.",
        "Medially, identify the Femoral Artery (pulsating) and Femoral Vein (compressible) within the femoral triangle.",
        "Lateral to the femoral vessels, identify the Femoral Nerve as a hyperechoic triangular/oval structure sitting in the groove BETWEEN psoas major (medial) and iliacus (lateral), on the anterior iliacus surface.",
        "Deep to the Sartorius and lateral to the femoral vessels, the Iliopsoas appears as a large oval hypoechoic muscle with a central hyperechoic tendon.",
        "The Iliacus component lies laterally and the Psoas Major lies medially — the femoral nerve runs in the cleft between them. Direct the needle into the muscle belly AWAY from this groove.",
        "Deep to the iliopsoas, identify the anterior acetabular rim or femoral head as a hyperechoic curved line.",
    ]
    m["ultrasound"]["safetyNotes"] = [
        "The femoral artery and vein lie medial to the iliopsoas — always use color Doppler to map the vessels before needle insertion.",
        "CRITICAL: The femoral nerve runs WITHIN the iliopsoas complex, in the groove between iliacus (lateral) and psoas major (medial). It is NOT simply medial to iliopsoas. Identify it as a hyperechoic honeycomb structure and direct the needle to the muscle belly away from this cleft.",
        "The lateral femoral cutaneous nerve runs near the ASIS and may cross the field — note its position if visible.",
        "Do not inject too medially — this risks entering the femoral triangle and injuring the neurovascular bundle.",
    ]
    changes += 1

    # -----------------------------------------------------------------------
    # A2. Infraspinatus — reference-only, do not inject
    # -----------------------------------------------------------------------
    m = find(muscles, "infraspinatus")
    m["pattern"] = "⚠️ NOT TYPICALLY INJECTED — External rotator (reference only)"
    m["pearls"] = [
        "⚠️ DO NOT INJECT in typical UMN spasticity. The infraspinatus is a shoulder EXTERNAL rotator. In hemiplegic shoulder posturing, the deformity is INTERNAL rotation — injecting infraspinatus would weaken the external rotators and WORSEN the pattern.",
        "Listed here for anatomic reference only. In the rare case of post-stroke external-rotation dystonia or focal dystonia, expert consultation is required before injecting.",
        "Suprascapular nerve runs through the spinoglenoid notch nearby — additional reason to avoid this muscle without strong indication.",
    ]
    changes += 1

    # -----------------------------------------------------------------------
    # A3. Tibialis anterior — reference-only, do not inject
    # -----------------------------------------------------------------------
    m = find(muscles, "tibialis-anterior")
    m["pattern"] = "⚠️ NOT TYPICALLY INJECTED — Dorsiflexor (reference only)"
    m["setup"] = [
        "The tibialis anterior is superficial and easily identified — this is a straightforward injection.",
        "Avoid the anterior tibial artery, which runs deep to the muscle near the interosseous membrane.",
        "The deep peroneal nerve runs alongside the anterior tibial artery — it is generally protected by the muscle itself.",
        "⚠️ STOP — DO NOT INJECT in typical UMN spasticity. The tibialis anterior is the primary ankle dorsiflexor and is almost always WEAK in upper-motor-neuron syndromes (it's the muscle that fails in foot drop). Injecting it will cause or worsen drop foot.",
    ]
    m["pearls"] = [
        "⚠️ DO NOT INJECT in typical UMN spasticity — this muscle is almost always weak, not spastic. Injecting it causes foot drop.",
        "Rare exception: focal dystonia with confirmed EMG over-activity in TA, with neurology / physiatry consultation. Even then, very low doses only.",
        "Listed here for anatomic reference and to warn against injection. PROTECT this muscle's function for foot clearance during swing phase.",
    ]
    changes += 1

    # -----------------------------------------------------------------------
    # A4. Subscapularis — anterior axillary fold approach
    # -----------------------------------------------------------------------
    m = find(muscles, "subscapularis")
    for i, step in enumerate(m["placement"]):
        if "posterior axillary fold" in step:
            m["placement"][i] = "Insert the needle through the ANTERIOR axillary fold (formed by pec major), directing it posterolaterally toward the anterior (costal) surface of the scapula."
            break
    changes += 1

    # -----------------------------------------------------------------------
    # A5. Brachialis — anterior approach through biceps (not lateral)
    # -----------------------------------------------------------------------
    m = find(muscles, "brachialis")
    m["placement"] = [
        "Position the patient supine or seated with the elbow slightly flexed (about 30 degrees) and the forearm supinated.",
        "Use an ANTERIOR approach through the biceps muscle belly in the distal third of the arm — this avoids both the medial neurovascular bundle and the radial nerve, which dives around the lateral humerus into the spiral groove.",
        "Palpate the biceps muscle belly in the distal third of the arm (about 4-6 cm proximal to the elbow crease).",
        "Under ultrasound, identify biceps as the superficial muscle and brachialis as the deeper hypoechoic muscle directly on the humeral cortex.",
        "Insert the needle perpendicular to the skin through the biceps belly, advancing into the brachialis below it.",
        "Confirm the needle tip is in brachialis (deep) and not biceps (superficial) before injecting.",
        "Stop advancing just before contacting bone — the target is the muscle belly, not the periosteum.",
        "Aspirate before injecting to rule out intravascular placement.",
    ]
    m["setup"] = [
        "USG is MANDATORY for brachialis injection — the radial nerve courses around the lateral humerus and is at risk with any lateral approach.",
        "Use an anterior in-plane approach through biceps. The needle should be visible on US the entire time.",
        "Ensure the needle tip is in the muscular plane deep to the biceps but superficial to the humerus.",
        "The brachial artery and median nerve lie medial — keep the needle in the central/anterior plane.",
        "Consider EMG guidance as an adjunct to confirm placement in the correct muscle.",
    ]
    changes += 1

    # -----------------------------------------------------------------------
    # A6 + A9. Pec major — tangential needle + brachial plexus safety note
    # -----------------------------------------------------------------------
    m = find(muscles, "pec-major")
    for i, step in enumerate(m["placement"]):
        if "Insert perpendicular to the skin into the muscle bulk" in step:
            m["placement"][i] = "Insert the needle TANGENTIALLY to the chest wall (15-30° from the skin, NEVER perpendicular) and aim the needle path OVER a rib, never over an intercostal space. The rib acts as a hard backstop and protects against pleural puncture."
            # Insert an extra confirmation step after it
            m["placement"].insert(
                i + 1,
                "Under ultrasound, confirm the needle tip is in pec major and the rib's bright cortical line is directly deep to the needle path before injecting.",
            )
            break
    m["ultrasound"]["safetyNotes"] = [
        "PNEUMOTHORAX RISK: The lung lies deep to the pectoralis muscles, separated only by a thin layer of intercostal muscle in the spaces between ribs. NEVER use a perpendicular needle approach. Always angle the needle tangentially to the chest wall and aim the trajectory OVER a rib (which acts as a backstop), never over an intercostal space.",
        "The brachial plexus and axillary vessels run in the axilla just lateral to pec major — do not let the needle drift laterally into the axillary fossa. Use color Doppler to map the axillary artery before injection.",
        "The Lateral Pectoral Nerve runs between Pec Major and Minor — avoid the inter-fascial plane.",
        "Use real-time US guidance to keep the needle within the Pec Major muscle belly at all times.",
        "The thoracoacromial artery runs in the deltopectoral groove — use color Doppler laterally.",
    ]
    changes += 1

    # -----------------------------------------------------------------------
    # A7. FDB + add-hallucis markers — clean up dead data
    # (marker field is unused in UI; set to null so data isn't misleading)
    # -----------------------------------------------------------------------
    find(muscles, "fdb")["marker"] = None
    find(muscles, "add-hallucis")["marker"] = None
    changes += 2

    # -----------------------------------------------------------------------
    # A8. Convert all dosages to typed {botox, xeomin, dysport}
    # -----------------------------------------------------------------------
    dosage_count = 0
    for mus in muscles:
        d = mus.get("dosage")
        if isinstance(d, str):
            mus["dosage"] = botox_to_typed(d)
            dosage_count += 1
    print(f"  Converted {dosage_count} dosages to typed format")
    changes += dosage_count

    # -----------------------------------------------------------------------
    # A10. Stiff-knee pattern — remove vasti
    # -----------------------------------------------------------------------
    for p in patterns:
        if p["id"] == "stiff-knee":
            p["muscles"] = ["rectus-femoris"]
            break
    # Remove 'stiff-knee' from vasti spasticityPatterns
    for vid in ["vastus-medialis", "vastus-lateralis", "vastus-intermedius"]:
        try:
            v = find(muscles, vid)
            if "stiff-knee" in v.get("spasticityPatterns", []):
                v["spasticityPatterns"] = [
                    p for p in v["spasticityPatterns"] if p != "stiff-knee"
                ]
        except KeyError:
            pass
    changes += 1

    # -----------------------------------------------------------------------
    # A11. Brachioradialis — remove from pronated-forearm + replace in pattern
    # -----------------------------------------------------------------------
    m = find(muscles, "brachioradialis")
    m["pattern"] = "Elbow flexion (forearm in neutral position)"
    m["spasticityPatterns"] = [
        p for p in m.get("spasticityPatterns", []) if p != "pronated-forearm"
    ]
    for p in patterns:
        if p["id"] == "pronated-forearm":
            p["muscles"] = ["pronator-teres", "pronator-quadratus"]
            break
    changes += 1

    # -----------------------------------------------------------------------
    # NEW: Add pronator-quadratus muscle entry
    # -----------------------------------------------------------------------
    if not any(m.get("id") == "pronator-quadratus" for m in muscles):
        pronator_quadratus = {
            "id": "pronator-quadratus",
            "name": "Pronator Quadratus",
            "group": "Upper Extremity",
            "pattern": "Forearm pronation (distal)",
            "landmarks": [
                "Distal Radius (palpate the flat bony prominence on the radial side of the distal forearm just proximal to the wrist crease — pronator quadratus lies directly over the volar distal radius and ulna)",
                "Distal Ulna (palpate the ulnar styloid and move proximally ~4 cm — the muscle origin is the anterior distal ulnar shaft)",
                "Flexor Tendons at the Wrist (palpate the FCR and palmaris longus tendons — pronator quadratus lies DEEP to all the flexor tendons on the volar distal forearm)",
            ],
            "placement": [
                "Position the patient supine or seated with the forearm supinated and resting on a support, wrist in neutral.",
                "Identify the volar (anterior) distal forearm, approximately 3-5 cm proximal to the wrist crease.",
                "⚠️ USG is MANDATORY — the muscle is deep and the median nerve, ulnar nerve, radial artery, and ulnar artery all cross this plane.",
                "Use a dorsal or ulnar approach to avoid the median nerve and radial/ulnar arteries on the volar side.",
                "DORSAL APPROACH (preferred): Insert the needle from the dorsal distal forearm, between the radius and ulna, advancing through the interosseous membrane into pronator quadratus on the volar side.",
                "Under ultrasound, track the needle tip through the interosseous membrane and stop as soon as it enters the thin hypoechoic pronator quadratus muscle belly just superficial to the pronator line of the radius.",
                "The muscle is thin (5-10 mm) — advance only the minimum distance needed to place the tip within it.",
                "Aspirate before injecting. A single injection site is usually sufficient.",
            ],
            "setup": [
                "USG guidance is MANDATORY — pronator quadratus is deep and surrounded by neurovascular structures (median nerve, anterior interosseous nerve, radial/ulnar arteries).",
                "A dorsal approach avoids the median nerve and the radial/ulnar arteries on the volar side.",
                "Use color Doppler to map the radial and ulnar arteries before needle insertion.",
                "The anterior interosseous nerve (branch of median nerve) runs on the volar surface of the interosseous membrane deep to FDP and FPL — it innervates pronator quadratus. Stay within the muscle belly, not the plane between muscles.",
                "Consider EMG guidance as an adjunct to confirm placement in this small deep muscle.",
            ],
            "ultrasound": {
                "probe": "High-frequency linear (10-15 MHz)",
                "orientation": "Transverse across the distal volar forearm, 3-5 cm proximal to the wrist crease",
                "viewSteps": [
                    "Place the probe transversely on the volar distal forearm, 3-5 cm proximal to the wrist crease.",
                    "Identify the radius (radial side) and ulna (ulnar side) as bright hyperechoic cortical curves with posterior shadowing — these are your deep lateral landmarks.",
                    "Between the radius and ulna on the deep volar side, identify pronator quadratus as a thin (5-10 mm) flat hypoechoic muscle band with horizontal fibers running directly between the two bones.",
                    "Superficial to pronator quadratus, identify the long flexor tendons (FDS, FDP, FPL) as hyperechoic oval cross-sections with a striated fibrillar pattern.",
                    "CRITICAL: The median nerve appears as a honeycomb hyperechoic oval between the FDS and FPL tendons, more superficial than pronator quadratus. Map it before inserting the needle.",
                    "Use color Doppler to identify the radial artery (radial side) and ulnar artery (ulnar side) — both should be out of the needle path.",
                    "To confirm muscle identification, ask the patient to pronate the forearm against resistance — pronator quadratus will contract.",
                ],
                "safetyNotes": [
                    "The median nerve and anterior interosseous nerve lie in this plane — always identify the median nerve on US before needle insertion.",
                    "The radial and ulnar arteries lie on the volar surface of the forearm — use color Doppler to map them. A dorsal approach avoids both.",
                    "The pronator quadratus is thin — minor needle over-advancement can exit the muscle. Use in-plane technique with continuous needle tip visualization.",
                    "Very low doses are appropriate given the small muscle volume — start at 10-20 U Botox per site.",
                ],
                "probeDiagram": {
                    "cx": 50,
                    "cy": 70,
                    "angle": 0,
                    "length": 10,
                },
            },
            "dosage": {"botox": "10-25", "xeomin": "10-25", "dysport": "30-75"},
            "marker": None,
            "referenceImages": [],
            "hasReferenceImage": False,
            "probePlacementHint": "Patient supine, forearm supinated on table. Place probe transversely on volar distal forearm, 3-5 cm proximal to wrist crease. Photo from volar view showing probe on distal forearm.",
            "pearls": [
                "The TRUE distal pronator — often missed because pronator teres gets all the attention",
                "Thin, deep muscle — USG mandatory; a dorsal approach through the interosseous membrane is safest",
                "Low doses only (10-25 U Botox) given the small muscle volume",
                "Co-inject with pronator teres for refractory forearm pronation pattern",
            ],
            "supplies": [
                "Ultrasound machine with linear probe",
                "Sterile ultrasound gel",
                "Tegaderm or probe cover",
                "Alcohol swabs / ChloraPrep",
                "Reconstituted botulinum toxin (drawn up)",
                "25-27G needle (1.5-2 inch)",
                "1-3 mL syringe(s)",
                "Gloves (non-sterile)",
                "Gauze pads",
                "Band-aids",
                "Sharps container",
            ],
            "spasticityPatterns": ["pronated-forearm"],
            "relatedMuscles": ["pronator-teres", "fcr", "fcu"],
        }
        muscles.append(pronator_quadratus)
        print("  Added pronator-quadratus muscle entry")
        changes += 1

    # -----------------------------------------------------------------------
    # Write out
    # -----------------------------------------------------------------------
    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    PATTERNS.write_text(json.dumps(patterns, indent=2, ensure_ascii=False) + "\n")
    print(f"\nDone. {changes} changes written to muscles.json and patterns.json.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
