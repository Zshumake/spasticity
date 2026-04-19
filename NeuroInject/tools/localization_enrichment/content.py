"""Per-muscle localization content sourced from the Jost Atlas of Botulinum Toxin Injection.

All content is paraphrased — no verbatim book text — per copyright considerations.
Each muscle entry may contribute to four Muscle fields:

  - landmarks      : palpable bony/tendon/surface anchors with measurement cues
  - placement      : injection-site language specific to the muscle, including depth
                     (cm/mm) and fiber direction when the book specifies
  - setup          : patient position + any required guidance modality (US / EMG / fluoro)
  - pearls         : clinical-application notes, synergy with other muscles,
                     adjacent-muscle hazards ("too X direction → hits Y")

The merge script (`apply_content.py`) appends each list into the existing Muscle
field rather than replacing it. Duplicates are deduplicated by case-insensitive
exact-match.

Per-muscle confidence:
  "full"    : high-DPI image read of the book page used; all four categories populated
              from the book directly
  "ocr"     : OCR extraction; content reconstructed from text that was mostly readable
  "partial" : OCR was fragmented; some categories populated from partial capture;
              others left empty
  "ocr-imageread" : mix of OCR + image read for specific gaps

Muscles not listed here either were not in the book parts we audited or had
no readable content for any category.
"""
from __future__ import annotations

