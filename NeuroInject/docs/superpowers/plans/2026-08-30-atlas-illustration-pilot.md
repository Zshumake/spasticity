# Atlas Illustration Pilot Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce and validate three non-destructive Atlas-style calibration illustrations covering injection, positioning, and non-explicit groin-adjacent clinical imagery.

**Architecture:** Use the built-in image editing service once per staged source photograph. Normalize the global Atlas contract around each task's existing verbatim prompt, save candidates under a separate calibration directory, and inspect each candidate against the source before presenting the trio for style acceptance.

**Tech Stack:** Codex built-in image generation, existing JSON task manifest, PNG calibration assets, existing review workflow after promotion.

---

### Task 1: Prepare Pilot Inputs

**Files:**
- Read: `tools/gemini-illustrations/tasks.json`
- Read: `tools/gemini-illustrations/review-status.json`
- Read: `tools/gemini-illustrations/sources/biceps-brachii.jpg`
- Read: `tools/gemini-illustrations/sources/supine-arm-abducted.jpg`
- Read: `tools/gemini-illustrations/sources/adductor-longus.jpg`
- Create: `tools/gemini-illustrations/calibration/`
- Create: `tools/gemini-illustrations/calibration/input/`

- [ ] **Step 1: Record the authorization and de-identification preflight**

Before any provider call, confirm the operator has stated that the staged clinical photographs are authorized and sufficiently de-identified for third-party AI processing. Stop if this confirmation is absent.

- [ ] **Step 2: Verify manifest and review state**

Read each pilot's ID, mode, source, output, and verbatim prompt from `tasks.json`. Confirm all three entries exist, none has status `approved`, and no step in the pilot writes to its production output or `review-status.json`.

- [ ] **Step 3: Verify all three source files exist and decode as images**

Run: `file tools/gemini-illustrations/sources/{biceps-brachii,supine-arm-abducted,adductor-longus}.jpg`

Expected: three 2048x1365 JPEG images.

- [ ] **Step 4: Inspect each image before editing**

Confirm framing, laterality, visible clothing, procedural marker locations, and that the proximal-thigh image is non-explicit.

- [ ] **Step 5: Create metadata-free working copies**

Create `calibration/input/` and use ImageMagick to re-encode each pilot source while stripping profiles and metadata:

`magick sources/<id>.jpg -strip calibration/input/<id>.jpg`

Verify each working copy is 2048x1365 and `identify -verbose calibration/input/<id>.jpg` contains no EXIF profile. Use only these copies for provider calls.

- [ ] **Step 6: Preserve production state**

Snapshot hashes of the three established production output paths when present and of `review-status.json`; verify them again after the pilot.

### Task 2: Generate Injection Calibration

**Files:**
- Read: `tools/gemini-illustrations/sources/biceps-brachii.jpg`
- Create: `tools/gemini-illustrations/calibration/biceps-brachii-atlas-v1.png`

- [ ] **Step 1: Build the normalized edit prompt**

Use the task prompt verbatim. Add the Atlas visual contract, strict source crop and laterality, fully opaque sanitized skin, cobalt rounded probe bar, solid crimson target circle, and no trajectory/crosshair/reticle.

- [ ] **Step 2: Generate one candidate through built-in image editing**

Use only `calibration/input/biceps-brachii.jpg` as the edit target.

- [ ] **Step 3: Inspect the result**

Verify exact output decoding, aspect ratio, viewpoint, laterality, pose, visible anatomy, marker geometry, opaque skin, clothing context, no unwanted additions, and consistent Atlas physique, ink linework, shading, and neutral background.

- [ ] **Step 4: Apply at most one focused correction if needed**

Repeat all invariants and request only the failed property be corrected. Save the correction as `biceps-brachii-atlas-v2.png`; do not overwrite v1. Record which version is selected.

### Task 3: Generate Position Calibration

**Files:**
- Read: `tools/gemini-illustrations/sources/supine-arm-abducted.jpg`
- Create: `tools/gemini-illustrations/calibration/supine-arm-abducted-atlas-v1.png`

- [ ] **Step 1: Build the normalized edit prompt**

Use the task prompt verbatim. Add the Atlas visual contract, strict source crop and laterality, and an explicit prohibition on all procedural overlays.

- [ ] **Step 2: Generate one candidate through built-in image editing**

Use only `calibration/input/supine-arm-abducted.jpg` as the edit target.

- [ ] **Step 3: Inspect the result**

Verify exact output decoding, aspect ratio, viewpoint, right-side laterality, raised-arm pose, visible anatomy, unchanged crop, opaque skin, source-aware clothing, no blue/red graphics or unwanted additions, and consistent Atlas physique, ink linework, shading, and neutral background.

