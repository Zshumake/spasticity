# Antigravity kickoff — medical atlas illustration batch

Open this folder (`NeuroInject/tools/gemini-illustrations/`) as the workspace in
Antigravity, start a new agent (Gemini 3 Pro with image generation), and paste
the mission below. The same text works for the follow-up regeneration passes.

---

## Mission (paste into the Agent Manager)

You are running a batch of medical-illustration image generations. Everything
you need is in this workspace folder. Follow README.md as the contract; this
mission restates the essentials.

SETUP — do once:
1. Read `gem-system-instructions.md` in full. Those are your illustration
   style rules for EVERY image you generate in this mission. Do not restyle,
   reinterpret, or "improve" on them.
2. Read `tasks.md` (45 tasks). Read `review-status.json`.

MODE SELECTION:
- If every task in `review-status.json` is "pending" and `output/` is empty,
  this is the FIRST PASS: work every unchecked `[ ]` task in tasks.md, top to
  bottom.
- Otherwise this is a REGENERATION PASS: work ONLY the tasks whose status in
  `review-status.json` is "regenerate". Never touch "approved" tasks. Never
  regenerate a "pending" task that already has an output file.

PER TASK — one at a time, never batched:
1. Load ONLY that task's source image from `sources/`.
2. Generate one image from: the system rules + that source image + the task's
   prompt from tasks.md, verbatim. On a regeneration pass, append one line:
   `Reviewer feedback on the previous attempt: <note from review-status.json>`
   (omit if the note is empty).
3. Save the image to the task's exact `output/` path from tasks.md (PNG).
4. Self-check against the SOURCE photo before moving on:
   - laterality and framing match the photo exactly
   - injection-mode: cobalt-blue probe bar and crimson dot sit where the
     painted marks are in the photo; position-mode: NO overlays at all
   - no extra limbs, digits, or fabricated anatomy outside the source crop
   If the check fails, regenerate once with the same prompt plus a one-line
   correction. If it fails again, leave the best attempt in place and mark the
   task `[!]` in tasks.md, then continue.
5. Mark the task `[x]` in tasks.md (or `[!]` as above).
6. On a regeneration pass only: set that task's status to "pending" in
   `review-status.json` (keep its note and rounds unchanged).

HARD RULES:
- Never write anything outside this folder. Never touch `../../assets/`.
- Never modify prompts, `tasks.json`, `picks.json`, or the source images.
- One source image per generation — never combine tasks.
- If image generation is unavailable or repeatedly failing, STOP and report
  which tasks remain, rather than substituting a different model or style.

DONE = every eligible task is `[x]` or `[!]`. Finish with a summary table:
task id | status | notes. The human reviews results with `python3 review.py`
and will start the next regeneration pass when ready.

---

## Notes for the human

- Progress is inspectable at any time: `tasks.md` checkboxes are the ground
  truth, `output/` holds the images.
- Review UI: `python3 review.py` → http://127.0.0.1:8123 (Approve /
  Regenerate with feedback notes).
- Loop: kickoff → review → paste the same mission again (it auto-detects the
  regeneration pass) → review → … until everything is approved.
- API alternative (no Antigravity, needs a key):
  `export GEMINI_API_KEY=... && python3 generate.py` then
  `python3 generate.py --regen` after each review round.
