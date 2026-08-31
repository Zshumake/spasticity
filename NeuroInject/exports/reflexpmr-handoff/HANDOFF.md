# Handoff: NeuroInject ultrasound muscle content → reflexpmr.com

This bundle is self-contained. Everything you need to import the 48
ultrasound-backed muscles is in this folder — you should not need to read the
NeuroInject repo, but it lives at `Desktop/MyInventions/NeuroInject` if you do.
Retheme freely: every color in this system is applied at render time, nothing
is baked into the images (see "Rendering the highlight").

## What's here

```
data/muscles.json                48 muscles (pre-filtered), full clinical records
assets/scans/                    38 ultrasound scans (9 are shared by 2-3 muscles)
assets/masks/                    47 muscle-highlight alpha masks (PNG, white RGB + alpha)
assets/probe-illustrations/      48 atlas illustrations (blue probe bar + red entry dot)
reference/us-label-archive.json  transcript of the label burned into each original scan
reference/us-label-crops/        the literal text-band pixels cut from each original
reference/highlight-captures.json  raw hand-drawn lasso polygons (provenance/rebake source)
```

## Data contract

Each record in `data/muscles.json` is the full NeuroInject clinical record
(name, group, pattern, landmarks[], placement[], setup[], ultrasound{probe,
orientation, viewSteps}, dosage, dosageNote, pearls[], dangerZones[],
spasticityPatterns[], relatedMuscles[], positionGroup/Label, …) plus a
resolved `export` object so you never re-implement path logic:

```json
"export": {
  "scan": "assets/scans/us-gastrocnemius-medial-soleus.jpg",
  "scanSharedWith": ["soleus-medial"],
  "mask": "assets/masks/gastrocnemius-medial-us.mask.png",
  "probeIllustration": "assets/probe-illustrations/gastrocnemius-medial-probe.jpg"
}
```

A multi-approach muscle looks like this instead — same keys, one set per
window:

```json
"export": {
  "scan": "assets/scans/us-tibialis-anterior-posterior.jpg",
  "mask": null,
  "probeIllustration": "assets/probe-illustrations/tibialis-anterior-probe.jpg",
  "views": [
    {"label": "Anterior approach",
     "scan": "assets/scans/us-tibialis-anterior-posterior.jpg",
     "mask": "assets/masks/tibialis-posterior-anterior-us.mask.png",
     "probeIllustration": "assets/probe-illustrations/tibialis-anterior-probe.jpg"},
    {"label": "Medial approach",
     "scan": "assets/scans/fdl-us.jpg",
     "mask": "assets/masks/tibialis-posterior-medial-us.mask.png",
     "probeIllustration": "assets/probe-illustrations/fdl-probe.jpg"}
  ]
}
```

The scalar `scan`/`probeIllustration` mirror `views[0]` so an importer that
ignores `views` still renders something coherent.

- **Shared scans are intentional.** One transverse view often shows several
  muscles (all three adductors; each gastroc + its soleus; FDS + FDP; …) and
  the relationship IS the lesson. Muscles listed in `scanSharedWith` point at
  the same scan file; only the mask differs. Do not duplicate scan bytes per
  muscle — key your UI on (scan, mask) pairs.
- **One muscle has TWO approaches, not one view: tibialis-posterior.** It is
  scanned and injected from two different windows — anterior (through the
  tibialis anterior, onto the interosseous membrane) and medial (the FDL
  window) — so its record carries `export.views[]` instead of a single
  scan/mask/probe triple, and its scalar `export.mask` is `null` to stop a
  naive importer picking one arbitrarily. Each entry in `views[]` has its own
  `label`, `scan`, `mask` and `probeIllustration`.

  **Swap all three together.** The probe illustration says where the
  transducer sits on the skin; pairing one window's probe picture with the
  other window's scan teaches the wrong needle entry. NeuroInject renders
  this as a labelled chip toggle above the two big pictures. Muscles without
  `views[]` are single-window and unchanged.

  Both tibialis-posterior masks are `null` today — the outlines are pending
  a redraw (the previously drawn one duplicated tibialis anterior). Show the
  plain scan until they land; a wrong highlight is worse than none.
