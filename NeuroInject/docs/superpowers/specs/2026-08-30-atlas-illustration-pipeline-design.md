# Atlas Illustration Pipeline Design

## Goal

Replace the manual Gemini copy/paste loop with a Codex-operated, review-gated workflow that converts the existing clinical photographs into consistent medical textbook illustrations. Preserve the current task order, output filenames, review state, and asset-copy boundary.

## Scope

The first stage is a three-image calibration pilot:

- `biceps-brachii`: injection mode and procedural markers.
- `supine-arm-abducted`: positioning mode without procedural markers.
- `adductor-longus`: non-explicit groin-adjacent clinical framing.

After the user accepts the pilot style, the same normalized prompt contract is applied to the remaining queue. Existing output files are not overwritten during calibration. Pilot candidates live under `calibration/`, outside `output/`, and are not visible to `review.py`. The accepted candidate is promoted to the task's exact output path before entering the normal review UI.

## Visual Contract

Every image uses the Atlas standardized patient: an average healthy adult male physique, hairless and sanitized skin, clean ink contours, soft volume-based shading, and a neutral light-gray clinical background. Skin remains fully opaque. The illustration must preserve the source crop, viewpoint, laterality, pose, and visible anatomy without expanding the frame.

Injection-mode images retain only two procedural graphics: a cobalt-blue bar with rounded caps at the source probe footprint and a solid crimson circle at the source needle target. Position-mode images contain neither marker. Clothing is context-aware and is never invented when absent from the source.

Groin-adjacent inputs are treated as non-explicit clinical anatomy. The generator must preserve the source crop, avoid adding genital anatomy, avoid sexualized presentation, and depict only the visible proximal thigh and relevant landmarks.

The normalized Atlas contract in this specification replaces `gem-system-instructions.md` for this workflow. Each task prompt from `tasks.json` is retained verbatim as task-specific context. If older instructions conflict, task-specific anatomical facts take precedence, followed by the new mode rule: position mode has no overlays; injection mode has only the rounded cobalt probe bar and solid crimson target circle, with no trajectory, crosshair, or reticle.

## Data Flow

1. Read the next eligible task from `tasks.json` and its state from `review-status.json`. Regeneration tasks run first with their reviewer note appended. Otherwise, run `pending` tasks with no established output in `tasks.json` order. Never modify an `approved` task.
2. Load the task's single source image as the edit target.
3. Combine the global Atlas contract with the task prompt without changing the task's anatomical facts.
4. Generate one non-destructive pilot candidate under `calibration/`.
5. Inspect framing, laterality, anatomy, marker geometry, opacity, and unwanted additions.
6. Make at most one focused correction per iteration.
7. After calibration/style acceptance, promote the candidate to the task's established output filename and return it to the existing review loop. This acceptance does not set the task to `approved`; only the existing per-task review action may do that or authorize copying to app assets.
8. After successful regeneration, set the task status back to `pending` without changing its `note` or `rounds`, and keep `tasks.md` synchronized with whether the exact production output exists.

## Failure Handling

Safety refusals are not bypassed. For a non-explicit clinical image, retry once with narrower language emphasizing medical education, visible proximal-thigh anatomy only, and no genital depiction. If the request is still refused, record the task in `parked-tasks.json` with its reason and timestamp, mark it `[!]` in `tasks.md`, and exclude IDs present in that file from automatic selection. Removing its entry and restoring `[ ]` explicitly resumes it.

Anatomical or compositional failures remain reviewable rather than being silently accepted. No generated image is copied into `assets/images/clinical/` until it has passed the existing human approval step.

## Verification

Each pilot is checked against the source for crop, aspect ratio, laterality, pose, marker placement, marker shape, clothing context, opaque skin, absence of extra anatomy, and stylistic consistency. The three pilots are also compared side by side before the batch continues.

## Source Data Safeguards

Only the staged source image for the active task is sent to the image provider. Unrelated workspace files, EXIF metadata, and other task images are not included. Generated results remain within the provider operation and this workspace; they are not intentionally shared or retained elsewhere by the workflow. Before the first provider call, the operator must confirm that the staged photographs are authorized and sufficiently de-identified for third-party image processing.
