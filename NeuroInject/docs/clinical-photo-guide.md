# NeuroInject — Clinical Photo Capture Guide

Shot list for the clinical photography session. **30 patient-position photos (shared) + 75 probe + 68 ultrasound = 173 images** across 75 muscles.

> Auto-generated from `assets/data/muscles.json` by `tools/generate_photo_capture_guide.py`. Re-run after editing muscle data.

## The three photos per muscle

| # | Photo | What to capture |
|---|-------|-----------------|
| 1 | **Patient Position** | The patient positioned and the segment exposed. **Shared** — many muscles use the same position, so this is shot once and reused (see the table below). |
| 2 | **Probe + Needle Site** | ONE surface photo, annotated: a **blue bar** over the probe footprint on the skin and a **red dot** at the needle insertion point. Per-muscle. |
| 3 | **Ultrasound Image** | The US screen of the target muscle (with the needle in the muscle if you can). Per-muscle. |

## Naming & where files go

Save each photo with this **exact** name into `NeuroInject/assets/images/clinical/`:

```
pos-<positionGroup>.jpg   (ONE shared patient-position photo)
<muscleId>-probe.jpg      (combined probe + needle site, per muscle)
<muscleId>-us.jpg         (ultrasound, per muscle)
```

- **Format:** JPG (convert HEIC → JPG first). Landscape preferred.
- **Patient position is shared.** The 75 muscles need only **30** position photos — capture each `pos-<group>.jpg` once and every muscle in that group reuses it. That's 45 fewer position shots.
- **Annotation convention:** blue bar = probe footprint, red dot = needle insertion point — drawn on the same image.
- The app auto-detects each file — the muscle's detail page swaps the placeholder for the photo and shows an "N/3 captured" counter. No code or data edit needed.
- **68/75** muscles are ultrasound-guided; for the 7 that are not, the US image is optional and the site photo needs only the red needle dot (blue probe bar optional).

## Patient positions — 30 photos to capture once

Each row is **one** photo. Shoot it once; every listed muscle reuses it.

| Position | File | Muscles |
|----------|------|---------|
| Supine · arm abducted, externally rotated | `pos-supine-arm-abducted.jpg` | 2 — Pectoralis Major, Subscapularis |
| Lateral decubitus (or prone) · arm slightly abducted | `pos-lateral-decub-arm-abducted.jpg` | 1 — Latissimus Dorsi |
| Seated or prone · arm adducted at the side | `pos-seated-or-prone-arm-at-side.jpg` | 2 — Infraspinatus, Teres Major |
| Supine or seated · arm supinated on a support | `pos-arm-supinated-on-support.jpg` | 2 — Biceps Brachii, Brachialis |
| Seated or prone · elbow flexed ~90° | `pos-seated-elbow-flexed.jpg` | 1 — Triceps |
| Seated · forearm neutral, thumb up | `pos-seated-forearm-neutral.jpg` | 1 — Brachioradialis |
| Seated · forearm supinated on a flat surface | `pos-seated-forearm-supinated.jpg` | 7 — Pronator Teres, Flexor Carpi Radialis, Flexor Carpi Ulnaris, Flexor Digitorum Superficialis, Flexor Digitorum Profundus, Flexor Pollicis Longus, Pronator Quadratus |
| Seated · forearm pronated on a flat surface | `pos-seated-forearm-pronated.jpg` | 4 — Extensor Carpi Radialis Longus, Extensor Carpi Radialis Brevis, Extensor Carpi Ulnaris, Extensor Digitorum Communis |
| Hand resting palm-down, thumb abducted | `pos-hand-pronated-flat.jpg` | 1 — Adductor Pollicis |
| Hand supinated, palm up, fingers relaxed | `pos-hand-supinated.jpg` | 1 — Hand Lumbricals |
| Prone · pillow under the abdomen | `pos-prone-pillow-abdomen.jpg` | 2 — Paraspinals (Erector Spinae Group), Quadratus Lumborum |
| Supine · knees slightly bent | `pos-supine-knees-bent.jpg` | 1 — Rectus Abdominis |
| Supine or lateral decubitus · affected side up | `pos-supine-or-lat-decub.jpg` | 3 — Obliques (External & Internal), Tensor Fasciae Latae (TFL), Vastus Lateralis |
| Supine · hip neutral, knee extended | `pos-supine-hip-neutral.jpg` | 1 — Iliopsoas |
| Prone (or lateral decubitus) · buttock exposed | `pos-prone-or-lat-decub-buttock.jpg` | 1 — Gluteus Maximus |
| Prone · pillow under the pelvis | `pos-prone-pillow-pelvis.jpg` | 1 — Piriformis |
| Supine · frog-leg (hip abducted & externally rotated) | `pos-supine-frog-leg.jpg` | 4 — Pectineus, Adductor Longus, Adductor Brevis, Gracilis |
| Prone, legs apart (or supine, hip abducted & ER) | `pos-prone-legs-apart.jpg` | 1 — Adductor Magnus |
| Supine · knee extended, thigh relaxed | `pos-supine-knee-extended.jpg` | 3 — Rectus Femoris, Vastus Medialis, Vastus Intermedius |
| Prone · knee slightly flexed (pillow/bolster) | `pos-prone-knee-flexed.jpg` | 3 — Biceps Femoris, Semitendinosus, Semimembranosus |
| Prone · feet hanging off the edge of the bed | `pos-prone-feet-off-bed.jpg` | 5 — Gastrocnemius (Medial), Gastrocnemius (Lateral), Soleus (Medial), Soleus (Lateral), Flexor Hallucis Longus (FHL) |
| Prone or supine · leg externally rotated (expose medial calf) | `pos-leg-ext-rotated.jpg` | 2 — Tibialis Posterior, Flexor Digitorum Longus (FDL) |
| Supine · leg extended, ankle neutral | `pos-supine-leg-neutral.jpg` | 3 — Tibialis Anterior, Extensor Hallucis Longus (EHL), Extensor Digitorum Longus |
| Supine · leg internally rotated (or lateral decubitus) | `pos-supine-leg-internal-rot.jpg` | 1 — Peroneus Longus |
| Prone foot off bed (or supine, ankle dorsiflexed to expose the sole) | `pos-expose-sole.jpg` | 3 — Flexor Digitorum Brevis (FDB), Adductor Hallucis, Foot Lumbricals |
| Supine · head neutral or turned slightly | `pos-supine-head-neutral.jpg` | 2 — Sternocleidomastoid (SCM), Scalenes (Anterior, Middle, Posterior) |
| Seated upright, arms relaxed (or prone, forehead on hands) | `pos-seated-or-prone-forehead.jpg` | 2 — Upper Trapezius, Levator Scapulae |
| Seated · neck slightly flexed (or prone, forehead on hands) | `pos-cervical-posterior-flexed.jpg` | 5 — Splenius Capitis, Splenius Cervicis, Obliquus Capitis Inferior, Semispinalis Capitis, Longissimus Capitis |
| Seated upright · face forward, relaxed | `pos-seated-face-forward.jpg` | 6 — Frontalis, Corrugator Supercilii, Procerus, Orbicularis Oculi, Mentalis, Platysma |
| Seated upright (or supine) · jaw relaxed | `pos-seated-jaw-relaxed.jpg` | 4 — Temporalis, Masseter, Lateral Pterygoid, Medial Pterygoid |

---

## Upper Extremity  ·  22 muscles  ·  66 photos

### Pectoralis Major  `pec-major`
*Upper Extremity / Trunk — Shoulder adduction, internal rotation*

- [ ] **Patient Position** — `pos-supine-arm-abducted.jpg` · _shared_
  Position the patient supine with the arm abducted 30-45 degrees and externally rotated slightly to open the chest.
- [ ] **Probe + Needle Site** — `pec-major-probe.jpg`
  Patient supine, arm abducted 30°. Place probe transversely on anterior chest, lateral to sternum at 3rd-4th rib. Photo from patient's right side showing probe on chest wall. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse across the anterior chest wall, lateral to the sternal border at the 3rd-4th rib level. Needle: For the clavicular head: insert the needle 2-3 cm inferior to the lateral clavicle, angled slightly caudally at about 30 degrees to the skin surface.
- [ ] **Ultrasound Image** — `pec-major-us.jpg`
  You should see: Position the patient supine with the arm slightly abducted. Place the probe transversely on the anterior chest. The Pectoralis Major appears as the broad, flat superficial muscle layer directly under the subcutaneous fat — it spans most of the anterior chest. Depth ≈ 5.5 cm. ⚠ PNEUMOTHORAX RISK: The lung lies deep to the pectoralis muscles, separated only by a thin layer of intercostal muscle in the spaces between ribs. NEVER use a perpendicular needle…

### Latissimus Dorsi  `lat-dorsi`
*Upper Extremity / Trunk — Shoulder adduction, internal rotation, extension*

- [ ] **Patient Position** — `pos-lateral-decub-arm-abducted.jpg` · _shared_
  Position the patient in lateral decubitus with the affected side up, or prone with arm slightly abducted.
- [ ] **Probe + Needle Site** — `lat-dorsi-probe.jpg`
  Patient lateral decubitus or prone. Place probe transversely across posterior axillary fold. Photo from behind showing probe on lateral back/axilla. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior axillary fold, perpendicular to the long axis of the muscle fibers. Needle: Insert the needle perpendicular to the skin into the mid-belly of the muscle.
- [ ] **Ultrasound Image** — `lat-dorsi-us.jpg`
  You should see: Identify subcutaneous tissue superficially as a hyperechoic layer. The Latissimus Dorsi appears as a broad, flat hypoechoic muscle with a bright fascial envelope — it is the most superficial muscle in the posterior axillary fold. ⚠ The thoracodorsal nerve and artery run along the deep surface of the Latissimus Dorsi — use color Doppler to identify the vascular bundle.

### Subscapularis  `subscapularis`
*Upper Extremity / Trunk — Shoulder internal rotation, Adduction*

- [ ] **Patient Position** — `pos-supine-arm-abducted.jpg` · _shared_
  Position the patient supine or seated with the arm abducted to 45-60 degrees and externally rotated, resting on a support.
- [ ] **Probe + Needle Site** — `subscapularis-probe.jpg`
  Patient supine, arm abducted 45-60° and externally rotated. Place probe parasagitally in anterior axilla. Photo from front showing probe in axillary fold aimed toward scapula. Probe: Low-to-medium frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) in thin patients. Orientation: Parasagittal in the anterior axilla, with the probe face directed toward the costal surface of the scapula. Needle: Insert the needle through the ANTERIOR axillary fold (formed by pec major), directing it posterolaterally toward the anterior (costal) surface of the scapula.
- [ ] **Ultrasound Image** — `subscapularis-us.jpg`
  You should see: Identify the subcutaneous fat and the pectoralis major as the most superficial muscular layer on the anterior chest. Deep to the pectoralis major, the pectoralis minor appears as a smaller triangular hypoechoic muscle. ⚠ The axillary artery, vein, and brachial plexus cords are immediately anterior and lateral to the subscapularis in the axilla — always identify them with Doppler and ensure the…

### Infraspinatus  `infraspinatus`
*Upper Extremity / Trunk — ⚠️ NOT TYPICALLY INJECTED — External rotator (reference only)*

- [ ] **Patient Position** — `pos-seated-or-prone-arm-at-side.jpg` · _shared_
  Position the patient seated, leaning forward, or in a prone position with the arms at the sides.
- [ ] **Probe + Needle Site** — `infraspinatus-probe.jpg`
  Patient seated leaning forward or prone. Place probe transversely across infraspinous fossa, parallel to scapular spine. Photo from behind showing probe below scapular spine. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the infraspinous fossa, parallel to the spine of the scapula. Needle: Insert the needle perpendicular to the skin into the center of the infraspinous fossa, targeting the thickest part of the muscle belly.
- [ ] **Ultrasound Image** — `infraspinatus-us.jpg`
  You should see: Identify the subcutaneous fat and the thin trapezius muscle as the most superficial layers (the trapezius overlies the infraspinatus medially and superiorly). The infraspinatus appears as a large hypoechoic muscle with a multipennate architecture, filling the infraspinous fossa. ⚠ The suprascapular nerve passes through the spinoglenoid notch at the lateral base of the scapular spine — avoid injecting within 2 cm of this landmark.

### Teres Major  `teres-major`
*Upper Extremity / Trunk — Shoulder adduction, Internal rotation, Extension*

- [ ] **Patient Position** — `pos-seated-or-prone-arm-at-side.jpg` · _shared_
  Position the patient seated or prone with the arm adducted at the side.
