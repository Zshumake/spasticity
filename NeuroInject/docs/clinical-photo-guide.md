# NeuroInject — Clinical Photo Capture Guide

Shot list for the clinical photography session. **68 muscles × 4 photos = 272 images.**

> Auto-generated from `assets/data/muscles.json` by `tools/generate_photo_capture_guide.py`. Re-run after editing muscle data.

## The four photos per muscle

| # | Photo | What to capture |
|---|-------|-----------------|
| 1 | **Patient Position** | The patient positioned and the segment exposed, as you set up to inject. |
| 2 | **Probe Placement** | The ultrasound probe held on the skin at the injection site. |
| 3 | **Needle Insertion** | The needle entry point and angle at the surface. |
| 4 | **Ultrasound Image** | The US screen of the target muscle (with the needle in the muscle if you can). |

## Naming & where files go

Save each photo with this **exact** name into `NeuroInject/assets/images/clinical/`:

```
<muscleId>-position.jpg
<muscleId>-probe.jpg
<muscleId>-needle.jpg
<muscleId>-us.jpg
```

- **Format:** JPG (convert HEIC → JPG first). Landscape preferred.
- The app auto-detects each file — the muscle's detail page swaps the placeholder for the photo and shows an "N/4 captured" counter. No code or data edit needed.
- **61/68** muscles are ultrasound-guided; for the 7 that are not, the probe/US shots are marked optional.

---

## Upper Extremity  ·  18 muscles  ·  72 photos

### Pectoralis Major  `pec-major`
*Upper Extremity / Trunk — Shoulder adduction, internal rotation*

- [ ] **Patient Position** — `pec-major-position.jpg`
  Position the patient supine with the arm abducted 30-45 degrees and externally rotated slightly to open the chest.
- [ ] **Probe Placement** — `pec-major-probe.jpg`
  Patient supine, arm abducted 30°. Place probe transversely on anterior chest, lateral to sternum at 3rd-4th rib. Photo from patient's right side showing probe on chest wall. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse across the anterior chest wall, lateral to the sternal border at the 3rd-4th rib level.
- [ ] **Needle Insertion** — `pec-major-needle.jpg`
  For the clavicular head: insert the needle 2-3 cm inferior to the lateral clavicle, angled slightly caudally at about 30 degrees to the skin surface. Advance the needle 1-2 cm into the muscle belly — you should feel the firm resistance of muscle tissue.
- [ ] **Ultrasound Image** — `pec-major-us.jpg`
  You should see: Position the patient supine with the arm slightly abducted. Place the probe transversely on the anterior chest. The Pectoralis Major appears as the broad, flat superficial muscle layer directly under the subcutaneous fat — it spans most of the anterior chest. Depth ≈ 5.5 cm. ⚠ PNEUMOTHORAX RISK: The lung lies deep to the pectoralis muscles, separated only by a thin layer of intercostal muscle in the spaces between ribs. NEVER use a perpendicular needle…

### Latissimus Dorsi  `lat-dorsi`
*Upper Extremity / Trunk — Shoulder adduction, internal rotation, extension*

- [ ] **Patient Position** — `lat-dorsi-position.jpg`
  Position the patient in lateral decubitus with the affected side up, or prone with arm slightly abducted.
- [ ] **Probe Placement** — `lat-dorsi-probe.jpg`
  Patient lateral decubitus or prone. Place probe transversely across posterior axillary fold. Photo from behind showing probe on lateral back/axilla. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior axillary fold, perpendicular to the long axis of the muscle fibers.
- [ ] **Needle Insertion** — `lat-dorsi-needle.jpg`
  Insert the needle perpendicular to the skin into the mid-belly of the muscle. Advance 1-2 cm into the muscle substance; you should feel firm muscular resistance.
- [ ] **Ultrasound Image** — `lat-dorsi-us.jpg`
  You should see: Identify subcutaneous tissue superficially as a hyperechoic layer. The Latissimus Dorsi appears as a broad, flat hypoechoic muscle with a bright fascial envelope — it is the most superficial muscle in the posterior axillary fold. ⚠ The thoracodorsal nerve and artery run along the deep surface of the Latissimus Dorsi — use color Doppler to identify the vascular bundle.

### Biceps Brachii  `biceps-brachii`
*Upper Extremity — Elbow flexion, Forearm supination*

- [ ] **Patient Position** — `biceps-brachii-position.jpg`
  Position the patient supine or seated with the arm supinated and elbow extended, resting on a support surface.
- [ ] **Probe Placement** — `biceps-brachii-probe.jpg`
  Patient supine, arm supinated. Place probe transversely on anterior mid-upper arm. Photo from lateral view showing probe across biceps belly. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the anterior arm at the mid-humeral level.
- [ ] **Needle Insertion** — `biceps-brachii-needle.jpg`
  Insert the needle into the bulk of the muscle belly at the mid-humeral level, perpendicular to the skin surface. Advance 1-1.5 cm into the muscle — the biceps is a superficial muscle, so you do not need to go deep.
- [ ] **Ultrasound Image** — `biceps-brachii-us.jpg`
  You should see: Position the patient supine with the arm slightly abducted and externally rotated. Place the probe transversely on the anterior arm. The Biceps Brachii (short and long heads) appears as the large superficial hypoechoic muscle — it is the most prominent structure in the anterior compartment. Depth ≈ 3.5-4.0 cm. ⚠ The Musculocutaneous Nerve runs between the biceps and brachialis — inject into the superficial belly of the biceps only.

### Brachialis  `brachialis`
*Upper Extremity — Pure elbow flexion*

- [ ] **Patient Position** — `brachialis-position.jpg`
  Position the patient supine or seated with the elbow slightly flexed (about 30 degrees) and the forearm supinated.
- [ ] **Probe Placement** — `brachialis-probe.jpg`
  Patient supine, elbow slightly flexed. Place probe transversely on anterior distal arm, 4-6 cm above elbow crease. Photo showing probe on anterior distal arm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior distal third of the arm, ~4-6 cm proximal to the elbow crease (matching the anterior-through-biceps approach).
- [ ] **Needle Insertion** — `brachialis-needle.jpg`
  Insert the needle perpendicular to the skin through the biceps belly, advancing into the brachialis below it. Confirm the needle tip is in brachialis (deep) and not biceps (superficial) before injecting.
- [ ] **Ultrasound Image** — `brachialis-us.jpg`
  You should see: Place the probe transversely across the anterior distal third of the arm, ~4-6 cm proximal to the elbow crease. Identify subcutaneous tissue and the superficial hyperechoic fascia. ⚠ The radial nerve courses along the lateral and posterior humerus in the spiral groove — always identify it before needle insertion.

### Triceps  `triceps`
*Upper Extremity — Elbow extension*

- [ ] **Patient Position** — `triceps-position.jpg`
  Position the patient seated or prone with the arm resting on a support, elbow flexed to approximately 90 degrees.
- [ ] **Probe Placement** — `triceps-probe.jpg`
  Patient seated or prone. Place probe transversely on posterior mid-upper arm. Photo from behind showing probe across triceps belly. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the posterior arm at the mid-humeral level.
- [ ] **Needle Insertion** — `triceps-needle.jpg`
  For the long head: insert the needle into the medial portion of the posterior arm at mid-humeral level, perpendicular to the skin. For the lateral head: insert the needle into the lateral portion of the posterior arm, slightly more proximal, perpendicular to the skin.
- [ ] **Ultrasound Image** — `triceps-us.jpg`
  You should see: Position the patient prone or seated with the arm supported. Place the probe transversely on the posterior arm. The Long Head of the Triceps appears as the large, prominent hypoechoic muscle — it is the most superficial and medial of the three triceps heads at the mid-arm level. Depth ≈ 3.5-4.5 cm. ⚠ The Radial Nerve runs in the spiral groove of the humerus, directly deep to the triceps — ALWAYS identify it before injecting.

### Brachioradialis  `brachioradialis`
*Upper Extremity — Elbow flexion (forearm in neutral position)*

- [ ] **Patient Position** — `brachioradialis-position.jpg`
  Position the patient seated with the forearm resting on a table in neutral position (thumb pointing upward).
- [ ] **Probe Placement** — `brachioradialis-probe.jpg`
  Patient seated, forearm neutral on table. Place probe transversely on lateral proximal forearm, 4-6 cm below lateral epicondyle. Photo from lateral view showing probe on lateral forearm. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the lateral proximal forearm, approximately 4-6 cm distal to the lateral epicondyle.
- [ ] **Needle Insertion** — `brachioradialis-needle.jpg`
  Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, perpendicular to the skin. Advance 1-1.5 cm — the muscle is superficial.
- [ ] **Ultrasound Image** — `brachioradialis-us.jpg`
  You should see: Place the probe transversely on the lateral forearm with the patient's elbow slightly flexed and forearm in neutral (thumb-up) position. Identify the Brachioradialis as the most superficial muscle on the lateral side — it appears as a crescent-shaped hypoechoic structure directly under the subcutaneous tissue. Depth ≈ 3.5 cm. ⚠ The Radial Nerve runs in the intermuscular septum between the Brachioradialis and Brachialis — always identify it before injecting.

### Pronator Teres  `pronator-teres`
*Upper Extremity — Forearm pronation*

- [ ] **Patient Position** — `pronator-teres-position.jpg`
  Position the patient seated with the forearm supinated and the elbow extended, resting on a support surface.
- [ ] **Probe Placement** — `pronator-teres-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial proximal forearm, 3-5 cm below medial epicondyle. Photo showing probe on medial proximal forearm near elbow. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the medial proximal forearm, 3-5 cm distal to the medial epicondyle.
- [ ] **Needle Insertion** — `pronator-teres-needle.jpg`
  Insert the needle 2-3 cm distal to the medial epicondyle, into the bulk of the muscle belly on the medial-to-anterior proximal forearm. Advance the needle 1-1.5 cm perpendicular to the skin.
- [ ] **Ultrasound Image** — `pronator-teres-us.jpg`
  You should see: Position the patient with the elbow extended and forearm supinated to stretch the pronator teres. Place the probe transversely on the medial proximal forearm just distal to the elbow crease. Depth ≈ 4.5 cm. ⚠ The median nerve passes between the two heads of the pronator teres — inject into the superficial muscle belly only.

### Flexor Carpi Radialis  `fcr`
*Upper Extremity — Wrist flexion, Radial deviation*

- [ ] **Patient Position** — `fcr-position.jpg`
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe Placement** — `fcr-probe.jpg`
  Patient seated, forearm supinated on table. Place probe transversely on central volar forearm at proximal-to-mid third. Photo from above showing probe on volar mid-forearm. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the central volar forearm, at the proximal-to-mid third.
- [ ] **Needle Insertion** — `fcr-needle.jpg`
  Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, perpendicular to the skin. Advance 1-1.5 cm — the FCR is a relatively superficial muscle.
- [ ] **Ultrasound Image** — `fcr-us.jpg`
  You should see: Place the probe transversely on the volar forearm, centered over the palpable FCR tendon. The FCR appears as a superficial, triangular/oval hypoechoic muscle directly under the antebrachial fascia — it is one of the most superficial forearm flexors. Depth ≈ 2.0 cm. ⚠ The Median Nerve lies deep to the FCR — it is typically between the FDS and FDP layers just ulnar to the FCR.

### Flexor Carpi Ulnaris  `fcu`
*Upper Extremity — Wrist flexion, Ulnar deviation*

- [ ] **Patient Position** — `fcu-position.jpg`
  Position the patient seated with the forearm supinated or in neutral, resting on a support.
- [ ] **Probe Placement** — `fcu-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial forearm. Photo showing probe on ulnar/medial side of mid-forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the medial forearm, forearm supinated.
- [ ] **Needle Insertion** — `fcu-needle.jpg`
  Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, on the medial (ulnar) aspect. Advance 1-1.5 cm perpendicular to the skin — the muscle is superficial.
- [ ] **Ultrasound Image** — `fcu-us.jpg`
  You should see: Place the probe transversely on the medial (ulnar) side of the forearm with the forearm fully supinated. The FCU is the most superficial and most medial muscle — it appears as a rounded hypoechoic muscle directly under the skin on the ulnar border. Depth ≈ 2.5-3.5 cm. ⚠ The Ulnar Nerve is immediately deep to the FCU — it is the single most important structure to identify before injecting.

### Flexor Digitorum Superficialis  `fds`
*Upper Extremity — Finger flexion at PIP joints, Wrist flexion*

