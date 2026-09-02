---
date: 2026-06-10
topic: ux-and-teaching
focus: Improve UX on the NeuroInject app and strengthen its teaching/educational value
---

# Ideation: NeuroInject UX & Teaching Improvements

## Codebase Context

NeuroInject is a Flutter clinical reference (6 platforms) for botulinum toxin
injection in spasticity/dystonia. 68 muscles, 29 patterns, brand-specific dosing
(Botox / Dysport / Xeomin / Myobloc). Three screens: a pattern-first dashboard,
a muscle-detail page (procedure + study modes), and a standalone dilution
calculator. State via `provider`; routing via `go_router`; content is data-driven
from `assets/data/*.json`.

**Leverage points found by grounding (verified against the data):**

- **Three disconnected "islands."** The dose calculator is reachable only from the
  sidebar — there is no link from a muscle's dose into it, and `CalculatorScreen`
  takes no arguments. Pattern → muscle → dose → calculator is not one flow.
- **Safety data present but inert.** `ToxinBrand.maxDoseNote` encodes per-brand
  session ceilings (Botox 400 U; Dysport 1000 U UL / 1500 U LL; etc.) as prose,
  but nothing totals a multi-muscle plan against them.
- **Modeled-but-dead data.** `MarkerPosition{body,x,y}` is populated for **51/68**
  muscles and `UltrasoundGuide.probeDiagram{cx,cy,angle,length}` for **61/68**, yet
  neither is rendered anywhere — parsed then discarded. `ue_pattern_classification`
  (Jost–Hefter–Reißig) is loaded into rich typed models but referenced nowhere in
  the UI.
- **No teaching layer at all.** No quiz, flashcard, spaced repetition, case mode,
  onboarding, or progress tracking. The structured per-muscle data (landmarks,
  danger zones, dose ranges, pattern→muscle maps) is a ready-made question bank.
- **Empty/inconsistent content slots.** `referenceImages`, `hasReferenceImage`,
  and `videoUrl` are **0/68** (US-reference galleries and the VideoLinkCard are
  wired but never render). Myobloc is selectable in the calculator but has **0/68**
  per-muscle doses. Anatomy images (204 PNGs) are the one fully-populated gallery.

## Ranked Ideas

### 1. Session planner with a live max-dose ceiling guard
**Description:** A persistent "injection tray" the clinician adds muscles to (with
a chosen dose, brand, and L/R side) while browsing. A tray badge shows running
per-brand unit totals checked against each brand's session ceiling, turning
amber/red as the plan approaches or exceeds the cap. Add-to-tray lives on muscle
cards and the detail header; a pattern card can bulk-add its whole muscle set.
Extend `print_cheat_sheet` to emit the whole session as one handout, and persist
trays so a returning patient's prior plan reloads in one tap (≈12-week cycle).
**Rationale:** This is the app's biggest gap and converged across all four
ideation frames. It turns a passive lookup into an active safety guardrail at the
exact moment cumulative-overdose errors happen, and it's the connective tissue
that fuses the three islands into one flow. ~80% of the data already exists.
**Downsides:** Largest surface area here — needs a new provider, tray UI, a
structured `maxSessionUnits` field (today the ceilings are prose), and laterality
modeling. Deliberately local-only/no PHI to stay simple and safe.
**Confidence:** 90%
**Complexity:** High (ships in slices: tray+total → ceiling meter → bulk-add → save/reload)
**Status:** Explored — core slices implemented 2026-06-10. Persistent `SessionPlanner`
provider (local, no PHI) holding one line per muscle with brand / per-side dose /
laterality (R/L/Bilateral, bilateral doubles the total); per-brand running totals
vs a new structured `ToxinBrand.maxSessionUnits` ceiling, rendered as an amber/red
meter on `/session`; add-to-session action on the muscle detail app bar; top-bar
Session chip with a live count badge; clear-session. Follow-ups also shipped
2026-06-10: **pattern bulk-add** ("Add all N to session" on a pattern's muscle
grid), **named save/reload** of sessions for recurring 12-week visits (local
on-device, via a session-options menu), and a **whole-session PDF handout**
(`printSessionPlan`, multi-page table with per-brand totals vs ceiling). Covered
by `test/data/session_planner_test.dart` and `test/screens/session_screen_test.dart`.
All originally-scoped slices for this idea are now complete.