- [ ] **Probe + Needle Site** — `teres-major-probe.jpg`
  Patient seated or prone, arm at side. Place probe transversely over posterior axillary fold. Photo from behind showing probe on posterior axilla/inferior scapular angle. Probe: High-frequency linear (10-15 MHz) or curvilinear for deeper patients. Orientation: Transverse (short-axis) over the posterior axillary fold, with the patient's arm slightly abducted. Needle: Identify the posterior axillary fold and the inferior angle of the scapula.
- [ ] **Ultrasound Image** — `teres-major-us.jpg`
  You should see: Position the patient seated or prone with the arm slightly abducted. Place the probe on the posterior axillary fold. The Teres Major appears as a flat, broad hypoechoic muscle at the inferior aspect of the posterior axillary fold — in Dr. Bursuc's video it is highlighted with a purple overlay. Depth ≈ 3.5-4.5 cm. ⚠ The circumflex scapular artery and thoracodorsal neurovascular bundle run near the Teres Major — use color Doppler.

### Biceps Brachii  `biceps-brachii`
*Upper Extremity — Elbow flexion, Forearm supination*

- [ ] **Patient Position** — `pos-arm-supinated-on-support.jpg` · _shared_
  Position the patient supine or seated with the arm supinated and elbow extended, resting on a support surface.
- [ ] **Probe + Needle Site** — `biceps-brachii-probe.jpg`
  Patient supine, arm supinated. Place probe transversely on anterior mid-upper arm. Photo from lateral view showing probe across biceps belly. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the anterior arm at the mid-humeral level. Needle: Insert the needle into the bulk of the muscle belly at the mid-humeral level, perpendicular to the skin surface.
- [ ] **Ultrasound Image** — `biceps-brachii-us.jpg`
  You should see: Position the patient supine with the arm slightly abducted and externally rotated. Place the probe transversely on the anterior arm. The Biceps Brachii (short and long heads) appears as the large superficial hypoechoic muscle — it is the most prominent structure in the anterior compartment. Depth ≈ 3.5-4.0 cm. ⚠ The Musculocutaneous Nerve runs between the biceps and brachialis — inject into the superficial belly of the biceps only.

### Brachialis  `brachialis`
*Upper Extremity — Pure elbow flexion*

- [ ] **Patient Position** — `pos-arm-supinated-on-support.jpg` · _shared_
  Position the patient supine or seated with the elbow slightly flexed (about 30 degrees) and the forearm supinated.
- [ ] **Probe + Needle Site** — `brachialis-probe.jpg`
  Patient supine, elbow slightly flexed. Place probe transversely on anterior distal arm, 4-6 cm above elbow crease. Photo showing probe on anterior distal arm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior distal third of the arm, ~4-6 cm proximal to the elbow crease (matching the anterior-through-biceps approach). Needle: Insert the needle perpendicular to the skin through the biceps belly, advancing into the brachialis below it.
- [ ] **Ultrasound Image** — `brachialis-us.jpg`
  You should see: Place the probe transversely across the anterior distal third of the arm, ~4-6 cm proximal to the elbow crease. Identify subcutaneous tissue and the superficial hyperechoic fascia. ⚠ The radial nerve courses along the lateral and posterior humerus in the spiral groove — always identify it before needle insertion.

### Triceps  `triceps`
*Upper Extremity — Elbow extension*

- [ ] **Patient Position** — `pos-seated-elbow-flexed.jpg` · _shared_
  Position the patient seated or prone with the arm resting on a support, elbow flexed to approximately 90 degrees.
- [ ] **Probe + Needle Site** — `triceps-probe.jpg`
  Patient seated or prone. Place probe transversely on posterior mid-upper arm. Photo from behind showing probe across triceps belly. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the posterior arm at the mid-humeral level. Needle: For the long head: insert the needle into the medial portion of the posterior arm at mid-humeral level, perpendicular to the skin.
- [ ] **Ultrasound Image** — `triceps-us.jpg`
  You should see: Position the patient prone or seated with the arm supported. Place the probe transversely on the posterior arm. The Long Head of the Triceps appears as the large, prominent hypoechoic muscle — it is the most superficial and medial of the three triceps heads at the mid-arm level. Depth ≈ 3.5-4.5 cm. ⚠ The Radial Nerve runs in the spiral groove of the humerus, directly deep to the triceps — ALWAYS identify it before injecting.

### Brachioradialis  `brachioradialis`
*Upper Extremity — Elbow flexion (forearm in neutral position)*

- [ ] **Patient Position** — `pos-seated-forearm-neutral.jpg` · _shared_
  Position the patient seated with the forearm resting on a table in neutral position (thumb pointing upward).
- [ ] **Probe + Needle Site** — `brachioradialis-probe.jpg`
  Patient seated, forearm neutral on table. Place probe transversely on lateral proximal forearm, 4-6 cm below lateral epicondyle. Photo from lateral view showing probe on lateral forearm. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the lateral proximal forearm, approximately 4-6 cm distal to the lateral epicondyle. Needle: Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, perpendicular to the skin.
- [ ] **Ultrasound Image** — `brachioradialis-us.jpg`
  You should see: Place the probe transversely on the lateral forearm with the patient's elbow slightly flexed and forearm in neutral (thumb-up) position. Identify the Brachioradialis as the most superficial muscle on the lateral side — it appears as a crescent-shaped hypoechoic structure directly under the subcutaneous tissue. Depth ≈ 3.5 cm. ⚠ The Radial Nerve runs in the intermuscular septum between the Brachioradialis and Brachialis — always identify it before injecting.

### Pronator Teres  `pronator-teres`
*Upper Extremity — Forearm pronation*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated and the elbow extended, resting on a support surface.
- [ ] **Probe + Needle Site** — `pronator-teres-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial proximal forearm, 3-5 cm below medial epicondyle. Photo showing probe on medial proximal forearm near elbow. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the medial proximal forearm, 3-5 cm distal to the medial epicondyle. Needle: Insert the needle 2-3 cm distal to the medial epicondyle, into the bulk of the muscle belly on the medial-to-anterior proximal forearm.
- [ ] **Ultrasound Image** — `pronator-teres-us.jpg`
  You should see: Position the patient with the elbow extended and forearm supinated to stretch the pronator teres. Place the probe transversely on the medial proximal forearm just distal to the elbow crease. Depth ≈ 4.5 cm. ⚠ The median nerve passes between the two heads of the pronator teres — inject into the superficial muscle belly only.

### Flexor Carpi Radialis  `fcr`
*Upper Extremity — Wrist flexion, Radial deviation*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe + Needle Site** — `fcr-probe.jpg`
  Patient seated, forearm supinated on table. Place probe transversely on central volar forearm at proximal-to-mid third. Photo from above showing probe on volar mid-forearm. Probe: High-frequency linear (10-15 MHz), Samsung LA3-16AD recommended. Orientation: Transverse (short-axis) over the central volar forearm, at the proximal-to-mid third. Needle: Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, perpendicular to the skin.
- [ ] **Ultrasound Image** — `fcr-us.jpg`
  You should see: Place the probe transversely on the volar forearm, centered over the palpable FCR tendon. The FCR appears as a superficial, triangular/oval hypoechoic muscle directly under the antebrachial fascia — it is one of the most superficial forearm flexors. Depth ≈ 2.0 cm. ⚠ The Median Nerve lies deep to the FCR — it is typically between the FDS and FDP layers just ulnar to the FCR.

### Flexor Carpi Ulnaris  `fcu`
*Upper Extremity — Wrist flexion, Ulnar deviation*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated or in neutral, resting on a support.
- [ ] **Probe + Needle Site** — `fcu-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial forearm. Photo showing probe on ulnar/medial side of mid-forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the medial forearm, forearm supinated. Needle: Insert the needle into the bulk of the muscle belly at the junction of the proximal and middle thirds of the forearm, on the medial (ulnar) aspect.
- [ ] **Ultrasound Image** — `fcu-us.jpg`
  You should see: Place the probe transversely on the medial (ulnar) side of the forearm with the forearm fully supinated. The FCU is the most superficial and most medial muscle — it appears as a rounded hypoechoic muscle directly under the skin on the ulnar border. Depth ≈ 2.5-3.5 cm. ⚠ The Ulnar Nerve is immediately deep to the FCU — it is the single most important structure to identify before injecting.

### Flexor Digitorum Superficialis  `fds`
*Upper Extremity — Finger flexion at PIP joints, Wrist flexion*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe + Needle Site** — `fds-probe.jpg`
  Patient seated, forearm supinated on table. Place probe transversely on volar forearm, 5-8 cm below medial epicondyle. Photo showing probe on central volar forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the volar forearm, 5-8 cm distal to the medial epicondyle. Needle: Insert the needle at the mid-forearm level, between the FCR and FCU, slightly deeper than the superficial flexor layer.
- [ ] **Ultrasound Image** — `fds-us.jpg`
  You should see: Place the probe transversely on the central volar forearm. The FDS is the broad, flat muscle layer in the superficial volar compartment — it appears as a wide hypoechoic band directly under the subcutaneous tissue and fascia. Depth ≈ 2.0-3.0 cm. ⚠ The Median Nerve lies directly at the deep border of the FDS — inject into the superficial-to-mid portion of the muscle belly.

### Flexor Digitorum Profundus  `fdp`
*Upper Extremity — Finger flexion at DIP joints, Wrist flexion*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated and resting on a flat surface.
- [ ] **Probe + Needle Site** — `fdp-probe.jpg`
  Patient seated, forearm supinated. Place probe transversely on medial-volar mid-forearm. Photo showing probe on deep volar forearm, slightly ulnar. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the medial-volar mid-forearm. Needle: Insert the needle from the medial (ulnar) side of the forearm, just anterior to the palpable subcutaneous ulnar border, at the junction of the proximal and middle thirds of the forearm.
- [ ] **Ultrasound Image** — `fdp-us.jpg`
  You should see: Place the probe transversely on the volar-ulnar forearm at the mid-forearm level. Identify the superficial flexor layer first: the Palmaris Longus (PL) as a small superficial structure, and the FCU on the ulnar border. Depth ≈ 3.0-4.0 cm. ⚠ The Median Nerve lies between FDS and FDP — needle must pass through FDS to reach FDP. Always visualize the median nerve and keep the needle tip away from it.

### Flexor Pollicis Longus  `fpl`
*Upper Extremity — Thumb flexion at IP joint*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient seated with the forearm supinated and resting flat on a support surface.
- [ ] **Probe + Needle Site** — `fpl-probe.jpg`
  Patient seated, forearm supinated flat. Place probe transversely on mid-volar forearm at junction of middle and distal thirds. Photo showing probe on distal volar forearm, radial side. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the mid-volar forearm, at the junction of the middle and distal thirds. Needle: Insert the needle at the mid-forearm level, on the radial side, between the brachioradialis (laterally) and the FCR (medially).
- [ ] **Ultrasound Image** — `fpl-us.jpg`
  You should see: Place the probe transversely on the volar forearm with the patient supinated. Identify the Radius as the large hyperechoic curved bony surface on the lateral (thumb) side. Depth ≈ 3.0-3.5 cm. ⚠ The Anterior Interosseous Nerve (AIN) — a pure motor branch of the median nerve — runs on the anterior surface of the interosseous membrane between FPL and FDP. Do not inject deep…

### Pronator Quadratus  `pronator-quadratus`
*Upper Extremity — Forearm pronation (distal)*

- [ ] **Patient Position** — `pos-seated-forearm-supinated.jpg` · _shared_
  Position the patient supine or seated with the forearm supinated and resting on a support, wrist in neutral.
- [ ] **Probe + Needle Site** — `pronator-quadratus-probe.jpg`
  Patient supine, forearm supinated on table. Place probe transversely on volar distal forearm, 3-5 cm proximal to wrist crease. Photo from volar view showing probe on distal forearm. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal volar forearm, 3-5 cm proximal to the wrist crease. Needle: DORSAL APPROACH (preferred): Insert the needle from the dorsal distal forearm, between the radius and ulna, advancing through the interosseous membrane into pronator quadratus on the volar side.
- [ ] **Ultrasound Image** — `pronator-quadratus-us.jpg`
  You should see: Place the probe transversely on the volar distal forearm, 3-5 cm proximal to the wrist crease. Identify the radius (radial side) and ulna (ulnar side) as bright hyperechoic cortical curves with posterior shadowing — these are your deep lateral landmarks. ⚠ The median nerve and anterior interosseous nerve lie in this plane — always identify the median nerve on US before needle insertion.