- [ ] **Patient Position** — `fds-position.jpg`
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe Placement** — `fds-probe.jpg`
  Patient seated, forearm supinated on table. Place probe transversely on volar forearm, 5-8 cm below medial epicondyle. Photo showing probe on central volar forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the volar forearm, 5-8 cm distal to the medial epicondyle.
- [ ] **Needle Insertion** — `fds-needle.jpg`
  Insert the needle at the mid-forearm level, between the FCR and FCU, slightly deeper than the superficial flexor layer. Advance 1.5-2 cm perpendicular to the skin to pass through the superficial flexor layer and into the FDS.
- [ ] **Ultrasound Image** — `fds-us.jpg`
  You should see: Place the probe transversely on the central volar forearm. The FDS is the broad, flat muscle layer in the superficial volar compartment — it appears as a wide hypoechoic band directly under the subcutaneous tissue and fascia. Depth ≈ 2.0-3.0 cm. ⚠ The Median Nerve lies directly at the deep border of the FDS — inject into the superficial-to-mid portion of the muscle belly.

### Flexor Digitorum Profundus  `fdp`
*Upper Extremity — Finger flexion at DIP joints, Wrist flexion*

- [ ] **Patient Position** — `fdp-position.jpg`
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe Placement** — `fdp-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial-volar mid-forearm. Photo showing probe on deep volar forearm, slightly ulnar. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the medial-volar mid-forearm.
- [ ] **Needle Insertion** — `fdp-needle.jpg`
  Insert the needle from the medial (ulnar) side of the forearm, just anterior to the palpable subcutaneous ulnar border, at the junction of the proximal and middle thirds of the forearm. Advance the needle 2-2.5 cm, directing it anterolaterally toward the interosseous membrane to reach the deep compartment.
- [ ] **Ultrasound Image** — `fdp-us.jpg`
  You should see: Place the probe transversely on the volar-ulnar forearm at the mid-forearm level. Identify the superficial flexor layer first: the Palmaris Longus (PL) as a small superficial structure, and the FCU on the ulnar border. Depth ≈ 3.0-4.0 cm. ⚠ The Median Nerve lies between FDS and FDP — needle must pass through FDS to reach FDP. Always visualize the median nerve and keep the needle tip away from it.

### Flexor Pollicis Longus  `fpl`
*Upper Extremity — Thumb flexion at IP joint*

- [ ] **Patient Position** — `fpl-position.jpg`
  Position the patient seated with the forearm supinated and resting flat on a support surface.
- [ ] **Probe Placement** — `fpl-probe.jpg`
  Patient seated, forearm supinated flat. Place probe transversely on mid-volar forearm at junction of middle and distal thirds. Photo showing probe on distal volar forearm, radial side. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the mid-volar forearm, at the junction of the middle and distal thirds.
- [ ] **Needle Insertion** — `fpl-needle.jpg`
  Insert the needle at the mid-forearm level, on the radial side, between the brachioradialis (laterally) and the FCR (medially). Advance the needle 2-2.5 cm, directing it posteriorly toward the radius to reach the deep compartment where the FPL lies.
- [ ] **Ultrasound Image** — `fpl-us.jpg`
  You should see: Place the probe transversely on the volar forearm with the patient supinated. Identify the Radius as the large hyperechoic curved bony surface on the lateral (thumb) side. Depth ≈ 3.0-3.5 cm. ⚠ The Anterior Interosseous Nerve (AIN) — a pure motor branch of the median nerve — runs on the anterior surface of the interosseous membrane between FPL and FDP. Do not inject deep…

### Adductor Pollicis  `adductor-pollicis`
*Upper Extremity — Thumb adduction (thumb-in-palm deformity)*

- [ ] **Patient Position** — `adductor-pollicis-position.jpg`
  Position the patient with the hand resting on a flat surface, palm down (pronated), with the thumb abducted away from the palm.
- [ ] **Probe Placement** — `adductor-pollicis-probe.jpg`
  Patient hand pronated on table. Place small linear or hockey-stick probe transversely across first web space from dorsal approach. Photo from above showing probe on dorsal thumb web space. Probe: High-frequency linear (10-15 MHz); a hockey-stick probe is helpful in the tight first web space. Orientation: Transverse across the first web space from the dorsal approach.
- [ ] **Needle Insertion** — `adductor-pollicis-needle.jpg`
  Insert the needle from the dorsal aspect of the first web space, perpendicular to the plane of the hand. Advance 0.5-1 cm — this is a thin muscle in a confined space.
- [ ] **Ultrasound Image** — `adductor-pollicis-us.jpg`
  You should see: Identify the subcutaneous fat and thin dorsal skin as the most superficial layers. The first dorsal interosseous appears as a superficial hypoechoic muscle on the dorsal-radial aspect of the web space. ⚠ The deep branch of the ulnar nerve passes through the adductor pollicis (between the two heads) — use a superficial injection into the transverse head when possible.

### Subscapularis  `subscapularis`
*Upper Extremity / Trunk — Shoulder internal rotation, Adduction*

- [ ] **Patient Position** — `subscapularis-position.jpg`
  Position the patient supine or seated with the arm abducted to 45-60 degrees and externally rotated, resting on a support.
- [ ] **Probe Placement** — `subscapularis-probe.jpg`
  Patient supine, arm abducted 45-60° and externally rotated. Place probe parasagitally in anterior axilla. Photo from front showing probe in axillary fold aimed toward scapula. Probe: Low-to-medium frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) in thin patients. Orientation: Parasagittal in the anterior axilla, with the probe face directed toward the costal surface of the scapula.
- [ ] **Needle Insertion** — `subscapularis-needle.jpg`
  Insert the needle through the ANTERIOR axillary fold (formed by pec major), directing it posterolaterally toward the anterior (costal) surface of the scapula. Advance under ultrasound guidance until the needle tip is within the subscapularis muscle belly on the costal (anterior) surface of the scapula.
- [ ] **Ultrasound Image** — `subscapularis-us.jpg`
  You should see: Identify the subcutaneous fat and the pectoralis major as the most superficial muscular layer on the anterior chest. Deep to the pectoralis major, the pectoralis minor appears as a smaller triangular hypoechoic muscle. ⚠ The axillary artery, vein, and brachial plexus cords are immediately anterior and lateral to the subscapularis in the axilla — always identify them with Doppler and ensure the…

### Infraspinatus  `infraspinatus`
*Upper Extremity / Trunk — ⚠️ NOT TYPICALLY INJECTED — External rotator (reference only)*

- [ ] **Patient Position** — `infraspinatus-position.jpg`
  Position the patient seated, leaning forward, or in a prone position with the arms at the sides.
- [ ] **Probe Placement** — `infraspinatus-probe.jpg`
  Patient seated leaning forward or prone. Place probe transversely across infraspinous fossa, parallel to scapular spine. Photo from behind showing probe below scapular spine. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the infraspinous fossa, parallel to the spine of the scapula.
- [ ] **Needle Insertion** — `infraspinatus-needle.jpg`
  Insert the needle perpendicular to the skin into the center of the infraspinous fossa, targeting the thickest part of the muscle belly. Advance 1.5-2 cm — the muscle lies directly on the scapular bone, so you will feel resistance when the needle contacts the scapula.
- [ ] **Ultrasound Image** — `infraspinatus-us.jpg`
  You should see: Identify the subcutaneous fat and the thin trapezius muscle as the most superficial layers (the trapezius overlies the infraspinatus medially and superiorly). The infraspinatus appears as a large hypoechoic muscle with a multipennate architecture, filling the infraspinous fossa. ⚠ The suprascapular nerve passes through the spinoglenoid notch at the lateral base of the scapular spine — avoid injecting within 2 cm of this landmark.

### Teres Major  `teres-major`
*Upper Extremity / Trunk — Shoulder adduction, Internal rotation, Extension*

- [ ] **Patient Position** — `teres-major-position.jpg`
  Position the patient seated or prone with the arm adducted at the side.
- [ ] **Probe Placement** — `teres-major-probe.jpg`
  Patient seated or prone, arm at side. Place probe transversely over posterior axillary fold. Photo from behind showing probe on posterior axilla/inferior scapular angle. Probe: High-frequency linear (10-15 MHz) or curvilinear for deeper patients. Orientation: Transverse (short-axis) over the posterior axillary fold, with the patient's arm slightly abducted.
- [ ] **Needle Insertion** — `teres-major-needle.jpg`
  Identify the posterior axillary fold and the inferior angle of the scapula. The teres major lies along the lateral border of the scapula, running from the inferior angle to the humerus.
- [ ] **Ultrasound Image** — `teres-major-us.jpg`
  You should see: Position the patient seated or prone with the arm slightly abducted. Place the probe on the posterior axillary fold. The Teres Major appears as a flat, broad hypoechoic muscle at the inferior aspect of the posterior axillary fold — in Dr. Bursuc's video it is highlighted with a purple overlay. Depth ≈ 3.5-4.5 cm. ⚠ The circumflex scapular artery and thoracodorsal neurovascular bundle run near the Teres Major — use color Doppler.

### Pronator Quadratus  `pronator-quadratus`
*Upper Extremity — Forearm pronation (distal)*

- [ ] **Patient Position** — `pronator-quadratus-position.jpg`
  Position the patient supine or seated with the forearm supinated and resting on a support, wrist in neutral.
- [ ] **Probe Placement** — `pronator-quadratus-probe.jpg`
  Patient supine, forearm supinated on table. Place probe transversely on volar distal forearm, 3-5 cm proximal to wrist crease. Photo from volar view showing probe on distal forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal volar forearm, 3-5 cm proximal to the wrist crease.
- [ ] **Needle Insertion** — `pronator-quadratus-needle.jpg`
  DORSAL APPROACH (preferred): Insert the needle from the dorsal distal forearm, between the radius and ulna, advancing through the interosseous membrane into pronator quadratus on the volar side. Under ultrasound, track the needle tip through the interosseous membrane and stop as soon as it enters the thin hypoechoic pronator quadratus muscle belly just superficial to the pronator line of the radius.
- [ ] **Ultrasound Image** — `pronator-quadratus-us.jpg`
  You should see: Place the probe transversely on the volar distal forearm, 3-5 cm proximal to the wrist crease. Identify the radius (radial side) and ulna (ulnar side) as bright hyperechoic cortical curves with posterior shadowing — these are your deep lateral landmarks. ⚠ The median nerve and anterior interosseous nerve lie in this plane — always identify the median nerve on US before needle insertion.

### Hand Lumbricals  `hand-lumbricals`
*Upper Extremity — MCP flexion + IP extension (intrinsic-plus posture)*

- [ ] **Patient Position** — `hand-lumbricals-position.jpg`
  Position the patient with the hand supinated (palm up), fingers relaxed and slightly extended.
- [ ] **Probe Placement** — `hand-lumbricals-probe.jpg`
  Patient palm-up, fingers relaxed. Place hockey-stick probe longitudinally on palm along the metacarpal. Photo from palmar view showing probe on mid-palm. Probe: High-frequency linear (10-15 MHz); hockey-stick probe preferred for the tight palmar space. Orientation: Longitudinal along the metacarpal shaft on the palmar surface, or transverse across the palm at the MCP level.
- [ ] **Needle Insertion** — `hand-lumbricals-needle.jpg`
  PALMAR APPROACH: Insert the needle into the palm just proximal to the MCP joint of the target finger, on the radial side of the flexor tendon. Advance only 5-10 mm — the lumbricals are very small and superficial in the palmar space.
- [ ] **Ultrasound Image** — `hand-lumbricals-us.jpg`
  You should see: Place the probe longitudinally on the palmar surface along the metacarpal of the target finger. Identify the FDP and FDS tendons as hyperechoic linear structures running along the metacarpal. ⚠ The proper digital nerves and arteries run immediately adjacent to the lumbricals — always identify them before injecting.

---

## Lower Extremity  ·  33 muscles  ·  132 photos

### Quadratus Lumborum  `quadratus-lumborum`
*Lower Extremity / Trunk — Pelvic hiking, trunk lateral flexion*

- [ ] **Patient Position** — `quadratus-lumborum-position.jpg`
  Position the patient prone with a pillow under the abdomen to reduce lumbar lordosis.
- [ ] **Probe Placement** — `quadratus-lumborum-probe.jpg`
  Patient prone, pillow under abdomen. Place curvilinear probe transversely on flank, just above iliac crest. Photo from side showing probe on lateral flank. Probe: Curvilinear (5-8 MHz). Orientation: Transverse (axial) across the flank, just superior to the iliac crest, lateral to the erector spinae.
- [ ] **Needle Insertion** — `quadratus-lumborum-needle.jpg`
  Insert the needle perpendicular to the skin, angling slightly medially toward the transverse processes of L3/L4. Advance slowly under ultrasound guidance — the QL lies anterior to the erector spinae and posterior to the kidney.
- [ ] **Ultrasound Image** — `quadratus-lumborum-us.jpg`
  You should see: Identify the subcutaneous fat and thoracolumbar fascia superficially as hyperechoic layers. The Erector Spinae group appears as a large hypoechoic muscle mass medially, adjacent to the spinous processes. ⚠ The kidneys lie anterior and deep to the QL — always identify the anterior border of the muscle and do not advance beyond it.

### Rectus Abdominis  `rectus-abdominis`
*Lower Extremity / Trunk — Trunk flexion (camptocormia / forward-flexed posture)*

- [ ] **Patient Position** — `rectus-abdominis-position.jpg`
  Position the patient supine with the knees slightly bent to relax the abdominal wall.
- [ ] **Probe Placement** — `rectus-abdominis-probe.jpg`
  Patient supine, knees bent. Place linear probe transversely on the anterior abdomen, just lateral to midline at the umbilical level. Photo from the patient's side showing probe on the abdomen. Probe: High-frequency linear (10-15 MHz); curvilinear (5-8 MHz) for larger body habitus. Orientation: Transverse across the anterior abdominal wall, centered over the rectus abdominis, lateral to the midline.
- [ ] **Needle Insertion** — `rectus-abdominis-needle.jpg`
  Inject at 2-4 sites distributed along the length of the muscle — typically at the supra-umbilical and infra-umbilical levels bilaterally. Insert the needle at a shallow oblique angle (30-45 degrees to the skin) under real-time ultrasound guidance.
- [ ] **Ultrasound Image** — `rectus-abdominis-us.jpg`
  You should see: Place the probe transversely on the anterior abdominal wall, just lateral to the midline at the level of the umbilicus. The subcutaneous fat appears as a superficial hypoechoic layer of variable thickness. ⚠ PERITONEAL PENETRATION RISK: The peritoneum and bowel lie immediately deep to the posterior rectus sheath. Never advance the needle past the posterior fascial boundary. Use a…

### Obliques (External & Internal)  `obliques`
*Lower Extremity / Trunk — Trunk rotation, lateral flexion*

- [ ] **Patient Position** — `obliques-position.jpg`
  Position the patient supine or in the lateral decubitus position with the target side up.
- [ ] **Probe Placement** — `obliques-probe.jpg`
  Patient supine or lateral decubitus. Place linear probe transversely on the lateral abdominal wall between the costal margin and iliac crest, along the mid-axillary line. Photo from the side showing probe on the flank. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral abdominal wall, between the costal margin and iliac crest, along or posterior to the mid-axillary line.
- [ ] **Needle Insertion** — `obliques-needle.jpg`
  Target the external oblique and/or internal oblique depending on the clinical pattern — typically inject the internal oblique as it is the primary trunk rotator. Insert the needle in-plane under real-time ultrasound guidance, advancing into the target muscle layer.
- [ ] **Ultrasound Image** — `obliques-us.jpg`
  You should see: Place the probe transversely on the lateral abdominal wall at the level of the umbilicus, along the mid-axillary line. Identify the three distinct hypoechoic muscle layers separated by bright hyperechoic fascial planes — this is the classic 'three-layer sandwich' view. ⚠ INTERCOSTAL NERVE INJURY RISK: The thoracoabdominal nerves (T7-T12) travel in the fascial plane between the internal oblique and transversus abdominis. Avoid injecting directly…

### Paraspinals (Erector Spinae Group)  `paraspinals`
*Lower Extremity / Trunk — Trunk extension spasticity, axial dystonia, camptocormia treatment*

- [ ] **Patient Position** — `paraspinals-position.jpg`
  Position the patient prone with a pillow under the abdomen to reduce lumbar lordosis and open the interlaminar spaces.
- [ ] **Probe Placement** — `paraspinals-probe.jpg`
  Patient prone, pillow under abdomen. Place curvilinear probe parasagittally 2-3 cm lateral to midline spinous processes, or transversely across the spine at the target level. Photo from behind showing probe on the paraspinal region. Probe: Curvilinear (5-8 MHz); high-frequency linear (10-15 MHz) may suffice in thin patients at thoracic levels. Orientation: Parasagittal along the paraspinal muscle mass, 2-3 cm lateral to the midline; or transverse (axial) across the spine at each target level.
- [ ] **Needle Insertion** — `paraspinals-needle.jpg`
  Insert the needle perpendicular to the skin or at a slight lateral-to-medial angle, advancing into the muscle belly. CRITICAL: The needle must stay within the paraspinal muscle mass LATERAL to the spinous processes. NEVER direct the needle medially past the lamina — the spinal canal lies immediately deep to the lamina.
- [ ] **Ultrasound Image** — `paraspinals-us.jpg`
  You should see: PARASAGITTAL VIEW: Place the probe longitudinally (parasagittal), 2-3 cm lateral to the midline spinous processes. The transverse processes appear as a series of hyperechoic humps… The Erector Spinae muscles (iliocostalis laterally, longissimus medially, spinalis most medially) appear as a large hypoechoic muscle mass superficial to the transverse processes. ⚠ SPINAL CANAL PENETRATION RISK: The spinal canal lies immediately deep to the laminae. NEVER advance the needle medially past the lamina or between the laminae into the…

### Gluteus Maximus  `gluteus-maximus`
*Lower Extremity — Hip extension, external rotation*

- [ ] **Patient Position** — `gluteus-maximus-position.jpg`
  Position the patient prone or in lateral decubitus with the affected side up.
- [ ] **Probe Placement** — `gluteus-maximus-probe.jpg`
  Patient prone. Place curvilinear probe transversely on upper-outer quadrant of buttock. Photo from behind showing probe position on buttock. Probe: Curvilinear (5-8 MHz). Orientation: Transverse across the mid-buttock, centered on the gluteus maximus belly between the sacrum and the greater trochanter.
- [ ] **Needle Insertion** — `gluteus-maximus-needle.jpg`
  Insert the needle perpendicular to the skin into the muscle bulk at multiple sites distributed across the belly (3-4 sites for a large muscle). Advance 3-5 cm into the large muscle bulk (depth varies with body habitus).
- [ ] **Ultrasound Image** — `gluteus-maximus-us.jpg`
  You should see: Identify the thick subcutaneous fat layer, which can be substantial in this region. The Gluteus Maximus appears as a large, thick hypoechoic muscle with characteristic coarse fiber texture and bright fascial borders. ⚠ The sciatic nerve exits the greater sciatic foramen deep to the piriformis and runs deep to the gluteus maximus — always inject in the upper-outer quadrant.

### Piriformis  `piriformis`
*Lower Extremity — Hip external rotation, abduction*

- [ ] **Patient Position** — `piriformis-position.jpg`
  Position the patient prone with a pillow under the pelvis to slightly flex the hips.
- [ ] **Probe Placement** — `piriformis-probe.jpg`
  Patient prone, pillow under pelvis. Place curvilinear probe transversely along PSIS-to-greater-trochanter line, at midpoint. Photo showing probe between PSIS and GT. Probe: Curvilinear (5-8 MHz). Orientation: Transverse along the line from PSIS to Greater Trochanter, centered at the midpoint.
- [ ] **Needle Insertion** — `piriformis-needle.jpg`
  Insert the needle perpendicular to the skin surface at the midpoint. Advance through the Gluteus Maximus (typically 4-6 cm depending on body habitus) until the needle tip enters the piriformis.
- [ ] **Ultrasound Image** — `piriformis-us.jpg`
  You should see: Identify the subcutaneous tissue and the thick Gluteus Maximus as a large superficial hypoechoic muscle. Deep to the Gluteus Maximus, identify the hyperechoic fascial plane — the piriformis lies just below this. ⚠ The sciatic nerve exits immediately inferior to the piriformis — always identify it on ultrasound before injecting.

### Tensor Fasciae Latae (TFL)  `tfl`
*Lower Extremity — Hip flexion, abduction, internal rotation*

- [ ] **Patient Position** — `tfl-position.jpg`
  Position the patient supine or in lateral decubitus with the affected side up.
- [ ] **Probe Placement** — `tfl-probe.jpg`
  Patient supine or lateral. Place probe transversely on anterolateral hip, 2-3 cm below ASIS. Photo showing probe just distal to ASIS on lateral hip. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterolateral hip, 2-3 cm distal to the ASIS.
- [ ] **Needle Insertion** — `tfl-needle.jpg`
  Insert the needle perpendicular to the skin surface directly into the palpated muscle belly. Advance only 1-2 cm — the TFL is a superficial muscle and the deeper Gluteus Minimus lies beneath it.
- [ ] **Ultrasound Image** — `tfl-us.jpg`
  You should see: Identify the subcutaneous fat as a superficial hyperechoic layer — it is usually thin in this region. The TFL appears as a small, oval hypoechoic muscle belly with a bright fascial envelope, superficial and anterior. ⚠ The lateral femoral cutaneous nerve runs near the ASIS — avoid injecting too close to the ASIS to prevent nerve injury.

### Rectus Femoris  `rectus-femoris`
*Lower Extremity — Stiff knee gait, Knee extension*

- [ ] **Patient Position** — `rectus-femoris-position.jpg`
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe Placement** — `rectus-femoris-probe.jpg`
  Patient supine, knee extended. Place probe transversely on anterior mid-thigh. Photo from lateral view showing probe across anterior thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior mid-thigh.
- [ ] **Needle Insertion** — `rectus-femoris-needle.jpg`
  Insert the needle perpendicular to the skin into the bulk of the muscle belly at mid-thigh. Advance 1-2 cm into the muscle, staying superficial to the Vastus Intermedius below.
- [ ] **Ultrasound Image** — `rectus-femoris-us.jpg`
  You should see: Identify subcutaneous fat and the superficial fascia (fascia lata) as the most superficial hyperechoic layers. The Rectus Femoris appears as a prominent oval hypoechoic muscle belly in the center of the anterior thigh, with a bright fascial envelope. ⚠ The femoral nerve, artery, and vein lie in the femoral triangle (medial proximal thigh) — avoid the proximal medial approach.

### Vastus Medialis  `vastus-medialis`
*Lower Extremity — Knee extension (distal stabilization)*

- [ ] **Patient Position** — `vastus-medialis-position.jpg`
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe Placement** — `vastus-medialis-probe.jpg`
  Patient supine, knee extended. Place probe transversely on distal medial thigh, just above patella (VMO area). Photo showing probe on medial knee/thigh junction. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal medial thigh, just proximal to the patella.
- [ ] **Needle Insertion** — `vastus-medialis-needle.jpg`
  Insert the needle perpendicular to the skin into the bulk of the VMO muscle belly. Advance 1-2 cm into the muscle substance.
- [ ] **Ultrasound Image** — `vastus-medialis-us.jpg`
  You should see: Identify subcutaneous tissue and the superficial fascia as hyperechoic layers. The Sartorius appears as a thin, strap-like hypoechoic muscle superficially on the medial side. ⚠ The saphenous nerve and descending genicular artery travel in the adductor canal deep to the Sartorius — do not inject too medially or deeply.

### Vastus Lateralis  `vastus-lateralis`
*Lower Extremity — Knee extension*

- [ ] **Patient Position** — `vastus-lateralis-position.jpg`
  Position the patient supine or in lateral decubitus with the affected side up.
- [ ] **Probe Placement** — `vastus-lateralis-probe.jpg`
  Patient supine or lateral. Place probe transversely on lateral mid-thigh. Photo from lateral view showing probe on outer thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral mid-thigh.
- [ ] **Needle Insertion** — `vastus-lateralis-needle.jpg`
  Insert the needle through the IT band, angling slightly anteriorly to enter the VL muscle belly. Advance 2-3 cm into the muscle substance until you feel the firm muscle against bone.
- [ ] **Ultrasound Image** — `vastus-lateralis-us.jpg`
  You should see: Identify subcutaneous fat and the fascia lata (including the IT band component) as hyperechoic superficial layers. The Vastus Lateralis appears as a large hypoechoic muscle deep to the IT band, wrapping around the lateral femur. ⚠ The descending branch of the lateral circumflex femoral artery runs in the intermuscular septum between VL and RF — use color Doppler.

### Vastus Intermedius  `vastus-intermedius`
*Lower Extremity — Knee extension*

- [ ] **Patient Position** — `vastus-intermedius-position.jpg`
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe Placement** — `vastus-intermedius-probe.jpg`
  Patient supine, knee extended. Place probe transversely on anterior proximal thigh (same region as rectus femoris but deeper target). Photo from front showing probe on anterior thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior proximal-to-mid thigh.
- [ ] **Needle Insertion** — `vastus-intermedius-needle.jpg`
  Insert the needle perpendicular to the skin through the center of the Rectus Femoris. Advance through the RF (typically 1-2 cm) until you feel a subtle 'pop' through the fascial septum separating the two muscles.
- [ ] **Ultrasound Image** — `vastus-intermedius-us.jpg`
  You should see: Identify subcutaneous fat and fascia lata superficially. The Rectus Femoris appears as the superficial oval hypoechoic muscle in the center of the field. ⚠ The descending branch of the lateral circumflex femoral artery runs laterally between the muscles — use color Doppler before inserting.

### Semimembranosus  `semimembranosus`
*Lower Extremity — Knee flexion*

- [ ] **Patient Position** — `semimembranosus-position.jpg`
  Position the patient prone with the knee slightly flexed (place a pillow under the ankle).
- [ ] **Probe Placement** — `semimembranosus-probe.jpg`
  Patient prone, knee slightly flexed. Place probe transversely on posterior medial thigh at mid-to-distal level. Photo from behind showing probe on posteromedial thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior medial thigh at mid-to-distal level.
- [ ] **Needle Insertion** — `semimembranosus-needle.jpg`
  Insert the needle from the medial aspect, angling slightly posteriorly and laterally to pass deep to the Semitendinosus. Advance 2-3 cm to reach the semimembranosus muscle belly.
- [ ] **Ultrasound Image** — `semimembranosus-us.jpg`
  You should see: Identify subcutaneous tissue and the deep fascia as superficial hyperechoic layers. The Semitendinosus appears as a round or oval hypoechoic muscle belly superficially (or its hyperechoic tendon distally). ⚠ The sciatic nerve runs in the lateral posterior thigh — a medial approach avoids it, but always verify its position.

### Semitendinosus  `semitendinosus`
*Lower Extremity — Knee flexion*

- [ ] **Patient Position** — `semitendinosus-position.jpg`
  Position the patient prone with the knee slightly flexed (place a pillow under the ankle).
- [ ] **Probe Placement** — `semitendinosus-probe.jpg`
  Patient prone, knee slightly flexed. Place probe transversely on posterior mid-thigh. Photo from behind showing probe on posterior thigh, medial side. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior mid-thigh.
- [ ] **Needle Insertion** — `semitendinosus-needle.jpg`
  Insert the needle perpendicular to the skin into the mid-belly of the muscle (proximal to the tendinous portion). Advance 1-2 cm into the muscle substance — it is relatively superficial.
- [ ] **Ultrasound Image** — `semitendinosus-us.jpg`
  You should see: Identify subcutaneous tissue and the deep fascia superficially. The Semitendinosus appears as a round or oval hypoechoic muscle belly in the medial posterior thigh — it is the most superficial of the medial hamstrings. ⚠ The sciatic nerve runs laterally in the posterior thigh — it is generally safe with a medial injection approach.

### Gastrocnemius (Medial)  `gastrocnemius-medial`
*Lower Extremity — Equinus deformity, Plantarflexion*

- [ ] **Patient Position** — `gastrocnemius-medial-position.jpg`
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe Placement** — `gastrocnemius-medial-probe.jpg`
  Patient prone, feet off bed edge. Place probe transversely on proximal medial calf, 2-3 cm below popliteal crease. Photo from behind showing probe on medial proximal calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial posterior calf, 2-3 cm distal to the popliteal crease.
- [ ] **Needle Insertion** — `gastrocnemius-medial-needle.jpg`
  Insert the needle perpendicular to the skin into the bulk of the medial gastrocnemius belly. Advance 1-2 cm into the muscle — the gastrocnemius is superficial.
- [ ] **Ultrasound Image** — `gastrocnemius-medial-us.jpg`
  You should see: Identify subcutaneous fat and the superficial fascia. The medial Gastrocnemius appears as a large, thick hypoechoic muscle with a pennate fiber pattern and bright fascial borders. ⚠ The sural nerve and small saphenous vein run in the midline between the two gastrocnemius heads — avoid the midline.

### Gastrocnemius (Lateral)  `gastrocnemius-lateral`
*Lower Extremity — Equinus deformity, Plantarflexion*

- [ ] **Patient Position** — `gastrocnemius-lateral-position.jpg`
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe Placement** — `gastrocnemius-lateral-probe.jpg`
  Patient prone, feet off bed edge. Place probe transversely on proximal lateral calf, 2-3 cm below popliteal crease. Photo from behind showing probe on lateral proximal calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal lateral posterior calf, 2-3 cm distal to the popliteal crease.
- [ ] **Needle Insertion** — `gastrocnemius-lateral-needle.jpg`
  Insert the needle perpendicular to the skin into the lateral muscle belly. Advance 1-1.5 cm into the muscle substance.
- [ ] **Ultrasound Image** — `gastrocnemius-lateral-us.jpg`
  You should see: Identify subcutaneous fat and superficial fascia. The lateral Gastrocnemius appears as a hypoechoic muscle belly — it is typically thinner and narrower than the medial head. ⚠ The common peroneal nerve wraps around the fibular head — always identify its position and stay medial to the fibular head.

### Soleus (Medial)  `soleus-medial`
*Lower Extremity — Plantarflexion*

- [ ] **Patient Position** — `soleus-medial-position.jpg`
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe Placement** — `soleus-medial-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on medial mid-calf, just posterior to tibial border. Photo from behind/medial showing probe on mid-calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the medial mid-calf, 1-2 cm posterior to the tibial border.
- [ ] **Needle Insertion** — `soleus-medial-needle.jpg`
  Insert the needle perpendicular to the skin, directed slightly laterally and posteriorly. Advance 2-3 cm to pass deep to the Gastrocnemius and enter the Soleus muscle belly.