- **ecrl and ecrb share one mask by design** (identical files): separating the
  radial wrist extensors at the scanned level is clinically arbitrary, so they
  highlight as one ECR group. Not a bug; do not "fix".

## Rendering the highlight (the part that carries the teaching value)

Masks are white-RGB PNGs whose ALPHA channel holds the muscle region: opaque
through the belly, smoothstep-feathered to zero over a narrow border band.
Color is applied at render time — this is your retheme hook.

The reference implementation (Flutter) composites in two steps, which you can
reproduce on the web with canvas:

1. Draw the scan.
2. Stamp your accent color into the mask's alpha shape
   (`source-in` on the mask), then composite that colored shape over the scan
   with **`globalCompositeOperation = "color"`** — the luminosity-preserving
   blend. This is non-negotiable for quality: it tints the muscle with your
   hue while the scan's own brightness carries through, so the echotexture
   (speckle, fascial lines) that the learner is supposed to read stays at
   full contrast. A plain semi-transparent fill washes it out — we tried
   several variants (opacity fades, color ramps); uniform luminosity-
   preserving tint won on review.

CSS-only fallback: layer the mask as a `mask-image` on a solid-color div with
`mix-blend-mode: color` over the scan img. Test in Safari.

NeuroInject currently colors by region (arm orange, leg blue, neck purple via
`group`), but that is one function — use whatever mapping fits reflexpmr's
theme. `group` values present: "Upper Extremity", "Upper Extremity / Trunk",
"Lower Extremity", "Cervical".

## Invariants — do not break these

1. **Masks are pixel-aligned to their scan at identical dimensions.** Never
   crop, trim, letterbox, or resize a scan independently of its mask. Scale
   them together (same transform) and alignment is preserved at any display
   size.
2. **Scans still carry SonoSite chrome and burned-in labels** (timestamps,
   view labels, machine footer). The owner reverted an automated de-chroming
   pass — presentation cropping is HIS call, not yours. If he asks for
   cropping inside reflexpmr, crop scan and mask by the same box, and
   `reference/us-label-archive.json` has machine-detected sector boxes to
   start from.
3. **Two scans are PHI-redacted** (pronator-teres, fcr: patient-name band
   blanked at top-left). Use ONLY the files in this bundle — never source
   these two images from anywhere else in the owner's filesystem, and don't
   "restore" the black band area.
4. This is the complete intended set: exactly these 48. The other 27
   NeuroInject muscles have no ultrasound and are deliberately excluded.

## Reference material (for the planned structure-labeling feature)

The owner intends to later annotate adjacent structures (vessels, nerves,
bone) around each target. When that happens:
- `reference/us-label-archive.json` maps every scan to the description the
  sonographer burned into it at acquisition ("ADD LONGUS TOP, SECOND LAYER
  RIGHT ADD BREVIS…") — the ground truth for what each view contains.
- `reference/us-label-crops/` holds those words as image strips if the
  transcript is ever in doubt.
- Suggested colors already in use for structures in NeuroInject: crimson =
  artery/vessel, amber = nerve, gray = bone (see its StructureKind) — but
  again, theme as you wish.
- `reference/highlight-captures.json` is the raw lasso data (canvas-space
  polygons + canvas size, drawn over these exact scan files displayed with
  cover-fit). New masks can be regenerated from lassos with NeuroInject's
  `tools/refine_highlights.py` (fascia-ridge watershed refinement) if the
  pipeline is ever needed on the reflexpmr side.

## Quick import validation

After ingesting, assert: 48 muscle records; every scan file referenced by
`export.scan` or `export.views[].scan` exists; 47 non-null masks whose PNG
dimensions equal their scan's dimensions; `tibialis-posterior` carries two
entries in `export.views[]` with distinct scans and probe illustrations, and
a null scalar `export.mask`; `ecrl`/`ecrb` mask files byte-identical; 9 scan
files referenced by 2+ muscles. If all pass, the import is faithful.