### Extensor Carpi Radialis Longus  `ecrl`
*Upper Extremity — Wrist extension, Radial deviation*

- [ ] **Patient Position** — `pos-seated-forearm-pronated.jpg` · _shared_
  Position the patient seated with the forearm pronated and resting on a flat surface to expose the dorsoradial forearm.
- [ ] **Probe + Needle Site** — `ecrl-probe.jpg`
  Patient seated, forearm pronated on table. Place probe transversely on the radiodorsal proximal forearm, 3-5 cm below the lateral epicondyle, over the mobile wad. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse (short-axis) over the radiodorsal proximal forearm, ~3-5 cm distal to the lateral epicondyle. Needle: Insert the needle into the muscle belly in the proximal third of the forearm, perpendicular to the skin.
- [ ] **Ultrasound Image** — `ecrl-us.jpg`
  You should see: Place the probe transversely on the dorsoradial proximal forearm with the forearm pronated. Identify the mobile wad: brachioradialis most superficial/volar, ECRL just dorsal to it, ECRB deep to the ECRL. Depth ≈ 1-2 cm. ⚠ The posterior interosseous nerve (deep motor branch of the radial nerve) passes deep, between the ECRB and the supinator — keep the needle superficial in the ECRL belly.

### Extensor Carpi Radialis Brevis  `ecrb`
*Upper Extremity — Wrist extension*

- [ ] **Patient Position** — `pos-seated-forearm-pronated.jpg` · _shared_
  Position the patient seated with the forearm pronated and resting on a flat surface.
- [ ] **Probe + Needle Site** — `ecrb-probe.jpg`
  Patient seated, forearm pronated. Place probe transversely on the radiodorsal proximal forearm, 4-6 cm below the lateral epicondyle; ECRB lies deep to ECRL over the radius. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the radiodorsal proximal forearm, ~4-6 cm distal to the lateral epicondyle. Needle: Insert the needle into the proximal third of the forearm, angling slightly deeper than the ECRL.
- [ ] **Ultrasound Image** — `ecrb-us.jpg`
  You should see: Place the probe transversely on the dorsoradial proximal forearm, forearm pronated. Identify ECRL superficially and ECRB immediately deep to it, overlying the radius. Depth ≈ 1.5-2.5 cm. ⚠ The posterior interosseous nerve runs in the supinator immediately deep to the ECRB at the radial neck — keep the needle in the superficial-to-mid ECRB belly and never advance to…

### Extensor Carpi Ulnaris  `ecu`
*Upper Extremity — Wrist extension, Ulnar deviation*

- [ ] **Patient Position** — `pos-seated-forearm-pronated.jpg` · _shared_
  Position the patient seated with the forearm pronated and resting on a flat surface to expose the dorsal forearm.
- [ ] **Probe + Needle Site** — `ecu-probe.jpg`
  Patient seated, forearm pronated. Place probe transversely on the dorsoulnar forearm, just radial to the subcutaneous ulnar border. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the dorsoulnar proximal-to-mid forearm, just radial to the ulna. Needle: Insert the needle into the muscle belly in the proximal-to-mid forearm, perpendicular to the skin.
- [ ] **Ultrasound Image** — `ecu-us.jpg`
  You should see: Place the probe transversely on the dorsoulnar forearm with the forearm pronated. Identify the subcutaneous ulna; the ECU is the superficial muscle immediately radial to it. Depth ≈ 1-1.5 cm. ⚠ The posterior interosseous nerve and artery run deep on the interosseous membrane — keep the needle in the superficial ECU belly.

### Extensor Digitorum Communis  `edc`
*Upper Extremity — Finger extension (MCP)*

- [ ] **Patient Position** — `pos-seated-forearm-pronated.jpg` · _shared_
  Position the patient seated with the forearm pronated and resting on a flat surface.
- [ ] **Probe + Needle Site** — `edc-probe.jpg`
  Patient seated, forearm pronated. Place probe transversely on the central dorsal proximal-to-mid forearm, between the radial wrist extensors and the ECU. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the central dorsal proximal-to-mid forearm. Needle: Insert the needle into the muscle belly in the proximal-to-mid forearm, perpendicular to the skin.
- [ ] **Ultrasound Image** — `edc-us.jpg`
  You should see: Place the probe transversely on the central dorsal forearm with the forearm pronated. Identify the EDC as the central superficial extensor, with the radial wrist extensors laterally and the ECU medially. Depth ≈ 1-1.5 cm. ⚠ The posterior interosseous nerve and artery run deep on the interosseous membrane — do not advance the needle to this depth.

### Adductor Pollicis  `adductor-pollicis`
*Upper Extremity — Thumb adduction (thumb-in-palm deformity)*

- [ ] **Patient Position** — `pos-hand-pronated-flat.jpg` · _shared_
  Position the patient with the hand resting on a flat surface, palm down (pronated), with the thumb abducted away from the palm.
- [ ] **Probe + Needle Site** — `adductor-pollicis-probe.jpg`
  Patient hand pronated on table. Place small linear or hockey-stick probe transversely across first web space from dorsal approach. Photo from above showing probe on dorsal thumb web space. Probe: High-frequency linear (10-15 MHz); a hockey-stick probe is helpful in the tight first web space. Orientation: Transverse across the first web space from the dorsal approach. Needle: Insert the needle from the dorsal aspect of the first web space, perpendicular to the plane of the hand.
- [ ] **Ultrasound Image** — `adductor-pollicis-us.jpg`
  You should see: Identify the subcutaneous fat and thin dorsal skin as the most superficial layers. The first dorsal interosseous appears as a superficial hypoechoic muscle on the dorsal-radial aspect of the web space. ⚠ The deep branch of the ulnar nerve passes through the adductor pollicis (between the two heads) — use a superficial injection into the transverse head when possible.

### Hand Lumbricals  `hand-lumbricals`
*Upper Extremity — MCP flexion + IP extension (intrinsic-plus posture)*

- [ ] **Patient Position** — `pos-hand-supinated.jpg` · _shared_
  Position the patient with the hand supinated (palm up), fingers relaxed and slightly extended.
- [ ] **Probe + Needle Site** — `hand-lumbricals-probe.jpg`
  Patient palm-up, fingers relaxed. Place hockey-stick probe longitudinally on palm along the metacarpal. Photo from palmar view showing probe on mid-palm. Probe: High-frequency linear (10-15 MHz); hockey-stick probe preferred for the tight palmar space. Orientation: Longitudinal along the metacarpal shaft on the palmar surface, or transverse across the palm at the MCP level. Needle: PALMAR APPROACH: Insert the needle into the palm just proximal to the MCP joint of the target finger, on the radial side of the flexor tendon.
- [ ] **Ultrasound Image** — `hand-lumbricals-us.jpg`
  You should see: Place the probe longitudinally on the palmar surface along the metacarpal of the target finger. Identify the FDP and FDS tendons as hyperechoic linear structures running along the metacarpal. ⚠ The proper digital nerves and arteries run immediately adjacent to the lumbricals — always identify them before injecting.

---

## Lower Extremity  ·  34 muscles  ·  102 photos

### Paraspinals (Erector Spinae Group)  `paraspinals`
*Lower Extremity / Trunk — Trunk extension spasticity, axial dystonia, camptocormia treatment*

- [ ] **Patient Position** — `pos-prone-pillow-abdomen.jpg` · _shared_
  Position the patient prone with a pillow under the abdomen to reduce lumbar lordosis and open the interlaminar spaces.
- [ ] **Probe + Needle Site** — `paraspinals-probe.jpg`
  Patient prone, pillow under abdomen. Place curvilinear probe parasagittally 2-3 cm lateral to midline spinous processes, or transversely across the spine at the target level. Photo from behind showing probe on the paraspinal region. Probe: Curvilinear (5-8 MHz); high-frequency linear (10-15 MHz) may suffice in thin patients at thoracic levels. Orientation: Parasagittal along the paraspinal muscle mass, 2-3 cm lateral to the midline; or transverse (axial) across the spine at each target level. Needle: Insert the needle perpendicular to the skin or at a slight lateral-to-medial angle, advancing into the muscle belly.
- [ ] **Ultrasound Image** — `paraspinals-us.jpg`
  You should see: PARASAGITTAL VIEW: Place the probe longitudinally (parasagittal), 2-3 cm lateral to the midline spinous processes. The transverse processes appear as a series of hyperechoic humps… The Erector Spinae muscles (iliocostalis laterally, longissimus medially, spinalis most medially) appear as a large hypoechoic muscle mass superficial to the transverse processes. ⚠ SPINAL CANAL PENETRATION RISK: The spinal canal lies immediately deep to the laminae. NEVER advance the needle medially past the lamina or between the laminae into the…

### Quadratus Lumborum  `quadratus-lumborum`
*Lower Extremity / Trunk — Pelvic hiking, trunk lateral flexion*

- [ ] **Patient Position** — `pos-prone-pillow-abdomen.jpg` · _shared_
  Position the patient prone with a pillow under the abdomen to reduce lumbar lordosis.
- [ ] **Probe + Needle Site** — `quadratus-lumborum-probe.jpg`
  Patient prone, pillow under abdomen. Place curvilinear probe transversely on flank, just above iliac crest. Photo from side showing probe on lateral flank. Probe: Curvilinear (5-8 MHz). Orientation: Transverse (axial) across the flank, just superior to the iliac crest, lateral to the erector spinae. Needle: Insert the needle perpendicular to the skin, angling slightly medially toward the transverse processes of L3/L4.
- [ ] **Ultrasound Image** — `quadratus-lumborum-us.jpg`
  You should see: Identify the subcutaneous fat and thoracolumbar fascia superficially as hyperechoic layers. The Erector Spinae group appears as a large hypoechoic muscle mass medially, adjacent to the spinous processes. ⚠ The kidneys lie anterior and deep to the QL — always identify the anterior border of the muscle and do not advance beyond it.

### Rectus Abdominis  `rectus-abdominis`
*Lower Extremity / Trunk — Trunk flexion (camptocormia / forward-flexed posture)*

- [ ] **Patient Position** — `pos-supine-knees-bent.jpg` · _shared_
  Position the patient supine with the knees slightly bent to relax the abdominal wall.
- [ ] **Probe + Needle Site** — `rectus-abdominis-probe.jpg`
  Patient supine, knees bent. Place linear probe transversely on the anterior abdomen, just lateral to midline at the umbilical level. Photo from the patient's side showing probe on the abdomen. Probe: High-frequency linear (10-15 MHz); curvilinear (5-8 MHz) for larger body habitus. Orientation: Transverse across the anterior abdominal wall, centered over the rectus abdominis, lateral to the midline. Needle: Inject at 2-4 sites distributed along the length of the muscle — typically at the supra-umbilical and infra-umbilical levels bilaterally.
- [ ] **Ultrasound Image** — `rectus-abdominis-us.jpg`
  You should see: Place the probe transversely on the anterior abdominal wall, just lateral to the midline at the level of the umbilicus. The subcutaneous fat appears as a superficial hypoechoic layer of variable thickness. ⚠ PERITONEAL PENETRATION RISK: The peritoneum and bowel lie immediately deep to the posterior rectus sheath. Never advance the needle past the posterior fascial boundary. Use a…

### Obliques (External & Internal)  `obliques`
*Lower Extremity / Trunk — Trunk rotation, lateral flexion*

- [ ] **Patient Position** — `pos-supine-or-lat-decub.jpg` · _shared_
  Position the patient supine or in the lateral decubitus position with the target side up.
- [ ] **Probe + Needle Site** — `obliques-probe.jpg`
  Patient supine or lateral decubitus. Place linear probe transversely on the lateral abdominal wall between the costal margin and iliac crest, along the mid-axillary line. Photo from the side showing probe on the flank. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral abdominal wall, between the costal margin and iliac crest, along or posterior to the mid-axillary line. Needle: Target the external oblique and/or internal oblique depending on the clinical pattern — typically inject the internal oblique as it is the primary trunk rotator.
- [ ] **Ultrasound Image** — `obliques-us.jpg`
  You should see: Place the probe transversely on the lateral abdominal wall at the level of the umbilicus, along the mid-axillary line. Identify the three distinct hypoechoic muscle layers separated by bright hyperechoic fascial planes — this is the classic 'three-layer sandwich' view. ⚠ INTERCOSTAL NERVE INJURY RISK: The thoracoabdominal nerves (T7-T12) travel in the fascial plane between the internal oblique and transversus abdominis. Avoid injecting directly…