- [ ] **Ultrasound Image** — `soleus-medial-us.jpg`
  You should see: Identify subcutaneous tissue and superficial fascia. The Gastrocnemius (or its aponeurosis distally) appears as a superficial hypoechoic layer with a bright fascial border. ⚠ The posterior tibial artery and tibial nerve run deep to the soleus in the deep posterior compartment — do not advance the needle through the soleus.

### Soleus (Lateral)  `soleus-lateral`
*Lower Extremity — Plantarflexion*

- [ ] **Patient Position** — `soleus-lateral-position.jpg`
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe Placement** — `soleus-lateral-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on lateral mid-calf. Photo from behind showing probe on lateral mid-calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral mid-calf.
- [ ] **Needle Insertion** — `soleus-lateral-needle.jpg`
  Insert the needle perpendicular to the skin into this lateral soleus bulge at mid-calf level. Advance 1-2 cm into the muscle belly.
- [ ] **Ultrasound Image** — `soleus-lateral-us.jpg`
  You should see: Identify subcutaneous tissue and superficial fascia. The lateral Gastrocnemius (or its aponeurosis) appears as a superficial hypoechoic layer, tapering distally. ⚠ The peroneal artery runs between the soleus and tibialis posterior in the deep compartment — use color Doppler.

### Flexor Digitorum Longus (FDL)  `fdl`
*Lower Extremity — Claw toes, toe flexion*

- [ ] **Patient Position** — `fdl-position.jpg`
  Position the patient prone or supine with the leg externally rotated to expose the medial calf.
- [ ] **Probe Placement** — `fdl-probe.jpg`
  Patient prone or supine with leg externally rotated. Place probe transversely on medial distal leg, just behind tibial border. Photo showing probe on posteromedial distal leg. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the medial distal leg, just posterior to the tibial border.
- [ ] **Needle Insertion** — `fdl-needle.jpg`
  Insert the needle perpendicular to the skin, directing it toward the posterior aspect of the tibia and fibula. Advance 2-3 cm under ultrasound guidance to enter the FDL muscle belly.
- [ ] **Ultrasound Image** — `fdl-us.jpg`
  You should see: Identify subcutaneous tissue and the superficial crural fascia. The Gastrocnemius/Soleus complex is visible superficially as a hypoechoic muscle layer (or tendon distally). ⚠ The posterior tibial artery and tibial nerve run immediately adjacent to the FDL — always identify them with color Doppler before injecting.

### Flexor Digitorum Brevis (FDB)  `fdb`
*Lower Extremity — Toe flexion (plantar)*

- [ ] **Patient Position** — `fdb-position.jpg`
  Position the patient prone with the foot hanging off the edge of the bed, or supine with the ankle dorsiflexed to expose the sole.
- [ ] **Probe Placement** — `fdb-probe.jpg`
  Patient prone, foot hanging off bed. Place probe longitudinally on plantar midfoot from calcaneus toward toes. Photo from plantar view showing probe on sole of foot. Probe: High-frequency linear (10-15 MHz). Orientation: Longitudinal (sagittal) along the midline of the plantar foot, from calcaneus toward the toes.
- [ ] **Needle Insertion** — `fdb-needle.jpg`
  Insert the needle perpendicular to the plantar skin surface. Advance through the thick plantar fascia (you will feel firm resistance, then a give as you penetrate the fascia).
- [ ] **Ultrasound Image** — `fdb-us.jpg`
  You should see: Identify the thick hyperechoic plantar fascia as the most superficial fibrous layer on the sole. Deep to the plantar fascia, the FDB appears as a hypoechoic muscle belly with a fibrillar pattern. ⚠ The medial and lateral plantar nerves and arteries run deep to the FDB — do not advance too deeply.

### Tibialis Anterior  `tibialis-anterior`
*Lower Extremity — ⚠️ NOT TYPICALLY INJECTED — Dorsiflexor (reference only)*

- [ ] **Patient Position** — `tibialis-anterior-position.jpg`
  Position the patient supine with the leg extended and the ankle in neutral.
- [ ] **Probe Placement** — `tibialis-anterior-probe.jpg`
  Patient supine, leg extended. Place probe transversely on proximal anterolateral leg, 2 cm lateral to tibial crest. Photo from front showing probe on anterior shin. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal anterolateral leg, 2 cm lateral to the tibial crest.
- [ ] **Needle Insertion** — `tibialis-anterior-needle.jpg`
  Insert the needle perpendicular to the skin into the largest muscle bulk, approximately 2 cm lateral to the tibial crest. Advance 1-2 cm into the muscle belly.
- [ ] **Ultrasound Image** — `tibialis-anterior-us.jpg`
  You should see: Identify subcutaneous tissue — it is thin on the anterior leg. The Tibialis Anterior appears as a large hypoechoic muscle with a prominent central tendon in the distal portion, located immediately lateral to the tibial cortex. ⚠ The anterior tibial artery and deep peroneal nerve run deep to the muscle on the interosseous membrane — do not advance the needle to this depth.

### Tibialis Posterior  `tibialis-posterior`
*Lower Extremity — Equinovarus (Plantarflexion + Inversion)*

- [ ] **Patient Position** — `tibialis-posterior-position.jpg`
  Position the patient prone or supine with the leg externally rotated.
- [ ] **Probe Placement** — `tibialis-posterior-probe.jpg`
  Patient prone or supine with leg externally rotated. Place probe transversely on medial mid-leg, just behind tibia. Photo from medial side showing probe behind tibial border. Probe: High-frequency linear (10-15 MHz) in thin patients; lower-frequency linear (6-9 MHz) or curvilinear (5-8 MHz) is often required in average/larger patients due to muscle depth (3-5+ cm). Orientation: Transverse across the medial mid-leg, posterior to the tibial border.
- [ ] **Needle Insertion** — `tibialis-posterior-needle.jpg`
  Insert the needle directed posterolaterally, sliding along the posterior aspect of the tibia. Advance through the superficial posterior compartment muscles (Gastrocnemius/Soleus) toward the interosseous membrane.
- [ ] **Ultrasound Image** — `tibialis-posterior-us.jpg`
  You should see: Identify subcutaneous tissue and the crural fascia superficially. The Gastrocnemius and Soleus form the superficial posterior compartment — they appear as hypoechoic muscle layers with a fascial septum between them. ⚠ The posterior tibial artery and tibial nerve run in the deep posterior compartment directly superficial to the tibialis posterior — always identify them with color Doppler.

### Flexor Hallucis Longus (FHL)  `fhl`
*Lower Extremity — Claw hallux, Equinovarus support*

- [ ] **Patient Position** — `fhl-position.jpg`
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe Placement** — `fhl-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on distal posterolateral calf, adjacent to fibula. Photo from behind showing probe on distal lateral calf near fibula. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal posterolateral calf, adjacent to the fibula.
- [ ] **Needle Insertion** — `fhl-needle.jpg`
  Insert the needle lateral to the Achilles tendon, directed toward the posterior fibula. Advance 2-4 cm under ultrasound guidance to pass through the Soleus and enter the FHL belly.
