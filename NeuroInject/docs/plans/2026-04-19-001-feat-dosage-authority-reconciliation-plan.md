---
title: Dosage Authority Reconciliation for US Residents
type: feat
status: active
date: 2026-04-19
origin: docs/brainstorms/2026-04-19-dosage-authority-reconciliation-requirements.md
deepened: 2026-04-19
---

# Dosage Authority Reconciliation for US Residents

## Enhancement Summary

**Deepened on:** 2026-04-19
**Sections enhanced:** 13 phases + architectural overview + testing + governance
**Research agents used:** data-integrity-guardian, accessibility-specialist, test-architect, architecture-strategist, compliance-auditor, framework-docs-researcher, performance-engineer, ui-designer, flutter-expert, healthcare-engineer
**Legal-advisor agent:** refused (usage policy) — real counsel review required for final disclaimer copy, which is the correct posture anyway.

### Key improvements surfaced by deepening

1. **`BrandDose` becomes a sealed class** (`StandardDose | LimitedEvidenceDose`) rather than a nullable-fields + boolean sentinel — Dart 3 pattern matching enforces exhaustive UI handling at compile time. (flutter-expert, data-integrity-guardian)
2. **Dosing data splits into its own JSON** (`assets/data/muscle_dosing.json`) keyed by muscle id, separate from anatomy. Different lifecycles (dosing refreshes quarterly; anatomy stable for years), cleaner freeze boundaries, and the Muscle class stops trending toward god-object. (architecture-strategist)
3. **New `DoseRow` shared widget + `ResolvedDose` value object** replace ad-hoc rendering in each of the 7 surfaces. PDF generation receives pre-resolved doses — no `BuildContext` inside `pw.*` trees. (architecture-strategist)
4. **Pre-reconciliation JSON archived at `assets/data/archive/muscles-2026-04-15.json`** with SHA pin — preserves chain of custody for clinical audit trail; never rewrites git history. (data-integrity-guardian, compliance-auditor)
5. **FDA indication text must be verbatim from DailyMed** with setid + retrieval date — paraphrase is a 21 CFR 201.56 misleading-labeling risk. (compliance-auditor)
6. **Per-muscle "Reviewed YYYY-MM-DD" + App clinical reviewer** (name + credentials) attribution — this is reference-app convention (UpToDate, DynaMed) and residents are trained to look for it. (healthcare-engineer)
7. **AAN Simpson 2016 rendered struck-through/dimmed when cited as historical context** and never allowed to be the sole authority for a visible dose. (healthcare-engineer)
8. **Amber contrast ISSUE:** the plan's assumption that `onTertiaryContainer` guarantees 4.5:1 is WRONG for a custom `#E17055`-seeded scheme — contrast must be measured and asserted. Amber-next-to-terracotta is a hue-collision risk; ui-designer recommends cooler/darker amber plus never-filled + dashed-border for limited-evidence. (accessibility-specialist, ui-designer)
9. **Off-label goes in Semantics `label`, not `hint`** (hints are user-disableable). Single flat `Semantics` label is WRONG — use `explicitChildNodes` with focusable citation + badge children. (accessibility-specialist)
10. **PDF is not WCAG-compliant** — the `pdf` package does not emit tagged PDFs / structure trees. Flagged as known gap; HTML companion export is the mitigation if screen-reader access to the cheat sheet becomes a requirement. (accessibility-specialist, framework-docs-researcher)
11. **Web-render perf is a potential blocker:** 408 Text.rich + 204 Wrap + 68 Semantics nodes may drop frames while scrolling on CanvasKit; MergeSemantics at card level (not container on every row) and const TextSpans + RepaintBoundary are required. (performance-engineer)
12. **No mechanical BoNT-A brand conversions, ever.** Reference apps explicitly warn against 1:1 Xeomin / 3:1 Dysport computed ratios. Each brand is shown at its own labeled range only. Make this an explicit non-goal. (healthcare-engineer)
13. **Migration script hardening:** `.lock` sentinel, `--checkpoint` resume, mandatory `--dry-run` with SHA-pinned diff, `fsync` before `os.replace`, idempotency test. (data-integrity-guardian)
14. **Freeze enforced by CI, not discipline** — grep-based architecture test fails the build if any file outside the resolver reads `dosage.botox`/`.xeomin`/`.dysport` directly. (data-integrity-guardian, architecture-strategist)
15. **Governance thresholds encoded in CI** — fail build if `sources-last-verified` > 365 days for AAN tier, > 90 days for FDA tier. Human judgment stays in docs; mechanical rules go in code. (architecture-strategist)

### New considerations discovered

- **App store compliance hurdle:** Apple §1.4.1 / §5.1.1 and Google Play Medical Device policy require pre-first-use disclaimer modal, "educational reference" store-listing copy (never "clinical decision support"), and honest Health Apps declaration. Factor into Phase 13 release gate.
- **Calculator / dilution explainer scope:** must stay strictly unit-conversion / dilution arithmetic to remain inside the 21st Century Cures §3060 CDS exemption. No "recommended dose for this patient" button — would flip the app into SaMD territory.
- **Trademark acknowledgment** required: BOTOX®/Xeomin®/Dysport® with manufacturer names, plus explicit "not affiliated with or endorsed by" statement. Never display manufacturer logos.
- **Retired-guideline CI rule:** `assert(sourceTier != retired || hasSecondarySource)` — retired sources must never be the sole authority for a displayed dose.
- **Release-snapshot discipline:** every release tags `assets/data/archive/muscles-vX.Y.Z.json` for 6-year retention. If a resident is ever subpoenaed about what the app displayed on date X, the git tag answers it.
- **Performance blockers to gate release:** web list-view scroll fps (≥58fps p95) and web Semantics perf with screen readers.

### Contradictions flagged for resolution

- **Brand stacking direction.** ui-designer proposes "horizontal-primary, vertical-secondary hybrid" on the hero. healthcare-engineer says reference apps overwhelmingly stack brands **vertically** as labeled rows. → Resolution: accept ui-designer's hybrid on the hero (dose chips horizontal scan is existing affordance) but use vertical stacking on muscle cards and print — adopt vertical ordering by FDA approval date within indication per healthcare-engineer's convention.
- **Legal disclaimer wording.** legal-advisor agent refused; compliance-auditor provided structural guidance but is not counsel. → Resolution: plan's Phase 11 produces draft copy from template corpora, but the draft is explicitly marked "requires counsel review before ship" in the release gate.

---

## Overview

NeuroInject currently displays per-muscle botulinum-toxin dose ranges for Botox, Xeomin, and Dysport, but every dose in the app is unsourced: there is no citation infrastructure, no FDA-label indication, and no disclaimer. A recent audit against the Jost Atlas found NeuroInject's doses run 1.5–3× higher than Jost across 30+ muscles. Safety risk is directly clinical: residents acting on these numbers with no source could over- or under-dose patients. Commits `deeaaf2`/`e31c82c` (2026-04-15) did a partial re-sourcing citing "Allergan PI + Albanese 2021 + Esquenazi 2013 + Wissel 2009" with a mechanical Xeomin 1:1 and Dysport 3:1 conversion — but those sources were not captured in the data model, mix US and European authorities, and the mechanical Dysport 3:1 is on the high end of the 2.5–3× conversion range (which helps explain the "higher than Jost" pattern).

This plan builds the citation data layer, resolves every muscle's dose to a named US authority (or marks it "limited evidence"), adds inline source attribution and a per-brand-per-age-per-extremity FDA on/off-label badge to every dose surface, and establishes a governance cadence so sources don't silently drift.

## Problem Statement

**Three intertwined problems:**