### Iliopsoas  `iliopsoas`
*Lower Extremity — Hip flexion*

- [ ] **Patient Position** — `pos-supine-hip-neutral.jpg` · _shared_
  Position the patient supine with the hip in neutral position and the knee extended.
- [ ] **Probe + Needle Site** — `iliopsoas-probe.jpg`
  Patient supine, hip neutral. Place curvilinear probe transversely on proximal anterior thigh, 2-3 cm below inguinal ligament, lateral to femoral vessels. Photo from front showing probe in inguinal/proximal thigh region. Probe: Low-frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) in thin patients. Orientation: Transverse across the proximal anterior thigh, 2-3 cm distal to the inguinal ligament, lateral to the femoral vessels. Needle: Under ultrasound guidance, insert the needle lateral to the femoral vessels and advance toward the iliopsoas muscle belly.
- [ ] **Ultrasound Image** — `iliopsoas-us.jpg`
  You should see: Identify subcutaneous fat, the fascia lata, and the Sartorius muscle as the most superficial structures laterally. Medially, identify the Femoral Artery (pulsating) and Femoral Vein (compressible) within the femoral triangle. ⚠ The femoral artery and vein lie medial to the iliopsoas — always use color Doppler to map the vessels before needle insertion.

### Gluteus Maximus  `gluteus-maximus`
*Lower Extremity — Hip extension, external rotation*

- [ ] **Patient Position** — `pos-prone-or-lat-decub-buttock.jpg` · _shared_
  Position the patient prone or in lateral decubitus with the affected side up.
- [ ] **Probe + Needle Site** — `gluteus-maximus-probe.jpg`
  Patient prone. Place curvilinear probe transversely on upper-outer quadrant of buttock. Photo from behind showing probe position on buttock. Probe: Curvilinear (5-8 MHz). Orientation: Transverse across the mid-buttock, centered on the gluteus maximus belly between the sacrum and the greater trochanter. Needle: Insert the needle perpendicular to the skin into the muscle bulk at multiple sites distributed across the belly (3-4 sites for a large muscle).
- [ ] **Ultrasound Image** — `gluteus-maximus-us.jpg`
  You should see: Identify the thick subcutaneous fat layer, which can be substantial in this region. The Gluteus Maximus appears as a large, thick hypoechoic muscle with characteristic coarse fiber texture and bright fascial borders. ⚠ The sciatic nerve exits the greater sciatic foramen deep to the piriformis and runs deep to the gluteus maximus — target the thick mid-belly and stay lateral to a line from the…

### Piriformis  `piriformis`
*Lower Extremity — Hip external rotation, abduction*

- [ ] **Patient Position** — `pos-prone-pillow-pelvis.jpg` · _shared_
  Position the patient prone with a pillow under the pelvis to slightly flex the hips.
- [ ] **Probe + Needle Site** — `piriformis-probe.jpg`
  Patient prone, pillow under pelvis. Place curvilinear probe transversely along PSIS-to-greater-trochanter line, at midpoint. Photo showing probe between PSIS and GT. Probe: Curvilinear (5-8 MHz). Orientation: Transverse along the line from PSIS to Greater Trochanter, centered at the midpoint. Needle: Insert the needle perpendicular to the skin surface at the midpoint.
- [ ] **Ultrasound Image** — `piriformis-us.jpg`
  You should see: Identify the subcutaneous tissue and the thick Gluteus Maximus as a large superficial hypoechoic muscle. Deep to the Gluteus Maximus, identify the hyperechoic fascial plane — the piriformis lies just below this. ⚠ The sciatic nerve exits immediately inferior to the piriformis — always identify it on ultrasound before injecting.

### Tensor Fasciae Latae (TFL)  `tfl`
*Lower Extremity — Hip flexion, abduction, internal rotation*

- [ ] **Patient Position** — `pos-supine-or-lat-decub.jpg` · _shared_
  Position the patient supine or in lateral decubitus with the affected side up.
- [ ] **Probe + Needle Site** — `tfl-probe.jpg`
  Patient supine or lateral. Place probe transversely on anterolateral hip, 2-3 cm below ASIS. Photo showing probe just distal to ASIS on lateral hip. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterolateral hip, 2-3 cm distal to the ASIS. Needle: Insert the needle perpendicular to the skin surface directly into the palpated muscle belly.
- [ ] **Ultrasound Image** — `tfl-us.jpg`
  You should see: Identify the subcutaneous fat as a superficial hyperechoic layer — it is usually thin in this region. The TFL appears as a small, oval hypoechoic muscle belly with a bright fascial envelope, superficial and anterior. ⚠ The lateral femoral cutaneous nerve runs near the ASIS — avoid injecting too close to the ASIS to prevent nerve injury.

### Pectineus  `pectineus`
*Lower Extremity — Hip flexion, Hip adduction*

- [ ] **Patient Position** — `pos-supine-frog-leg.jpg` · _shared_
  Position the patient supine with the hip slightly abducted and externally rotated (frog-leg) to open the groin and femoral triangle.
- [ ] **Probe + Needle Site** — `pectineus-probe.jpg`
  Patient supine, hip abducted/externally rotated. Place probe transversely in the groin just below the inguinal crease; identify the femoral vessels (Doppler) and the pectineus just medial to the femoral vein. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the femoral triangle, just distal to the inguinal ligament. Needle: Insert the needle from MEDIAL to lateral into the pectineus belly, keeping the femoral vessels in view at all times.
- [ ] **Ultrasound Image** — `pectineus-us.jpg`
  You should see: Place the probe transversely in the groin just below the inguinal crease and identify the femoral artery and vein with color Doppler. Medial to the femoral vein, identify the pectineus as a flat muscle overlying the superior pubic ramus. Depth ≈ 1.5-3 cm. ⚠ The femoral vein, artery, and nerve lie immediately lateral in the femoral triangle — identify them with color Doppler and approach from MEDIAL to lateral; aspirate before…

### Adductor Longus  `adductor-longus`
*Lower Extremity — Hip adduction*

- [ ] **Patient Position** — `pos-supine-frog-leg.jpg` · _shared_
  Position the patient supine with the hip slightly abducted and externally rotated, and the knee flexed with the sole of the foot resting against the opposite knee (frog-leg position).
- [ ] **Probe + Needle Site** — `adductor-longus-probe.jpg`
  Patient supine, hip slightly abducted and externally rotated. Place probe transversely on proximal medial thigh, 3-5 cm below pubic tubercle. Photo showing probe on inner proximal thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh, 3-5 cm distal to the pubic tubercle. Needle: Insert the needle perpendicular to the skin into the muscle belly just lateral to the palpable tendon.
- [ ] **Ultrasound Image** — `adductor-longus-us.jpg`
  You should see: Identify subcutaneous fat and the fascia lata as the superficial layers. The Adductor Longus appears as a triangular or oval hypoechoic muscle belly immediately deep to the fascia — it is the most superficial adductor at this level. ⚠ The femoral artery and vein lie lateral to the adductor longus in the femoral triangle — always confirm their location with color Doppler before injecting.

### Adductor Brevis  `adductor-brevis`
*Lower Extremity — Hip adduction (deep, short adductor)*

- [ ] **Patient Position** — `pos-supine-frog-leg.jpg` · _shared_
  Position the patient supine with the hip abducted 30-45 degrees, knee flexed, and the leg externally rotated (frog-leg position).
- [ ] **Probe + Needle Site** — `adductor-brevis-probe.jpg`
  Patient supine, frog-leg position. Place probe transversely on proximal medial thigh at the adductor longus origin. Photo from medial view showing probe on inner thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh, at the level of the adductor longus origin, perpendicular to the muscle fibers. Needle: USG is strongly recommended — insert the needle through the adductor longus to reach the adductor brevis layer deep to it.
- [ ] **Ultrasound Image** — `adductor-brevis-us.jpg`
  You should see: Place the probe transversely on the proximal medial thigh with the hip abducted. Identify the adductor longus as the most superficial adductor — a large hypoechoic muscle belly with a prominent proximal tendon originating from the pubic tubercle. ⚠ The anterior branch of the obturator nerve runs between adductor longus and brevis — identify it and keep the needle tip within the muscle belly, not in the inter-fascial plane.

### Adductor Magnus  `adductor-magnus`
*Lower Extremity — Hip adduction, Hip extension*

- [ ] **Patient Position** — `pos-prone-legs-apart.jpg` · _shared_
  Position the patient prone with the legs slightly apart, or supine with the hip abducted and externally rotated.
- [ ] **Probe + Needle Site** — `adductor-magnus-probe.jpg`
  Patient prone, legs slightly apart. Place probe transversely on posteromedial thigh at junction of middle and distal thirds. Photo from behind showing probe on posteromedial distal thigh. Probe: Low-frequency curvilinear (5-8 MHz) or high-frequency linear (10-15 MHz) for thinner patients. Orientation: Transverse across the posteromedial thigh at the junction of the middle and distal thirds. Needle: Insert the needle from the posteromedial aspect of the thigh, angling slightly anteriorly.
- [ ] **Ultrasound Image** — `adductor-magnus-us.jpg`
  You should see: Identify subcutaneous fat and the deep fascia as the superficial layers. The Gracilis and Adductor Longus appear as superficial hypoechoic muscles in the medial compartment. ⚠ The profunda femoris artery and vein run between the adductor longus and adductor magnus — use color Doppler to identify and avoid these vessels.

### Gracilis  `gracilis`
*Lower Extremity — Hip adduction + knee flexion (crosses both joints)*

- [ ] **Patient Position** — `pos-supine-frog-leg.jpg` · _shared_
  Position the patient supine with the hip abducted 30-45 degrees and knee slightly flexed.
- [ ] **Probe + Needle Site** — `gracilis-probe.jpg`
  Patient supine, frog-leg position. Place probe transversely on proximal medial thigh. Photo from medial view showing probe on inner thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial thigh. Needle: Insert the needle perpendicular to the skin on the medial thigh into the superficial muscle belly.
- [ ] **Ultrasound Image** — `gracilis-us.jpg`
  You should see: Place the probe transversely on the proximal medial thigh with the hip abducted. Gracilis appears as a thin, flat hypoechoic muscle strap on the most medial and superficial aspect of the thigh, directly under the subcutaneous tissue. ⚠ The saphenous nerve and great saphenous vein run in the subsartorial canal anterior to gracilis — identify them if visible and avoid.

### Rectus Femoris  `rectus-femoris`
*Lower Extremity — Stiff knee gait, Knee extension*

- [ ] **Patient Position** — `pos-supine-knee-extended.jpg` · _shared_
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe + Needle Site** — `rectus-femoris-probe.jpg`
  Patient supine, knee extended. Place probe transversely on anterior mid-thigh. Photo from lateral view showing probe across anterior thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior mid-thigh. Needle: Insert the needle perpendicular to the skin into the bulk of the muscle belly at mid-thigh.
- [ ] **Ultrasound Image** — `rectus-femoris-us.jpg`
  You should see: Identify subcutaneous fat and the superficial fascia (fascia lata) as the most superficial hyperechoic layers. The Rectus Femoris appears as a prominent oval hypoechoic muscle belly in the center of the anterior thigh, with a bright fascial envelope. ⚠ The femoral nerve, artery, and vein lie in the femoral triangle (medial proximal thigh) — avoid the proximal medial approach.

### Vastus Lateralis  `vastus-lateralis`
*Lower Extremity — Knee extension*

- [ ] **Patient Position** — `pos-supine-or-lat-decub.jpg` · _shared_
  Position the patient supine or in lateral decubitus with the affected side up.
- [ ] **Probe + Needle Site** — `vastus-lateralis-probe.jpg`
  Patient supine or lateral. Place probe transversely on lateral mid-thigh. Photo from lateral view showing probe on outer thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral mid-thigh. Needle: Insert the needle through the IT band, angling slightly anteriorly to enter the VL muscle belly.
- [ ] **Ultrasound Image** — `vastus-lateralis-us.jpg`
  You should see: Identify subcutaneous fat and the fascia lata (including the IT band component) as hyperechoic superficial layers. The Vastus Lateralis appears as a large hypoechoic muscle deep to the IT band, wrapping around the lateral femur. ⚠ The descending branch of the lateral circumflex femoral artery runs in the intermuscular septum between VL and RF — use color Doppler.

### Vastus Medialis  `vastus-medialis`
*Lower Extremity — Knee extension (distal stabilization)*