- [ ] **Ultrasound Image** — `fhl-us.jpg`
  You should see: Identify subcutaneous tissue and the Soleus muscle/aponeurosis superficially. The fibula appears as a bright hyperechoic cortical line laterally with posterior acoustic shadowing. ⚠ The posterior tibial artery and tibial nerve lie medial to the FHL — always use a lateral approach.

### Extensor Hallucis Longus (EHL)  `ehl`
*Lower Extremity — Hallux extension, hitchhiking thumb sign*

- [ ] **Patient Position** — `ehl-position.jpg`
  Position the patient supine with the leg extended and the ankle in neutral.
- [ ] **Probe Placement** — `ehl-probe.jpg`
  Patient supine, leg extended. Place probe transversely on distal anterolateral leg, ~10 cm above ankle. Photo from front showing probe on anterior distal leg. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal anterolateral leg, approximately 10 cm proximal to the ankle.
- [ ] **Needle Insertion** — `ehl-needle.jpg`
  Insert the needle perpendicular to the skin into the EHL muscle belly. Advance 1-2 cm into the muscle substance.
- [ ] **Ultrasound Image** — `ehl-us.jpg`
  You should see: Identify the thin subcutaneous tissue on the anterior leg. The Tibialis Anterior is the large hypoechoic muscle medially, adjacent to the tibial cortex. ⚠ The anterior tibial artery and deep peroneal nerve run immediately adjacent to the EHL — identify them with color Doppler before injecting.