1. **No source tracking.** The `Dosage { botox, xeomin, dysport }` model carries ranges but no source, year, or FDA-indication metadata. Zero citation infrastructure exists in the repo (repo research confirmed across `lib/`, `assets/`, and JSON).
2. **Unverified provenance with mixed authority lineage.** The only cited doses (from 4 days ago) blend US and European sources with mechanical brand conversions — not a single defensible US standard.
3. **Unknown dose authority post-2025.** The Simpson 2016 AAN guideline — originally named as the off-label authority in the brainstorm — was **retired by AAN on April 7, 2025** (<https://www.neurology.org/doi/10.1212/WNL.0000000000002560>). No replacement guideline has been identified. This is a material research gap the plan must resolve before patching.

**Why it matters:** a PM&R or neurology resident trusting NeuroInject cannot defend any single dose to an attending. Lack of FDA on/off-label surfacing makes the app feel authoritative when it may be off-label in ways the resident can't see.

## Proposed Solution

A three-track reconciliation, run partly in sequence and partly in parallel:

**Track A — Research & authority assignment.** Confirm/supersede the AAN guideline; verify the 2026-04-15 audit citations; compile a brand × age × extremity FDA approval matrix; assign a named US authority to every muscle or flag it "limited evidence."

**Track B — Data model & patch.** Extend `Dosage` with a per-brand `BrandDose { range, source, fdaStatus }` wrapper (backward compatible). Add `AuthorityResolver` Provider. Script the `muscles.json` patch via a new `tools/apply_dosage_authority_reconciliation.py` mirroring the repo's existing `apply_*.py` convention.

**Track C — UI surfaces.** Add inline source attribution (UpToDate-style tappable superscript) and per-brand FDA badges (Material 3 amber/blue semantic roles) to all 7 dose consumer files. Extend `safety_callout.dart` with `offLabel | limitedEvidence | contraindication` variants. Update `print_cheat_sheet.dart` with footer citation legend. Mirror `docs/credits/anatomy-sources.md` for dose sources.

**Freeze discipline (R10):** until Tracks A+B land, no new dose-dependent features ship. The 7 consumer files enter a "bug fixes only" freeze; the freeze list is explicitly enumerated in Phase 10.

## Technical Approach

### Architecture

**Data model (Dart):**

```dart
// NEW — per-brand wrapper object
class BrandDose {
  final String? range;                // "50-100" — legacy-string-compatible
  final SourceRef? source;            // citation metadata
  final FdaStatus? fdaStatus;         // per-brand indication
  static BrandDose? tryParse(dynamic v) { ... }  // accepts String (legacy) OR Map
}

class SourceRef {
  final String name;                  // "Simpson 2016 (retired)" or "Botox PI (AbbVie)"
  final int? year;
  final String? url;                  // DailyMed setid-based or DOI
  final String? retiredYear;          // null unless source has been retired
  final SourceTier tier;              // fdaLabel, peerGuideline, textbook, endorsement, manufacturer
}

class FdaStatus {
  final bool approved;                // on-label if true
  final String? indication;           // "adult upper limb spasticity"
  final int? approvalYear;
}

// EXTENDED — Dosage keeps existing API via transitional getters
class Dosage {
  final BrandDose? botox, xeomin, dysport;
  String? get botoxRange => botox?.range;   // legacy-compat
  // ... same for xeomin, dysport
}
```

JSON schema gains optional fields; legacy parsing preserved via `tryParse`. A top-level `"schemaVersion": 2` lands in `muscles.json`.

**State management:** new `AuthorityResolver` exposed via `Provider<AuthorityResolver>` (stateless, pure) above `MuscleDataProvider`. Resolves `(muscle, brand) → BrandDose` with a fixed precedence: explicit muscle-level attribution → brand default → limited-evidence sentinel. Both `muscle_detail.dart` and `print_cheat_sheet.dart` use the same resolver.

**UI — inline citation:** UpToDate-style superscript numeral tappable from a `Text.rich` TextSpan. Tap opens a bottom-sheet with full citation + retrieval date + outbound link. Deduplicated reference list per screen. `onSurfaceVariant` color, 12px font — demoted visually relative to the dose.

**UI — FDA badge:** per-brand compact pill using a custom 20px Container (not Material `Chip`, which is too heavy). Two-state color: blue = FDA approved for indication, amber = off-label. Text is brand + age-extremity (e.g. "Dysport: pediatric LL"). `Wrap` layout flows to multi-line on narrow widths.

**UI — limited-evidence callout:** extend `lib/widgets/safety_callout.dart` with a `variant` enum. Replaces the dose chip when no US authority is available — shows "Limited evidence — consult supervisor or institutional protocol."

**PDF rendering:** `pw.RichText` in `print_cheat_sheet.dart` for inline citations; footer reference legend keyed to superscript numerals; amber-bordered container for off-label indicator.

**Credits infrastructure:** mirror existing `docs/credits/anatomy-sources.md` + `anatomy-*-manifest.json` + in-app `credits_page.dart`. Add `docs/credits/dosage-sources.md` + `assets/credits/dosage-sources-manifest.json` + a "Dose Sources" section on the Credits screen. Includes a "sources last verified YYYY-MM-DD" stamp.

### Implementation Phases

#### Phase 1: Source discovery & authority slate (research-only) ✓ COMPLETE 2026-04-19

**Deliverable:** [`docs/audits/2026-04-dose-sources-discovery.md`](../audits/2026-04-dose-sources-discovery.md) — drafted; awaiting clinical author sign-off.

**Headline findings** (see audit for full detail):
- AAN Simpson 2016 **retired April 7, 2025**; no replacement published.
- Simpson 2016 **never had per-muscle dose ranges** — only brand-level Level A/B/C/U ratings. The brainstorm's "FDA → AAN → Mayo" hierarchy was never workable; replaced with a revised hierarchy in the audit.
- "Albanese 2021" in commit `deeaaf2` is likely a misattribution of **Dressler 2021** (*J Neural Transm* 128(3):321-335, DOI 10.1007/s00702-021-02312-4). Needs clinical author confirmation.
- "Mayo BoNT Handbook" in the brainstorm is almost certainly the **Cambridge Manual of Botulinum Toxin Therapy, 3rd ed. (2024)** (Truong, Dressler, Hallett, Zachary, eds.; ISBN 9781009098663).
- **Xeomin is NOT FDA-approved for adult lower-limb or pediatric lower-limb spasticity in the US.** Approved in Canada (Dec 2024) and UK only.
- Wissel 2009 is European — dropped from the authority hierarchy per brainstorm R5.
- 7 clinical-author questions must resolve before Phase 2 proceeds.

**Tasks:**

- Identify the post-2025 AAN replacement guideline for adult BoNT spasticity (critical open question — may be none). If none, decide on fallback authority (peer-reviewed review, Cambridge Manual of Botulinum Toxin Therapy 3e 2024, or equivalent).
- Verify publication metadata for the 2026-04-15 audit's cited sources (Albanese 2021, Esquenazi 2013, Wissel 2009, Allergan PI).
- Verify existence / ISBN of any "Mayo BoNT Handbook" referenced in the brainstorm — research suggests this may be the Cambridge Manual under a different name; confirm with clinical author.
- Verify AANEM BoNT-spasticity position (research suggests AANEM endorses the retired AAN rather than publishing standalone).
- Compile FDA brand × age × extremity approval matrix from DailyMed with approval years (per research: Botox adult UL 2010, adult LL 2016, ped UL 2019, ped LL 2020 excluding CP; Dysport adult UL 2015, adult LL 2017, ped UL 2019, ped LL 2016; Xeomin adult UL 2015/2018, ped UL 2020; **Xeomin NOT approved for any LL**).
- Produce the "authority hierarchy" decision table: tier 1 FDA label → tier 2 peer guideline → tier 3 peer textbook → tier 4 society endorsement → tier 5 manufacturer guide.

**Success criteria:**

- Every brand × age × extremity cell in the FDA matrix has an approval year or explicit "not approved" entry with a DailyMed URL.
- Post-2025 AAN replacement is named, OR the plan explicitly decides to use a different peer authority with rationale.
- Every 2026-04-15 audit citation verified or flagged for replacement.

### Research Insights

**FDA verbatim requirement (compliance-auditor).** Indication text shown next to the FDA badge must be quoted **verbatim from DailyMed's SPL "Indications and Usage" section**, in quotation marks, with the DailyMed setid + retrieval date. Paraphrase is a 21 CFR 201.56 misleading-labeling risk, even when the paraphrase is technically accurate. Add audit field `indicationVerbatimQuote: true/false` to `FdaStatus` so CI can enforce.

**No mechanical brand conversion (healthcare-engineer).** Reference apps explicitly warn against BoNT-A mechanical conversion ratios (Xeomin 1:1 / Dysport 2.5:1 or 3:1). Each brand's dose comes from that brand's label or cited source — conversions only appear in narrative clinical pearls, never as computed numbers. Plan adds this as an explicit non-goal to prevent recurrence of the 2026-04-15 audit pattern.

**Retired-guideline posture (healthcare-engineer).** Keep Simpson 2016 visible but render it dimmed/struck-through, pointing to any superseding source. Never allow a retired source to own a visible dose alone. Matches AAN's own retirement-page convention.

**AANEM + Mayer & Esquenazi (research gaps).** Research could not verify a standalone AANEM BoNT-spasticity position (AANEM endorsed the retired AAN rather than publishing their own) or Mayer/Esquenazi "Toronto Spasticity Institute" protocol (authors are affiliated with MossRehab, not Toronto; no textbook found under that exact name). Phase 1 removes these from the authority slate unless clinical author confirms otherwise.

**Mayo "Handbook" likely mis-named (research gap).** Searches surface the Cambridge University Press "Manual of Botulinum Toxin Therapy" 3e 2024 (ISBN 9781009098663) rather than any Mayo-authored title. Phase 1 reconciles with the clinical author; the plan treats Cambridge Manual as the likely tier-3 textbook authority.

#### Phase 2: Per-muscle authority assignment

**Deliverable:** `docs/audits/2026-04-dose-authority-assignments.json` — machine-readable, per-muscle `{botox, xeomin, dysport}` source assignment.

**Tasks:**

- For each of the 68 muscles and each of the 3 brands, apply the authority hierarchy to name ONE source (or mark `{tier: "limited-evidence"}`).
- For each muscle, capture FDA approval status per brand per age band.
- Flag muscles likely to fall into "no US authority" (expected: paraspinals, QL, rectus abdominis, some intrinsic foot, pelvic floor, cervical paraspinals for spasticity).
- Human review by clinical author before Phase 3 begins — this is the last chance to catch authority-assignment errors before they propagate into code and JSON.

**Success criteria:** every `(muscle, brand)` cell has an authority OR `limited-evidence` sentinel. Clinical sign-off recorded.

### Research Insights

**Reference-app convention for no-authority (healthcare-engineer).** The plan's "Limited evidence — consult supervisor" phrasing is acceptable but not idiomatic. Reference-app convention is "No established dose — consult attending" (Lexicomp pattern) or "No established dose — institutional protocol applies" (pediatric pattern). Adopt "No established dose — consult attending" for this resident audience; it matches convention and honors the supervisory relationship already present.

**Per-muscle clinical reviewer (healthcare-engineer).** UpToDate, DynaMed, and Medscape all attribute content to named physician reviewers. Phase 2's authority assignment JSON gains `reviewedBy: { name, credentials, reviewedDate }` at both the muscle level and the app level. This is a trust signal residents are trained to seek.

**Architecture: separate dosing JSON (architecture-strategist).** Dosing data has a distinct lifecycle from anatomy (quarterly FDA check, annual AAN check) — worth splitting to `assets/data/muscle_dosing.json` keyed by muscle id, loaded by a sibling `DosingProvider`. `AuthorityResolver` composes both. Makes the Phase 10 freeze physically enforceable (dosing files are in a separate directory). Worth doing before Phase 5 writes to muscles.json. **Plan impact:** Phase 2 output JSON becomes the seed of `muscle_dosing.json`; Phase 5 writes to the new file, not to muscles.json.

#### Phase 3: Comparison report

**Deliverable:** `docs/audits/2026-04-dose-authority-comparison.md` — side-by-side matrix.

**Tasks:**

- For each muscle × brand: columns for [current NeuroInject range, Jost range, FDA label range if on-label, chosen-authority range, delta].
- Flag material discrepancies (>25% shift, or range flips up vs down).
- Flag muscles losing a dose entirely (moving to "limited evidence").
- Present to clinical author for approval before Phase 5 patch.

### Research Insights

**Indication section synchronized with badges (healthcare-engineer).** Best practice is to render a dedicated "FDA-approved indications" read-only panel on each muscle detail page, projected from the SAME canonical indication table that drives the inline per-(muscle, age, extremity) badges. Never hand-enter the same fact in two places — drift is inevitable. Phase 3 comparison table becomes the source of truth feeding both UI projections.

**Retired-guideline CI invariant (compliance-auditor).** Add to the Phase 12 test battery: `assert(sourceTier != retired || hasSecondarySource)`. No muscle should have a retired guideline as its sole cited authority.

#### Phase 4: Data model extension

**Deliverables:**

- `lib/models/muscle.dart`: new `BrandDose`, `SourceRef`, `FdaStatus`; extended `Dosage`.
- `lib/data/authority_resolver.dart`: new `AuthorityResolver` class.
- `lib/data/muscle_provider.dart`: Provider wiring.

**Tasks:**

- Add new classes with `tryParse` accepting legacy String shape (mirrors `_parseStringOrList` / `Dosage.tryParse` pattern).
- Add transitional getters (`dosage.botoxRange` etc.) so existing 7 consumer files compile unchanged.
- Add top-level `"schemaVersion": 2` to muscles.json at patch time (Phase 5).
- Add fail-loud schemaVersion check on load.
- Unit tests: legacy JSON loads with new code; new JSON fields are read; schemaVersion mismatch is caught.

**System-wide impact — see dedicated section below.**

### Research Insights

**Sealed class for `BrandDose` (flutter-expert, data-integrity-guardian).** Upgrade from `BrandDose { limitedEvidence: bool, range: String? }` sentinel to Dart 3 sealed hierarchy:

```dart
sealed class BrandDose {
  const BrandDose();
  static BrandDose? tryParse(dynamic v) => _parseBrandDose(v);
}
final class StandardDose extends BrandDose {
  final String range;
  final SourceRef source;
  final FdaStatus? fdaStatus;
  const StandardDose({required this.range, required this.source, this.fdaStatus});
}
final class LimitedEvidenceDose extends BrandDose {
  final String reason;
  const LimitedEvidenceDose({required this.reason});
}
```

UI code becomes `switch (dose) { case StandardDose(:final range) => ...; case LimitedEvidenceDose() => ...; }` with compile-time exhaustiveness. Dart 3 pattern matching makes this cheap (~20 extra lines total) and catches every missed case at compile time. Worth it for safety-critical rendering.

**`SourceRef` stays final + enum tier (flutter-expert).** Sealed variants per tier would force pattern-matching on a distinction that rarely matters for rendering. Keep `enum SourceTier { fdaLabel, peerGuideline, textbook, endorsement, manufacturer, retired }`.

**Unknown-key detection (data-integrity-guardian).** Add `static const knownKeys` set on each model; `tryParse` asserts `map.keys.difference(knownKeys).isEmpty` in debug builds, logs to analytics in release. Prevents silent data-loss when future JSON keys are added without model updates.

**Resolver signature gains `ResolutionContext` now (architecture-strategist).** `resolve(muscle, brand, {ResolutionContext? ctx})` — even if unused in v1, it avoids a breaking signature change when institutional overrides eventually land. Current call sites pass `null`.

**Brand-keyed internal map for future brand extensibility (architecture-strategist).** `Dosage` stays with three named getters (`botox`, `xeomin`, `dysport`) as the public surface, but internally backs them with `Map<BrandId, BrandDose>`. Adding a 4th toxin (e.g., Daxxify/prabotulinumtoxinA) then requires only an enum entry, not a Dosage schema change.

**Splitting dosing data into its own JSON (architecture-strategist).** `assets/data/muscle_dosing.json` keyed by muscle id, loaded by a sibling `DosingProvider`, separate from anatomy's muscles.json. Different lifecycles; cleaner freeze boundary; prevents Muscle from becoming a god object. Phase 5 writes to the new file.

**Equality + hashCode on the dose classes (flutter-expert).** `Object.hash(range, source, fdaStatus)` — needed for golden test comparisons and Riverpod-style key equality. Skip on `Muscle` itself (reference equality still fine; no caller benefit).

**Provider-based memoization via Riverpod `Provider.family` OR a manual `Map<(muscleId, brand), ResolvedBrandDose>` precomputed at init (flutter-expert, performance-engineer).** For 68×3 = 204 entries, precomputing once at load (~1ms) beats lookup-time memoization. Cache invalidates when `MuscleDataProvider` reloads.

**`SchemaMismatchScreen` route instead of raw exception (architecture-strategist).** Fail-loud is correct, but route to a dedicated error screen with reload button and changelog link rather than crashing. Throw in debug builds, route in release. Same safety, better UX.

**Pattern-matching spots in UI (flutter-expert).** High-value use sites: dose chip rendering (`switch (dose) { case StandardDose(...) => Chip, case LimitedEvidenceDose(:final reason) => WarningChip, case null => SizedBox.shrink() }`), citation footer (`SourceRef(:final name, :final year?)` destructure), off-label banner (`if (dose case StandardDose(fdaStatus: FdaStatus(approved: false)))`).

#### Phase 5: muscles.json patch

**Deliverables:**

- `tools/apply_dosage_authority_reconciliation.py` — migration script following the repo's `apply_*.py` idiom.
- Updated `assets/data/muscle_dosing.json` (new file per architecture split — see Phase 4 insights) plus `schemaVersion: 2` in muscles.json.
- Archive file `assets/data/archive/muscles-2026-04-15.json` (pre-reconciliation snapshot, read-only).
- `tools/golden_muscles_schema_test.py` — JSON schema golden snapshot.

**Tasks:**

- Script reads `docs/audits/2026-04-dose-authority-assignments.json`, merges into `muscle_dosing.json`.
- Every (muscle, brand) cell either (a) gets a `StandardDose` with source + fdaStatus, or (b) a `LimitedEvidenceDose(reason: "No established dose — consult attending")` per healthcare-engineer convention.
- Record the script run date in `docs/credits/dosage-sources.md`'s "last verified" stamp.
- Run schema golden snapshot test.

### Research Insights

**Migration script hardening (data-integrity-guardian).** Plan's "temp file + atomic rename" is necessary but not sufficient. Add:

1. `.muscles.json.lock` sentinel — refuses to run if present (prevents concurrent developers).
2. `--checkpoint FILE` — records per-muscle completion so a batched clinical-author run resumes across sessions.
3. Mandatory `--dry-run` emitting a unified diff to `docs/audits/2026-04-dose-patch-preview.diff`; real run requires `--apply` plus the diff SHA as witness.
4. `os.fsync(tempfile)` **before** `os.replace` — on macOS, `os.replace` alone does not guarantee durability across power loss.
5. Idempotency test — running the script twice produces byte-identical output.

**Audit-trail archive (data-integrity-guardian, compliance-auditor).** Commit a read-only snapshot `assets/data/archive/muscles-2026-04-15.json` in the **same PR** that ships the reconciliation. Reference from `docs/credits/dosage-sources-last-verified.md` with the SHA. Commit message explicitly notes "previous values archived at `<path>`; see commits `deeaaf2`, `e31c82c` for original provenance." Never rewrite git history. Rationale: if a resident is ever subpoenaed about what the app displayed on date X, the archive + git tag answer it. Aligns with FDA 21 CFR 820.180 record-retention spirit (6-year retention even though HIPAA doesn't apply).

**Pre-commit hooks (data-integrity-guardian).**

- Reject changes to `assets/data/archive/`.
- Require a matching `docs/audits/*-dose-patch-preview.diff` SHA entry in the commit when `muscles.json` or `muscle_dosing.json` changes.

**No mechanical brand conversions (healthcare-engineer).** The migration script MUST NOT derive Xeomin from Botox (1:1) or Dysport from Botox (3:1). Every brand cell must come from that brand's cited source or be marked `LimitedEvidenceDose`. This is an explicit non-goal in the migration script — add it as a guard in the script itself that refuses to write a computed conversion.

#### Phase 6: UI — inline source attribution

**Deliverables:**

- `lib/widgets/citation_span.dart` — `TextSpan` builder for inline citations.
- `lib/widgets/citation_sheet.dart` — bottom-sheet with full citation + retrieval date + outbound link.
- Updates to: `muscle_detail.dart` (hero dose chips + `dosageNote` line), `muscle_card.dart` (`_tag()` extended), `print_cheat_sheet.dart` (`pw.RichText`).

**Tasks:**

- Implement `Text.rich` pattern per research recommendation.
- Tappable superscript opens `showModalBottomSheet` with citation detail.
- Deduplicated per-screen reference list (multiple doses sharing a source cite once).
- Per accessibility-specialist correction: use `Semantics(container: true, explicitChildNodes: true, ...)` with `MergeSemantics` on dose text + separate focusable nodes for citation + off-label badge. **NOT** a single flat label (that buries the interactive citation).
- Golden widget tests per consumer: on-label state, off-label state, limited-evidence state, retired-source state.

### Research Insights

**Introduce `DoseRow` shared widget + `ResolvedDose` value object (architecture-strategist).** All 7 surfaces rendering dose+source+FDA states are exactly the pattern a shared widget prevents from drifting. `DoseRow.full` (detail hero), `DoseRow.compact` (card), `DoseRow.print` (PDF) accept a `ResolvedDose` plain value object. Calculator / dilution / syringe consume it read-only. Without this, Phase 7 will ship three divergent FDA badge implementations inside 6 months.

**PDF receives pre-resolved doses (architecture-strategist).** Do NOT call `context.read<AuthorityResolver>()` inside `pw.*` trees. Signature becomes `printCheatSheet(List<ResolvedDose> doses)`. Caller resolves on the Flutter side. Makes PDF unit-testable without a widget tree; enables future isolate-based rendering.

**Accessibility pattern — per dose row (accessibility-specialist):**

```dart
Semantics(
  container: true, explicitChildNodes: true,
  label: 'Botox 50 to 100 units',
  child: Row(children: [
    MergeSemantics(child: Row(children: [doseText, brandText])),
    Semantics(button: true, label: 'Citation: Simpson 2016, open details', child: supTap),
    Semantics(label: 'FDA off-label for this muscle', child: badge),
  ]),
);
```

Critical: off-label announcement goes in `label`, NOT `hint` (hints can be disabled by screen-reader users). WCAG 1.3.1, 3.3.2, 4.1.2.

**Focus stops — cap at 6 per card (accessibility-specialist).** Three brands × 3 focus stops (dose+source merged, citation tappable, badge) = 6 stops. Not the 9 the naive implementation would produce. Use `FocusTraversalGroup(policy: ReadingOrderTraversalPolicy())` around the Wrap of badges. WCAG 2.4.3.

**Tap-target sizing (accessibility-specialist).** Superscript renders at 10pt visually but is wrapped in `SizedBox(width: 24, height: 24)` with `InkResponse` centered inside. Meets WCAG 2.5.8 AA (24×24 minimum).

**Decorative separators excluded (accessibility-specialist).** `ExcludeSemantics(child: Text(' · '))` around every middle-dot — screen readers announce it as "middle dot" otherwise. WCAG 1.3.1.

**Amber contrast — MUST measure for custom seed (accessibility-specialist, ui-designer).** Plan's claim that M3's `onTertiaryContainer` guarantees 4.5:1 is WRONG for a `#E17055`-seeded scheme. Add a golden contrast test:

```dart
test('fda off-label contrast', () {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFE17055), brightness: Brightness.light);
  expect(contrast(scheme.onTertiaryContainer, scheme.tertiaryContainer), greaterThanOrEqualTo(4.5));
});
```

If the seeded amber fails or collides with terracotta (real risk per ui-designer), hard-code cooler/darker amber (`#B45309` light / `#FBBF24` dark) and document stepping outside the seeded palette.

**M3 status pill is Container, not Chip (framework-docs-researcher, ui-designer).** Material 3 `Chip` is 32dp min-height (too tall) and has interactive state layers (wrong affordance for read-only status). Use `Container` + `BorderRadius.circular(999)` + `colorScheme.tertiaryContainer`/`secondaryContainer`. 20px height, 4px radius, 8px horizontal padding.

**`pw.RichText` + `pw.MultiPage` footer (framework-docs-researcher).** For PDF: per-span styling works via `pw.TextSpan(style: pw.TextStyle(...))`. Multi-page footer uses `pw.MultiPage(footer: (ctx) => ...)` — fires per page with `ctx.pageNumber / ctx.pagesCount`. Reference legend goes at the end of `build:` list for single-page, or in `footer:` for every-page repeat.

**`pdf` package does NOT emit tagged PDFs (framework-docs-researcher, accessibility-specialist).** Known limitation. PDF output is visual-only, not WCAG-compliant for screen readers. Mitigations: set `PdfDocument(title:, author:, subject:)` metadata for basic discoverability; offer an HTML companion export if screen-reader access to the printed sheet ever becomes a hard requirement. Document as "Known limitation" in Phase 12 test report.

**Perf — const TextSpans + RepaintBoundary (performance-engineer).** 48 Text.rich paragraph layouts per visible frame is borderline 16ms on CanvasKit. Mitigations: `const` TextSpans where possible, hoist `TextStyle` out of build, `RepaintBoundary` per card, collapse dose + badge into a single Text.rich with `WidgetSpan` to halve paragraph count. **Gates release on web** if raster p95 > 16ms.

**Perf — MergeSemantics at card level, not per row (performance-engineer, accessibility-specialist).** 204 `container: true` nodes doubles the a11y tree and slows CanvasKit's DOM overlay rebuild. Use `MergeSemantics` at card level, reserve `container: true` for detail view where node count is bounded. Re-test after implementation with VoiceOver on Safari.

#### Phase 7: UI — FDA on/off-label badge

**Deliverables:**

- `lib/widgets/fda_badge.dart` — per-brand status pill.
- Extended `lib/widgets/safety_callout.dart` with `variant: SafetyVariant.offLabel | limitedEvidence | contraindication`.
- Updates to: `muscle_detail.dart` hero (full per-brand row), `muscle_card.dart` (reduced single-badge), `print_cheat_sheet.dart` (text-only).

**Tasks:**

- Compact Container pill (20px height, 4px radius) following research recommendation — not Material `Chip`.
- `colorScheme.tertiaryContainer` background for off-label; blue approved color; neutral gray with dashed border for no-data.
- WCAG AA contrast verified by a test — **not assumed** (see Phase 6 insight). Color is never the sole signal; text always present; a glyph also present (`✓` / `△` / `?`).
- Wrap layout flowing to multi-line at 600px and 840px breakpoints.
- `ExpansionTile` summary on muscle-card grid ("3 brand indications") expanding to per-brand on tap.

### Research Insights

**Hero layout — horizontal-primary with vertical-secondary attribution strip (ui-designer).** Dose chips stay horizontal in their current Wrap. Below them, a NEW three-column "attribution strip" renders FDA pill + source citation line per brand. On narrow (<768px) the strip collapses to one brand-per-row stacked layout. Dose-scan left-to-right is preserved; source/FDA is demoted via smaller type + lighter surface (`surfaceContainerLowest`).

**Muscle card — combined dose+FDA pill (ui-designer).** One primary-brand dose+FDA combined pill (e.g., "100–200u · Botox FDA✓") with a "+2 brand indications ⌄" expander showing the other two brands in place. Glyph `✓` / `△` / `?` communicates FDA state non-color-only. When all three brands are off-label, add a 2px left amber accent bar (only in that case, so it's meaningful). When all three are limited-evidence, the pill is replaced with a neutral-gray mini-callout "No established dose — tap for guidance."

**Print cheat sheet stays 1 page (ui-designer).** Citations + FDA land inline via superscripts + a 2-column micro-legend in the footer. 2-page breaks the cheat-sheet contract. Reclaim space by collapsing the 5-clause disclaimer into a 3-line `·`-separated run and merging landmarks + technique into a 2-column block.

**Amber hue-collision with terracotta (ui-designer).** The base amber `#F59E0B` is too close to the terracotta `#E17055` primary in hue and warmth. Mitigations: shift to cooler/darker amber (`#B45309` light / `#FBBF24` dark); never use amber as a filled surface >20% area — use it as border + icon tint with `surfaceContainer` fill; ensure every state also has a glyph and text code (`✓` / `△` / `?`). Terracotta remains the only filled warm color in the app.

**Typography tokens defined (ui-designer).**

| Role | Family | Weight | Size/line |
|---|---|---|---|
| Dose number (hero chip) | Sora | 600 | 18/22 |
| Dose number (card pill) | Sora | 600 | 14/18 |
| Dose number (print) | Source Sans | 700 | 11/14 |
| FDA badge text | Source Sans | 500 | 11/14, 0.02em tracking |
| FDA badge glyph | Source Sans | 700 | 12 |
| Source citation line | IBM Plex Mono | 400 | 12/16 |
| Superscript numeral | Source Sans | 600 | 9 (0.7em baseline shift) |
| Limited-evidence callout | Source Sans | 500 | 13/18, italic |
| Print disclaimer | Source Sans | 400 | 7/9 |

**New theme tokens.** `color.fda.approved.{bg,fg,border}`, `color.fda.offLabel.{bg,fg,border}`, `color.fda.limited.{bg,fg,border}` (dashed), `radius.badge = 4`, `radius.pill = 999`, `size.badge.height = 20`, `space.attribution.strip = 12`.

**Reference-app brand ordering (healthcare-engineer).** When stacking brands, order by FDA approval date for the indication shown, not alphabetically. Falls back to alphabetical when co-indicated. Never collapse into a single "BoNT-A" row.

#### Phase 8: Credits & source governance page

**Deliverables:**

- `docs/credits/dosage-sources.md` — mirrors `anatomy-sources.md`.
- `assets/credits/dosage-sources-manifest.json` — machine-readable source registry.
- Update `lib/screens/credits_page.dart` with "Dose Sources" section.
- `docs/credits/dosage-sources-last-verified.md` — human log of source review dates.
- **New — App clinical reviewer attribution.** Both in-app (Credits screen) and per-muscle (reviewed date). Populated from Phase 2 authority assignments.
- **New — Trademark acknowledgment section** in Credits: "BOTOX is a registered trademark of AbbVie Inc.; Dysport of Ipsen Biopharm Ltd.; Xeomin of Merz Pharma GmbH & Co. KGaA. NeuroInject is not affiliated with or endorsed by these companies or by the FDA."

### Research Insights

**Don't generalize the credits infrastructure yet (architecture-strategist).** Two instances (anatomy + dosing) does not justify an "Attributions" abstraction (Rule of Three). Mirror the existing structure directly. Shared contract is the manifest JSON shape — enforce via JSON schema, not a runtime abstraction. Revisit when a third attribution family appears.

**Per-muscle reviewed date (healthcare-engineer).** UpToDate, DynaMed, Medscape all attribute content to named physician reviewers with dates — residents are trained to look for this. Add `reviewedBy` + `reviewedDate` fields both at app level and at muscle level. UpToDate's two-line topic currency stamp is the template.

**No manufacturer logos (compliance-auditor).** Word-mark acknowledgment is nominative fair use; logos increase affiliation-confusion risk. Display "BOTOX®" not the Allergan / AbbVie logo. First mention per screen pairs brand with generic (onabotulinumtoxinA, etc.) — the plan already does this.

#### Phase 9: Governance — source-review cadence (R11 — added via SpecFlow)

**Deliverables:**

- `docs/solutions/best-practices/dosage-authority-governance.md` — first entry in `docs/solutions/` (directory does not yet exist; create it).
- Calendar reminders: quarterly FDA DailyMed label refresh, annual AAN guideline refresh, any manufacturer injector-guide republication.

**Tasks:**

- Document the review cadence, the named reviewer, the escalation path if a retired guideline isn't replaced, and the hotfix path for mid-release FDA approval.
- State that source drift triggers a new `apply_dosage_authority_reconciliation.py` run, not hand edits.

### Research Insights

**Encode the mechanical rules in CI (architecture-strategist).** Rule of thumb: dates and thresholds belong in CI, human judgment stays in docs. Add a CI check that fails the build if:

- `sourcesLastVerified` for any tier-1 FDA source is older than 90 days.
- `sourcesLastVerified` for any tier-2 peer guideline is older than 365 days.
- Any source has `tier == retired` AND no secondary source for the same (muscle, brand) cell.

Keep in docs: named reviewer, escalation path on retired-guideline non-replacement, hotfix procedure. CI check is ~15 lines Dart; write alongside the markdown governance doc.

**Hotfix policy (compliance-auditor + data-integrity-guardian).** Data-only JSON update ships as a minor version bump; no code freeze needed if schema is stable. Re-run the migration script in hotfix branch; PR gates same as full release (Phase 3 sign-off).

#### Phase 10: Feature freeze & unfreeze enumeration (R10)

**Deliverables:**

- Explicit freeze list in the plan + CI check blocking changes to those files.
- `docs/freezes/2026-04-dose-freeze.md` — rationale + unfreeze criterion.

**Frozen during reconciliation (per research inventory):**

1. `lib/screens/guide/muscle_detail.dart` (hero dose chips, dosageNote line)
2. `lib/widgets/muscle_card.dart` (`_tag`, dose chip)
3. `lib/widgets/print_cheat_sheet.dart` (dose rendering)
4. `lib/screens/calculator/calculator_screen.dart` (dose math)
5. `lib/widgets/dilution_explainer.dart`
6. `lib/widgets/syringe_visual.dart`
7. `lib/data/toxin_data.dart` (brand-level `maxDoseNote`)

Bug fixes to existing behavior are permitted; new features that read `dosage.*` or a Dosage getter are blocked until Phase 5 ships.

Parallel-permitted work during freeze: the UI facelift plan (`noble-waddling-torvalds`), pattern-first landing (`2026-04-15`), and anatomy-reference-images plan (`2026-04-15-anatomy-reference-images-plan.md`) — confirmed by brainstorm R10 and SpecFlow §4a review.

### Research Insights

**Two-tier freeze with CI enforcement (architecture-strategist, data-integrity-guardian).** The 7-file hard list is Tier 1. Tier 2 is "touches require plan-owner review" files discovered by `grep -l 'Dosage\|dosage\.' lib/`. Encode as a CI check that computes the actual dependency closure on every PR, rather than maintaining a static list.

**Grep-based architecture test (data-integrity-guardian).** Add `test/architecture/no_direct_dosage_access_test.dart` that walks `lib/` and fails if any file outside the resolver references `.botox`, `.xeomin`, `.dysport` on a `Dosage`. Pattern match; false positives are acceptable because fixing them is trivial. Prevents the freeze from relying on human discipline alone.

**Transitional getter sunset (flutter-expert, architecture-strategist).** `dosage.botoxRange` getters get `@Deprecated('Use dosage.botox?.range directly. Removed 2026-06-01.')` annotation. Phase 12 explicitly deletes them. Without a sunset they outlive the migration as permanent debt.

#### Phase 11: Liability disclaimer

**Deliverables:**

- Disclaimer text in `lib/screens/about_page.dart` (or wherever About lives — research confirmed no existing disclaimer).
- Footer disclaimer in print_cheat_sheet.dart.
- `lib/data/strings.dart` centralized copy (preparing for future i18n per SpecFlow §5c).

**Disclaimer structure (five clauses, drafted from template corpora):**

1. For educational and informational purposes only.
2. Not intended as medical advice, diagnosis, or treatment.
3. Use of this app does not create a physician-patient relationship.
4. Clinical decisions remain the responsibility of the treating clinician.
5. Information may not reflect the most recent FDA labeling or guidelines; verify against current prescribing information before use.

**Additional clauses surfaced by research:**

6. **No PHI collection** — "NeuroInject does not collect, store, or transmit patient-identifying information. Do not enter patient data into any field." (compliance-auditor, addresses HIPAA surface + app-store privacy nutrition label).
7. **No FDA or manufacturer endorsement** — "NeuroInject is not affiliated with or endorsed by the FDA, AbbVie, Merz, Ipsen, or any other company or agency." (compliance-auditor, trademark + advertising risk).
8. **Off-label dose hazard** — "Some displayed doses are for indications not approved by the FDA. Off-label use is the prescriber's responsibility; verify against current prescribing information." (compliance-auditor, FDA SIUU 2023 guidance framing).
9. **Pediatric specificity** — "Pediatric dosing varies by weight and indication; verify against current pediatric prescribing information and institutional protocol before administration." (compliance-auditor).
10. **No clinical-efficacy claim** — "NeuroInject makes no claim of diagnostic or therapeutic efficacy." (compliance-auditor, FTC §5 advertising risk).

**Display contexts (6 contexts per legal-advisor agent spec, but agent refused — draft required before counsel review):**

- Full disclaimer (About screen, 200–300 words).
- Compact footer (Muscle detail, <40 words, taps to full).
- Print/PDF footer (every page, <80 words, includes retrieval date placeholder).
- Off-label inline warning (next to off-label badge, <20 words).
- Limited-evidence callout ("No established dose — consult attending...", 30–50 words).
- Retired-guideline note (next to retired citation, <25 words).
- First-launch modal (all 5 base clauses, mandatory "I understand" with acceptance persisted).

### Research Insights

**Counsel review required before ship (legal-advisor agent refused; compliance-auditor flagged explicitly).** The disclaimer drafts produced by the plan are derived from template corpora and compliance analysis. They are NOT a substitute for qualified counsel. Release gate in Phase 13 includes a mandatory counsel-review checkbox.

**Verbatim FDA text + trademark ® on first mention (compliance-auditor).** FDA indication text is quoted verbatim from DailyMed (21 CFR 201.56 — paraphrase is a misleading-labeling risk). Trademark ® on first mention is best practice though not legally required for nominative fair use.

**Versioned disclaimers in git (compliance-auditor).** Disclaimer text is committed to `lib/data/strings.dart` (preparing for future i18n) AND changes are tracked by a `disclaimerVersion` field visible in the About screen ("Disclaimer v1.2, updated 2026-04-19"). Supports subpoena-defense: "what did the app display on date X."

**No marketing copy of clinical validation (compliance-auditor).** App-store listings and marketing copy must NOT use "clinically validated," "trusted by clinicians," or "evidence-based decision support" — these are FTC §5 triable claims. Use "educational reference for medical trainees" consistently.

**First-launch modal respects WCAG no-time-limit (accessibility-specialist).** No countdown; user must explicitly tap "I understand" to dismiss. No auto-dismiss. WCAG 2.2.1.

#### Phase 12: Testing

**Deliverables:**

- `test/golden/muscles_schema_test.dart` — snapshot test for JSON structure.
- `test/models/dosage_invariant_test.dart` — every dose has source or limited-evidence sentinel.
- `test/data/muscles_json_migration_test.dart` — load legacy + new fixtures, both succeed.
- `test/widgets/citation_span_test.dart` + golden PNGs for on-label / off-label / limited-evidence / retired-source states.
- `test/widgets/fda_badge_test.dart` + goldens.
- `test/widgets/print_cheat_sheet_test.dart` + PDF golden.
- `test/a11y/muscle_detail_semantics_test.dart` — Semantics node reading order.
- `test/architecture/no_direct_dosage_access_test.dart` — grep-based freeze enforcement.
- `test/models/brand_dose_unknown_keys_test.dart` — assertion on unknown JSON keys (debug).
- `test/data/archive_preserved_test.dart` — archive file exists with pinned SHA.
- `test/data/migration_idempotent_test.dart` — running the script twice produces identical output.
- `test/perf/authority_resolver_bench.dart` + `integration_test/app_launch_time_test.dart` — 150ms launch ceiling.
- `test/widgets/fda_badge_contrast_test.dart` — measured WCAG contrast for seeded `#E17055` theme.
- `test/retired_source_invariant_test.dart` — no dose has a retired source as sole authority.
- CI gates on all above.

### Research Insights

**Coverage policy (test-architect).**
- 95% **line** coverage on `lib/domain/` (AuthorityResolver, DoseRange, migration).
- 100% **branch** coverage on AuthorityResolver precedence logic (use `coverage: ^1.7.2` + `lcov --branch-coverage`).
- 80% line coverage on UI widgets (goldens cover the rest).
- 100% of muscles asserted via data-driven invariant test (non-negotiable).
- Exempt generated files.

**Golden testing package (test-architect).** Use `alchemist: ^0.12.0` — CI-stable, handles macOS + web font differences, explicit `goldensConfig.enabled` per platform. `golden_toolkit` is unmaintained since 2023. Builtin `matchesGoldenFile` is flaky cross-platform.

**PDF golden strategy (test-architect).** Do NOT byte-compare PDFs (timestamp/xref drift). Render to PNG via `pdfx: ^2.7.0` then alchemist golden on the raster. Also parse with `syncfusion_flutter_pdf` and assert every expected muscle string + "Source:" line appears in text extraction.

**Property-based testing on dose-range parsing (test-architect).** Use `glados: ^0.2.0` for parsing edge cases ("50-100U", "100 U / site", "≤200U total"). Skip for AuthorityResolver — finite input space, table-driven clearer.

**Mutation testing narrowly (test-architect).** `mutation_test: ^1.2.6` on `lib/domain/authority_resolver.dart` and `lib/domain/dose_range.dart` only (~400 LOC). Weekly cron, not per-PR. Target mutation score ≥85%.

**Golden regeneration requires two-reviewer approval (test-architect).** Auto-regen on CI is unacceptable for a medical app — a dose overlay silently swapping to a wrong value would ship. Document `--update-goldens` policy in CONTRIBUTING: one clinical reviewer + one engineering reviewer required on any golden update PR.

**Accessibility guidelines (accessibility-specialist, test-architect).**

```dart
await expectLater(tester, meetsGuideline(textContrastGuideline));
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline)); // 44x44
```

Drop `androidTapTargetGuideline` — not a platform target. Add `accessibility_tools` package in debug builds for live overlay; run `axe-core` via Playwright on Flutter web build.

**Performance regression gate (performance-engineer, test-architect).** `integration_test` harness + `binding.traceAction()`:

```dart
final t = await binding.traceAction(() => app.main());
expect(t.timedValue('app_launch'), lessThan(Duration(milliseconds: 150)));
```

Allow 10% headroom (165ms) to avoid CI flakes; alert on 3-run rolling median, not single run.

**Explicit blockers for release (performance-engineer).**

1. Web scroll fps < 58 p95 on the muscle list view.
2. Web Semantics node count > 2× baseline after implementation.
3. Web first-paint p95 > 150ms from cold asset load.

All three are integration-tested; CI fails on regression.

#### Phase 13: Release

**Deliverables:**

- Release notes.
- Deployment (web: gh-pages auto-deploy per commit `0c0827d` convention; macOS: standard Flutter build).
- Post-release monitoring: ensure "Sources last verified" stamp renders; Credits page loads; no crash reports related to muscles.json parse.
- **Release snapshot:** `assets/data/archive/muscles-vX.Y.Z.json` committed and git-tagged. 6-year retention policy.

### Research Insights

**Release gate checklist (compliance-auditor, healthcare-engineer, accessibility-specialist).**

| Gate | Owner | Pass criteria |
|---|---|---|
| Clinical author sign-off on Phase 2 | Clinical author | Signed `docs/audits/2026-04-dose-authority-assignments.json` |
| Clinical author sign-off on Phase 3 | Clinical author | Signed comparison report |
| Counsel review of disclaimers | Counsel | All 7 display contexts reviewed |
| FDA indication verbatim verification | Engineering | CI passes `indicationVerbatimQuote` invariant |
| No mechanical brand conversion | Engineering | CI asserts no computed cross-brand dose |
| Performance — web scroll fps ≥58 p95 | Engineering | `integration_test` passes |
| Performance — web first-paint ≤150ms p95 | Engineering | `integration_test` passes |
| Accessibility — meets M3 AA guidelines | Engineering | `meetsGuideline` tests pass on macOS + web |
| Archive snapshot committed | Engineering | `assets/data/archive/muscles-2026-04-15.json` SHA matches last-verified log |
| App store listing copy reviewed | Product | No "clinical validation" / "decision support" language |
| First-launch disclaimer modal verified | QA | Shown once on fresh install; not bypassable |

**App store considerations (compliance-auditor).**

- **Apple App Store Guideline 1.4.1 / 5.1.1.** Pre-first-use disclaimer modal required. Health category declaration: "Medical reference / education."
- **Google Play Medical Device policy (2023).** Honest Health Apps declaration. No "clinical benefit" claims in listing.
- **Privacy nutrition label.** If no PHI is collected, declare "Data Not Collected" for every category.

**Six-year retention (compliance-auditor).** Every released build snapshots `muscles.json` + `dosage-sources-manifest.json` into a git tag and a committed `assets/data/archive/muscles-vX.Y.Z.json`. Aligns with FDA 21 CFR 820.180 spirit. Covers product-liability discovery (what did the app display on date X).

### Alternative Approaches Considered

**Alt 1 — Parallel fields on `Dosage` (option (a) from framework research).** Add `botoxSource`, `xeominSource`, `dysportSource` directly. Rejected because it scatters invariants, duplicates brand logic three times, and doesn't compose cleanly when `fdaStatus` and future fields follow.

**Alt 2 — Single `Source` on `Dosage` (option (c)).** One source covers all three brands. Rejected because FDA labels differ per brand: one Source cannot express "Botox on-label, Xeomin off-label, Dysport pediatric-only." This violates research finding #4b.

**Alt 3 — Keep Jost as a displayed alternative.** Brainstorm considered showing Jost alongside US authority. Rejected by R9 (single range shown) and reaffirmed by research showing UpToDate/DynaMed/Lexicomp all use authority-wins with source citation, not parallel ranges.

**Alt 4 — Wait for an updated AAN guideline before patching.** Rejected because (a) no indication a replacement is imminent, (b) current NeuroInject doses are unsourced and the safety risk is present today, (c) a retired-source note ("Simpson 2016 — retired 2025") honestly communicates the gap while FDA labels do the primary work.

**Alt 5 — Drop the calculator and dilution widgets entirely.** Considered because they'd need freezing anyway. Rejected because they're core educational features; freezing during reconciliation + unfreezing after is cleaner than removal. **Constraint surfaced by compliance review:** the calculator must stay strictly as unit-conversion / dilution arithmetic to remain inside the 21st Century Cures §3060 CDS exemption. A "recommended dose for this patient" button would flip the app into SaMD territory.

**Alt 6 — Keep dosing data inside `muscles.json` rather than splitting to `muscle_dosing.json`.** Original plan. Architecture review pushed to split them because (a) dosing has a distinct update cadence from anatomy (quarterly vs yearly), (b) freeze boundaries are physically enforceable when files are separate, (c) Muscle class stops trending toward god-object. Accepted the split — see Phase 4 insights.

**Alt 7 — Use `freezed` codegen for new model classes.** Rejected again (framework-docs-researcher + flutter-expert agree). Adds `build_runner` to a repo with zero existing codegen, fights the legacy-tolerant parsing pattern, and manual `tryParse` + sealed classes + `Object.hash` covers the use case in ~20 extra lines total.

## System-Wide Impact

### Interaction Graph

`AuthorityResolver.resolve(muscle, brand)` is called from:
- `muscle_detail.dart _buildHeroHeader()` per brand for dose chip render.
- `muscle_detail.dart _buildHeroHeader()` per brand for FDA badge.
- `muscle_detail.dart _buildHeroHeader()` per brand for source attribution line.
- `muscle_card.dart _tag()` for compact badge.
- `muscle_card.dart` dose chip.
- `print_cheat_sheet.dart` dose row.
- `print_cheat_sheet.dart` reference legend (deduplicated).
- `calculator_screen.dart` on brand switch + muscle switch.
- `dilution_explainer.dart` on muscle select.
- `syringe_visual.dart` on muscle select.
- `toxin_data.dart` maxDoseNote currently hardcoded — must be replaced with resolver call.

Every call site reads from `MuscleDataProvider` via `context.read<MuscleDataProvider>().getMuscle(id)` and then passes through `AuthorityResolver`. No call site constructs a Dosage from raw JSON — all go through the resolver.

### Error & Failure Propagation

- **Schema mismatch on load** — `muscles.json` schemaVersion != 2 must fail loudly at app init (show error screen, crash analytics event). No silent fallback to stale data.
- **Missing source** — the resolver returns `BrandDose.limitedEvidence` sentinel rather than null. UI renders the "Consult supervisor" callout. No brand row is ever blank.
- **Retired source** — `SourceRef.retiredYear != null` surfaces a "Retired YYYY" badge inline with the citation. UI does not hide retired sources — honesty > cleanliness.
- **Print/PDF rendering failure** — if a citation legend overflows the page, the pdf package truncates; the invariant test ensures every dose on a printed page has its citation token in the legend even if abbreviated.

### State Lifecycle Risks

- **Partial migration.** If `apply_dosage_authority_reconciliation.py` crashes mid-run, muscles.json could land in a half-migrated state. Mitigation: script writes to a temp file and atomic-renames only on successful completion; golden schema test gates commit.
- **Stale cache.** Flutter web caches assets aggressively. Bump `pubspec.yaml` version and append a cache-busting param on the gh-pages deploy config per commit `0c0827d` convention.
- **Provider rebuild loops.** `AuthorityResolver` is stateless (`Provider`, not `ChangeNotifier`) — will not trigger rebuilds on data change. `MuscleDataProvider` triggers rebuilds only on initial load; resolver depends on it via `context.read` (not `context.watch`) inside build methods.

### API Surface Parity

Every UI surface exposing a dose MUST also expose source + FDA status. Parity checklist:

| Surface | Dose | Source | FDA status | Limited-evidence variant |
|---|---|---|---|---|
| muscle_detail hero | current | add | add | add |
| muscle_detail study-mode | current | add | add | add |
| muscle_card | current | add (compact) | add (compact) | add |
| print_cheat_sheet | current | add | add | add |
| calculator_screen | current | add | add | add |
| dilution_explainer | current | add | add | add |
| syringe_visual | current | add | add | add |
| credits_page | N/A | new section | N/A | N/A |

### Integration Test Scenarios

1. **Load legacy muscles.json (pre-schema-v2) with new app code.** All fields that aren't present default to null; app renders without crash; "limited evidence" is shown for every brand.
2. **Load current muscles.json (post-patch) on ALL 7 consumer screens** and verify every dose row has source + FDA badge.
3. **Print a cheat sheet for a muscle with retired-source citation** (e.g., Simpson 2016) — verify "Retired 2025" label renders in the PDF legend.
4. **Authority resolver override precedence** — construct a test muscle with explicit muscle-level source AND brand default; assert muscle-level wins.
5. **Hotfix a DailyMed update mid-cycle** — replace one muscle's Botox `SourceRef` in muscles.json; verify detail + print + calculator all reflect the new source after app reload (no rebuild needed).

## Acceptance Criteria

### Functional Requirements

- [ ] Every dose range displayed in NeuroInject has an inline citation with source name and year (origin R7).
- [ ] Every muscle has a per-brand-per-age-per-extremity FDA on/off-label badge (origin R8, verbose format per origin key decision).
- [ ] Muscles with no US authority display "Limited evidence — consult supervisor or institutional protocol" instead of a dose number (origin R6 + no-authority key decision).
- [ ] The 7 dose consumer files (listed in Phase 10) all use `AuthorityResolver` — no direct `dosage.botox` access for display purposes.
- [ ] `muscles.json` has `schemaVersion: 2` and every brand cell has source metadata or limited-evidence sentinel.
- [ ] `docs/credits/dosage-sources.md`, `assets/credits/dosage-sources-manifest.json`, and the in-app Credits screen section exist and agree on the full source list.
- [ ] Print cheat sheet renders source attribution + FDA badge + reference legend.
- [ ] About screen shows the liability disclaimer (Phase 11, five-clause structure).
- [ ] "Sources last verified YYYY-MM-DD" stamp visible on the Credits screen.
- [ ] Pattern-first landing, anatomy-reference-images, and UI-facelift plans remain un-blocked during freeze.

### Non-Functional Requirements

- [ ] WCAG 2.1 AA contrast on all badges and callouts — verified via accessibility inspector on macOS and `flutter test --platform chrome` semantics tests.
- [ ] Screen reader announces "Dose X to Y units of brand, source name year, FDA status" as a single coherent unit per dose row.
- [ ] App launch time not regressed by more than 150 ms after Phase 4 lands (resolver init overhead).
- [ ] Golden JSON schema test gates commits; no unapproved schema drift reaches main.
- [ ] CI runs all widget goldens (Phase 12) on every PR.

### Quality Gates

- [ ] Clinical author sign-off on Phase 2 authority assignments before Phase 5 patch.
- [ ] Clinical author sign-off on Phase 3 comparison report.
- [ ] All tests in Phase 12 green.
- [ ] No PR to the 7 frozen files merges without a "freeze-override" label from the plan owner during freeze window.

## Success Metrics

- **Zero unsourced doses.** Every dose displayed has a named source or a limited-evidence sentinel. Measured by CI invariant test.
- **FDA badge coverage.** Every brand-per-muscle cell has an fdaStatus. Measured by CI invariant test.
- **Source currency.** "Sources last verified" stamp never older than 365 days for AAN, 90 days for FDA labels. Measured by governance cadence (Phase 9) and a CI date check.
- **Clinical defensibility.** Resident interview (post-release UX research) — every dose shown can be traced to its source.
- **Freeze compliance.** Zero new-feature PRs touching the 7 frozen files during the freeze window.
- **Performance budget held.** Web scroll fps ≥58 p95; web first-paint ≤150ms p95; web Semantics node count ≤2× pre-reconciliation baseline. Gated in Phase 13 release.
- **No mechanical brand conversions.** CI guard in migration script refuses to produce computed cross-brand doses. Every brand cell traced to its brand's own cited source or to `LimitedEvidenceDose`.
- **No FDA paraphrase.** `indicationVerbatimQuote: true` on every on-label `FdaStatus`. CI enforces.
- **Counsel-reviewed disclaimers.** Release gate blocks ship without counsel sign-off on all 7 display contexts.

## Dependencies & Prerequisites

- Clinical author availability for Phase 1 & 2 (authority assignment) and Phase 3 (comparison sign-off).
- DailyMed access for FDA label verification.
- Access to Cambridge Manual of Botulinum Toxin Therapy (3e, 2024) or whichever textbook authority is chosen in Phase 1.
- No new pub.dev dependencies — `provider`, `pdf`, `printing`, `google_fonts` already in `pubspec.yaml`. Plain Flutter and Material 3 for all UI.
- Brainstorm resolved all user decisions (no Resolve-Before-Planning items remain).

## Risk Analysis & Mitigation

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| AAN has no post-2025 replacement guideline | High | Moderate | Phase 1 identifies this; fallback to peer-reviewed textbook (Cambridge Manual 2024) documented as next-tier authority with "AAN 2016 retired" inline label. |
| Clinical author unavailable for sign-off | Medium | Moderate | Phase 2 and 3 are blocking; schedule sign-off windows in advance; appoint backup reviewer. |
| 2026-04-15 audit citations (Wissel 2009, Albanese 2021, Esquenazi 2013) are mostly European/unfit for US | Medium | High (already confirmed partially European) | Phase 1 re-validates every citation; Phase 2 replaces with US-preferred sources; honest freeze of the unsourced state until Phase 5. |
| Legacy app versions read new muscles.json and silently drop fields | Low | Low | schemaVersion fail-loud check; old builds refuse to load new JSON rather than degrade silently. |
| Retired Simpson 2016 used as authority for any muscle | Low | Low (caught by research) | Policy: retired sources are surfaced, not hidden; never used as primary authority. Hierarchy enforces "retired → demote one tier." |
| Print PDF line-wrap breaks citation legend | Low | Moderate | Golden PDF test per Phase 12 catches regressions. |
| Post-release mid-cycle FDA update | Low | High (eventually) | Governance hotfix path in Phase 9: data-only JSON update ships as a minor version bump; no code freeze needed. |
| FDA badge text too long for `muscle_card` space | Medium | High | `ExpansionTile` pattern recommended by framework research; reduced single-badge on card, full per-brand on detail. |
| Scope-creep into content expansion (landmarks, hazards) | Medium | Moderate | Brainstorm scope-boundary is explicit: "content expansion out of scope; separate future brainstorm." Plan owner rejects such PRs. |
| Web scroll fps regression from 408 Text.rich + 68 Semantics nodes | High | High | Performance blockers in Phase 13 release gate; MergeSemantics at card level + const TextSpans + RepaintBoundary per card required in Phase 6 implementation. |
| Amber FDA badge hue-collides with terracotta primary | Medium | High | Measured WCAG contrast test in Phase 12; cooler/darker amber token (`#B45309` / `#FBBF24`); never-filled + dashed border for limited-evidence; glyph + text code always present. |
| PDF not screen-reader accessible | Medium | High (known gap) | Documented as "Known limitation"; HTML companion export is the mitigation if requirement escalates. Not a blocker for Phase 13 because the PDF is one of many access paths. |
| FDA reclassification as SaMD | High | Low | Calculator scope strictly constrained (no patient-specific dose output); verbatim FDA indication text; "independently review" prong preserved via always-visible sources. Counsel review in Phase 13 gate. |
| Mechanical conversion re-introduced by future commit | High | Moderate | Explicit non-goal in migration script; runtime guard refuses to write computed cross-brand doses; documented in Phase 9 governance. |
| Silent data-drop on unknown JSON keys | Medium | Moderate | Debug assertion + release analytics log in `BrandDose.tryParse`; unknown-keys test in Phase 12. |
| Golden tests auto-regenerated without clinical review | High | Moderate | Two-reviewer rule (clinical + engineering) on any `--update-goldens` PR; documented in CONTRIBUTING. |

## Resource Requirements

- **Engineering:** 1 Flutter engineer, ~3 weeks for Phases 3–8, 12, 13. ~1 week for Phases 9–11 (governance + disclaimer + freeze).
- **Clinical author:** ~5 hours for Phase 1 & 2 review + ~3 hours for Phase 3 comparison sign-off.
- **Research:** ~4 hours for Phase 1 (FDA matrix compile + post-AAN replacement search).
- **No new infra or paid services required.**

## Future Considerations

- **i18n for sources.** US-only for v1; string keys are `Intl.message`-wrapped so future brainstorm can add regional profiles without refactor.
- **User-selectable authority preference.** Some residents follow institutional protocols over guidelines. A future "preferred authority override" setting could let each user pick.
- **Cited-by counts or evidence-level badges.** DynaMed-style evidence tags (Level 1/2/3) could refine the source hierarchy post-launch.
- **Source-change alerts.** A future version could notify users when their most-used muscles have a source update.
- **Content expansion (deferred brainstorm topic).** The Jost audit surfaced rich instruction content (landmarks, depths, adjacent hazards, synergists, patient position) that deserves its own data-model extension after reconciliation ships.

## Documentation Plan

- `docs/brainstorms/2026-04-19-dosage-authority-reconciliation-requirements.md` — source (already written).
- `docs/plans/2026-04-19-001-feat-dosage-authority-reconciliation-plan.md` — this file.
- `docs/audits/2026-04-dose-sources-discovery.md` — Phase 1 output.
- `docs/audits/2026-04-dose-authority-assignments.json` — Phase 2 output.
- `docs/audits/2026-04-dose-authority-comparison.md` — Phase 3 output.
- `docs/credits/dosage-sources.md` — Phase 8.
- `assets/credits/dosage-sources-manifest.json` — Phase 8.
- `docs/credits/dosage-sources-last-verified.md` — Phase 8.
- `docs/solutions/best-practices/dosage-authority-governance.md` — Phase 9 (first entry in `docs/solutions/`, which currently does not exist).
- `docs/freezes/2026-04-dose-freeze.md` — Phase 10.
- `CHANGELOG.md` entry for the release.

## Sources & References

### Origin

- **Origin document:** [docs/brainstorms/2026-04-19-dosage-authority-reconciliation-requirements.md](../brainstorms/2026-04-19-dosage-authority-reconciliation-requirements.md) — the brainstorm is the authoritative product spec. Key decisions carried forward verbatim: target audience = US residents; authority hierarchy = FDA → AAN (now retired, replacement TBD) → Mayo/peer textbook → limited evidence; single range per brand with source attribution; per-brand + age-specific FDA badge; unknown-source = deprecate all; no-authority = "consult supervisor" callout with no dose number; R10 freeze on dose-dependent features until Phase 5 lands.

### Internal References

- `lib/models/muscle.dart` lines 134–196 — `Dosage` class to be extended (Phase 4).
- `lib/models/muscle.dart` lines 108–128, 158–173 — existing `tryParse` legacy-tolerant patterns to mirror.
- `lib/widgets/safety_callout.dart` — to be extended with variant enum (Phase 7).
- `lib/widgets/muscle_card.dart` lines 123–136 — `_tag()` pill pattern, reuse for compact FDA badge.
- `lib/screens/guide/muscle_detail.dart` lines 454–538 — hero layout, where dose chips and `dosageNote` line render today (Phase 6/7).
- `lib/screens/guide/muscle_detail.dart` lines 554–575 — `_heroChip()` widget for per-brand dose.
- `lib/widgets/print_cheat_sheet.dart` lines 40–48 — dose rendering in PDF (Phase 6/7).
- `lib/data/toxin_data.dart` line 20 — only existing `maxDoseNote` with FDA text; must be generalized (Phase 4).
- `docs/credits/anatomy-sources.md` — precedent for per-source credit tracking (Phase 8 mirrors this).
- `tools/apply_technique_and_dose_audit.py`, `tools/apply_critical_fixes.py`, `tools/apply_moderate_batches_1_4.py` — existing idiom for batched JSON migrations (Phase 5 follows same pattern).
- Commit `deeaaf2` (2026-04-15) — the only prior commit citing dose sources (Allergan PI + Albanese 2021 + Esquenazi 2013 + Wissel 2009, mechanical Xeomin 1:1 and Dysport 3:1). Phase 1 validates these.
- Commit `fc04915` (2026-04-08) — typed `Dosage` migration; same backward-compat pattern to follow for `BrandDose`.

### External References

- **AAN Guideline (Simpson 2016, retired 2025-04-07):** <https://www.neurology.org/doi/10.1212/WNL.0000000000002560> — DOI 10.1212/WNL.0000000000002560; PMID 27164716. Named authority in brainstorm; replacement TBD in Phase 1.
- **DailyMed (FDA labels):**
    - BOTOX search: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=BOTOX>
    - Dysport search: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=dysport>
    - Xeomin (current setid): <https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=ccdc3aae-6e2d-4cd0-a51c-8375bfee9458>
- **FDA approval announcements (Phase 1 input):**
    - BOTOX pediatric lower limb: <https://news.abbvie.com/news/press-releases/therapeutic-area/neuroscience/fda-approves-botox-onabotulinumtoxina-for-pediatric-patients-with-lower-limb-spasticity-excluding-spasticity-caused-by-cerebral-palsy.htm>
    - BOTOX 2021 adult upper limb muscle additions: <https://news.abbvie.com/2021-07-29-FDA-Approves-Expanded-BOTOX-R-onabotulinumtoxinA-Label-to-Include-Eight-New-Muscles-to-Treat-Adults-with-Upper-Limb-Spasticity>
    - Ipsen Dysport pediatric LL: <https://www.prnewswire.com/news-releases/ipsen-biopharmaceuticals-inc-announces-fda-approval-of-dysport-abobotulinumtoxina-for-the-treatment-of-lower-limb-spasticity-in-pediatric-patients-aged-two-and-older-300306718.html>
    - Dysport CP expansion: <https://www.neurologylive.com/view/abobotulinumtoxina-approved-for-pediatric-spasticity-including-in-cerebral-palsy>
    - Merz Xeomin pediatric UL: <https://merztherapeutics.com/us/fda-approves-first-pediatric-indication-for-xeomin-incobotulinumtoxina-for-the-treatment-of-upper-limb-spasticity-excluding-spasticity-caused-by-cerebral-palsy/>
- **Cambridge Manual of Botulinum Toxin Therapy, 3e (2024):** <https://www.cambridge.org/9781009098663> — likely replaces the ambiguous "Mayo BoNT Handbook" reference pending Phase 1 clinical-author confirmation.
- **UpToDate citation format:** <https://www.wolterskluwer.com/en/solutions/uptodate/resources/cite-a-topic> — inline convention reference for Phase 6.
- **DynaMed evidence levels:** <http://www.dynamed.com/home/content/levels-of-evidence> — future-work reference for evidence-level badges.
- **Medical disclaimer templates:** <https://www.websitepolicies.com/blog/medical-disclaimer> + <https://www.termsfeed.com/blog/medical-disclaimer-template/> — Phase 11 copy grounding.

### Related Work

- `docs/brainstorms/2026-04-15-pattern-first-landing-requirements.md` — parallel UI work, unblocked per R10.
- `docs/plans/2026-04-15-anatomy-reference-images-plan.md` — precedent for schema extension script + credits page update.
- `docs/plans/2026-04-05-001-refactor-frontend-polish-audit-plan.md` — frontend polish, pre-dates this audit, no overlap.

## Outstanding Questions Deferred to Planning — now resolved or flagged here

- **[Resolved][Technical]** Where does source attribution live? → Per-brand `BrandDose` wrapper object (Phase 4 decision, following framework research recommendation).
- **[Resolved][Technical]** Schema migration strategy? → Additive optional fields with `schemaVersion: 2` fail-loud check; legacy string shape still parseable.
- **[Resolved][Research]** Post-2025 AAN update? → **Not found; Phase 1 makes a clinician-approved fallback decision.** This is a material unknown. If Phase 1 cannot find a suitable replacement authority, the fallback is Cambridge Manual of Botulinum Toxin Therapy 3e (2024) or the AAN-retired guideline surfaced with "Retired 2025" label.
- **[Resolved][Research]** Do Simpson 2016 doses cite units per brand or brand-agnostic? → Brainstorm's assumption about Simpson 2016 is moot (retired); future authority choice will dictate. Flag for Phase 1.
- **[Resolved][Research]** Toronto Spasticity Institute / Mayer & Esquenazi textbook status? → Research could not verify existence under that name; Phase 1 re-investigates or drops.
- **[Resolved][Technical]** FDA badge placement? → Per-brand row immediately below dose chips in hero; compact ExpansionTile summary on muscle_card; text-only in print.
- **[Resolved][Technical]** Badge wrapping/truncation? → `Wrap` flows multi-line; no truncation — verbose over lossy per brainstorm key decision.
- **[Flagged][Needs Phase-1 enumeration]** Which specific muscles fall into "no US authority"? → Phase 1 research + Phase 2 assignment produce the enumeration.

## New questions surfaced by SpecFlow analysis — resolved

- **[Resolved]** "Off-label" tri-state: off-label for spasticity vs never-approved? → Two states suffice: approved for this indication / off-label. "Never-approved" is rendered as "off-label for all indications" in prose if relevant; no third badge state.
- **[Resolved]** `source` field nullability: nullable vs sentinel? → **Sentinel** (`limitedEvidence: true, reason: "..."`) — non-nullable contract per SpecFlow 2a.
- **[Resolved]** Single-brand authority coverage: show other brands blank, hidden, or with callout? → **All three brands always render**; brands without authority show "Limited evidence" in place of the dose number, not hidden. Parity > tidiness.
- **[Resolved]** Share/export a dose sheet? → Out of scope this release; attribution must survive future export.
- **[Resolved]** `Consult supervisor` link target? → Text-only v1; `institutionalProtocolUrl` field reserved for future settings work.