- [ ] **Patient Position** — `pos-supine-knee-extended.jpg` · _shared_
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe + Needle Site** — `vastus-medialis-probe.jpg`
  Patient supine, knee extended. Place probe transversely on distal medial thigh, just above patella (VMO area). Photo showing probe on medial knee/thigh junction. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal medial thigh, just proximal to the patella. Needle: Insert the needle perpendicular to the skin into the bulk of the VMO muscle belly.
- [ ] **Ultrasound Image** — `vastus-medialis-us.jpg`
  You should see: Identify subcutaneous tissue and the superficial fascia as hyperechoic layers. The Sartorius appears as a thin, strap-like hypoechoic muscle superficially on the medial side. ⚠ The saphenous nerve and descending genicular artery travel in the adductor canal deep to the Sartorius — do not inject too medially or deeply.

### Vastus Intermedius  `vastus-intermedius`
*Lower Extremity — Knee extension*

- [ ] **Patient Position** — `pos-supine-knee-extended.jpg` · _shared_
  Position the patient supine with the knee extended and the thigh relaxed.
- [ ] **Probe + Needle Site** — `vastus-intermedius-probe.jpg`
  Patient supine, knee extended. Place probe transversely on anterior proximal thigh (same region as rectus femoris but deeper target). Photo from front showing probe on anterior thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterior proximal-to-mid thigh. Needle: Insert the needle perpendicular to the skin through the center of the Rectus Femoris.
- [ ] **Ultrasound Image** — `vastus-intermedius-us.jpg`
  You should see: Identify subcutaneous fat and fascia lata superficially. The Rectus Femoris appears as the superficial oval hypoechoic muscle in the center of the field. ⚠ The descending branch of the lateral circumflex femoral artery runs laterally between the muscles — use color Doppler before inserting.

### Biceps Femoris  `biceps-femoris`
*Lower Extremity — Knee flexion, Hip extension*

- [ ] **Patient Position** — `pos-prone-knee-flexed.jpg` · _shared_
  Position the patient prone with the knee slightly flexed over a pillow or bolster.
- [ ] **Probe + Needle Site** — `biceps-femoris-probe.jpg`
  Patient prone, knee flexed over pillow. Place probe transversely on lateral posterior thigh at junction of proximal and middle thirds. Photo from behind showing probe on posterolateral thigh. Probe: High-frequency linear (10-15 MHz) or low-frequency curvilinear (5-8 MHz) for deeper targets. Orientation: Transverse across the lateral posterior thigh at the junction of the proximal and middle thirds. Needle: Insert the needle perpendicular to the skin into the lateral muscle belly of the posterior thigh.
- [ ] **Ultrasound Image** — `biceps-femoris-us.jpg`
  You should see: Identify subcutaneous fat and the deep fascia (fascia lata) as the superficial layers. The Biceps Femoris Long Head appears as a large hypoechoic muscle belly in the lateral posterior thigh, superficial to the short head. ⚠ The sciatic nerve courses medial and deep to the biceps femoris long head — always identify it with ultrasound before injecting.

### Semitendinosus  `semitendinosus`
*Lower Extremity — Knee flexion*

- [ ] **Patient Position** — `pos-prone-knee-flexed.jpg` · _shared_
  Position the patient prone with the knee slightly flexed (place a pillow under the ankle).
- [ ] **Probe + Needle Site** — `semitendinosus-probe.jpg`
  Patient prone, knee slightly flexed. Place probe transversely on posterior mid-thigh. Photo from behind showing probe on posterior thigh, medial side. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior mid-thigh. Needle: Insert the needle perpendicular to the skin into the mid-belly of the muscle (proximal to the tendinous portion).
- [ ] **Ultrasound Image** — `semitendinosus-us.jpg`
  You should see: Identify subcutaneous tissue and the deep fascia superficially. The Semitendinosus appears as a round or oval hypoechoic muscle belly in the medial posterior thigh — it is the most superficial of the medial hamstrings. ⚠ The sciatic nerve runs laterally in the posterior thigh — it is generally safe with a medial injection approach.

### Semimembranosus  `semimembranosus`
*Lower Extremity — Knee flexion*

- [ ] **Patient Position** — `pos-prone-knee-flexed.jpg` · _shared_
  Position the patient prone with the knee slightly flexed (place a pillow under the ankle).
- [ ] **Probe + Needle Site** — `semimembranosus-probe.jpg`
  Patient prone, knee slightly flexed. Place probe transversely on posterior medial thigh at mid-to-distal level. Photo from behind showing probe on posteromedial thigh. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior medial thigh at mid-to-distal level. Needle: Insert the needle from the medial aspect, angling slightly posteriorly and laterally to pass deep to the Semitendinosus.
- [ ] **Ultrasound Image** — `semimembranosus-us.jpg`
  You should see: Identify subcutaneous tissue and the deep fascia as superficial hyperechoic layers. The Semitendinosus appears as a round or oval hypoechoic muscle belly superficially (or its hyperechoic tendon distally). ⚠ The sciatic nerve runs in the lateral posterior thigh — a medial approach avoids it, but always verify its position.

### Gastrocnemius (Medial)  `gastrocnemius-medial`
*Lower Extremity — Equinus deformity, Plantarflexion*

- [ ] **Patient Position** — `pos-prone-feet-off-bed.jpg` · _shared_
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe + Needle Site** — `gastrocnemius-medial-probe.jpg`
  Patient prone, feet off bed edge. Place probe transversely on proximal medial calf, 2-3 cm below popliteal crease. Photo from behind showing probe on medial proximal calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal medial posterior calf, 2-3 cm distal to the popliteal crease. Needle: Insert the needle perpendicular to the skin into the bulk of the medial gastrocnemius belly.
- [ ] **Ultrasound Image** — `gastrocnemius-medial-us.jpg`
  You should see: Identify subcutaneous fat and the superficial fascia. The medial Gastrocnemius appears as a large, thick hypoechoic muscle with a pennate fiber pattern and bright fascial borders. ⚠ The sural nerve and small saphenous vein run in the midline between the two gastrocnemius heads — avoid the midline.

### Gastrocnemius (Lateral)  `gastrocnemius-lateral`
*Lower Extremity — Equinus deformity, Plantarflexion*

- [ ] **Patient Position** — `pos-prone-feet-off-bed.jpg` · _shared_
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe + Needle Site** — `gastrocnemius-lateral-probe.jpg`
  Patient prone, feet off bed edge. Place probe transversely on proximal lateral calf, 2-3 cm below popliteal crease. Photo from behind showing probe on lateral proximal calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal lateral posterior calf, 2-3 cm distal to the popliteal crease. Needle: Insert the needle perpendicular to the skin into the lateral muscle belly.
- [ ] **Ultrasound Image** — `gastrocnemius-lateral-us.jpg`
  You should see: Identify subcutaneous fat and superficial fascia. The lateral Gastrocnemius appears as a hypoechoic muscle belly — it is typically thinner and narrower than the medial head. ⚠ The common peroneal nerve wraps around the fibular head — always identify its position and stay medial to the fibular head.

### Soleus (Medial)  `soleus-medial`
*Lower Extremity — Plantarflexion*

- [ ] **Patient Position** — `pos-prone-feet-off-bed.jpg` · _shared_
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe + Needle Site** — `soleus-medial-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on medial mid-calf, just posterior to tibial border. Photo from behind/medial showing probe on mid-calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the medial mid-calf, 1-2 cm posterior to the tibial border. Needle: Insert the needle perpendicular to the skin, directed slightly laterally and posteriorly.
- [ ] **Ultrasound Image** — `soleus-medial-us.jpg`
  You should see: Identify subcutaneous tissue and superficial fascia. The Gastrocnemius (or its aponeurosis distally) appears as a superficial hypoechoic layer with a bright fascial border. ⚠ The posterior tibial artery and tibial nerve run deep to the soleus in the deep posterior compartment — do not advance the needle through the soleus.

### Soleus (Lateral)  `soleus-lateral`
*Lower Extremity — Plantarflexion*

- [ ] **Patient Position** — `pos-prone-feet-off-bed.jpg` · _shared_
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe + Needle Site** — `soleus-lateral-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on lateral mid-calf. Photo from behind showing probe on lateral mid-calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral mid-calf. Needle: Insert the needle perpendicular to the skin into this lateral soleus bulge at mid-calf level.
- [ ] **Ultrasound Image** — `soleus-lateral-us.jpg`
  You should see: Identify subcutaneous tissue and superficial fascia. The lateral Gastrocnemius (or its aponeurosis) appears as a superficial hypoechoic layer, tapering distally. ⚠ The peroneal artery runs between the soleus and tibialis posterior in the deep compartment — use color Doppler.

### Tibialis Posterior  `tibialis-posterior`
*Lower Extremity — Equinovarus (Plantarflexion + Inversion)*

- [ ] **Patient Position** — `pos-leg-ext-rotated.jpg` · _shared_
  Position the patient prone or supine with the leg externally rotated.
- [ ] **Probe + Needle Site** — `tibialis-posterior-probe.jpg`
  Patient prone or supine with leg externally rotated. Place probe transversely on medial mid-leg, just behind tibia. Photo from medial side showing probe behind tibial border. Probe: High-frequency linear (10-15 MHz) in thin patients; lower-frequency linear (6-9 MHz) or curvilinear (5-8 MHz) is often required in average/larger patients due to muscle depth (3-5+ cm). Orientation: Transverse across the medial mid-leg, posterior to the tibial border. Needle: Insert the needle directed posterolaterally, sliding along the posterior aspect of the tibia.
- [ ] **Ultrasound Image** — `tibialis-posterior-us.jpg`
  You should see: Identify subcutaneous tissue and the crural fascia superficially. The Gastrocnemius and Soleus form the superficial posterior compartment — they appear as hypoechoic muscle layers with a fascial septum between them. ⚠ The posterior tibial artery and tibial nerve run in the deep posterior compartment directly superficial to the tibialis posterior — always identify them with color Doppler.

### Flexor Digitorum Longus (FDL)  `fdl`
*Lower Extremity — Claw toes, toe flexion*

- [ ] **Patient Position** — `pos-leg-ext-rotated.jpg` · _shared_
  Position the patient prone or supine with the leg externally rotated to expose the medial calf.
- [ ] **Probe + Needle Site** — `fdl-probe.jpg`
  Patient prone or supine with leg externally rotated. Place probe transversely on medial distal leg, just behind tibial border. Photo showing probe on posteromedial distal leg. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the medial distal leg, just posterior to the tibial border. Needle: Insert the needle perpendicular to the skin, directing it toward the posterior aspect of the tibia and fibula.
- [ ] **Ultrasound Image** — `fdl-us.jpg`
  You should see: Identify subcutaneous tissue and the superficial crural fascia. The Gastrocnemius/Soleus complex is visible superficially as a hypoechoic muscle layer (or tendon distally). ⚠ The posterior tibial artery and tibial nerve run immediately adjacent to the FDL — always identify them with color Doppler before injecting.

### Flexor Hallucis Longus (FHL)  `fhl`
*Lower Extremity — Claw hallux, Equinovarus support*

- [ ] **Patient Position** — `pos-prone-feet-off-bed.jpg` · _shared_
  Position the patient prone with the feet hanging off the edge of the bed.
- [ ] **Probe + Needle Site** — `fhl-probe.jpg`
  Patient prone, feet off edge. Place probe transversely on distal posterolateral calf, adjacent to fibula. Photo from behind showing probe on distal lateral calf near fibula. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal posterolateral calf, adjacent to the fibula. Needle: Insert the needle lateral to the Achilles tendon, directed toward the posterior fibula.
- [ ] **Ultrasound Image** — `fhl-us.jpg`
  You should see: Identify subcutaneous tissue and the Soleus muscle/aponeurosis superficially. The fibula appears as a bright hyperechoic cortical line laterally with posterior acoustic shadowing. ⚠ The posterior tibial artery and tibial nerve lie medial to the FHL — always use a lateral approach.

### Tibialis Anterior  `tibialis-anterior`
*Lower Extremity — ⚠️ NOT TYPICALLY INJECTED — Dorsiflexor (reference only)*

- [ ] **Patient Position** — `pos-supine-leg-neutral.jpg` · _shared_
  Position the patient supine with the leg extended and the ankle in neutral.
- [ ] **Probe + Needle Site** — `tibialis-anterior-probe.jpg`
  Patient supine, leg extended. Place probe transversely on proximal anterolateral leg, 2 cm lateral to tibial crest. Photo from front showing probe on anterior shin. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the proximal anterolateral leg, 2 cm lateral to the tibial crest. Needle: Insert the needle perpendicular to the skin into the largest muscle bulk, approximately 2 cm lateral to the tibial crest.