### Adductor Hallucis  `add-hallucis`
*Lower Extremity — Hallux adduction, transverse arch collapse*

- [ ] **Patient Position** — `add-hallucis-position.jpg`
  Position the patient supine with the foot accessible, or prone with the foot dorsiflexed.
- [ ] **Probe Placement** — `add-hallucis-probe.jpg`
  Patient supine, foot accessible. Place probe longitudinally along 1st-2nd intermetatarsal space on plantar surface. Photo showing probe on plantar forefoot between 1st and 2nd metatarsals. Probe: High-frequency linear (10-15 MHz). Orientation: Longitudinal along the 1st-2nd intermetatarsal space on the plantar surface, or transverse across the metatarsal heads.
- [ ] **Needle Insertion** — `add-hallucis-needle.jpg`
  A dorsal approach is an alternative: insert the needle from the dorsum of the foot between the 1st and 2nd metatarsal shafts, directed plantarward. Insert the needle perpendicular to the foot surface into the small muscle belly.
- [ ] **Ultrasound Image** — `add-hallucis-us.jpg`
  You should see: Identify the hyperechoic cortex of the 1st and 2nd metatarsal shafts as bright lines with posterior shadowing. Between the metatarsals, the Adductor Hallucis (oblique head) appears as a small hypoechoic muscle belly in the interosseous space. ⚠ The plantar digital nerves run between the metatarsal heads — interdigital neuromas are common here; identify nerve tissue before injecting.

### Adductor Longus  `adductor-longus`
*Lower Extremity — Hip adduction*

- [ ] **Patient Position** — `adductor-longus-position.jpg`
  Position the patient supine with the hip slightly abducted and externally rotated, and the knee flexed with the sole of the foot resting against the opposite knee (frog-leg position).
- [ ] **Probe Placement** — `adductor-longus-probe.jpg`
  Patient supine, hip slightly abducted and externally rotated. Place probe transversely on proximal medial thigh, 3-5 cm below pubic tubercle. Photo showing probe on inner proximal thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh, 3-5 cm distal to the pubic tubercle.
- [ ] **Needle Insertion** — `adductor-longus-needle.jpg`
  Insert the needle perpendicular to the skin into the muscle belly just lateral to the palpable tendon. Advance approximately 1.5-2.5 cm — the adductor longus is the most superficial muscle in the medial compartment at this level.
- [ ] **Ultrasound Image** — `adductor-longus-us.jpg`
  You should see: Identify subcutaneous fat and the fascia lata as the superficial layers. The Adductor Longus appears as a triangular or oval hypoechoic muscle belly immediately deep to the fascia — it is the most superficial adductor at this level. ⚠ The femoral artery and vein lie lateral to the adductor longus in the femoral triangle — always confirm their location with color Doppler before injecting.

### Adductor Magnus  `adductor-magnus`
*Lower Extremity — Hip adduction, Hip extension*

- [ ] **Patient Position** — `adductor-magnus-position.jpg`
  Position the patient prone with the legs slightly apart, or supine with the hip abducted and externally rotated.
- [ ] **Probe Placement** — `adductor-magnus-probe.jpg`
  Patient prone, legs slightly apart. Place probe transversely on posteromedial thigh at junction of middle and distal thirds. Photo from behind showing probe on posteromedial distal thigh. Probe: Low-frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) for thinner patients. Orientation: Transverse across the posteromedial thigh at the junction of the middle and distal thirds.
- [ ] **Needle Insertion** — `adductor-magnus-needle.jpg`
  Insert the needle from the posteromedial aspect of the thigh, angling slightly anteriorly. Advance approximately 2.5-4 cm — the adductor magnus is a deep muscle and the needle must traverse the more superficial adductors or approach from the posterior aspect.
- [ ] **Ultrasound Image** — `adductor-magnus-us.jpg`
  You should see: Identify subcutaneous fat and the deep fascia as the superficial layers. The Gracilis and Adductor Longus appear as superficial hypoechoic muscles in the medial compartment. ⚠ The profunda femoris artery and vein run between the adductor longus and adductor magnus — use color Doppler to identify and avoid these vessels.

### Biceps Femoris  `biceps-femoris`
*Lower Extremity — Knee flexion, Hip extension*

- [ ] **Patient Position** — `biceps-femoris-position.jpg`
  Position the patient prone with the knee slightly flexed over a pillow or bolster.
- [ ] **Probe Placement** — `biceps-femoris-probe.jpg`
  Patient prone, knee flexed over pillow. Place probe transversely on lateral posterior thigh at junction of proximal and middle thirds. Photo from behind showing probe on posterolateral thigh. Probe: High-frequency linear (10-15 MHz) or low-frequency curvilinear (5-8 MHz) for deeper targets. Orientation: Transverse across the lateral posterior thigh at the junction of the proximal and middle thirds.
- [ ] **Needle Insertion** — `biceps-femoris-needle.jpg`
  Insert the needle perpendicular to the skin into the lateral muscle belly of the posterior thigh. Advance approximately 1.5-3 cm depending on subcutaneous tissue thickness — the biceps femoris long head is relatively superficial in the lateral posterior thigh.
- [ ] **Ultrasound Image** — `biceps-femoris-us.jpg`
  You should see: Identify subcutaneous fat and the deep fascia (fascia lata) as the superficial layers. The Biceps Femoris Long Head appears as a large hypoechoic muscle belly in the lateral posterior thigh, superficial to the short head. ⚠ The sciatic nerve courses medial and deep to the biceps femoris long head — always identify it with ultrasound before injecting.

### Iliopsoas  `iliopsoas`
*Lower Extremity — Hip flexion*

- [ ] **Patient Position** — `iliopsoas-position.jpg`
  Position the patient supine with the hip in neutral position and the knee extended.
- [ ] **Probe Placement** — `iliopsoas-probe.jpg`
  Patient supine, hip neutral. Place curvilinear probe transversely on proximal anterior thigh, 2-3 cm below inguinal ligament, lateral to femoral vessels. Photo from front showing probe in inguinal/proximal thigh region. Probe: Low-frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) in thin patients. Orientation: Transverse across the proximal anterior thigh, 2-3 cm distal to the inguinal ligament, lateral to the femoral vessels.
- [ ] **Needle Insertion** — `iliopsoas-needle.jpg`
  Under ultrasound guidance, insert the needle lateral to the femoral vessels and advance toward the iliopsoas muscle belly. Advance approximately 2-4 cm to reach the muscle belly deep to the sartorius and rectus femoris. Aspirate before injecting. Distribute the dose across 1-2 sites.
- [ ] **Ultrasound Image** — `iliopsoas-us.jpg`
  You should see: Identify subcutaneous fat, the fascia lata, and the Sartorius muscle as the most superficial structures laterally. Medially, identify the Femoral Artery (pulsating) and Femoral Vein (compressible) within the femoral triangle. ⚠ The femoral artery and vein lie medial to the iliopsoas — always use color Doppler to map the vessels before needle insertion.

### Peroneus Longus  `peroneus-longus`
*Lower Extremity — Ankle eversion, Ankle plantarflexion*

- [ ] **Patient Position** — `peroneus-longus-position.jpg`
  Position the patient supine with the leg internally rotated to expose the lateral compartment, or in a lateral decubitus position with the affected side up.
- [ ] **Probe Placement** — `peroneus-longus-probe.jpg`
  Patient supine, leg internally rotated. Place probe transversely on lateral proximal leg, 5-8 cm below fibular head. Photo from lateral view showing probe on lateral upper calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral proximal leg, 5-8 cm distal to the fibular head.
- [ ] **Needle Insertion** — `peroneus-longus-needle.jpg`
  Insert the needle perpendicular to the skin into the lateral muscle belly, aiming toward the fibula. Advance approximately 1-2 cm — the peroneus longus is relatively superficial in the lateral compartment.
- [ ] **Ultrasound Image** — `peroneus-longus-us.jpg`
  You should see: Identify subcutaneous fat and the crural fascia as the superficial layers. The Peroneus Longus appears as a hypoechoic muscle belly superficial and posterior in the lateral compartment, lying directly on the lateral fibular surface. ⚠ The common peroneal nerve wraps around the fibular neck just distal to the fibular head — never inject within 3 cm of the fibular head.

### Extensor Digitorum Longus  `edl`
*Lower Extremity — Toe extension, Ankle dorsiflexion*

- [ ] **Patient Position** — `edl-position.jpg`
  Position the patient supine with the leg in neutral position and the foot relaxed.
- [ ] **Probe Placement** — `edl-probe.jpg`
  Patient supine, leg neutral. Place probe transversely on anterolateral proximal leg at proximal-middle third junction. Photo from anterolateral view showing probe on outer upper shin. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterolateral proximal leg, at the junction of the proximal and middle thirds.
- [ ] **Needle Insertion** — `edl-needle.jpg`
  Insert the needle perpendicular to the skin into the anterolateral muscle belly. Advance approximately 1.5-2.5 cm — the EDL lies deep to the tibialis anterior proximally but becomes more superficial in the mid-leg.
- [ ] **Ultrasound Image** — `edl-us.jpg`
  You should see: Identify subcutaneous fat and the crural fascia as the superficial layers. The Tibialis Anterior appears as a large hypoechoic muscle in the anteromedial compartment, lying directly on the lateral tibial surface and the interosseous membrane. ⚠ The deep peroneal nerve and anterior tibial artery lie on the interosseous membrane between the tibialis anterior and EDL — use color Doppler to identify the artery and avoid this…

### Adductor Brevis  `adductor-brevis`
*Lower Extremity — Hip adduction (deep, short adductor)*

- [ ] **Patient Position** — `adductor-brevis-position.jpg`
  Position the patient supine with the hip abducted 30-45 degrees, knee flexed, and the leg externally rotated (frog-leg position).
- [ ] **Probe Placement** — `adductor-brevis-probe.jpg`
  Patient supine, frog-leg position. Place probe transversely on proximal medial thigh at the adductor longus origin. Photo from medial view showing probe on inner thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh, at the level of the adductor longus origin, perpendicular to the muscle fibers.
- [ ] **Needle Insertion** — `adductor-brevis-needle.jpg`
  USG is strongly recommended — insert the needle through the adductor longus to reach the adductor brevis layer deep to it. Under ultrasound, advance the needle through the adductor longus until the tip crosses the fascial plane into the deeper adductor brevis muscle belly.
- [ ] **Ultrasound Image** — `adductor-brevis-us.jpg`
  You should see: Place the probe transversely on the proximal medial thigh with the hip abducted. Identify the adductor longus as the most superficial adductor — a large hypoechoic muscle belly with a prominent proximal tendon originating from the pubic tubercle. ⚠ The anterior branch of the obturator nerve runs between adductor longus and brevis — identify it and keep the needle tip within the muscle belly, not in the inter-fascial plane.