### 2. Deep-link a muscle's dose into the pre-filled calculator
**Description:** A "Calculate this" affordance beside each brand dose chip opens
the calculator pre-seeded with that brand and the muscle's dose, so the draw-up
volume appears with zero retyping. Give `CalculatorScreen` optional
`initialBrand`/`initialDose` params and a `/calculator?brand=&dose=` route.
**Rationale:** The single most obvious disconnect, fixable in hours. Also the
natural first step toward (and entry point into) the session planner.
**Downsides:** Doses are stored as *ranges* ("50–100"), so it must seed a sensible
default (midpoint) the user can adjust.
**Confidence:** 95%
**Complexity:** Low
**Status:** Explored — implemented 2026-06-10. Tappable brand dose chips (study
view) and a "Calculate draw-up volume" link (procedure view) deep-link into
`/calculator?brand=&dose=` (dose = range midpoint); `CalculatorScreen` seeds from
those params. Covered by `test/screens/calculator_deep_link_test.dart`.

### 3. "Learn Mode" — an active-recall teaching layer over existing data
**Description:** An opt-in trainer built entirely from current content. Lead with
the two highest-value drills: **(a) Danger-Zone drill** — "which adjacent structure
is most at risk here?" generated from `dangerZones`; **(b) Case-based pattern
reasoning** — a posture vignette from the Jost classification asks the learner to
name the pattern and pick the target muscles, then reveals the expert plan. Add a
spaced-repetition scheduler (landmarks ⇄ muscle ⇄ dose cards) as the retention
engine and a per-region competency map for onboarding.
**Rationale:** Directly answers "help teach." Trainees learn this by apprenticeship,
which doesn't scale; the 68 muscles × patterns × danger zones is already a
structured curriculum, so a teaching layer is nearly free content-wise and widens
the audience to residents/fellows. Active recall of danger zones builds the
reflexive caution passive reading never instills.
**Downsides:** Biggest *new* feature concept; needs a quiz engine, a scheduler, and
the progress persistence the app currently lacks. Scope creep risk — start with one
drill.
**Confidence:** 80%
**Complexity:** High (start with the Danger-Zone drill alone to prove it)
**Status:** Unexplored

### 4. Interactive body-map navigation (activate `MarkerPosition`)
**Description:** A spatial entry screen: anterior/posterior body silhouettes with
tappable dots placed from each muscle's `MarkerPosition`; tap a dot to open the
muscle, and light up a selected pattern's muscles in place. Matches how clinicians
actually localize ("posterior calf, these four").
**Rationale:** Fully-modeled data (51/68) that is currently rendered nowhere; a
spatial map is a more intuitive navigation mode than text search + filter chips,
and reinforces the pattern-first philosophy.
**Downsides:** Needs body-silhouette assets and a coordinate space; **17 muscles
lack markers** (mostly face/intrinsics) and need coords or a list fallback.
**Confidence:** 75%
**Complexity:** High
**Status:** Unexplored

### 5. Render the probe-placement diagram from `ProbePosition` (best ROI)
**Description:** In the probe/needle area (today an empty "ADD PHOTO" slot for all
68 muscles), draw the probe as an oriented rectangle on the muscle's anatomy image
with a `CustomPainter`, using the already-parsed `ProbePosition{cx,cy,angle,length}`.
**Rationale:** Highest effort-to-value ratio in the set: 61/68 muscles already
carry this data, parsed then thrown away, while the photo slot is permanently
empty. Converts a dead slot into a useful schematic for essentially free — no
photography needed.
**Downsides:** A schematic isn't a real ultrasound/probe photo; 7 muscles lack the
data and keep the current placeholder.
**Confidence:** 85%
**Complexity:** Medium
**Status:** Unexplored