- [ ] **Ultrasound Image** — `tibialis-anterior-us.jpg`
  You should see: Identify subcutaneous tissue — it is thin on the anterior leg. The Tibialis Anterior appears as a large hypoechoic muscle with a prominent central tendon in the distal portion, located immediately lateral to the tibial cortex. ⚠ The anterior tibial artery and deep peroneal nerve run deep to the muscle on the interosseous membrane — do not advance the needle to this depth.

### Extensor Hallucis Longus (EHL)  `ehl`
*Lower Extremity — Hallux extension, hitchhiking thumb sign*

- [ ] **Patient Position** — `pos-supine-leg-neutral.jpg` · _shared_
  Position the patient supine with the leg extended and the ankle in neutral.
- [ ] **Probe + Needle Site** — `ehl-probe.jpg`
  Patient supine, leg extended. Place probe transversely on distal anterolateral leg, ~10 cm above ankle. Photo from front showing probe on anterior distal leg. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the distal anterolateral leg, approximately 10 cm proximal to the ankle. Needle: Insert the needle perpendicular to the skin into the EHL muscle belly.
- [ ] **Ultrasound Image** — `ehl-us.jpg`
  You should see: Identify the thin subcutaneous tissue on the anterior leg. The Tibialis Anterior is the large hypoechoic muscle medially, adjacent to the tibial cortex. ⚠ The anterior tibial artery and deep peroneal nerve run immediately adjacent to the EHL — identify them with color Doppler before injecting.

### Extensor Digitorum Longus  `edl`
*Lower Extremity — Toe extension, Ankle dorsiflexion*

- [ ] **Patient Position** — `pos-supine-leg-neutral.jpg` · _shared_
  Position the patient supine with the leg in neutral position and the foot relaxed.
- [ ] **Probe + Needle Site** — `edl-probe.jpg`
  Patient supine, leg neutral. Place probe transversely on anterolateral proximal leg at proximal-middle third junction. Photo from anterolateral view showing probe on outer upper shin. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the anterolateral proximal leg, at the junction of the proximal and middle thirds. Needle: Insert the needle perpendicular to the skin into the anterolateral muscle belly.
- [ ] **Ultrasound Image** — `edl-us.jpg`
  You should see: Identify subcutaneous fat and the crural fascia as the superficial layers. The Tibialis Anterior appears as a large hypoechoic muscle in the anteromedial compartment, lying directly on the lateral tibial surface and the interosseous membrane. ⚠ The deep peroneal nerve and anterior tibial artery lie on the interosseous membrane between the tibialis anterior and EDL — use color Doppler to identify the artery and avoid this…

### Peroneus Longus  `peroneus-longus`
*Lower Extremity — Ankle eversion, Ankle plantarflexion*

- [ ] **Patient Position** — `pos-supine-leg-internal-rot.jpg` · _shared_
  Position the patient supine with the leg internally rotated to expose the lateral compartment, or in a lateral decubitus position with the affected side up.
- [ ] **Probe + Needle Site** — `peroneus-longus-probe.jpg`
  Patient supine, leg internally rotated. Place probe transversely on lateral proximal leg, 5-8 cm below fibular head. Photo from lateral view showing probe on lateral upper calf. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral proximal leg, 5-8 cm distal to the fibular head. Needle: Insert the needle perpendicular to the skin into the lateral muscle belly, aiming toward the fibula.
- [ ] **Ultrasound Image** — `peroneus-longus-us.jpg`
  You should see: Identify subcutaneous fat and the crural fascia as the superficial layers. The Peroneus Longus appears as a hypoechoic muscle belly superficial and posterior in the lateral compartment, lying directly on the lateral fibular surface. ⚠ The common peroneal nerve wraps around the fibular neck just distal to the fibular head — never inject within 3 cm of the fibular head.

### Flexor Digitorum Brevis (FDB)  `fdb`
*Lower Extremity — Toe flexion (plantar)*

- [ ] **Patient Position** — `pos-expose-sole.jpg` · _shared_
  Position the patient prone with the foot hanging off the edge of the bed, or supine with the ankle dorsiflexed to expose the sole.
- [ ] **Probe + Needle Site** — `fdb-probe.jpg`
  Patient prone, foot hanging off bed. Place probe longitudinally on plantar midfoot from calcaneus toward toes. Photo from plantar view showing probe on sole of foot. Probe: High-frequency linear (10-15 MHz). Orientation: Longitudinal (sagittal) along the midline of the plantar foot, from calcaneus toward the toes. Needle: Insert the needle perpendicular to the plantar skin surface.
- [ ] **Ultrasound Image** — `fdb-us.jpg`
  You should see: Identify the thick hyperechoic plantar fascia as the most superficial fibrous layer on the sole. Deep to the plantar fascia, the FDB appears as a hypoechoic muscle belly with a fibrillar pattern. ⚠ The medial and lateral plantar nerves and arteries run deep to the FDB — do not advance too deeply.

### Adductor Hallucis  `add-hallucis`
*Lower Extremity — Hallux adduction, transverse arch collapse*

- [ ] **Patient Position** — `pos-expose-sole.jpg` · _shared_
  Position the patient supine with the foot accessible, or prone with the foot dorsiflexed.
- [ ] **Probe + Needle Site** — `add-hallucis-probe.jpg`
  Patient supine, foot accessible. Place probe longitudinally along 1st-2nd intermetatarsal space on plantar surface. Photo showing probe on plantar forefoot between 1st and 2nd metatarsals. Probe: High-frequency linear (10-15 MHz). Orientation: Longitudinal along the 1st-2nd intermetatarsal space on the plantar surface, or transverse across the metatarsal heads. Needle: A dorsal approach is an alternative: insert the needle from the dorsum of the foot between the 1st and 2nd metatarsal shafts, directed plantarward.
- [ ] **Ultrasound Image** — `add-hallucis-us.jpg`
  You should see: Identify the hyperechoic cortex of the 1st and 2nd metatarsal shafts as bright lines with posterior shadowing. Between the metatarsals, the Adductor Hallucis (oblique head) appears as a small hypoechoic muscle belly in the interosseous space. ⚠ The plantar digital nerves run between the metatarsal heads — interdigital neuromas are common here; identify nerve tissue before injecting.

### Foot Lumbricals  `foot-lumbricals`
*Lower Extremity — MTP flexion + IP extension in the foot (contributes to claw toe deformity)*

- [ ] **Patient Position** — `pos-expose-sole.jpg` · _shared_
  Position the patient prone with the foot hanging off the bed, or supine with the ankle dorsiflexed to expose the sole.
- [ ] **Probe + Needle Site** — `foot-lumbricals-probe.jpg`
  Patient prone or supine with foot exposed. Place hockey-stick probe longitudinally on plantar surface along the metatarsal. Photo from plantar view. Probe: High-frequency linear (10-15 MHz); hockey-stick probe preferred for the narrow intermetatarsal spaces. Orientation: Longitudinal along the metatarsal shaft on the plantar surface, or transverse across the metatarsal heads. Needle: Insert the needle from the plantar surface perpendicular to the skin, just proximal to the MTP joint of the target toe, on the medial (tibial) side of the flexor tendon.
- [ ] **Ultrasound Image** — `foot-lumbricals-us.jpg`
  You should see: Place the probe longitudinally on the plantar surface along the metatarsal of the target toe. Identify the FDL tendon as a hyperechoic linear structure running along the plantar metatarsal. ⚠ The plantar digital nerves and arteries are immediately adjacent to the lumbricals — identify before injecting.

---

## Cervical / Neck  ·  9 muscles  ·  27 photos

### Sternocleidomastoid (SCM)  `scm`
*Cervical — Head rotation to opposite side, ipsilateral lateral flexion*

- [ ] **Patient Position** — `pos-supine-head-neutral.jpg` · _shared_
  Position the patient supine with the head turned slightly to the contralateral side to make the SCM prominent but not maximally stretched.
- [ ] **Probe + Needle Site** — `scm-probe.jpg`
  Patient supine, head turned slightly contralateral. Place probe transversely on lateral neck at thyroid cartilage level. Photo from front/lateral showing probe across SCM muscle belly on neck. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral neck at the level of the thyroid cartilage, perpendicular to the SCM muscle belly. Needle: Palpate the muscle belly at the mid-cervical level (approximately the level of the thyroid cartilage). Grasp the muscle between thumb and index finger and LIFT it anteriorly off the carotid sheath —…
- [ ] **Ultrasound Image** — `scm-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Immediately deep to the subcutaneous tissue, the SCM appears as an oval or elliptical hypoechoic muscle with a bright fascial envelope — it is typically 1-2 cm thick at the… ⚠ The carotid artery and internal jugular vein lie immediately deep to the SCM within the carotid sheath — always visualize these structures with color Doppler before injecting and…

### Scalenes (Anterior, Middle, Posterior)  `scalenes`
*Cervical — Ipsilateral lateral neck flexion (laterocollis), accessory inspiration*

- [ ] **Patient Position** — `pos-supine-head-neutral.jpg` · _shared_
  Position the patient supine with the head in neutral position or turned slightly to the contralateral side to expose the lateral neck.
- [ ] **Probe + Needle Site** — `scalenes-probe.jpg`
  Patient supine, head neutral or slightly turned contralateral. Place probe transversely on lateral neck at C5-C7 level, posterior to SCM. Photo from front/lateral showing probe on lateral neck behind the SCM. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral neck at the C5-C7 level, posterior to the SCM and anterior to the upper trapezius. Needle: Under ultrasound, identify the target scalene muscle and confirm the location of the brachial plexus, subclavian/vertebral vessels, and phrenic nerve before inserting the needle.
- [ ] **Ultrasound Image** — `scalenes-us.jpg`
  You should see: Identify the SCM as the most superficial anterolateral muscle — use it as your anterior landmark. Posterior and deep to the SCM, the anterior scalene appears as a triangular or trapezoidal hypoechoic muscle lying directly anterior to the brachial plexus roots. ⚠ The brachial plexus roots (C5-T1) pass through the interscalene groove between the anterior and middle scalenes — injection into or near the interscalene groove can cause brachial…

### Upper Trapezius  `upper-trapezius`
*Cervical — Scapular elevation, head lateral flexion*

- [ ] **Patient Position** — `pos-seated-or-prone-forehead.jpg` · _shared_
  Position the patient seated upright with arms relaxed at the sides, or prone with the forehead resting on hands.
- [ ] **Probe + Needle Site** — `upper-trapezius-probe.jpg`
  Patient seated, arms relaxed. Place probe transversely on upper trapezius ridge, midway between cervical spine and acromion. Photo from behind showing probe on upper trap between neck and shoulder. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the upper trapezius ridge, midway between the cervical spinous processes and the acromion. Needle: Insert the needle perpendicular to the skin surface into the midpoint of the palpated muscle bulk, advancing 1-2 cm into the muscle belly.
- [ ] **Ultrasound Image** — `upper-trapezius-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as a broad, flat hypoechoic muscle with parallel fiber architecture and bright fascial borders on its superficial and deep surfaces. ⚠ The spinal accessory nerve (CN XI) runs on the deep surface of the upper trapezius, approximately 2-3 cm above the scapular spine in the posterior triangle of the neck — avoid…

### Levator Scapulae  `levator-scapulae`
*Cervical — Scapular elevation, cervical lateral flexion and rotation*

- [ ] **Patient Position** — `pos-seated-or-prone-forehead.jpg` · _shared_
  Position the patient seated upright with arms relaxed, or prone with the forehead resting on hands. Slight contralateral lateral flexion of the neck can help stretch and define the muscle.
- [ ] **Probe + Needle Site** — `levator-scapulae-probe.jpg`
  Patient seated, arms relaxed. Place probe transversely over superior angle of scapula, 2-3 cm lateral to C7-T2 spinous processes. Photo from behind showing probe on posterolateral neck/upper back. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the superior angle of the scapula, approximately 2-3 cm lateral to the cervicothoracic spinous processes at the T1-T2 level. Needle: Identify the superior angle of the scapula by palpating the superomedial corner of the scapula — this is the most reliable surface landmark for the levator scapulae insertion.