### Gracilis  `gracilis`
*Lower Extremity — Hip adduction + knee flexion (crosses both joints)*

- [ ] **Patient Position** — `gracilis-position.jpg`
  Position the patient supine with the hip abducted 30-45 degrees and knee slightly flexed.
- [ ] **Probe Placement** — `gracilis-probe.jpg`
  Patient supine, frog-leg position. Place probe transversely on proximal medial thigh. Photo from medial view showing probe on inner thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh.
- [ ] **Needle Insertion** — `gracilis-needle.jpg`
  Insert the needle perpendicular to the skin on the medial thigh into the superficial muscle belly. Advance only 1-1.5 cm — gracilis is thin and superficial.
- [ ] **Ultrasound Image** — `gracilis-us.jpg`
  You should see: Place the probe transversely on the proximal medial thigh with the hip abducted. Gracilis appears as a thin, flat hypoechoic muscle strap on the most medial and superficial aspect of the thigh, directly under the subcutaneous tissue. ⚠ The saphenous nerve and great saphenous vein run in the subsartorial canal anterior to gracilis — identify them if visible and avoid.

### Foot Lumbricals  `foot-lumbricals`
*Lower Extremity — MTP flexion + IP extension in the foot (contributes to claw toe deformity)*

- [ ] **Patient Position** — `foot-lumbricals-position.jpg`
  Position the patient prone with the foot hanging off the bed, or supine with the ankle dorsiflexed to expose the sole.
- [ ] **Probe Placement** — `foot-lumbricals-probe.jpg`
  Patient prone or supine with foot exposed. Place hockey-stick probe longitudinally on plantar surface along the metatarsal. Photo from plantar view. Probe: High-frequency linear (10-15 MHz); hockey-stick probe preferred for the narrow intermetatarsal spaces. Orientation: Longitudinal along the metatarsal shaft on the plantar surface, or transverse across the metatarsal heads.
- [ ] **Needle Insertion** — `foot-lumbricals-needle.jpg`
  Insert the needle from the plantar surface perpendicular to the skin, just proximal to the MTP joint of the target toe, on the medial (tibial) side of the flexor tendon. Advance only 5-10 mm — these are very small, superficial muscles in the plantar compartment.
- [ ] **Ultrasound Image** — `foot-lumbricals-us.jpg`
  You should see: Place the probe longitudinally on the plantar surface along the metatarsal of the target toe. Identify the FDL tendon as a hyperechoic linear structure running along the plantar metatarsal. ⚠ The plantar digital nerves and arteries are immediately adjacent to the lumbricals — identify before injecting.

---

## Cervical / Neck  ·  7 muscles  ·  28 photos

### Sternocleidomastoid (SCM)  `scm`
*Cervical — Head rotation to opposite side, ipsilateral lateral flexion*

- [ ] **Patient Position** — `scm-position.jpg`
  Position the patient supine with the head turned slightly to the contralateral side to make the SCM prominent but not maximally stretched.
- [ ] **Probe Placement** — `scm-probe.jpg`
  Patient supine, head turned slightly contralateral. Place probe transversely on lateral neck at thyroid cartilage level. Photo from front/lateral showing probe across SCM muscle belly on neck. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral neck at the level of the thyroid cartilage, perpendicular to the SCM muscle belly.
- [ ] **Needle Insertion** — `scm-needle.jpg`
  Palpate the muscle belly at the mid-cervical level (approximately the level of the thyroid cartilage). Grasp the muscle between thumb and index finger and LIFT it anteriorly off the carotid sheath — this 'pinch technique' physically… For the sternal head: insert the needle into the mid-belly approximately 3-4 cm above the sternal origin, directing it tangentially (nearly parallel to the skin at 20-30 degrees) into the muscle to avoid deep penetration toward the carotid…
- [ ] **Ultrasound Image** — `scm-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Immediately deep to the subcutaneous tissue, the SCM appears as an oval or elliptical hypoechoic muscle with a bright fascial envelope — it is typically 1-2 cm thick at the… ⚠ The carotid artery and internal jugular vein lie immediately deep to the SCM within the carotid sheath — always visualize these structures with color Doppler before injecting and…

### Upper Trapezius  `upper-trapezius`
*Cervical — Scapular elevation, head lateral flexion*

- [ ] **Patient Position** — `upper-trapezius-position.jpg`
  Position the patient seated upright with arms relaxed at the sides, or prone with the forehead resting on hands.
- [ ] **Probe Placement** — `upper-trapezius-probe.jpg`
  Patient seated, arms relaxed. Place probe transversely on upper trapezius ridge, midway between cervical spine and acromion. Photo from behind showing probe on upper trap between neck and shoulder. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the upper trapezius ridge, midway between the cervical spinous processes and the acromion.
- [ ] **Needle Insertion** — `upper-trapezius-needle.jpg`
  Insert the needle perpendicular to the skin surface into the midpoint of the palpated muscle bulk, advancing 1-2 cm into the muscle belly. Stay within the superficial muscle bulk — do not advance beyond 2 cm to avoid penetrating into the supraspinous fossa or toward the lung apex medially.
- [ ] **Ultrasound Image** — `upper-trapezius-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as a broad, flat hypoechoic muscle with parallel fiber architecture and bright fascial borders on its superficial and deep surfaces. ⚠ The spinal accessory nerve (CN XI) runs on the deep surface of the upper trapezius, approximately 2-3 cm above the scapular spine in the posterior triangle of the neck — avoid…

### Levator Scapulae  `levator-scapulae`
*Cervical — Scapular elevation, cervical lateral flexion and rotation*

- [ ] **Patient Position** — `levator-scapulae-position.jpg`
  Position the patient seated upright with arms relaxed, or prone with the forehead resting on hands. Slight contralateral lateral flexion of the neck can help stretch and define the muscle.
- [ ] **Probe Placement** — `levator-scapulae-probe.jpg`
  Patient seated, arms relaxed. Place probe transversely over superior angle of scapula, 2-3 cm lateral to C7-T2 spinous processes. Photo from behind showing probe on posterolateral neck/upper back. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the superior angle of the scapula, approximately 2-3 cm lateral to the cervicothoracic spinous processes at the T1-T2 level.
- [ ] **Needle Insertion** — `levator-scapulae-needle.jpg`
  Identify the superior angle of the scapula by palpating the superomedial corner of the scapula — this is the most reliable surface landmark for the levator scapulae insertion. Palpate the levator scapulae deep to the upper trapezius by pressing firmly at the superior angle of the scapula — the muscle belly may be felt as a firm, tender band running superiorly toward the cervical spine.
- [ ] **Ultrasound Image** — `levator-scapulae-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as the first hypoechoic muscular layer with a bright superficial fascial border. ⚠ The dorsal scapular nerve runs on or through the levator scapulae along its deep surface, often accompanied by the dorsal scapular artery — use color Doppler to identify vascular…

### Splenius Capitis  `splenius-capitis`
*Cervical — Ipsilateral head rotation and extension*

- [ ] **Patient Position** — `splenius-capitis-position.jpg`
  Position the patient seated upright with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe Placement** — `splenius-capitis-probe.jpg`
  Patient seated, neck slightly flexed. Place probe transversely on posterolateral neck at C2-C4 level, 2-3 cm lateral to midline. Photo from behind showing probe on posterolateral neck between midline and mastoid. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterolateral neck at the C2-C4 level, approximately 2-3 cm lateral to the midline spinous processes.
- [ ] **Needle Insertion** — `splenius-capitis-needle.jpg`
  Insert the needle perpendicular to the skin, advancing through the trapezius (1-1.5 cm) and into the splenius capitis beneath it (an additional 0.5-1.5 cm). Total depth is typically 2-3.5 cm depending on body habitus.
- [ ] **Ultrasound Image** — `splenius-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as the first hypoechoic muscular layer with a bright fascial envelope — it is relatively thin in this region (0.5-1 cm). ⚠ The vertebral artery runs through the transverse foramina of C1-C6 — it lies deep and medial to the splenius capitis. Never direct the needle medially toward the transverse…

### Semispinalis Capitis  `semispinalis-capitis`
*Cervical — Bilateral head and neck extension (retrocollis)*

- [ ] **Patient Position** — `semispinalis-capitis-position.jpg`
  Position the patient seated with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe Placement** — `semispinalis-capitis-probe.jpg`
  Patient seated, neck flexed. Place probe transversely on posterior neck at C2-C5 level, 1-2 cm lateral to midline. Photo from behind showing probe on posterior midline neck just below the occiput. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior midline neck at the C2-C5 level, centered 1-2 cm lateral to the spinous processes.
- [ ] **Needle Insertion** — `semispinalis-capitis-needle.jpg`
  This is a DEEP muscle — the needle must traverse the trapezius and splenius capitis to reach it. USG guidance is essential to confirm correct depth and avoid injecting into the more superficial splenius capitis. Insert the needle perpendicular to the skin, advancing through the trapezius, then the splenius capitis, and into the semispinalis capitis beneath. Total depth is typically 3-5 cm depending on body habitus.
- [ ] **Ultrasound Image** — `semispinalis-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the trapezius appears as the first thin hypoechoic muscular layer at this paramedian location. ⚠ The vertebral artery lies anterior to the cervical laminae within the transverse foramina — the laminae serve as a protective bony barrier, but lateral needle angulation toward…

### Scalenes (Anterior, Middle, Posterior)  `scalenes`
*Cervical — Ipsilateral lateral neck flexion (laterocollis), accessory inspiration*

- [ ] **Patient Position** — `scalenes-position.jpg`
  Position the patient supine with the head in neutral position or turned slightly to the contralateral side to expose the lateral neck.
- [ ] **Probe Placement** — `scalenes-probe.jpg`
  Patient supine, head neutral or slightly turned contralateral. Place probe transversely on lateral neck at C5-C7 level, posterior to SCM. Photo from front/lateral showing probe on lateral neck behind the SCM. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral neck at the C5-C7 level, posterior to the SCM and anterior to the upper trapezius.
- [ ] **Needle Insertion** — `scalenes-needle.jpg`
  Under ultrasound, identify the target scalene muscle and confirm the location of the brachial plexus, subclavian/vertebral vessels, and phrenic nerve before inserting the needle. Insert the needle using an in-plane technique under continuous ultrasound visualization, directing it laterally to medially into the muscle belly while avoiding the interscalene groove and its neurovascular contents.
- [ ] **Ultrasound Image** — `scalenes-us.jpg`
  You should see: Identify the SCM as the most superficial anterolateral muscle — use it as your anterior landmark. Posterior and deep to the SCM, the anterior scalene appears as a triangular or trapezoidal hypoechoic muscle lying directly anterior to the brachial plexus roots. ⚠ The brachial plexus roots (C5-T1) pass through the interscalene groove between the anterior and middle scalenes — injection into or near the interscalene groove can cause brachial…

### Longissimus Capitis  `longissimus-capitis`
*Cervical — Head and neck extension (retrocollis), ipsilateral lateral flexion and rotation*

- [ ] **Patient Position** — `longissimus-capitis-position.jpg`
  Position the patient seated with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe Placement** — `longissimus-capitis-probe.jpg`
  Patient seated, neck slightly flexed. Place probe transversely on posterolateral neck at C4-C7 level, 2-4 cm lateral to midline. Photo from behind showing probe on posterolateral neck over the articular pillars. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterolateral neck at the C4-C7 level, approximately 2-4 cm lateral to the midline spinous processes.
- [ ] **Needle Insertion** — `longissimus-capitis-needle.jpg`
  This is a DEEP muscle in the erector spinae group — the needle must traverse the trapezius and splenius capitis to reach it. USG guidance is essential. Insert the needle perpendicular to the skin at the C4-C7 level, approximately 2-4 cm lateral to the midline, advancing through the superficial muscle layers to reach the longissimus capitis. Total depth is typically 3-5 cm depending on…
- [ ] **Ultrasound Image** — `longissimus-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the trapezius appears as a thin hypoechoic muscular layer in this region. ⚠ The vertebral artery lies within the transverse foramina anterior to the articular pillars — never advance the needle beyond the bony cortex of the articular pillar. The bone…

---

## Face / Neck  ·  10 muscles  ·  40 photos

### Masseter  `masseter`
*Face — Jaw clenching, bruxism, oromandibular dystonia (jaw closing type)*

- [ ] **Patient Position** — `masseter-position.jpg`
  Position the patient seated upright or supine with the jaw relaxed and slightly open.
