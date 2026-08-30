# Gemini illustration pipeline (Antigravity work package)

Turns the clinic's marked reference photographs (blue probe line + red needle dot painted
on skin) into publication-grade atlas illustrations, one Gemini image generation per photo.

## Contents
- `gem-system-instructions.md` — the custom-Gem instruction set. Pass as system context on EVERY generation.
- `tasks.md` — 45 tasks, human-readable checklist with the exact per-image prompt.
- `tasks.json` — the same tasks, machine-readable.
- `sources/` — staged input photos (2048 px), one per task, named by muscle/group.
- `output/` — write generated illustrations here, named exactly as each task's `output` field.

## How to run the batch
Three equivalent paths — the handoff page is the recommended one:
0. **Handoff page (one at a time, you drive):** `python3 handoff.py` →
   http://127.0.0.1:8125. Each screen is one task: Copy image → ⌘V into the
   Gemini chat in Antigravity, Copy prompt → ⌘V, send; then drag/paste the
   generated image back onto the drop zone — it is saved to the correct
   output path, ticked in tasks.md, and the next task appears. Reviewer-marked
   regenerations automatically jump the queue with feedback appended. Paste
   the Gem system instructions (top of the page) once per Gemini session.
1. **Antigravity (no API key):** open this folder as the workspace and paste the
   mission from `ANTIGRAVITY-KICKOFF.md` into the Agent Manager. Re-pasting the
   same mission after a review round automatically becomes a regeneration pass.
2. **Gemini API (unattended):** `export GEMINI_API_KEY=...` then
   `python3 generate.py` (first pass) / `python3 generate.py --regen` (after
   review). `--dry-run` previews the plan; `--only <id>` runs one task.

## Agent workflow (follow exactly)
1. Read `gem-system-instructions.md` once; use it as the system instruction for every generation.
2. Open `tasks.md`. Process tasks strictly top to bottom, one at a time.
3. For each task:
   a. Attach ONLY that task's `sources/<id>.jpg`.
   b. Send that task's prompt verbatim. Do not merge, shorten, or "improve" prompts.
   c. Save the image to the task's `output` path (PNG).
   d. Self-check before moving on: correct laterality vs the photo; blue bar and red dot at the
      photographed locations (injection mode) or no overlays at all (position mode); no extra
      limbs/digits; framing matches the source crop. If the check fails, regenerate once with the
      same prompt plus a one-line correction; if it fails twice, mark the task `[!]` and move on.
   e. Tick the task's checkbox in `tasks.md` (`[ ]` -> `[x]`, or `[!]` if parked).
4. Do NOT copy anything into `assets/images/clinical/` — the `copy_to_assets` lists are executed
   by a human after reviewing the output folder.

## Notes
- Sources named `*-phi` relate to ultrasound images that carry patient identifiers; the
  photographs themselves are clean, and the standard sanitization rules apply regardless.
- `piriformis` and `pronator-quadratus` prompts describe LOW-confidence markers (see
  `docs/photo-matching/index.html`); generate them anyway — they are flagged for human review.

## Regeneration pass (after human review)
The reviewer runs `python3 review.py` and marks each generated image Approve or
Regenerate (with a feedback note). That state lives in `review-status.json`.

When asked to run a regeneration pass:
1. Read `review-status.json`. Work ONLY the tasks whose `status` is `"regenerate"`.
2. For each: re-run the generation with the task's original prompt from `tasks.json`
   PLUS this line appended:  `Reviewer feedback on the previous attempt: <note>`
   (skip the line if the note is empty). Attach the same source image as before.
3. Save to the task's usual `output` path (the slot is empty — the rejected image
   was archived to `output/rejected/`).
4. In `review-status.json`, set that task's `status` back to `"pending"` (leave
   `note` and `rounds` untouched) so the reviewer sees it as fresh.
5. Never touch tasks marked `"approved"` or `"pending"`.