- [ ] **Step 4: Apply at most one focused correction if needed**

Repeat all invariants and request only the failed property be corrected. Save the correction as `supine-arm-abducted-atlas-v2.png`; do not overwrite v1. Record which version is selected.

### Task 4: Generate Groin-Adjacent Calibration

**Files:**
- Read: `tools/gemini-illustrations/sources/adductor-longus.jpg`
- Create: `tools/gemini-illustrations/calibration/adductor-longus-atlas-v1.png`

- [ ] **Step 1: Confirm the source remains non-explicit**

Proceed only if no genital anatomy is visible. Preserve the exact clinical crop and never add anatomy outside it.

- [ ] **Step 2: Build the normalized edit prompt**

Use the task prompt verbatim. Add the Atlas visual contract and describe the subject as a non-explicit medical illustration of the proximal medial right thigh. Require no genital depiction, no sexualized framing, and no transparent anatomy.

- [ ] **Step 3: Generate one candidate through built-in image editing**

Use only `calibration/input/adductor-longus.jpg` as the edit target.

- [ ] **Step 4: Inspect the result**

Verify exact output decoding, aspect ratio, viewpoint, right-side laterality, frog-leg pose, visible proximal-thigh anatomy, unchanged crop, marker geometry, opaque skin, source-aware clothing, absence of genital or other unwanted additions, and consistent Atlas physique, ink linework, shading, and neutral background.

- [ ] **Step 5: Retry once with narrower clinical wording after each safety refusal**

Do not bypass provider safeguards. After any safety refusal, make exactly one retry using narrower non-explicit clinical wording. Park only if that narrower retry is also refused. If a successful image needs a visual correction and that correction is refused, it still receives its one narrower safety retry. Save successful corrections as `adductor-longus-atlas-v2.png` and retain v1.

### Task 5: Make Refusal Parking Durable

**Files:**
- Create: `tools/gemini-illustrations/task_queue.py`
- Modify: `tools/gemini-illustrations/generate.py`
- Modify: `tools/gemini-illustrations/handoff.py`
- Create: `tools/gemini-illustrations/test_task_queue.py`
- Create only after a double refusal: `tools/gemini-illustrations/parked-tasks.json`

- [ ] **Step 1: Write failing selector tests**

Cover an absent parking file, an empty parking file, exclusion of a parked ID from first-pass selection, exclusion from regeneration selection, and preservation of normal task order.

- [ ] **Step 2: Run the selector tests and verify they fail**

Run: `python3 -m unittest tools/gemini-illustrations/test_task_queue.py -v`

Expected: failure because the shared selector does not exist.

- [ ] **Step 3: Implement the shared queue selector**

Add a focused helper that loads task state and `parked-tasks.json`, returns regeneration tasks first, otherwise returns pending tasks without established output in manifest order, and always excludes approved or parked IDs.

- [ ] **Step 4: Use the shared selector in both automatic entry points**

Replace the independent eligibility logic in `generate.py` and `handoff.py` with the shared helper while preserving their current output and navigation behavior.

- [ ] **Step 5: Run selector and dry-run regression checks**

Run: `python3 -m unittest tools/gemini-illustrations/test_task_queue.py -v`

Expected: all tests pass.

Run: `python3 tools/gemini-illustrations/generate.py --dry-run --limit 3`

Expected: eligible tasks remain in manifest order and no parked ID appears.

- [ ] **Step 6: Persist parking only after a double refusal**

Create or update `parked-tasks.json` with the task ID, the two-refusal reason, and an ISO-8601 timestamp; mark its `tasks.md` heading `[!]`; rerun the selector test/dry run to confirm exclusion. If no double refusal occurs, do not create or change parking state.

### Task 6: Compare and Hand Off Calibration

**Files:**
- Read: `tools/gemini-illustrations/calibration/*.png`
- Do not modify: `tools/gemini-illustrations/output/`
- Do not modify: `tools/gemini-illustrations/review-status.json`

- [ ] **Step 1: Compare the three candidates side by side**

Verify consistent skin tone, ink line weight, shading, background, physique, marker colors, and rendering polish.

- [ ] **Step 2: Present all successful pilots for style acceptance**

Report exact calibration paths and disclose any refusal or unresolved visual defect.

Record the selected version for each task while retaining all generated versions until the user accepts or rejects the calibration style.

- [ ] **Step 3: Stop before production promotion**

Do not replace exact production outputs or update review state until the user accepts the calibration style.

- [ ] **Step 4: Verify production state is unchanged**

Re-check the saved hashes of existing production outputs and `review-status.json`. Confirm exact equality and confirm every selected calibration PNG decodes successfully.