# Structure: { muscle_name: { "landmarks": [...], "placement": [...],
#                             "setup": [...], "pearls": [...], "confidence": "..." } }
MUSCLE_CONTENT: dict[str, dict] = {
    # ========================================================================
    # UPPER EXTREMITY — Shoulder / Arm (Part 1)
    # ========================================================================
    "Pectoralis Major": {
        "confidence": "full",
        "landmarks": [
            "Anterior axillary fold — the muscle itself forms this fold. Palpate with the arm abducted to 45-90°.",
            "Sternocostal border (lower) and clavicular border (upper) define different fiber groups — the injection site sits inside the fold the muscle creates.",
        ],
        "placement": [
            "Injection site: within the anterior axillary fold.",
            "Direction: medially, along the fiber course.",
        ],
        "setup": [
            "Patient position: sitting or supine, with the arm abducted to approximately 45-90°.",
            "Attention: vessels and nerves run cranial (above) the muscle — stay below the axillary neurovascular bundle.",
        ],
        "pearls": [
            "The sternocostal fibers form the anterior border of the axilla; the clavicular fibers define the border of the infraclavicular fossa.",
            "Can function as an accessory muscle of inspiration; the sternocostal fibers are important when walking on crutches.",
        ],
    },

    "Subscapularis": {
        "confidence": "full",
        "landmarks": [
            "Margo medialis scapulae (medial scapular border) — primary access landmark, palpable with the arm internally rotated (Lift-Off Test position).",
            "Inferior angle of the scapula — alternative access when the medial border is hard to reach.",
            "Lesser tubercle of the humerus — the insertion, commonly used by physiatrists via ventral access.",
        ],
        "placement": [
            "Preferred route: via the margo medialis or inferior angle of the scapula, advancing along the fiber direction toward the scapula itself (twin-needle contact confirms depth).",
            "Alternative ventral route: insertion through the axilla dorsocranially, tangential to the thorax, toward the scapula. Requires arm abducted + externally rotated.",
            "Alternative: direct insertion at the Lesser tubercle of the humerus (common physiatrist approach).",
        ],
        "setup": [
            "Patient position (dorsal route): Lift-Off Test position — arm internally rotated behind the back.",
            "Patient position (ventral route): arm abducted and externally rotated.",
            "EMG guidance is often useful given the muscle's depth under the scapula.",
        ],
        "pearls": [
            "Part of the rotator cuff; paresis leads to maximum external rotation of the arm.",
            "Frequently involved in upper-limb spasticity but treated only seldom — consider it when internal-rotation contracture resists biceps/pectoral-only treatment.",
        ],
    },

    "Infraspinatus": {
        "confidence": "ocr",
        "landmarks": [
            "Scapular spine — the muscle sits in the infraspinous fossa below it.",
            "Middle of the triangle formed by the scapular spine, medial border, and lateral border of the scapula.",
        ],
        "placement": [
            "Injection site: middle of the infraspinous fossa.",
        ],
        "setup": [
            "Patient position: sitting or prone. When prone, the patient's arm can drape over the edge of the table.",
        ],
        "pearls": [
            "Injecting too superficially risks hitting the overlying trapezius.",
            "Injecting too laterally risks hitting teres minor.",
            "Orientation on a curved scapular surface — pneumothorax risk if the needle goes too deep and medial.",
        ],
    },

    "Latissimus Dorsi": {
        "confidence": "ocr",
        "landmarks": [
            "Inferior angle of the scapula — the muscle wraps around and below this.",
            "Posterior axillary fold — latissimus forms its lower border.",
        ],
        "placement": [
            "Target the muscle belly 7-8 cm lateral to the spine, at or below the scapular tip level.",
        ],
        "setup": [
            "Patient position: prone with the arm flexed at the shoulder (overhead) to spread the muscle.",
        ],
        "pearls": [
            "Action is very similar to teres major — consider them together; palpation cannot always distinguish them.",
        ],
    },

    "Teres Major": {
        "confidence": "ocr",
        "landmarks": [
            "Inferior angle of the scapula (origin) — palpate the bony corner.",
            "Posterior axillary fold — teres major contributes to it along with latissimus dorsi.",
        ],
        "placement": [
            "Injection site: into the muscle belly along the lateral border of the scapula, below the level of the infraspinatus.",
        ],
        "setup": [
            "Patient position: prone or lateral decubitus, arm in neutral.",
        ],
        "pearls": [
            "Palpation can be challenging due to overlying latissimus — the two muscles are often fused and have very similar action.",
            "Consider together with latissimus dorsi in adduction / internal-rotation spasticity.",
        ],
    },

    "Biceps Brachii": {
        "confidence": "ocr",
        "landmarks": [
            "Mid-humeral level on the anterior arm — halfway between the coracoid process and the cubital fossa.",
        ],
        "placement": [
            "Standard sites: 2-4 across the muscle belly for typical dosing.",
        ],
        "setup": [],
        "pearls": [
            "Biceps is usually treated together with brachialis and brachioradialis — all three elbow flexors are viewed in synergy.",
            "Exclusive biceps injection is rarely indicated; the biceps is not the only elbow flexor and treating it alone often misses the larger contributor (brachialis).",
        ],
    },

    "Brachialis": {
        "confidence": "full",
        "landmarks": [
            "Elbow fold — measure 3-4 cm proximal to it for the injection site.",
            "Biceps tendon — the brachialis lies lateral and deep to it.",
        ],
        "placement": [
            "Injection site: approximately 3-4 cm proximal to the elbow fold, lateral to the biceps tendon, into the belly of brachialis deep to the biceps.",
            "Sites: 1-2 per treatment.",
        ],
        "setup": [],
        "pearls": [
            "Brachialis is unjustifiably neglected in elbow-flexor spasticity — most of the elbow-flexion force comes from brachialis, not biceps.",
            "Treat brachialis in cases of elbow-flexor spasticity; the dose is distributed among all elbow flexors rather than concentrated in biceps.",
        ],
    },

    "Brachioradialis": {
        "confidence": "ocr",
        "landmarks": [
            "Lateral supracondylar ridge of the humerus (origin) — palpate just above the lateral elbow.",
            "Radial aspect of the forearm — the muscle forms the lateral border of the cubital fossa.",
        ],
        "placement": [
            "Injection site: proximal third of the lateral forearm, into the muscle belly.",
        ],
        "setup": [
            "Patient position: elbow flexed and in mid-position (neither fully supinated nor fully pronated).",
        ],
        "pearls": [
            "All three flexors of the elbow (biceps, brachialis, brachioradialis) must be viewed in synergy.",
        ],
    },

    "Triceps": {
        "confidence": "full",
        "landmarks": [
            "Center of each muscle belly (long head, lateral head, medial head) — each head is treated as an independent belly.",
        ],
        "placement": [
            "Sites: 3-4 total, depending on dose and indication (typically 3 for routine spasticity).",
            "Direction: vertical, or along the fiber course.",
            "Injection depth: dictated by the thickness of the targeted head — thinner distally, thicker proximally.",
            "When injecting the lateral head, confirm it is distinguishable from the overlying deltoid.",
        ],
        "setup": [
            "Patient position: sitting or prone, with the shoulder slightly abducted.",
        ],
        "pearls": [
            "Rarely treated in spasticity — flexor spasticity is far more common than extensor spasticity.",
            "When treating extensors, always consider the action and loss-of-action of the opposing flexors and the shoulder muscles.",
            "The three heads are not always clearly distinguishable clinically — US guidance helps target specific heads.",
        ],
    },

    "Pronator Teres": {
        "confidence": "ocr",
        "landmarks": [
            "Medial epicondyle (humeral head origin) — palpate the bony prominence at the medial distal humerus.",
            "Middle of a line drawn from the medial epicondyle to the mid-point of the anterior radius (the insertion).",
        ],
        "placement": [
            "Injection site: proximal forearm along the line from medial epicondyle to mid-radius.",
        ],
        "setup": [
            "Patient position: forearm supinated, elbow flexed ~90°.",
        ],
        "pearls": [
            "Primary action: pronates the forearm; weakly flexes the elbow.",
            "A key muscle in the pronation component of the upper-limb spasticity pattern.",
        ],
    },

    "Pronator Quadratus": {
        "confidence": "partial",
        "landmarks": [
            "Distal anterior forearm, just proximal to the wrist crease.",
        ],
        "placement": [
            "Injection site: deep to FCR/FDS in the distal anterior forearm.",
        ],
        "setup": [
            "US guidance is strongly recommended — pronator quadratus lies deep to the superficial flexors and the median nerve/radial artery are in the vicinity.",
        ],
        "pearls": [],
    },

    # ========================================================================
    # UPPER EXTREMITY — Forearm / Hand (Part 2)
    # ========================================================================
    "Flexor Carpi Radialis": {
        "confidence": "ocr",
        "landmarks": [
            "Medial epicondyle of the humerus (common flexor origin).",
            "FCR tendon at the wrist (radial to palmaris longus) — palpable with resisted wrist flexion.",
        ],
        "placement": [
            "Injection site: proximal-to-middle forearm, into the muscle belly.",
            "Direction: vertical, along the fiber course, not too deep.",
        ],
        "setup": [
            "Patient position: seated with the forearm supinated on a flat surface.",
        ],
        "pearls": [
            "Median nerve runs deep between FCR and FDS — stay in the muscle belly; do not go deep.",
            "Should always be viewed in synergy with the other wrist flexors (FCU, palmaris longus) and treated accordingly.",
        ],
    },

    "Flexor Carpi Ulnaris": {
        "confidence": "ocr",
        "landmarks": [
            "Medial epicondyle of the humerus.",
            "FCU tendon at the ulnar wrist — palpable at the pisiform.",
        ],
        "placement": [
            "Injection site: proximal-to-middle medial forearm, into the muscle belly.",
            "Sites: 2 per treatment for typical dosing.",
        ],
        "setup": [
            "Patient position: forearm supinated.",
            "Ulnar nerve runs alongside FCU — US or careful palpation recommended to avoid nerve injection.",
        ],
        "pearls": [
            "Flexes and adducts (ulnar-deviates) the hand.",
            "Always examined and treated in synergy with the other flexors of the wrist.",
        ],
    },

    "Hand Lumbricals": {
        "confidence": "partial",
        "landmarks": [
            "Metacarpal bones — use them as the palpation reference.",
            "Radial aspect of each respective tendon at the upper half of the metacarpal.",
        ],
        "placement": [
            "Injection site: radial to each respective flexor tendon, approximately in the upper half of the metacarpal.",
        ],
        "setup": [
            "Patient position: elbow in supination with the hand resting palm-up.",
        ],
        "pearls": [
            "Many physiatrists suspect only a minor effect and refrain from injecting the lumbricals — consider with caution and reserve for clear intrinsic-plus deformity.",
        ],
    },

    "Flexor Digitorum Superficialis": {
        "confidence": "partial",
        "landmarks": [
            "Medial epicondyle of humerus (humeroulnar head) and anterior shaft of the radius (radial head).",
            "Middle of the anterior forearm — FDS lies superficial to FDP and deep to FCR/palmaris longus.",
        ],
        "placement": [
            "Injection site: mid-anterior forearm, into the muscle belly.",
            "Sites: 1-4 for typical dosing; usually 1-2.",
        ],
        "setup": [
            "US guidance strongly recommended — FDS and FDP lie side by side in the proximal forearm and cannot be reliably distinguished by palpation alone.",
        ],
        "pearls": [
            "Treated in most patients presenting with PIP (proximal interphalangeal) joint flexion spasticity.",
            "For finger-flexion spasticity, FDS and FDP typically both need treatment — the other flexors should be addressed as well.",
        ],
    },

    "Flexor Digitorum Profundus": {
        "confidence": "full",
        "landmarks": [
            "Proximal anterior shaft of the ulna (origin).",
            "Middle of the anterior forearm — FDP lies deep to FDS.",
        ],
        "placement": [
            "Injection site: mid-anterior forearm, at the depth of the ulna.",
            "Sites: 1-4 for typical dosing, usually 1-2.",
            "Injection depth: approximately 10-20 mm from the skin.",
        ],
        "setup": [
            "Patient position: elbow supinated.",
            "US guidance essential — FDS and FDP muscle bellies lie side-by-side and cannot be reliably distinguished by palpation alone.",
            "For action-induced dystonia, sonography is required for precise targeting of individual muscle parts.",
        ],
        "pearls": [
            "Only flexor of the distal interphalangeal (DIP) joint.",
            "For finger-flexion spasticity, FDP typically requires treatment alongside FDS and the other forearm flexors.",
            "Proximal injection benefits from in-plane US technique to confirm depth.",
        ],
    },

    "Flexor Pollicis Longus": {
        "confidence": "ocr",
        "landmarks": [
            "Middle of the anterior shaft of the radius (origin).",
            "Interosseous membrane — FPL lies along it, deep in the anterior forearm.",
            "Radial artery runs in the lateral forearm — stay medial to avoid it.",
        ],
        "placement": [
            "Injection site: proximal-to-middle anterior forearm.",
            "Sites: 1-2.",
            "Injection depth: approximately 10-20 mm.",
        ],
        "setup": [
            "Patient position: elbow extended, forearm supinated, wrist in neutral.",
            "US guidance recommended given radial artery proximity and depth.",
        ],
        "pearls": [
            "Only muscle that flexes the IP joint of the thumb — its action is additive to that of flexor pollicis brevis at the MCP joint.",
        ],
    },

    "Adductor Pollicis": {
        "confidence": "ocr",
        "landmarks": [
            "First web space of the hand — adductor pollicis forms the deep floor.",
            "Transverse head (along the 3rd metacarpal) and oblique head — the muscle is two-headed.",
        ],
        "placement": [
            "Injection site: into the first web space, toward the 3rd metacarpal.",
            "Sites: 1-2.",
        ],
        "setup": [
            "End branches of the radial artery run nearby — identify on US with Doppler.",
        ],
        "pearls": [
            "Two-headed muscle (transverse and oblique heads) — injection errors are common if you inject too superficially (hits dorsal interosseous instead).",
            "Key for thumb-in-palm deformity along with FPL and FPB.",
        ],
    },

    # ========================================================================
    # LOWER EXTREMITY — Hip / Thigh (Part 3)
    # ========================================================================
    "Gluteus Maximus": {
        "confidence": "ocr",
        "landmarks": [
            "Greater trochanter of the femur (palpable lateral bony prominence of the hip).",
            "Sacrum / PSIS — the muscle spans from sacrum to the iliotibial band and gluteal tuberosity.",
        ],
        "placement": [
            "Injection site: middle of a line drawn between the greater trochanter and the sacrum.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: prone or lateral decubitus.",
        ],
        "pearls": [
            "Depth varies significantly with subcutaneous-fat thickness — consider US or longer needle in patients with a thick gluteal region.",
        ],
    },

    "Piriformis": {
        "confidence": "ocr",
        "landmarks": [
            "Greater trochanter of the femur (insertion).",
            "Sacrum (origin) — piriformis runs from the anterior sacrum through the greater sciatic foramen.",
            "Depth anchor: approximately 6-12 cm from skin depending on body habitus.",
        ],
        "placement": [
            "Injection site: along a line from the greater trochanter to the sacrum, approximately halfway.",
        ],
        "setup": [
            "CT or fluoroscopic guidance is strongly recommended if at all possible — piriformis lies adjacent to the sciatic nerve.",
            "If CT/fluoroscopy unavailable, US with Doppler to identify inferior gluteal vessels, plus EMG confirmation.",
            "Patient position: prone with hip internally rotated to expose the muscle.",
        ],
        "pearls": [
            "Sciatic-nerve proximity is the dominant safety concern — never inject without image guidance.",
        ],
    },

    "Tensor Fasciae Latae (TFL)": {
        "confidence": "ocr",
        "landmarks": [
            "Anterior superior iliac spine (ASIS) — palpable bony prominence at the front of the pelvis.",
            "Greater trochanter of the femur.",
            "Anchor: approximately 2 fingers (2-3 cm) anterior to the greater trochanter, 5-10 cm below the ASIS.",
        ],
        "placement": [
            "Injection site: 2 fingers anterior to the greater trochanter, along the line from ASIS to trochanter.",
            "Sites: 1-3.",
            "Injection depth: 1-3 cm depending on body habitus.",
        ],
        "setup": [
            "Patient position: supine or lateral decubitus with the affected hip up.",
        ],
        "pearls": [
            "Going too far medial risks injecting sartorius.",
            "Going too far lateral or posterior risks injecting gluteus medius.",
        ],
    },

    "Adductor Longus": {
        "confidence": "full",
        "landmarks": [
            "Pubic tubercle — palpate the adductor longus tendon at its origin.",
            "Medial condyle of the tibia — adductor longus inserts along the middle third of the linea aspera.",
            "Anchor: 4 fingers (approximately 7-8 cm) distal to the pubic tubercle, along the adductor group.",
        ],
        "placement": [
            "Injection site: palpate the adductor longus tendon at the pubic tubercle, then move approximately 4 fingers (7-8 cm) distal, into the muscle belly.",
        ],
        "setup": [
            "Patient position: supine, hip slightly flexed and abducted.",
        ],
        "pearls": [
            "The adductors cannot be differentiated from one another with certainty by palpation — US guidance is recommended if targeting specifically.",
            "Going too deep risks hitting adductor magnus; too far lateral or posterior risks gracilis.",
        ],
    },

    "Adductor Brevis": {
        "confidence": "full",
        "landmarks": [
            "Pubic tubercle — palpate the adductor longus tendon at its origin (brevis lies deep and behind it).",
            "Anchor: 4 fingers (approximately 7-8 cm) distal from the pubic tubercle, 3-5 cm deep through the overlying adductor longus.",
        ],
        "placement": [
            "Injection site: palpate the tendon at the pubic tubercle origin; inject 4 fingers (7-8 cm) distal and 3-5 cm deep through the skin.",
            "Sites: 1-2, usually one site.",
            "Injection depth: 3-5 cm depending on muscle thickness.",
        ],
        "setup": [
            "Patient position: supine, hip slightly flexed and abducted, knee slightly flexed.",
            "US guidance recommended — adductor brevis lies between longus (anterior) and magnus (posterior); hard to target blindly.",
        ],
        "pearls": [
            "Going too far lateral hits adductor longus (not the target).",
            "Going too far medial or too deep hits adductor magnus.",
            "Going too far dorsomedial (posteromedial) penetrates gracilis instead.",
        ],
    },

    "Gracilis": {
        "confidence": "ocr",
        "landmarks": [
            "Pubic tubercle (origin).",
            "Medial condyle of the tibia (insertion).",
            "Anchor: middle of a line between the pubic tubercle and the medial tibial condyle.",
        ],
        "placement": [
            "Injection site: middle of the line between the pubic tubercle and the medial tibial condyle, into the long thin muscle belly.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: supine with the leg slightly abducted.",
        ],
        "pearls": [
            "Flexes both at the hip and knee; primarily active in initial hip flexion.",
            "Rarely treated individually — must be considered when treating adductor-group spasm since gracilis contributes to the adduction pattern.",
            "Going too deep risks hitting adductor magnus.",
        ],
    },

    "Adductor Magnus": {
        "confidence": "ocr",
        "landmarks": [
            "Pubic tubercle and ischial tuberosity (combined origin).",
            "Linea aspera of the femur (insertion).",
            "Anchor: 10-13 cm distal to the pubic tubercle for proximal injection; additional sites at 4 fingers (7-8 cm) intervals along the adductor line.",
        ],
        "placement": [
            "Injection site: multiple sites along the medial thigh, on a line from origin toward the linea aspera.",
            "Sites: 1-3.",
            "When injecting at two sites, position them on the same line rather than perpendicular — adductor magnus is long and oriented vertically.",
        ],
        "setup": [
            "Patient position: supine, leg slightly flexed and abducted.",
        ],
        "pearls": [
            "Adducts the free-swinging thigh; when standing, its most important action is stabilizing the femur together with TFL.",
            "A very strong muscle — dose tends to be at the higher end of the adductor-group range.",
        ],
    },

    "Rectus Femoris": {
        "confidence": "ocr",
        "landmarks": [
            "Anterior inferior iliac spine (AIIS) — straight head of origin.",
            "Superior border of the acetabulum — reflected (posterior) head of origin.",
            "Patella — insertion via the patellar ligament to the tibial tuberosity.",
            "Anchor: middle of the muscle belly, on a line from ASIS/AIIS to the patella.",
        ],
        "placement": [
            "Injection site: middle of the muscle belly, midway between the ASIS and the proximal patella.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: supine.",
        ],
        "pearls": [
            "The different components of quadriceps femoris must always be viewed as a whole — rectus femoris acts on TWO joints (hip flexion + knee extension) simultaneously.",
            "Rectus femoris is the primary quadriceps contributor to stiff-knee gait in hemiparetic patients.",
        ],
    },

    "Vastus Medialis": {
        "confidence": "ocr",
        "landmarks": [
            "Patella — vastus medialis inserts via its medial portion into the medial patellar retinaculum.",
            "Medial intermuscular septum / medial supracondylar ridge of the femur (origin).",
            "Anchor: approximately 7-8 cm (4 fingers) proximal to a line drawn from the superior patella to the medial epicondyle of the femur.",
        ],
        "placement": [
            "Injection site: distal portion of the muscle belly, 7-8 cm (4 fingers) proximal to the patella on the medial side.",
            "Sites: 1-3.",
            "Injection depth: 15-30 mm.",
        ],
        "setup": [
            "Patient position: supine with the leg extended.",
            "US guidance recommended — femoral vessels run in the anteromedial thigh; going too medial risks neurovascular injection.",
        ],
        "pearls": [
            "Works with the other vasti to stabilize the knee — they must be considered together.",
            "Going too medial risks injection into the femoral neurovascular bundle.",
        ],
    },

    "Vastus Intermedius": {
        "confidence": "ocr",
        "landmarks": [
            "Anterior shaft of the femur (origin — upper two-thirds).",
            "Patella — insertion via the patellar ligament to the tibial tuberosity.",
            "Anchor: middle of a line between the ASIS and the proximal patella.",
        ],
        "placement": [
            "Injection site: middle of the anterior thigh, deep to rectus femoris, on the line from ASIS to patella.",
            "Sites: 1-2.",
            "Injection depth: 3-5 cm (deep to rectus femoris).",
        ],
        "setup": [
            "Patient position: supine with the leg extended.",
            "US guidance essential — vastus intermedius cannot be palpated and cannot be reliably differentiated from the other vasti without imaging.",
        ],
        "pearls": [
            "Cannot be palpated or clinically differentiated from the other vasti — US guidance is not optional.",
            "Deep to rectus femoris; pass the needle through rectus to reach it.",
        ],
    },

    "Vastus Lateralis": {
        "confidence": "ocr",
        "landmarks": [
            "Greater trochanter and lateral lip of the linea aspera (origin).",
            "Patella — lateral portion of the patellar retinaculum (insertion).",
            "Anchor: middle-to-distal portion of the muscle belly, approximately 10-11 cm proximal to the superolateral patella.",
        ],
        "placement": [
            "Injection site: middle and distal portion of the muscle belly, on the lateral thigh.",
            "Sites: 1-3, usually 1-2.",
        ],
        "setup": [
            "Patient position: supine or lateral decubitus with the affected side up.",
        ],
        "pearls": [
            "Largest component of the quadriceps — the easiest vastus to inject.",
            "Going too medial or too distal risks the needle rotating into rectus femoris or infiltrating into the femur.",
        ],
    },

    "Biceps Femoris": {
        "confidence": "ocr",
        "landmarks": [
            "Long head: ischial tuberosity (origin). Anchor the injection at the middle of a line between the ischial tuberosity and the popliteal fossa (approximately 4 fingers).",
            "Short head: linea aspera (origin). Anchor approximately 2 cm above the popliteal cavity, superficial to the head of the fibula.",
            "Head of the fibula (insertion) — palpable lateral bony prominence behind the knee.",
        ],
        "placement": [
            "Long head injection: middle of the line between ischial tuberosity and popliteal cavity, approximately 4 fingers distal to the ischial tuberosity. Sites: 1-3.",
            "Short head injection: 2 cm above the popliteal cavity, superficial to the fibular head, medial or lateral to the short-head belly. Sites: 1-2.",
        ],
        "setup": [
            "Patient position: prone.",
        ],
        "pearls": [
            "Going too medial (from either head) risks penetrating semitendinosus.",
            "Biceps femoris is usually treated together with the other knee flexors for hamstring spasticity.",
            "Can rotate the flexed knee laterally — its action is distinct from semitendinosus and semimembranosus.",
        ],
    },

    "Semimembranosus": {
        "confidence": "ocr",
        "landmarks": [
            "Ischial tuberosity (origin).",
            "Posterior aspect of the medial tibial condyle (insertion).",
            "Anchor: distal portion of the posterior thigh, at the lateral margin of the semimembranosus tendon as it approaches the knee.",
        ],
        "placement": [
            "Injection site: distal portion of the posterior-medial thigh.",
            "Sites: 1-3, usually 1-2.",
        ],
        "setup": [
            "Patient position: prone.",
            "US guidance recommended — the three hamstring muscles are difficult to differentiate by palpation alone.",
        ],
        "pearls": [
            "Can be absent or fused with semitendinosus — if expected anatomy is not seen, look for the fused variant.",
            "The three hamstring muscles are difficult to differentiate from one another; treat them with awareness of their combined action.",
        ],
    },

    "Semitendinosus": {
        "confidence": "ocr",
        "landmarks": [
            "Ischial tuberosity (origin, shared with biceps femoris long head).",
            "Medial tibial surface (pes anserinus insertion).",
            "Anchor: middle of the posteromedial thigh, on a line between ischial tuberosity and the pes anserinus.",
        ],
        "placement": [
            "Injection site: middle of the muscle belly.",
            "Sites: 1-3, usually 1-2.",
            "Injection depth: 15-30 mm.",
        ],
        "setup": [
            "Patient position: prone.",
        ],
        "pearls": [
            "Long tendon of insertion can be palpated in the belly of the muscle — use it to orient during injection.",
            "Contraction affects lumbar lordosis indirectly; works antagonistically to hip flexors.",
        ],
    },

    "Gastrocnemius (Medial)": {
        "confidence": "full",
        "landmarks": [
            "Popliteal crease — palpable behind the knee, forms the proximal boundary of the gastroc.",
            "Medial femoral condyle (medial head origin).",
            "Anchor: approximately 4 fingers (8-10 cm) distal to the popliteal crease, in the muscle belly of the medial head.",
        ],
        "placement": [
            "Injection site: muscle belly of both medial and lateral heads, approximately 4 fingers (8-10 cm) distal to the popliteal crease.",
            "Sites: 1-3 per head (medial and lateral), usually 2 sites.",
            "Injection depth: 2-4 cm, depending on muscle thickness.",
        ],
        "setup": [
            "Patient position: prone, feet hanging over the edge of the table to relax the calf.",
        ],
        "pearls": [
            "Going too deep risks infiltrating the soleus (deep to gastroc).",
            "Going too deep into the medial head risks hitting flexor digitorum longus.",
            "Gastroc + soleus + plantaris form the triceps surae — full calf plantarflexion is only treatable if all three are addressed (or the soleus if gastroc alone is insufficient).",
            "The medial head is typically the dominant contributor to spastic equinus.",
        ],
    },

    "Gastrocnemius (Lateral)": {
        "confidence": "ocr",
        "landmarks": [
            "Popliteal crease — palpable behind the knee.",
            "Lateral femoral condyle (lateral head origin).",
            "Anchor: approximately 4 fingers (8-10 cm) distal to the popliteal crease, in the muscle belly of the lateral head.",
        ],
        "placement": [
            "Injection site: muscle belly of the lateral head, approximately 4 fingers (8-10 cm) distal to the popliteal crease.",
            "Sites: 1-3 per head.",
            "Injection depth: 2-4 cm, depending on muscle thickness.",
        ],
        "setup": [
            "Patient position: prone, feet hanging over the edge of the table.",
            "Common peroneal nerve runs lateral to the gastroc at the fibular head — stay in the muscle belly, do not go too lateral.",
        ],
        "pearls": [
            "Going too deep risks the soleus.",
            "The lateral head is usually smaller and contributes less to equinus than the medial head.",
        ],
    },

    "Soleus (Medial)": {
        "confidence": "ocr-imageread",
        "landmarks": [
            "Soleal line of the tibia and upper third of the posterior fibula (origin).",
            "Calcaneal tuberosity via the Achilles tendon (insertion).",
            "Middle-to-distal posterior calf — soleus is deep to gastrocnemius.",
        ],
        "placement": [
            "Injection site: middle-to-distal posterior calf, deep to the gastroc.",
            "Sites: 2-4.",
        ],
        "setup": [
            "Patient position: prone.",
            "US guidance recommended — soleus lies deep to gastroc and must be distinguished from it.",
        ],
        "pearls": [
            "Part of the triceps surae with gastrocnemius and plantaris — full calf plantarflexion is only controlled when all three are addressed.",
            "Critical muscle for equinus not responsive to gastroc-only injection.",
        ],
    },

    # ========================================================================
    # LOWER EXTREMITY — Leg / Foot (Part 4)
    # ========================================================================
    "Tibialis Posterior": {
        "confidence": "ocr-imageread",
        "landmarks": [
            "Lateral part of the posterior tibia, interosseous membrane, proximal posterior fibula (origin).",
            "Navicular tuberosity (primary insertion) — palpable medial-plantar foot bony prominence.",
            "Tibialis posterior is the deepest of the posterior-compartment muscles — below soleus, between tibia and fibula.",
        ],
        "placement": [
            "Injection site: middle-to-distal posterior leg, deep to soleus and flexor digitorum longus.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: prone or supine with the leg externally rotated.",
            "US guidance strongly recommended — tibialis posterior is deep; needle must pass through overlying muscles.",
        ],
        "pearls": [
            "Strongest supinator (inverter) of the foot — a key target for equinovarus deformity.",
            "Must be addressed alongside gastroc/soleus for comprehensive equinovarus treatment.",
        ],
    },

    "Tibialis Anterior": {
        "confidence": "ocr",
        "landmarks": [
            "Lateral tibial condyle and upper lateral tibial surface (origin).",
            "Medial cuneiform and base of the 1st metatarsal (insertion).",
            "Proximal-to-middle anterolateral leg, lateral to the tibial crest.",
        ],
        "placement": [
            "Injection site: upper third of the anterolateral leg, lateral to the tibial ridge, into the muscle belly.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: supine with the leg extended.",
        ],
        "pearls": [
            "Test for active contraction before injecting — contraction of the calf muscles may be mistaken for tibialis anterior activity.",
            "Tibialis anterior spasticity is less common than its weakness (in equinovarus) — always confirm the clinical picture before injecting.",
        ],
    },

    "Peroneus Longus": {
        "confidence": "ocr",
        "landmarks": [
            "Fibular head and upper lateral fibular surface (origin).",
            "Medial cuneiform and 1st metatarsal base (insertion) — peroneus longus has a very long tendon that wraps under the foot.",
            "Proximal-to-middle lateral leg, posterior to the fibular shaft.",
        ],
        "placement": [
            "Injection site: upper third of the lateral leg, posterior to the fibula, into the muscle belly (NOT the long tendon).",
            "Sites: 1-2.",
        ],
        "setup": [
            "Patient position: supine or lateral decubitus with the affected leg up.",
            "Common peroneal nerve wraps around the fibular head — avoid the immediate fibular-neck region.",
        ],
        "pearls": [
            "Also known as fibularis longus.",
            "Has a very long tendon that runs under the foot; the muscle belly is proximal — do not inject the distal tendon.",
        ],
    },

    "Extensor Hallucis Longus (EHL)": {
        "confidence": "ocr",
        "landmarks": [
            "Middle third of the medial anterior fibula and interosseous membrane (origin).",
            "Distal phalanx of the great toe (insertion).",
            "EHL tendon — palpable on the dorsum of the foot with active toe extension.",
        ],
        "placement": [
            "Injection site: middle third of the anterior leg, between tibia and fibula, into the muscle belly.",
            "Sites: 1-2, usually 1.",
        ],
        "setup": [
            "Patient position: supine with the leg extended.",
        ],
        "pearls": [
            "Treated in cases of striatal toe deformity (great toe extension) or rigid hallux valgus.",
            "EDL and EHL often examined together — both extend the toes.",
        ],
    },

    "Extensor Digitorum Longus": {
        "confidence": "ocr",
        "landmarks": [
            "Lateral tibial condyle, upper two-thirds of the anterior fibula, interosseous membrane (origin).",
            "Middle and distal phalanges of toes 2-5 (insertion).",
            "Anchor: middle third of the lower leg, between tibia and fibula.",
        ],
        "placement": [
            "Injection site: middle third of the lower leg, between tibia and fibula, into the muscle belly.",
            "Sites: 1-2, usually 1.",
        ],
        "setup": [
            "Patient position: supine.",
            "Note: if the injection is made too deep, the extensor hallucis longus can be reached instead.",
        ],
        "pearls": [
            "Examined together with the extensor digitorum brevis — both extend the toes.",
            "Treated in striatal toe or claw-toe deformity.",
        ],
    },

    "Flexor Hallucis Longus (FHL)": {
        "confidence": "ocr",
        "landmarks": [
            "Posterior surface of the fibula (origin).",
            "Plantar surface of the distal phalanx of the great toe (insertion).",
            "Deep posterior calf — FHL lies along the posterior fibula, deep to soleus.",
        ],
        "placement": [
            "Injection site: distal two-thirds of the posterior calf, deep to soleus.",
            "Sites: 1-2.",
        ],
        "setup": [
            "US guidance strongly recommended — FHL is deep; tibialis posterior and FDL are adjacent.",
        ],
        "pearls": [
            "The only muscle that flexes the IP joint of the great toe.",
            "Key target for spastic hallux (curled great toe) deformity.",
        ],
    },

    "Flexor Digitorum Brevis (FDB)": {
        "confidence": "ocr",
        "landmarks": [
            "Plantar aponeurosis and calcaneal tuberosity (origin).",
            "Middle phalanges of toes 2-5 (insertion).",
            "Anchor: middle of the plantar arch of the foot, superficial under the plantar aponeurosis.",
        ],
        "placement": [
            "Injection site: into the plantar aponeurosis in the middle of the arch of the foot.",
            "Sites: 1-3.",
            "Injection depth: 5-15 mm (shallow).",
        ],
        "setup": [
            "Patient position: supine or prone with the foot stabilized.",
            "The injection is very painful — brace the foot in a fixed position before proceeding.",
        ],
        "pearls": [
            "Supplements flexor digitorum longus at the PIP joints of toes 2-5.",
            "Going too far laterally risks hitting abductor digiti minimi or flexor digitorum longus's tendon.",
        ],
    },

    "Flexor Digitorum Longus (FDL)": {
        "confidence": "ocr",
        "landmarks": [
            "Posterior surface of the tibia (origin).",
            "Distal phalanges of toes 2-5 (insertion).",
            "Use the medial tibial margin for orientation — FDL lies posterior to it, deep to soleus.",
        ],
        "placement": [
            "Injection site: middle-to-distal posterior leg, deep to soleus.",
            "Sites: 1-2, usually 1.",
        ],
        "setup": [
            "Patient position: prone or supine.",
            "US guidance recommended — FDL lies deep and adjacent to tibialis posterior.",
        ],
        "pearls": [
            "Flexes toes 2-5 at the DIP joints.",
            "Must be considered with FHL and tibialis posterior in curling-toe + inversion patterns.",
        ],
    },

    # ========================================================================
    # TRUNK (Part 4)
    # ========================================================================
    "Obliques (External & Internal)": {
        "confidence": "ocr",
        "landmarks": [
            "Costal arch (lower rib margin) — upper boundary.",
            "Iliac crest — lower boundary.",
            "Midclavicular line — useful vertical reference on the anterior abdominal wall.",
            "Anchor: between the costal arch and the iliac crest, at the midclavicular line.",
        ],
        "placement": [
            "Injection site: between the costal arch and the iliac crest at the midclavicular line, for either external or internal oblique.",
            "Sites: 1-5 across the length of the muscle.",
            "External oblique is more superficial; internal oblique is deep to it.",
        ],
        "setup": [
            "US or EMG guidance is strongly recommended — risk of transperitoneal puncture into abdominal viscera if depth is not controlled.",
            "Patient position: supine.",
        ],
        "pearls": [
            "External oblique rotates the torso to the CONTRALATERAL side; internal oblique rotates to the IPSILATERAL side — choose the target based on the direction of the dystonic rotation.",
            "Transperitoneal puncture (into bowel or other viscera) is the dominant safety concern — never inject without guidance.",
        ],
    },

    # ========================================================================
    # CERVICAL (Part 4)
    # ========================================================================
    "Sternocleidomastoid (SCM)": {
        "confidence": "full",
        "landmarks": [
            "Manubrium of the sternum (sternal head origin).",
            "Medial third of the clavicle (clavicular head origin).",
            "Mastoid process and superior nuchal line (insertion) — palpable behind the ear.",
            "SCM forms the anterolateral neck border — clearly palpable with the head rotated to the contralateral side.",
        ],
        "placement": [
            "Injection site: into the muscle belly at the mid-cervical level, into either the sternal or clavicular head as clinically indicated.",
            "Sites: 1-3.",
        ],
        "setup": [
            "Patient position: supine with the head rotated to the opposite side to make SCM prominent.",
            "Needle length: 20-40 mm / 27 gauge (use the shorter length to avoid excessive depth).",
        ],
        "pearls": [
            "SCM and the upper trapezius often lie very close together — causing identification challenges for residents. Palpate with the patient actively turning the head to confirm SCM.",
            "Motor supply is accessory nerve (XI); sensory is cervical plexus C2-C3.",
            "Dysphagia is the most feared complication of bilateral SCM injection — reduce dose bilaterally and avoid deep/medial injection near the pharynx.",
        ],
    },
}