### 6. Dose provenance & "verified against labeling" stamps
**Description:** Attach a source citation and a "verified on <date>" stamp to each
muscle's dose block, surfaced as a small provenance line and stored structurally in
`muscles.json`; add a `tools/` audit that flags doses with missing or stale
verification.
**Rationale:** The app's credibility rests on "verify doses against labeling," yet
provenance lives only in the author's head and the source PDFs. Making it a
first-class, visible, auditable field compounds — it builds clinician trust, makes
updates reviewable, and underpins any future sharing/teaching. Trust as a feature.
**Downsides:** Requires a one-time backfill of citations; ongoing discipline to keep
"verified" dates current.
**Confidence:** 80%
**Complexity:** Medium
**Status:** Unexplored

## Rejection Summary

| # | Idea | Reason rejected / folded |
|---|------|--------------------------|
| 1 | Multi-muscle session cheat-sheet (PDF) | Folded into #1 as a sub-feature |
| 2 | Pattern → tray bulk-add | Folded into #1 |
| 3 | Laterality (L/R/bilateral) as session attribute | Folded into #1 (dose-doubling guard) |
| 4 | Save/reload a session for recurring visits | Folded into #1 (phase 2) |
| 5 | Patient-specific dose + volume in Procedure mode | Folded into #1 + #2 |
| 6 | Spaced-repetition flashcards | Folded into #3 as the retention engine |
| 7 | US step-ordering / "name the layer" drill | Folded into #3 (one drill type) |
| 8 | Competency checklist & progress map | Folded into #3 (onboarding/progress) |
| 9 | "Spot the landmark" tap-the-target | Higher effort; fuzzy proximity scoring on letterboxed images — #3 stretch goal |
| 10 | Brand dose-conversion trainer | Folded into #3; overlaps the calculator |
| 11 | Pearl-of-the-day push microlearning | Adds notification/platform complexity; folded into #3 |
| 12 | Jost pattern-diagnosis *wizard* (clinical) | Overlaps #3's case drill and #4; avoid triple-counting Jost |
| 13 | Hand-type (claw/clenched/lumbrical) selector | Narrow; a minor pre-filter — quick win, not a top survivor |
| 14 | Annotated injection-site overlay on anatomy | Partially overlaps #4 markers; secondary to #5 |
| 15 | Searchable, linked source-textbook layer | PDFs now gitignored/78 MB; OCR+copyright cost high vs value — risky stretch |
| 16 | Structured danger-zone hazard model | Enabler for #3, not user-facing on its own |
| 17 | Surface/honest-empty video links | Minor; belongs in the data-gap cleanup below |

## Data & content gaps surfaced (fix-its, not ideas)

These are concrete inconsistencies the grounding turned up — worth a small cleanup
pass independent of the ideas above:

- **Myobloc is selectable in the calculator but has 0/68 per-muscle doses** — the UI
  implies a brand the content can't support.
- **`videoUrl` 0/68** — `VideoLinkCard` is wired but never renders (note: `ultrasound.videoSource`
  holds video references as plain text; the two halves could be joined).
- **`referenceImages` / `hasReferenceImage` 0/68** — the US-reference gallery and the
  `.gitkeep`'d `us_reference/` + `probe_placement/` dirs are still unpopulated.

## Session Log
- 2026-06-10: Initial ideation — 33 candidates across 4 frames (bedside workflow,
  teaching, connect/complete, reframes/leverage) → 6 survivors after adversarial
  filtering and cross-cutting synthesis.
- 2026-06-10: Implemented idea #2 (muscle dose → calculator deep-link) directly as
  a quick win, skipping brainstorm. Marked Explored.