- [ ] **Probe Placement** — `masseter-probe.jpg`
  Patient seated upright with jaw relaxed. Place probe transversely on lateral face over the mandibular ramus midway between zygomatic arch and mandibular angle. Photo from lateral view showing probe on cheek. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral face overlying the mandibular ramus, with the probe parallel to the zygomatic arch.
- [ ] **Needle Insertion** — `masseter-needle.jpg`
  Ask the patient to clench their teeth forcefully — the masseter will bulge prominently as a thick rectangular mass over the mandibular ramus between the zygomatic arch and the angle of the mandible. Identify the thickest bulk of the muscle, typically at the mid-ramus level, approximately 1-2 cm anterior to the tragus and 1-2 cm superior to the mandibular angle.
- [ ] **Ultrasound Image** — `masseter-us.jpg`
  You should see: Place the probe transversely on the lateral face over the mandibular ramus, midway between the zygomatic arch and the angle of the mandible. The masseter appears as a thick, rectangular hypoechoic muscle with internal hyperechoic septa (reflecting its multipennate architecture) directly superficial to the hyperechoic… Depth ≈ 2.0-3.0 cm. ⚠ The parotid gland overlies the posterior masseter — deep injections in this area may inadvertently inject the parotid, causing sialadenitis or pain.

### Temporalis  `temporalis`
*Face — Jaw clenching, bruxism, oromandibular dystonia (jaw closing type), temporal headache*

- [ ] **Patient Position** — `temporalis-position.jpg`
  Position the patient seated upright or supine with the jaw relaxed.
- [ ] **Probe Placement** — `temporalis-probe.jpg`
  Patient seated upright with jaw relaxed. Place probe transversely in the temporal fossa above the zygomatic arch. Photo from lateral view showing probe on temple. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the temporal fossa, perpendicular to the fibers, above the zygomatic arch.
- [ ] **Needle Insertion** — `temporalis-needle.jpg`
  Insert the needle perpendicular to the skull surface into the muscle belly at each site. Advance only 0.5-1 cm — the temporalis is thin (5-10 mm) overlying the temporal bone, and the needle will contact bone quickly.
- [ ] **Ultrasound Image** — `temporalis-us.jpg`
  You should see: Place the probe transversely on the temporal fossa above the zygomatic arch. Apply minimal pressure — the temporalis is thin and compresses easily. The temporalis appears as a thin, flat hypoechoic muscle directly overlying the hyperechoic temporal bone cortex. Its fibers run in a fan-shaped pattern converging inferiorly. Depth ≈ 1.0-1.5 cm. ⚠ The superficial temporal artery runs in the subcutaneous tissue — always palpate and/or use Doppler to map it before injecting. Intravascular injection may cause localized…

### Lateral Pterygoid  `lateral-pterygoid`  _(not typically US-guided)_
*Face — Jaw opening dystonia, jaw protrusion, oromandibular dystonia (jaw opening type), jaw deviation to contralateral side*

- [ ] **Patient Position** — `lateral-pterygoid-position.jpg`
  Position the patient seated upright or supine with the jaw slightly open (to translate the condyle forward and open the coronoid notch).
- [ ] **Probe Placement** — `lateral-pterygoid-probe.jpg`
  EMG-guided injection — no ultrasound probe placement. Patient seated with jaw slightly open. Needle inserted through coronoid notch anterior to tragus, directed medially into infratemporal fossa. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `lateral-pterygoid-needle.jpg`
  Insert a 25-27G, 1.5-2 inch needle through the coronoid notch, directing it medially and slightly anteriorly toward the infratemporal fossa. Advance approximately 2-3 cm until EMG activity confirms placement in the lateral pterygoid. INTRAORAL APPROACH (alternative): Open the jaw maximally to expose the pterygomandibular raphe region. Insert the needle lateral to the pterygomandibular fold, directing it posterolaterally toward the lateral pterygoid plate. This approach…
- [ ] **Ultrasound Image** — `lateral-pterygoid-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Medial Pterygoid  `medial-pterygoid`
*Face — Jaw clenching, oromandibular dystonia (jaw closing type), synergist with masseter for jaw elevation*

- [ ] **Patient Position** — `medial-pterygoid-position.jpg`
  Position the patient seated upright or supine with the jaw slightly open.
- [ ] **Probe Placement** — `medial-pterygoid-probe.jpg`
  Patient seated with jaw slightly open. For US guidance: place probe in submandibular region below mandibular angle, angled superiorly. For EMG: needle through coronoid notch directed medially. Photo from submandibular view showing probe… Probe: High-frequency linear (10-15 MHz) or curvilinear (5-8 MHz) for deeper imaging. Orientation: Coronal oblique from the submandibular region, angled superiorly toward the medial surface of the mandibular ramus.
- [ ] **Needle Insertion** — `medial-pterygoid-needle.jpg`
  SUBMANDIBULAR (EXTRAORAL) APPROACH (preferred for US guidance): Palpate the medial surface of the mandibular angle from the submandibular region. Place the ultrasound probe submandibularly to visualize the medial pterygoid on the deep… Insert a 25-27G, 1.5-2 inch needle from the submandibular region, directing it superiorly and laterally toward the medial surface of the mandibular ramus. Under ultrasound or EMG, advance into the medial pterygoid muscle belly.
- [ ] **Ultrasound Image** — `medial-pterygoid-us.jpg`
  You should see: Place the probe in the submandibular region below and medial to the angle of the mandible, angled superiorly. Identify the mandibular ramus cortex as a hyperechoic line with posterior acoustic shadowing — this is the key deep landmark. Depth ≈ 2.5-4.0 cm. ⚠ The facial artery loops through the submandibular region — always use color Doppler to map it before needle insertion.

### Orbicularis Oculi  `orbicularis-oculi`  _(not typically US-guided)_
*Face — Blepharospasm (involuntary forceful eye closure), hemifacial spasm*

- [ ] **Patient Position** — `orbicularis-oculi-position.jpg`
  Position the patient seated upright in a well-lit room. The patient should be relaxed with eyes gently closed or in their resting blepharospasm position.
- [ ] **Probe Placement** — `orbicularis-oculi-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright in well-lit room. Six injection sites distributed around the orbital rim: 3 upper (medial, central, lateral) and 3 lower (lateral, central, medial). Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `orbicularis-oculi-needle.jpg`
  Insert the needle subcutaneously (bevel up) at each site, directed AWAY from the globe. The muscle is extremely thin (1-2 mm) and lies just beneath the skin with no significant subcutaneous fat over the eyelids. Inject 1.25-2.5 U Botox (or equivalent) per site. Use a tuberculin syringe for precise dosing at these low volumes.
- [ ] **Ultrasound Image** — `orbicularis-oculi-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Corrugator Supercilii  `corrugator-supercilii`  _(not typically US-guided)_
*Face — Blepharospasm (glabellar component), brow furrowing, glabellar dystonia*

- [ ] **Patient Position** — `corrugator-supercilii-position.jpg`
  Position the patient seated upright. Ask them to frown forcefully — the corrugator creates the vertical (11 lines) furrows between the brows.
- [ ] **Probe Placement** — `corrugator-supercilii-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, frowning to activate the corrugator. Injection at the medial eyebrow approximately 1 cm above the superomedial orbital rim. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `corrugator-supercilii-needle.jpg`
  Insert a 30G needle at a shallow angle (20-30 degrees from the skin surface) directed laterally along the corrugator muscle belly. Advance approximately 0.5 cm into the muscle. Inject 5-10 U Botox per side (per the Allergan PI). A single site per side is typically sufficient, though some practitioners split across 2 sites for broader coverage.
- [ ] **Ultrasound Image** — `corrugator-supercilii-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Procerus  `procerus`  _(not typically US-guided)_
*Face — Blepharospasm (glabellar component), horizontal nasal root furrows, glabellar dystonia*

- [ ] **Patient Position** — `procerus-position.jpg`
  Position the patient seated upright. Ask them to 'scrunch' their nose or pull their brows down toward the nose — the procerus creates horizontal wrinkles at the nasal root.
- [ ] **Probe Placement** — `procerus-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, actively scrunching the nose to identify the procerus. Single midline injection at the nasal root/glabella junction. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `procerus-needle.jpg`
  Insert a 30G needle perpendicular to the skin or at a shallow angle into the midline nasal root/glabella junction, advancing only 2-4 mm into the thin muscle belly. Inject 5-10 U Botox as a single midline injection.
- [ ] **Ultrasound Image** — `procerus-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Frontalis  `frontalis`  _(not typically US-guided)_
*Face — Brow elevation dystonia, forehead spasm, involuntary brow raising; NOTE: this is primarily a cosmetic target (horizontal forehead lines) and is NOT a typical spasticity target*

- [ ] **Patient Position** — `frontalis-position.jpg`
  Position the patient seated upright. Ask them to raise their eyebrows forcefully — the frontalis will contract, creating horizontal forehead lines.
- [ ] **Probe Placement** — `frontalis-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, raising eyebrows to activate frontalis. Four to five injection sites distributed across the mid-forehead at least 2 cm above the brow. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `frontalis-needle.jpg`
  Standard cosmetic approach: inject at 4-5 sites across the mid-forehead, each approximately 1.5-2 cm above the brow and spaced 1.5-2 cm apart. Insert the needle intradermally or into the very superficial subcutaneous plane (the frontalis is only 2-4 mm thick). Direct the bevel up and advance 2-3 mm.
- [ ] **Ultrasound Image** — `frontalis-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Platysma  `platysma`  _(not typically US-guided)_
*Face / Neck — Anterocollis (forward head flexion), neck banding, platysmal dystonia, involuntary neck tightening*

- [ ] **Patient Position** — `platysma-position.jpg`
  Position the patient seated upright or supine. Ask them to grimace or depress the mandible with lips retracted to make the platysmal bands prominent.
- [ ] **Probe Placement** — `platysma-probe.jpg`
  Landmark-guided injection — platysmal bands are identified visually by asking the patient to grimace. Patient seated upright, grimacing to display anterior neck bands. Inject subcutaneously into each visible band. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `platysma-needle.jpg`
  Insert a 30G needle subcutaneously into each platysmal band, directing it along the length of the band. Advance only 2-3 mm — the muscle is immediately beneath the skin. For anterocollis, inject 2-3 sites per band, with 2-4 prominent bands typically identified, for a total of 6-10 injection sites.
- [ ] **Ultrasound Image** — `platysma-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Mentalis  `mentalis`  _(not typically US-guided)_
*Face — Chin dimpling dystonia, involuntary chin puckering, mental crease deepening, lower lip protrusion*

- [ ] **Patient Position** — `mentalis-position.jpg`
  Position the patient seated upright. Ask them to 'pout' or push the lower lip forward — the mentalis will contract, producing the characteristic 'chin dimpling' or 'orange peel' appearance on the chin pad.