- [ ] **Ultrasound Image** — `levator-scapulae-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as the first hypoechoic muscular layer with a bright superficial fascial border. ⚠ The dorsal scapular nerve runs on or through the levator scapulae along its deep surface, often accompanied by the dorsal scapular artery — use color Doppler to identify vascular…

### Splenius Capitis  `splenius-capitis`
*Cervical — Ipsilateral head rotation and extension*

- [ ] **Patient Position** — `pos-cervical-posterior-flexed.jpg` · _shared_
  Position the patient seated upright with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe + Needle Site** — `splenius-capitis-probe.jpg`
  Patient seated, neck slightly flexed. Place probe transversely on posterolateral neck at C2-C4 level, 2-3 cm lateral to midline. Photo from behind showing probe on posterolateral neck between midline and mastoid. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterolateral neck at the C2-C4 level, approximately 2-3 cm lateral to the midline spinous processes. Needle: Insert the needle perpendicular to the skin, advancing through the trapezius (1-1.5 cm) and into the splenius capitis beneath it (an additional 0.5-1.5 cm). Total depth is typically 2-3.5 cm…
- [ ] **Ultrasound Image** — `splenius-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the upper trapezius appears as the first hypoechoic muscular layer with a bright fascial envelope — it is relatively thin in this region (0.5-1 cm). ⚠ The vertebral artery runs through the transverse foramina of C1-C6 — it lies deep and medial to the splenius capitis. Never direct the needle medially toward the transverse…

### Splenius Cervicis  `splenius-cervicis`
*Cervical — Cervical dystonia — ipsilateral rotation & laterocollis*

- [ ] **Patient Position** — `pos-cervical-posterior-flexed.jpg` · _shared_
  Position the patient prone or seated with the neck slightly flexed and the forehead supported.
- [ ] **Probe + Needle Site** — `splenius-cervicis-probe.jpg`
  Patient prone/seated, neck slightly flexed. Place probe transversely on the posterolateral neck at C2-C4; splenius cervicis lies deep to splenius capitis, heading to the upper cervical transverse processes. Confirm the vertebral artery… Probe: High-frequency linear (10-15 MHz). Orientation: Transverse over the posterolateral neck at the C2-C4 level. Needle: Insert the needle in-plane toward the muscle belly, staying lateral to the laminae and superficial to the transverse processes.
- [ ] **Ultrasound Image** — `splenius-cervicis-us.jpg`
  You should see: Place the probe transversely on the posterolateral neck at C2-C4. Identify the trapezius and splenius capitis superficially; the splenius cervicis lies deeper and more lateral, heading toward the C1-C3 transverse processes. Depth ≈ 1.5-3 cm. ⚠ The vertebral artery runs in the transverse foramina deep to the muscle — never advance the needle anteriorly toward the transverse processes without continuous ultrasound…

### Obliquus Capitis Inferior  `obliquus-capitis-inferior`
*Cervical — Cervical dystonia — ipsilateral head rotation (torticollis)*

- [ ] **Patient Position** — `pos-cervical-posterior-flexed.jpg` · _shared_
  Position the patient prone or seated with the neck slightly flexed and the forehead supported to open the suboccipital space.
- [ ] **Probe + Needle Site** — `obliquus-capitis-inferior-probe.jpg`
  Patient prone/seated, neck slightly flexed. Identify the C2 spinous process, then angle obliquely toward the C1 transverse process; OCI spans between them deep to semispinalis. Confirm the vertebral artery with Doppler. Probe: High-frequency linear (10-15 MHz); curvilinear for larger necks. Orientation: Oblique, aligned from the C2 spinous process to the C1 transverse process. Needle: Under ultrasound, identify the muscle spanning C2 spinous to C1 transverse process and insert in-plane toward the belly.
- [ ] **Ultrasound Image** — `obliquus-capitis-inferior-us.jpg`
  You should see: Identify the bifid C2 spinous process in the midline as the bony landmark. Angle the probe obliquely toward the C1 transverse process; the OCI spans between them, deep to semispinalis capitis. Depth ≈ 2-4 cm (deep). ⚠ The vertebral artery (V3 segment) loops across the suboccipital triangle over the posterior arch of C1, just deep and lateral to the OCI — never direct the needle anterolaterally;…

### Semispinalis Capitis  `semispinalis-capitis`
*Cervical — Bilateral head and neck extension (retrocollis)*

- [ ] **Patient Position** — `pos-cervical-posterior-flexed.jpg` · _shared_
  Position the patient seated with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe + Needle Site** — `semispinalis-capitis-probe.jpg`
  Patient seated, neck flexed. Place probe transversely on posterior neck at C2-C5 level, 1-2 cm lateral to midline. Photo from behind showing probe on posterior midline neck just below the occiput. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterior midline neck at the C2-C5 level, centered 1-2 cm lateral to the spinous processes. Needle: This is a DEEP muscle — the needle must traverse the trapezius and splenius capitis to reach it. USG guidance is essential to confirm correct depth and avoid injecting into the more superficial…
- [ ] **Ultrasound Image** — `semispinalis-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the trapezius appears as the first thin hypoechoic muscular layer at this paramedian location. ⚠ The vertebral artery lies anterior to the cervical laminae within the transverse foramina — the laminae serve as a protective bony barrier, but lateral needle angulation toward…

### Longissimus Capitis  `longissimus-capitis`
*Cervical — Head and neck extension (retrocollis), ipsilateral lateral flexion and rotation*

- [ ] **Patient Position** — `pos-cervical-posterior-flexed.jpg` · _shared_
  Position the patient seated with the neck slightly flexed to open the posterior cervical space, or prone with the forehead resting on hands.
- [ ] **Probe + Needle Site** — `longissimus-capitis-probe.jpg`
  Patient seated, neck slightly flexed. Place probe transversely on posterolateral neck at C4-C7 level, 2-4 cm lateral to midline. Photo from behind showing probe on posterolateral neck over the articular pillars. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the posterolateral neck at the C4-C7 level, approximately 2-4 cm lateral to the midline spinous processes. Needle: This is a DEEP muscle in the erector spinae group — the needle must traverse the trapezius and splenius capitis to reach it. USG guidance is essential.
- [ ] **Ultrasound Image** — `longissimus-capitis-us.jpg`
  You should see: Identify the skin and subcutaneous fat as the most superficial hyperechoic layer. Deep to the fat, the trapezius appears as a thin hypoechoic muscular layer in this region. ⚠ The vertebral artery lies within the transverse foramina anterior to the articular pillars — never advance the needle beyond the bony cortex of the articular pillar. The bone…

---

## Face / Neck  ·  10 muscles  ·  30 photos

### Frontalis  `frontalis`  _(not typically US-guided)_
*Face — Brow elevation dystonia, forehead spasm, involuntary brow raising; NOTE: this is primarily a cosmetic target (horizontal forehead lines) and is NOT a typical spasticity target*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright. Ask them to raise their eyebrows forcefully — the frontalis will contract, creating horizontal forehead lines.
- [ ] **Probe + Needle Site** — `frontalis-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, raising eyebrows to activate frontalis. Four to five injection sites distributed across the mid-forehead at least 2 cm above the brow. Needle: Standard cosmetic approach: inject at 4-5 sites across the mid-forehead, each approximately 1.5-2 cm above the brow and spaced 1.5-2 cm apart. Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `frontalis-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Corrugator Supercilii  `corrugator-supercilii`  _(not typically US-guided)_
*Face — Blepharospasm (glabellar component), brow furrowing, glabellar dystonia*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright. Ask them to frown forcefully — the corrugator creates the vertical (11 lines) furrows between the brows.
- [ ] **Probe + Needle Site** — `corrugator-supercilii-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, frowning to activate the corrugator. Injection at the medial eyebrow approximately 1 cm above the superomedial orbital rim. Needle: Insert a 30G needle at a shallow angle (20-30 degrees from the skin surface) directed laterally along the corrugator muscle belly. Advance approximately 0.5 cm into the muscle. Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `corrugator-supercilii-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Procerus  `procerus`  _(not typically US-guided)_
*Face — Blepharospasm (glabellar component), horizontal nasal root furrows, glabellar dystonia*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright. Ask them to 'scrunch' their nose or pull their brows down toward the nose — the procerus creates horizontal wrinkles at the nasal root.
- [ ] **Probe + Needle Site** — `procerus-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, actively scrunching the nose to identify the procerus. Single midline injection at the nasal root/glabella junction. Needle: Insert a 30G needle perpendicular to the skin or at a shallow angle into the midline nasal root/glabella junction, advancing only 2-4 mm into the thin muscle belly. Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `procerus-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Orbicularis Oculi  `orbicularis-oculi`  _(not typically US-guided)_
*Face — Blepharospasm (involuntary forceful eye closure), hemifacial spasm*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright in a well-lit room. The patient should be relaxed with eyes gently closed or in their resting blepharospasm position.
- [ ] **Probe + Needle Site** — `orbicularis-oculi-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright in well-lit room. Six injection sites distributed around the orbital rim: 3 upper (medial, central, lateral) and 3 lower (lateral, central, medial). Needle: Insert the needle subcutaneously (bevel up) at each site, directed AWAY from the globe. The muscle is extremely thin (1-2 mm) and lies just beneath the skin with no significant subcutaneous fat over… Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `orbicularis-oculi-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Temporalis  `temporalis`
*Face — Jaw clenching, bruxism, oromandibular dystonia (jaw closing type), temporal headache*

- [ ] **Patient Position** — `pos-seated-jaw-relaxed.jpg` · _shared_
  Position the patient seated upright or supine with the jaw relaxed.
- [ ] **Probe + Needle Site** — `temporalis-probe.jpg`
  Patient seated upright with jaw relaxed. Place probe transversely in the temporal fossa above the zygomatic arch. Photo from lateral view showing probe on temple. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the temporal fossa, perpendicular to the fibers, above the zygomatic arch. Needle: Insert the needle perpendicular to the skull surface into the muscle belly at each site. Advance only 0.5-1 cm — the temporalis is thin (5-10 mm) overlying the temporal bone, and the needle will…
- [ ] **Ultrasound Image** — `temporalis-us.jpg`
  You should see: Place the probe transversely on the temporal fossa above the zygomatic arch. Apply minimal pressure — the temporalis is thin and compresses easily. The temporalis appears as a thin, flat hypoechoic muscle directly overlying the hyperechoic temporal bone cortex. Its fibers run in a fan-shaped pattern converging inferiorly. Depth ≈ 1.0-1.5 cm. ⚠ The superficial temporal artery runs in the subcutaneous tissue — always palpate and/or use Doppler to map it before injecting. Intravascular injection may cause localized…

### Masseter  `masseter`
*Face — Jaw clenching, bruxism, oromandibular dystonia (jaw closing type)*

- [ ] **Patient Position** — `pos-seated-jaw-relaxed.jpg` · _shared_
  Position the patient seated upright or supine with the jaw relaxed and slightly open.
- [ ] **Probe + Needle Site** — `masseter-probe.jpg`
  Patient seated upright with jaw relaxed. Place probe transversely on lateral face over the mandibular ramus midway between zygomatic arch and mandibular angle. Photo from lateral view showing probe on cheek. Probe: High-frequency linear (10-15 MHz). Orientation: Transverse across the lateral face overlying the mandibular ramus, with the probe parallel to the zygomatic arch. Needle: Ask the patient to clench their teeth forcefully — the masseter will bulge prominently as a thick rectangular mass over the mandibular ramus between the zygomatic arch and the angle of the mandible.
- [ ] **Ultrasound Image** — `masseter-us.jpg`
  You should see: Place the probe transversely on the lateral face over the mandibular ramus, midway between the zygomatic arch and the angle of the mandible. The masseter appears as a thick, rectangular hypoechoic muscle with internal hyperechoic septa (reflecting its multipennate architecture) directly superficial to the hyperechoic… Depth ≈ 2.0-3.0 cm. ⚠ The parotid gland overlies the posterior masseter — deep injections in this area may inadvertently inject the parotid, causing sialadenitis or pain.

### Lateral Pterygoid  `lateral-pterygoid`  _(not typically US-guided)_
*Face — Jaw opening dystonia, jaw protrusion, oromandibular dystonia (jaw opening type), jaw deviation to contralateral side*

- [ ] **Patient Position** — `pos-seated-jaw-relaxed.jpg` · _shared_
  Position the patient seated upright or supine with the jaw slightly open (to translate the condyle forward and open the coronoid notch).
- [ ] **Probe + Needle Site** — `lateral-pterygoid-probe.jpg`
  EMG-guided injection — no ultrasound probe placement. Patient seated with jaw slightly open. Needle inserted through coronoid notch anterior to tragus, directed medially into infratemporal fossa. Needle: Insert a 25-27G, 1.5-2 inch needle through the coronoid notch, directing it medially and slightly anteriorly toward the infratemporal fossa. Advance approximately 2-3 cm until EMG activity confirms… Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `lateral-pterygoid-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Medial Pterygoid  `medial-pterygoid`
