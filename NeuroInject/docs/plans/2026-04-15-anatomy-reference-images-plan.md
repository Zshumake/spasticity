---
date: 2026-04-15
topic: anatomy-reference-images
status: planned
---

# Anatomy Reference Images — Deepened Implementation Plan

## Goal

Add a rendered anatomy reference image to every muscle detail page showing the bones with the target muscle highlighted. Example: for FCR, show a forearm skeleton with the flexor carpi radialis colored terracotta, highlighting its origin at the medial epicondyle and insertion at the base of metacarpal 2/3.

## Approach: Hybrid Wikimedia + Z-Anatomy Render Pipeline

Based on parallel research agents, the fastest path is a **hybrid** between two sources:

1. **Harvest ~20–30 pre-rendered images from Wikimedia Commons Anatomography category** (CC-BY-SA 2.1 JP, zero work)
2. **Render the remaining ~40 muscles from Z-Anatomy Sketchfab models** (CC-BY-SA 4.0, batch Blender script)

Both sources trace to the same BodyParts3D mesh data, so visual style is compatible.

---

## Phase 1 — Wikimedia Harvest (1-2 hours)

**Source:** [Category:Images of human muscles from Anatomography](https://commons.wikimedia.org/wiki/Category:Images_of_human_muscles_from_Anatomography) — 103 static PNGs + 223 animations, CC-BY-SA 2.1 JP.

**Coverage estimate:** 20-30 of our 68 muscles. Strong for lower leg (gastroc, soleus, tib post, peroneals, EHL/FHL, FDL, intrinsic foot), face (masseter, temporalis, zygomaticus, corrugator), neck (SCM, splenius). Weak for upper extremity, torso, hip.

**Steps:**
1. Scrape the category page for filenames
2. Match each filename to one of our 68 muscle IDs using a mapping dict
3. Download matching PNGs to `assets/images/anatomy/`
4. Record attribution metadata in `docs/credits/anatomy-sources.md`

**Deliverable:** `tools/harvest_wikimedia_anatomy.py` — a one-shot script that pulls the matchable images.

---

## Phase 2 — Z-Anatomy Blender Batch Render (10-12 hours)

For the ~40 muscles Wikimedia doesn't cover.

### 2.1 Source setup (1 hour)

- Download from [Z-Anatomy Sketchfab](https://sketchfab.com/Z-Anatomy) — grab **Myology** (5.7M tri, all muscles as named meshes, CC-BY-SA 4.0) and **Muscular insertions** (skeleton with insertion points, 2.1M tri, CC-BY-SA 4.0)
- Sketchfab free account required; download as glTF/GLB (preserves mesh names)
- **Validation step:** import one GLB into Blender, confirm Terminologia Anatomica names preserved (e.g. `Musculus flexor carpi radialis`). If names got flattened during Sketchfab export, fall back to the monolithic 291 MB .blend from [LluisV GitHub Google Drive](https://github.com/LluisV/Z-Anatomy)
- Cache the `TA2.csv` from [Z-Anatomy/The-blend](https://github.com/Z-Anatomy/The-blend) — it's the Rosetta stone for TA2 Latin → English muscle names

### 2.2 Name-discovery pass (2 hours)

Write `tools/dump_zanatomy_names.py` — a Blender Python script invoked via `blender --background --python`. It:
1. Imports Myology.glb
2. Iterates all objects, prints names matching regex `(?i)musculus` to `tools/zanatomy_muscle_names.txt`
3. Exits

Then manually map our 68 muscle IDs to their TA2 Latin names in `tools/muscle_render_map.json`:

```json
{
  "fcr": {
    "zAnatomyName": "Musculus flexor carpi radialis",
    "cameraPreset": "forearm_anterior",
    "highlightColor": [0.80, 0.40, 0.30, 1.0],
    "caption": "Anterior forearm · FCR highlighted"
  },
  "biceps-brachii": {
    "zAnatomyName": "Musculus biceps brachii",
    "cameraPreset": "upper_arm_anterior",
    "highlightColor": [0.80, 0.40, 0.30, 1.0],
    "caption": "Anterior arm · biceps brachii highlighted"
  }
}
```

**Risks:** Bilateral muscles may appear as separate `dextra`/`sinistra` instances. Split-head muscles (e.g. biceps) may have individual heads as separate objects. Budget extra time for edge cases.

### 2.3 Render script (3 hours)

Write `tools/render_anatomy.py` — Blender Python. Pattern:

```python
# Load both GLBs into one scene
bpy.ops.import_scene.gltf(filepath="Myology.glb")
bpy.ops.import_scene.gltf(filepath="Muscular-insertions.glb")

# Build neutral grey material for bones, terracotta for highlighted muscle
GREY = make_material("Bone", (0.85, 0.82, 0.78, 1.0))
HIGHLIGHT = make_material("Target", (0.88, 0.44, 0.34, 1.0))  # AppTheme terracotta

# Load mapping
mapping = json.load(open("tools/muscle_render_map.json"))

for muscle_id, config in mapping.items():
    # Hide all
    for obj in bpy.data.objects:
        obj.hide_render = True

    # Show skeleton, color grey
    for obj in bpy.data.collections["Skeleton"].all_objects:
        obj.hide_render = False
        obj.data.materials.clear()
        obj.data.materials.append(GREY)

    # Show + highlight target muscle
    target = bpy.data.objects[config["zAnatomyName"]]
    target.hide_render = False
    target.data.materials.clear()
    target.data.materials.append(HIGHLIGHT)

    # Apply camera preset
    preset = CAMERA_PRESETS[config["cameraPreset"]]
    cam.location = preset["location"]
    cam.rotation_euler = [math.radians(d) for d in preset["rotation_deg"]]

    # Render
    scene.render.filepath = f"assets/images/anatomy/{muscle_id}.png"
    bpy.ops.render.render(write_still=True)
```

**Settings:**
- Engine: **Eevee Next** (Blender 4.2+, headless-capable, ~5 sec/frame)
- Resolution: **1000×1000 PNG, RGBA transparent background** (`scene.render.film_transparent = True`)
- Lighting: add a simple 3-point rig (key, fill, rim) in the script before rendering — Z-Anatomy default lighting is tuned for interactive use, not render

### 2.4 Camera preset tuning (1.5 hours)

Manually tune these in Blender GUI, then freeze into the script:

```python
CAMERA_PRESETS = {
    "upper_arm_anterior":   {"location": (0, -1.5, 1.3),  "rotation_deg": (80, 0, 0)},
    "forearm_anterior":     {"location": (0.2, -1.2, 1.0), "rotation_deg": (82, 0, 10)},
    "forearm_posterior":    {"location": (0.2,  1.2, 1.0), "rotation_deg": (82, 0, 190)},
    "hand_palmar":          {"location": (0.3, -0.8, 0.9), "rotation_deg": (-90, 180, 15)},
    "thigh_anterior":       {"location": (0, -2.0, 0.5),  "rotation_deg": (85, 0, 0)},
    "thigh_medial":         {"location": (-1.5, 0, 0.5),  "rotation_deg": (85, 0, 270)},
    "leg_lateral":          {"location": (1.5, 0, 0.1),   "rotation_deg": (85, 0, 90)},
    "face_lateral":         {"location": (1.5, 0, 1.7),   "rotation_deg": (85, 0, 90)},
    "face_anterior":        {"location": (0, -1.5, 1.7),  "rotation_deg": (85, 0, 0)},
    "torso_anterior":       {"location": (0, -3.0, 1.2),  "rotation_deg": (85, 0, 0)},
    "torso_posterior":      {"location": (0, 3.0, 1.2),   "rotation_deg": (85, 0, 180)},
    "neck_lateral":         {"location": (1.2, 0, 1.6),   "rotation_deg": (85, 0, 90)},
}
```

### 2.5 Full batch render (30 min render + 1 hour QA)

With all presets set and mapping complete:
- `blender --background --python tools/render_anatomy.py`
- 68 muscles × 1 angle × 5 sec Eevee = ~6 minutes
- QA: open `assets/images/anatomy/` and scan thumbnails. Expect 5-10 outliers needing camera adjustment or a different angle preset.

### 2.6 Outlier iteration (2 hours)

Common issues:
- Muscle occluded by a bone → rotate camera or lower skeleton opacity
- Target muscle too small in frame → tighter region-specific zoom
- Deep muscle (iliopsoas, subscapularis) → may need semi-transparent overlying muscles
- Split-head muscles (biceps heads, gastroc heads) → decide whether to highlight all heads or just one

### 2.7 PNG → WebP conversion (15 min)

```bash
cd assets/images/anatomy
for f in *.png; do cwebp -q 85 -alpha_q 100 "$f" -o "${f%.png}.webp"; done
rm *.png
```

Reduces 68 × 250 KB = 17 MB → ~68 × 60 KB = 4 MB. Flutter handles WebP natively.

---

## Phase 3 — Flutter Integration (2 hours)

### 3.1 Model change (15 min)

File: `lib/models/muscle.dart`

Add:
```dart
final List<String> anatomyImages;
final String? anatomyCaption;
```

In `fromJson`:
```dart
anatomyImages: json['anatomyImages'] != null
    ? (json['anatomyImages'] as List).cast<String>()
    : const [],
anatomyCaption: json['anatomyCaption'] as String?,
```

### 3.2 Pubspec registration (5 min)

File: `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/data/muscles.json
    - assets/data/patterns.json
    - assets/images/us_reference/
    - assets/images/probe_placement/
    - assets/images/anatomy/    # NEW
```

### 3.3 UI widget (1 hour)

File: `lib/screens/guide/muscle_detail.dart`

**Placement:** new row in `_buildStudyView` left column, between `LandmarkList` and `_buildUltrasoundCard`. New reading order:

```
Landmarks → ANATOMY REFERENCE → Ultrasound Guide → Clinical Images (probe + US) → ...
```

**Specs:**
- Full-width (within left column) 16:10 landscape, **220px tall**
- `BoxFit.contain` with `_groupColor.withAlpha(8)` letterbox tint
- Accent border: `_groupColor.withAlpha(60)` (muscle's region color, not a global accent — matches the hero header)
- Section header: `ANATOMY REFERENCE` in IBM Plex Mono 10pt, letterSpacing 2.0, `_groupColor`
- Bottom gradient overlay with caption (e.g. `"ANTERIOR FOREARM · FCR HIGHLIGHTED"`)
- Top-right zoom icon (same pattern as clinical images)
- Tap → reuse existing `_showFullImage()` full-screen viewer (InteractiveViewer, zoom + pan)

**Placeholder state (when `anatomyImages.isEmpty`):**
- Visible card at the same dimensions (prevents layout jumping between pages)
- Icon: `Icons.view_in_ar_outlined`
- Label: `ANATOMY COMING SOON`
- Subtitle: `3D anatomy reference from Z-Anatomy` (doubles as placeholder attribution)

**Bug to fix while editing `_showFullImage`:**
The existing function hardcodes the appbar title as `'${muscle.name} — US View'`. It should use the `title` parameter that's already being passed in. One-line fix; current call sites already pass correct labels.

### 3.4 Populate muscles.json (1 hour)

Script: `tools/populate_anatomy_images.py`

For each muscle with a rendered/harvested image, add:
```json
"anatomyImages": ["fcr.webp"],
"anatomyCaption": "Anterior forearm · FCR highlighted"
```

### 3.5 Attribution page (30 min)

Add a Credits / About screen (or extend if one exists):
- Source: Z-Anatomy (Gauthier Kervyn, Lluís Vinent, Marcin Zielinski) — https://www.z-anatomy.com/
- Second source: BodyParts3D (The Database Center for Life Science) — via Wikimedia Commons
- License: CC-BY-SA 4.0 (Z-Anatomy) / CC-BY-SA 2.1 JP (Wikimedia Anatomography)
- Note: "Muscle illustrations are derivative works rendered in Blender with per-muscle highlighting"
- License URL links

Small link under each anatomy card: `ℹ About anatomy images` → routes to this page. Satisfies CC-BY-SA "reasonable notice" requirement without visual clutter.

---

## Deliverables

### Code
- `tools/harvest_wikimedia_anatomy.py` (Phase 1)
- `tools/dump_zanatomy_names.py` (Phase 2.2)
- `tools/render_anatomy.py` (Phase 2.3–2.5) — Blender Python
- `tools/muscle_render_map.json` (Phase 2.2) — 68-entry mapping
- `tools/populate_anatomy_images.py` (Phase 3.4)
- `lib/models/muscle.dart` — add `anatomyImages` + `anatomyCaption` fields
- `lib/screens/guide/muscle_detail.dart` — new anatomy reference row + `_showFullImage` bug fix
- `lib/screens/credits_page.dart` — attribution page
- `pubspec.yaml` — register `assets/images/anatomy/`

### Assets
- `assets/images/anatomy/<muscle-id>.webp` × 68 muscles
- `docs/credits/anatomy-sources.md` — full attribution record

### Data
- Updated `assets/data/muscles.json` with `anatomyImages` + `anatomyCaption` populated on 68 muscles

---

## Total Time Estimate

| Phase | Work | Time |
|---|---|---|
| 1 | Wikimedia harvest | 1-2 hr |
| 2.1 | Z-Anatomy source setup | 1 hr |
| 2.2 | Name discovery + mapping | 2 hr |
| 2.3 | Render script | 3 hr |
| 2.4 | Camera preset tuning | 1.5 hr |
| 2.5 | Full batch render | 1.5 hr (30 min render + 1 hr QA) |
| 2.6 | Outlier iteration | 2 hr |
| 2.7 | PNG → WebP conversion | 15 min |
| 3.1–3.5 | Flutter integration | 2 hr |
| **Total** | | **~14 hr** (2-3 sessions) |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Sketchfab GLB export loses muscle names | Medium | High | Validate in Phase 2.1 with one test model; fallback to 291 MB LluisV .blend via Google Drive |
| Headless Eevee fails on older Blender | Low | Medium | Require Blender 4.2+; fallback to Cycles if needed |
| Bilateral muscle duplicates confuse name matching | High | Low | Manual mapping step catches this; render both or pick left arbitrarily |
| Camera presets look wrong for deep muscles | High | Low | Iteration budget already includes 2 hr for outliers |
| Z-Anatomy default lighting is flat | Medium | Medium | Script adds 3-point light rig before rendering |
| Rendered images have inconsistent scale per body part | Medium | Medium | Fixed camera distance per region; let muscle size vary naturally. Optional: `frame_object()` helper |
| CC-BY-SA on derivative renders requires re-licensing | Certain | Low | Acknowledge in attribution page; SA does NOT infect app code |
| Bundle size bloat from 68 images | Low | Low | WebP conversion keeps total ~4 MB |

---

## Open Questions (deferred to implementation)

- **Caption length:** the gradient overlay supports ~40 chars; longer captions will need a tooltip. Likely not a problem for "ANTERIOR FOREARM · FCR HIGHLIGHTED" style captions.
- **Bilateral muscles:** render left or right side by convention? Suggest: always render **right side** (matches clinician's view of patient facing them).
- **Split-head muscles (biceps, gastroc):** highlight all heads (e.g. both biceps heads) or just one? Suggest: highlight all heads of the same muscle together — the entry is about "biceps-brachii" as a whole.
- **Anterior-only vs multiple angles:** v1 ships 1 angle per muscle. Future iteration could add a second (posterior/medial) view via the same `anatomyImages` List support.

---

## Execution Order

Follow **Phase 1 → Phase 2 → Phase 3** strictly. Phase 1 produces instant wins (some muscles covered without any Blender work) and validates the UI pipeline end-to-end before committing to the larger Phase 2 investment.

Within Phase 2, do a **single muscle end-to-end first** (e.g. FCR — it's well-named, bilateral but canonical, and sits in a familiar body region) before scaling to 40. Validate the render looks right in the app, then batch.

---

## References

- [Z-Anatomy GitHub org](https://github.com/Z-Anatomy)
- [Z-Anatomy Sketchfab](https://sketchfab.com/Z-Anatomy) — free-download models
- [Z-Anatomy LluisV repo with GDrive link](https://github.com/LluisV/Z-Anatomy)
- [TA2 canonical name viewer](https://ta2viewer.openanatomy.org/)
- [BodyParts3D source](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html)
- [Wikimedia Commons Anatomography muscle category](https://commons.wikimedia.org/wiki/Category:Images_of_human_muscles_from_Anatomography)
- [Kervyn 2022 paper on Z-Anatomy architecture](https://actascientific.com/ASAT/pdf/ASAT-01-0022.pdf)
- [Blender headless rendering docs](https://docs.blender.org/manual/en/latest/advanced/command_line/render.html)
- [CC-BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/deed.en)
- [Flutter asset bundling docs](https://docs.flutter.dev/ui/assets/assets-and-images)
- [model_viewer_plus Flutter package](https://pub.dev/packages/model_viewer_plus) (considered and rejected in favor of static renders)