- [ ] **Probe Placement** — `mentalis-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, pouting to activate the mentalis and display chin dimpling. Inject at the center of the chin pad approximately 1 cm below the labiomental crease. Not typically ultrasound-guided — probe shot optional.
- [ ] **Needle Insertion** — `mentalis-needle.jpg`
  For unilateral dystonia or dimpling, inject the affected side only. For bilateral chin dimpling, inject both sides. Insert a 30G needle at the center of the chin pad, approximately 1 cm below the labiomental crease, directed toward the mandible. Advance 3-5 mm into the muscle belly.
- [ ] **Ultrasound Image** — `mentalis-us.jpg`
  Not typically ultrasound-guided — US image optional.

---

## Appendix — flat filename checklist

All 272 files, for ticking off during the shoot:

- [ ] `pec-major-position.jpg`
- [ ] `pec-major-probe.jpg`
- [ ] `pec-major-needle.jpg`
- [ ] `pec-major-us.jpg`
- [ ] `lat-dorsi-position.jpg`
- [ ] `lat-dorsi-probe.jpg`
- [ ] `lat-dorsi-needle.jpg`
- [ ] `lat-dorsi-us.jpg`
- [ ] `biceps-brachii-position.jpg`
- [ ] `biceps-brachii-probe.jpg`
- [ ] `biceps-brachii-needle.jpg`
- [ ] `biceps-brachii-us.jpg`
- [ ] `brachialis-position.jpg`
- [ ] `brachialis-probe.jpg`
- [ ] `brachialis-needle.jpg`
- [ ] `brachialis-us.jpg`
- [ ] `triceps-position.jpg`
- [ ] `triceps-probe.jpg`
- [ ] `triceps-needle.jpg`
- [ ] `triceps-us.jpg`
- [ ] `brachioradialis-position.jpg`
- [ ] `brachioradialis-probe.jpg`
- [ ] `brachioradialis-needle.jpg`
- [ ] `brachioradialis-us.jpg`
- [ ] `pronator-teres-position.jpg`
- [ ] `pronator-teres-probe.jpg`
- [ ] `pronator-teres-needle.jpg`
- [ ] `pronator-teres-us.jpg`
- [ ] `fcr-position.jpg`
- [ ] `fcr-probe.jpg`
- [ ] `fcr-needle.jpg`
- [ ] `fcr-us.jpg`
- [ ] `fcu-position.jpg`
- [ ] `fcu-probe.jpg`
- [ ] `fcu-needle.jpg`
- [ ] `fcu-us.jpg`
- [ ] `fds-position.jpg`
- [ ] `fds-probe.jpg`
- [ ] `fds-needle.jpg`
- [ ] `fds-us.jpg`
- [ ] `fdp-position.jpg`
- [ ] `fdp-probe.jpg`
- [ ] `fdp-needle.jpg`
- [ ] `fdp-us.jpg`
- [ ] `fpl-position.jpg`
- [ ] `fpl-probe.jpg`
- [ ] `fpl-needle.jpg`
- [ ] `fpl-us.jpg`
- [ ] `adductor-pollicis-position.jpg`
- [ ] `adductor-pollicis-probe.jpg`
- [ ] `adductor-pollicis-needle.jpg`
- [ ] `adductor-pollicis-us.jpg`
- [ ] `subscapularis-position.jpg`
- [ ] `subscapularis-probe.jpg`
- [ ] `subscapularis-needle.jpg`
- [ ] `subscapularis-us.jpg`
- [ ] `infraspinatus-position.jpg`
- [ ] `infraspinatus-probe.jpg`
- [ ] `infraspinatus-needle.jpg`
- [ ] `infraspinatus-us.jpg`
- [ ] `teres-major-position.jpg`
- [ ] `teres-major-probe.jpg`
- [ ] `teres-major-needle.jpg`
- [ ] `teres-major-us.jpg`
- [ ] `pronator-quadratus-position.jpg`
- [ ] `pronator-quadratus-probe.jpg`
- [ ] `pronator-quadratus-needle.jpg`
- [ ] `pronator-quadratus-us.jpg`
- [ ] `hand-lumbricals-position.jpg`
- [ ] `hand-lumbricals-probe.jpg`
- [ ] `hand-lumbricals-needle.jpg`
- [ ] `hand-lumbricals-us.jpg`
- [ ] `quadratus-lumborum-position.jpg`
- [ ] `quadratus-lumborum-probe.jpg`
- [ ] `quadratus-lumborum-needle.jpg`
- [ ] `quadratus-lumborum-us.jpg`
- [ ] `rectus-abdominis-position.jpg`
- [ ] `rectus-abdominis-probe.jpg`
- [ ] `rectus-abdominis-needle.jpg`
- [ ] `rectus-abdominis-us.jpg`
- [ ] `obliques-position.jpg`
- [ ] `obliques-probe.jpg`
- [ ] `obliques-needle.jpg`
- [ ] `obliques-us.jpg`
- [ ] `paraspinals-position.jpg`
- [ ] `paraspinals-probe.jpg`
- [ ] `paraspinals-needle.jpg`
- [ ] `paraspinals-us.jpg`
- [ ] `gluteus-maximus-position.jpg`
- [ ] `gluteus-maximus-probe.jpg`
- [ ] `gluteus-maximus-needle.jpg`
- [ ] `gluteus-maximus-us.jpg`
- [ ] `piriformis-position.jpg`
- [ ] `piriformis-probe.jpg`
- [ ] `piriformis-needle.jpg`
- [ ] `piriformis-us.jpg`
- [ ] `tfl-position.jpg`
- [ ] `tfl-probe.jpg`
- [ ] `tfl-needle.jpg`
- [ ] `tfl-us.jpg`
- [ ] `rectus-femoris-position.jpg`
- [ ] `rectus-femoris-probe.jpg`
- [ ] `rectus-femoris-needle.jpg`
- [ ] `rectus-femoris-us.jpg`
- [ ] `vastus-medialis-position.jpg`
- [ ] `vastus-medialis-probe.jpg`
- [ ] `vastus-medialis-needle.jpg`
- [ ] `vastus-medialis-us.jpg`
- [ ] `vastus-lateralis-position.jpg`
- [ ] `vastus-lateralis-probe.jpg`
- [ ] `vastus-lateralis-needle.jpg`
- [ ] `vastus-lateralis-us.jpg`
- [ ] `vastus-intermedius-position.jpg`
- [ ] `vastus-intermedius-probe.jpg`
- [ ] `vastus-intermedius-needle.jpg`
- [ ] `vastus-intermedius-us.jpg`
- [ ] `semimembranosus-position.jpg`
- [ ] `semimembranosus-probe.jpg`
- [ ] `semimembranosus-needle.jpg`
- [ ] `semimembranosus-us.jpg`
- [ ] `semitendinosus-position.jpg`
- [ ] `semitendinosus-probe.jpg`
- [ ] `semitendinosus-needle.jpg`
- [ ] `semitendinosus-us.jpg`
- [ ] `gastrocnemius-medial-position.jpg`
- [ ] `gastrocnemius-medial-probe.jpg`
- [ ] `gastrocnemius-medial-needle.jpg`
- [ ] `gastrocnemius-medial-us.jpg`
- [ ] `gastrocnemius-lateral-position.jpg`
- [ ] `gastrocnemius-lateral-probe.jpg`
- [ ] `gastrocnemius-lateral-needle.jpg`
- [ ] `gastrocnemius-lateral-us.jpg`
- [ ] `soleus-medial-position.jpg`
- [ ] `soleus-medial-probe.jpg`
- [ ] `soleus-medial-needle.jpg`
- [ ] `soleus-medial-us.jpg`
- [ ] `soleus-lateral-position.jpg`
- [ ] `soleus-lateral-probe.jpg`
- [ ] `soleus-lateral-needle.jpg`
- [ ] `soleus-lateral-us.jpg`
- [ ] `fdl-position.jpg`
- [ ] `fdl-probe.jpg`
- [ ] `fdl-needle.jpg`
- [ ] `fdl-us.jpg`
- [ ] `fdb-position.jpg`
- [ ] `fdb-probe.jpg`
- [ ] `fdb-needle.jpg`
- [ ] `fdb-us.jpg`
- [ ] `tibialis-anterior-position.jpg`
- [ ] `tibialis-anterior-probe.jpg`
- [ ] `tibialis-anterior-needle.jpg`
- [ ] `tibialis-anterior-us.jpg`
- [ ] `tibialis-posterior-position.jpg`
- [ ] `tibialis-posterior-probe.jpg`
- [ ] `tibialis-posterior-needle.jpg`
- [ ] `tibialis-posterior-us.jpg`
- [ ] `fhl-position.jpg`
- [ ] `fhl-probe.jpg`
- [ ] `fhl-needle.jpg`
- [ ] `fhl-us.jpg`
- [ ] `ehl-position.jpg`
- [ ] `ehl-probe.jpg`
- [ ] `ehl-needle.jpg`
- [ ] `ehl-us.jpg`
- [ ] `add-hallucis-position.jpg`
- [ ] `add-hallucis-probe.jpg`
- [ ] `add-hallucis-needle.jpg`
- [ ] `add-hallucis-us.jpg`
- [ ] `adductor-longus-position.jpg`
- [ ] `adductor-longus-probe.jpg`
- [ ] `adductor-longus-needle.jpg`
- [ ] `adductor-longus-us.jpg`
- [ ] `adductor-magnus-position.jpg`
- [ ] `adductor-magnus-probe.jpg`
- [ ] `adductor-magnus-needle.jpg`
- [ ] `adductor-magnus-us.jpg`
- [ ] `biceps-femoris-position.jpg`
- [ ] `biceps-femoris-probe.jpg`
- [ ] `biceps-femoris-needle.jpg`
- [ ] `biceps-femoris-us.jpg`
- [ ] `iliopsoas-position.jpg`
- [ ] `iliopsoas-probe.jpg`
- [ ] `iliopsoas-needle.jpg`
- [ ] `iliopsoas-us.jpg`
- [ ] `peroneus-longus-position.jpg`
- [ ] `peroneus-longus-probe.jpg`
- [ ] `peroneus-longus-needle.jpg`
- [ ] `peroneus-longus-us.jpg`
- [ ] `edl-position.jpg`
- [ ] `edl-probe.jpg`
- [ ] `edl-needle.jpg`
- [ ] `edl-us.jpg`
- [ ] `adductor-brevis-position.jpg`
- [ ] `adductor-brevis-probe.jpg`
- [ ] `adductor-brevis-needle.jpg`
- [ ] `adductor-brevis-us.jpg`
- [ ] `gracilis-position.jpg`
- [ ] `gracilis-probe.jpg`
- [ ] `gracilis-needle.jpg`
- [ ] `gracilis-us.jpg`
- [ ] `foot-lumbricals-position.jpg`
- [ ] `foot-lumbricals-probe.jpg`
- [ ] `foot-lumbricals-needle.jpg`
- [ ] `foot-lumbricals-us.jpg`
- [ ] `scm-position.jpg`
- [ ] `scm-probe.jpg`
- [ ] `scm-needle.jpg`
- [ ] `scm-us.jpg`
- [ ] `upper-trapezius-position.jpg`
- [ ] `upper-trapezius-probe.jpg`
- [ ] `upper-trapezius-needle.jpg`
- [ ] `upper-trapezius-us.jpg`
- [ ] `levator-scapulae-position.jpg`
- [ ] `levator-scapulae-probe.jpg`
- [ ] `levator-scapulae-needle.jpg`
- [ ] `levator-scapulae-us.jpg`
- [ ] `splenius-capitis-position.jpg`
- [ ] `splenius-capitis-probe.jpg`
- [ ] `splenius-capitis-needle.jpg`
- [ ] `splenius-capitis-us.jpg`
- [ ] `semispinalis-capitis-position.jpg`
- [ ] `semispinalis-capitis-probe.jpg`
- [ ] `semispinalis-capitis-needle.jpg`
- [ ] `semispinalis-capitis-us.jpg`
- [ ] `scalenes-position.jpg`
- [ ] `scalenes-probe.jpg`
- [ ] `scalenes-needle.jpg`
- [ ] `scalenes-us.jpg`
- [ ] `longissimus-capitis-position.jpg`
- [ ] `longissimus-capitis-probe.jpg`
- [ ] `longissimus-capitis-needle.jpg`
- [ ] `longissimus-capitis-us.jpg`
- [ ] `masseter-position.jpg`
- [ ] `masseter-probe.jpg`
- [ ] `masseter-needle.jpg`
- [ ] `masseter-us.jpg`
- [ ] `temporalis-position.jpg`
- [ ] `temporalis-probe.jpg`
- [ ] `temporalis-needle.jpg`
- [ ] `temporalis-us.jpg`
- [ ] `lateral-pterygoid-position.jpg`
- [ ] `lateral-pterygoid-probe.jpg`
- [ ] `lateral-pterygoid-needle.jpg`
- [ ] `lateral-pterygoid-us.jpg`
- [ ] `medial-pterygoid-position.jpg`
- [ ] `medial-pterygoid-probe.jpg`
- [ ] `medial-pterygoid-needle.jpg`
- [ ] `medial-pterygoid-us.jpg`
- [ ] `orbicularis-oculi-position.jpg`
- [ ] `orbicularis-oculi-probe.jpg`
- [ ] `orbicularis-oculi-needle.jpg`
- [ ] `orbicularis-oculi-us.jpg`
- [ ] `corrugator-supercilii-position.jpg`
- [ ] `corrugator-supercilii-probe.jpg`
- [ ] `corrugator-supercilii-needle.jpg`
- [ ] `corrugator-supercilii-us.jpg`
- [ ] `procerus-position.jpg`
- [ ] `procerus-probe.jpg`
- [ ] `procerus-needle.jpg`
- [ ] `procerus-us.jpg`
- [ ] `frontalis-position.jpg`
- [ ] `frontalis-probe.jpg`
- [ ] `frontalis-needle.jpg`
- [ ] `frontalis-us.jpg`
- [ ] `platysma-position.jpg`
- [ ] `platysma-probe.jpg`
- [ ] `platysma-needle.jpg`
- [ ] `platysma-us.jpg`
- [ ] `mentalis-position.jpg`
- [ ] `mentalis-probe.jpg`
- [ ] `mentalis-needle.jpg`
- [ ] `mentalis-us.jpg`