*Face — Jaw clenching, oromandibular dystonia (jaw closing type), synergist with masseter for jaw elevation*

- [ ] **Patient Position** — `pos-seated-jaw-relaxed.jpg` · _shared_
  Position the patient seated upright or supine with the jaw slightly open.
- [ ] **Probe + Needle Site** — `medial-pterygoid-probe.jpg`
  Patient seated with jaw slightly open. For US guidance: place probe in submandibular region below mandibular angle, angled superiorly. For EMG: needle through coronoid notch directed medially. Photo from submandibular view showing probe… Probe: High-frequency linear (10-15 MHz) or curvilinear (5-8 MHz) for deeper imaging. Orientation: Coronal oblique from the submandibular region, angled superiorly toward the medial surface of the mandibular ramus. Needle: SUBMANDIBULAR (EXTRAORAL) APPROACH (preferred for US guidance): Palpate the medial surface of the mandibular angle from the submandibular region. Place the ultrasound probe submandibularly to…
- [ ] **Ultrasound Image** — `medial-pterygoid-us.jpg`
  You should see: Place the probe in the submandibular region below and medial to the angle of the mandible, angled superiorly. Identify the mandibular ramus cortex as a hyperechoic line with posterior acoustic shadowing — this is the key deep landmark. Depth ≈ 2.5-4.0 cm. ⚠ The facial artery loops through the submandibular region — always use color Doppler to map it before needle insertion.

### Mentalis  `mentalis`  _(not typically US-guided)_
*Face — Chin dimpling dystonia, involuntary chin puckering, mental crease deepening, lower lip protrusion*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright. Ask them to 'pout' or push the lower lip forward — the mentalis will contract, producing the characteristic 'chin dimpling' or 'orange peel' appearance on the chin pad.
- [ ] **Probe + Needle Site** — `mentalis-probe.jpg`
  Landmark-guided injection — no ultrasound used. Patient seated upright, pouting to activate the mentalis and display chin dimpling. Inject at the center of the chin pad approximately 1 cm below the labiomental crease. Needle: For unilateral dystonia or dimpling, inject the affected side only. For bilateral chin dimpling, inject both sides. Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `mentalis-us.jpg`
  Not typically ultrasound-guided — US image optional.

### Platysma  `platysma`  _(not typically US-guided)_
*Face / Neck — Anterocollis (forward head flexion), neck banding, platysmal dystonia, involuntary neck tightening*

- [ ] **Patient Position** — `pos-seated-face-forward.jpg` · _shared_
  Position the patient seated upright or supine. Ask them to grimace or depress the mandible with lips retracted to make the platysmal bands prominent.
- [ ] **Probe + Needle Site** — `platysma-probe.jpg`
  Landmark-guided injection — platysmal bands are identified visually by asking the patient to grimace. Patient seated upright, grimacing to display anterior neck bands. Inject subcutaneously into each visible band. Needle: Insert a 30G needle subcutaneously into each platysmal band, directing it along the length of the band. Advance only 2-3 mm — the muscle is immediately beneath the skin. Not typically ultrasound-guided — still mark the red needle dot; the blue probe bar is optional.
- [ ] **Ultrasound Image** — `platysma-us.jpg`
  Not typically ultrasound-guided — US image optional.

---

## Appendix — flat filename checklist

All 173 files, for ticking off during the shoot:

**Patient position — 30 shared:**
- [ ] `pos-supine-arm-abducted.jpg`
- [ ] `pos-lateral-decub-arm-abducted.jpg`
- [ ] `pos-seated-or-prone-arm-at-side.jpg`
- [ ] `pos-arm-supinated-on-support.jpg`
- [ ] `pos-seated-elbow-flexed.jpg`
- [ ] `pos-seated-forearm-neutral.jpg`
- [ ] `pos-seated-forearm-supinated.jpg`
- [ ] `pos-seated-forearm-pronated.jpg`
- [ ] `pos-hand-pronated-flat.jpg`
- [ ] `pos-hand-supinated.jpg`
- [ ] `pos-prone-pillow-abdomen.jpg`
- [ ] `pos-supine-knees-bent.jpg`
- [ ] `pos-supine-or-lat-decub.jpg`
- [ ] `pos-supine-hip-neutral.jpg`
- [ ] `pos-prone-or-lat-decub-buttock.jpg`
- [ ] `pos-prone-pillow-pelvis.jpg`
- [ ] `pos-supine-frog-leg.jpg`
- [ ] `pos-prone-legs-apart.jpg`
- [ ] `pos-supine-knee-extended.jpg`
- [ ] `pos-prone-knee-flexed.jpg`
- [ ] `pos-prone-feet-off-bed.jpg`
- [ ] `pos-leg-ext-rotated.jpg`
- [ ] `pos-supine-leg-neutral.jpg`
- [ ] `pos-supine-leg-internal-rot.jpg`
- [ ] `pos-expose-sole.jpg`
- [ ] `pos-supine-head-neutral.jpg`
- [ ] `pos-seated-or-prone-forehead.jpg`
- [ ] `pos-cervical-posterior-flexed.jpg`
- [ ] `pos-seated-face-forward.jpg`
- [ ] `pos-seated-jaw-relaxed.jpg`

**Probe + needle site — 75:**
- [ ] `pec-major-probe.jpg`
- [ ] `lat-dorsi-probe.jpg`
- [ ] `subscapularis-probe.jpg`
- [ ] `infraspinatus-probe.jpg`
- [ ] `teres-major-probe.jpg`
- [ ] `biceps-brachii-probe.jpg`
- [ ] `brachialis-probe.jpg`
- [ ] `triceps-probe.jpg`
- [ ] `brachioradialis-probe.jpg`
- [ ] `pronator-teres-probe.jpg`
- [ ] `fcr-probe.jpg`
- [ ] `fcu-probe.jpg`
- [ ] `fds-probe.jpg`
- [ ] `fdp-probe.jpg`
- [ ] `fpl-probe.jpg`
- [ ] `pronator-quadratus-probe.jpg`
- [ ] `ecrl-probe.jpg`
- [ ] `ecrb-probe.jpg`
- [ ] `ecu-probe.jpg`
- [ ] `edc-probe.jpg`
- [ ] `adductor-pollicis-probe.jpg`
- [ ] `hand-lumbricals-probe.jpg`
- [ ] `paraspinals-probe.jpg`
- [ ] `quadratus-lumborum-probe.jpg`
- [ ] `rectus-abdominis-probe.jpg`
- [ ] `obliques-probe.jpg`
- [ ] `iliopsoas-probe.jpg`
- [ ] `gluteus-maximus-probe.jpg`
- [ ] `piriformis-probe.jpg`
- [ ] `tfl-probe.jpg`
- [ ] `pectineus-probe.jpg`
- [ ] `adductor-longus-probe.jpg`
- [ ] `adductor-brevis-probe.jpg`
- [ ] `adductor-magnus-probe.jpg`
- [ ] `gracilis-probe.jpg`
- [ ] `rectus-femoris-probe.jpg`
- [ ] `vastus-lateralis-probe.jpg`
- [ ] `vastus-medialis-probe.jpg`
- [ ] `vastus-intermedius-probe.jpg`
- [ ] `biceps-femoris-probe.jpg`
- [ ] `semitendinosus-probe.jpg`
- [ ] `semimembranosus-probe.jpg`
- [ ] `gastrocnemius-medial-probe.jpg`
- [ ] `gastrocnemius-lateral-probe.jpg`
- [ ] `soleus-medial-probe.jpg`
- [ ] `soleus-lateral-probe.jpg`
- [ ] `tibialis-posterior-probe.jpg`
- [ ] `fdl-probe.jpg`
- [ ] `fhl-probe.jpg`
- [ ] `tibialis-anterior-probe.jpg`
- [ ] `ehl-probe.jpg`
- [ ] `edl-probe.jpg`
- [ ] `peroneus-longus-probe.jpg`
- [ ] `fdb-probe.jpg`
- [ ] `add-hallucis-probe.jpg`
- [ ] `foot-lumbricals-probe.jpg`
- [ ] `scm-probe.jpg`
- [ ] `scalenes-probe.jpg`
- [ ] `upper-trapezius-probe.jpg`
- [ ] `levator-scapulae-probe.jpg`
- [ ] `splenius-capitis-probe.jpg`
- [ ] `splenius-cervicis-probe.jpg`
- [ ] `obliquus-capitis-inferior-probe.jpg`
- [ ] `semispinalis-capitis-probe.jpg`
- [ ] `longissimus-capitis-probe.jpg`
- [ ] `frontalis-probe.jpg`
- [ ] `corrugator-supercilii-probe.jpg`
- [ ] `procerus-probe.jpg`
- [ ] `orbicularis-oculi-probe.jpg`
- [ ] `temporalis-probe.jpg`
- [ ] `masseter-probe.jpg`
- [ ] `lateral-pterygoid-probe.jpg`
- [ ] `medial-pterygoid-probe.jpg`
- [ ] `mentalis-probe.jpg`
- [ ] `platysma-probe.jpg`

**Ultrasound — 68:**
- [ ] `pec-major-us.jpg`
- [ ] `lat-dorsi-us.jpg`
- [ ] `subscapularis-us.jpg`
- [ ] `infraspinatus-us.jpg`
- [ ] `teres-major-us.jpg`
- [ ] `biceps-brachii-us.jpg`
- [ ] `brachialis-us.jpg`
- [ ] `triceps-us.jpg`
- [ ] `brachioradialis-us.jpg`
- [ ] `pronator-teres-us.jpg`
- [ ] `fcr-us.jpg`
- [ ] `fcu-us.jpg`
- [ ] `fds-us.jpg`
- [ ] `fdp-us.jpg`
- [ ] `fpl-us.jpg`
- [ ] `pronator-quadratus-us.jpg`
- [ ] `ecrl-us.jpg`
- [ ] `ecrb-us.jpg`
- [ ] `ecu-us.jpg`
- [ ] `edc-us.jpg`
- [ ] `adductor-pollicis-us.jpg`
- [ ] `hand-lumbricals-us.jpg`
- [ ] `paraspinals-us.jpg`
- [ ] `quadratus-lumborum-us.jpg`
- [ ] `rectus-abdominis-us.jpg`
- [ ] `obliques-us.jpg`
- [ ] `iliopsoas-us.jpg`
- [ ] `gluteus-maximus-us.jpg`
- [ ] `piriformis-us.jpg`
- [ ] `tfl-us.jpg`
- [ ] `pectineus-us.jpg`
- [ ] `adductor-longus-us.jpg`
- [ ] `adductor-brevis-us.jpg`
- [ ] `adductor-magnus-us.jpg`
- [ ] `gracilis-us.jpg`
- [ ] `rectus-femoris-us.jpg`
- [ ] `vastus-lateralis-us.jpg`
- [ ] `vastus-medialis-us.jpg`
- [ ] `vastus-intermedius-us.jpg`
- [ ] `biceps-femoris-us.jpg`
- [ ] `semitendinosus-us.jpg`
- [ ] `semimembranosus-us.jpg`
- [ ] `gastrocnemius-medial-us.jpg`
- [ ] `gastrocnemius-lateral-us.jpg`
- [ ] `soleus-medial-us.jpg`
- [ ] `soleus-lateral-us.jpg`
- [ ] `tibialis-posterior-us.jpg`
- [ ] `fdl-us.jpg`
- [ ] `fhl-us.jpg`
- [ ] `tibialis-anterior-us.jpg`
- [ ] `ehl-us.jpg`
- [ ] `edl-us.jpg`
- [ ] `peroneus-longus-us.jpg`
- [ ] `fdb-us.jpg`
- [ ] `add-hallucis-us.jpg`
- [ ] `foot-lumbricals-us.jpg`
- [ ] `scm-us.jpg`
- [ ] `scalenes-us.jpg`
- [ ] `upper-trapezius-us.jpg`
- [ ] `levator-scapulae-us.jpg`
- [ ] `splenius-capitis-us.jpg`
- [ ] `splenius-cervicis-us.jpg`
- [ ] `obliquus-capitis-inferior-us.jpg`
- [ ] `semispinalis-capitis-us.jpg`
- [ ] `longissimus-capitis-us.jpg`
- [ ] `temporalis-us.jpg`
- [ ] `masseter-us.jpg`
- [ ] `medial-pterygoid-us.jpg`

