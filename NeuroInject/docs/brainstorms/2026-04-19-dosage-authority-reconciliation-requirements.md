---
date: 2026-04-19
topic: dosage-authority-reconciliation
---

# Dosage Authority Reconciliation

## Problem Frame
The Jost Atlas audit revealed that NeuroInject's current dosage recommendations run 1.5–3× higher than the book across 30+ muscles. This is a directional, systematic discrepancy — not scattered error. Because NeuroInject targets US residents (PM&R, neurology) who act on these numbers clinically, under- or over-dosing risks patient harm: too little = ineffective treatment; too much = excess weakness, spread of toxin, or adverse events. Before any other product work proceeds, we need to know (a) where Jost's numbers come from, (b) where NeuroInject's numbers came from, (c) what the US standard actually is, and (d) reconcile the app's displayed doses to a defensible US authority with per-muscle source attribution.

## Requirements

- **R1. Source discovery for Jost Atlas.** Determine Jost Atlas's evidence base (European clinical practice, specific trials cited, German consensus). Capture citation details.

- **R2. Source discovery for NeuroInject's existing doses.** Trace where `muscles.json` dosages originated. Check git history, code comments, README, commit messages, and any notes in `Resources/`. If the original source can't be determined, note that explicitly as a red flag.

- **R3. US authority survey.** Collect per-muscle dose ranges from the key US references: FDA prescribing information (Botox/Xeomin/Dysport), Simpson et al. 2016 AAN practice guideline, Mayo Clinic BoNT Handbook, and manufacturer-provided dosing guides (Allergan, Merz, Ipsen). Note which are US-specific vs internationally applicable.

- **R4. Per-muscle authority assignment.** For each of NeuroInject's 68 muscles, identify the single best source to cite. Decision rule: on-label spasticity indications default to FDA label; off-label spasticity defaults to Simpson 2016 (AAN); other indications (cervical dystonia, headache) use the condition-appropriate authority. Record rationale if a different source is chosen.

- **R5. Comparison report.** Produce a side-by-side matrix: muscle × [Jost, NeuroInject current, FDA label, Simpson 2016/AAN, Mayo, chosen authority]. Flag muscles where the chosen authority materially disagrees with NeuroInject's current value. Flag muscles where no US authority provides a range.

- **R6. `muscles.json` patch.** Update every affected muscle's `dosage` object to match the chosen authority's range. Preserve brand structure (Botox/Xeomin/Dysport). For muscles where the chosen authority doesn't speak, flag the dose as "limited evidence" rather than silently keeping the old numbers.

- **R7. Per-dose source attribution.** Extend the data model to carry source metadata per dose (at minimum: source name, year, optional URL). Attribution text appears inline in the UI next to every dose display.

- **R8. FDA-label status badge per muscle.** Each muscle's detail page shows an "FDA-approved for [indication]" or "Off-label use" badge. Distinct from the source attribution. Helps residents document justification in their clinical note.

- **R9. Authority-wins display model.** The UI shows ONE dose range per brand, sourced from the chosen authority for that muscle. Alternate sources are NOT shown in the primary UI. (Rationale: reduces cognitive load; residents can look up alternates externally if needed.)

- **R10. Pre-release freeze on dosage-dependent features.** Until R1–R6 are complete, no other work that depends on dosages (print cheat sheet, any dose-calculator features, summary pages) ships. UI facelift, pattern-first landing, and non-dose features may proceed in parallel.

## Success Criteria

- Every dose displayed in NeuroInject has an inline citation to a named, dated, US-applicable source.
- Every muscle has an FDA on/off-label badge.
- No muscle shows a dose whose source is unknown or unverifiable.
- A PM&R resident using the app to plan an injection can defend every dose to an attending by naming the guideline source.
- The "2-3× higher than Jost" pattern is explained: it's because NeuroInject aligns with US standards (FDA/AAN), which are higher than European practice — OR — NeuroInject's old numbers were wrong and the patch fixes them.

## Scope Boundaries

- **Out of scope — content expansion.** The book's richer instruction content (landmark measurements, injection depth, adjacent hazards, synergists, patient position) is not part of this brainstorm. That becomes a separate future brainstorm once dosage authority is settled.
- **Out of scope — non-US guidelines.** European, Canadian, Australian, or Japanese dosing references are not consulted for attribution. Jost is used only as a comparison benchmark in the report, not as an authority.
- **Out of scope — pediatric-only FDA indications.** If a muscle is FDA-approved only for pediatric use but the app treats adults, we flag the mismatch and use Simpson 2016 or Mayo for adult off-label — detailed handling is a planning decision.
- **Out of scope — muscle set changes.** No new muscles are added or removed. The 68-muscle set stays.
- **Out of scope — i18n for dosing (non-US profile).** Single-region (US) only for this release.

## Key Decisions

- **Target audience = US residents (PM&R, neurology).** Every authority decision defaults to US practice.
- **Primary authority hierarchy:** FDA label (if on-label) → Simpson 2016 AAN guideline (if off-label spasticity) → Mayo BoNT Handbook or manufacturer guide (fallback) → "limited evidence" badge (last resort).
- **Single range shown per dose.** Not a multi-source table. Attribution text identifies the source.
- **FDA on/off-label badge is a critical first-class UI element.** Not a tooltip.
- **Data-integrity fixes batched into the same patch.** Missing doses (Tibialis Anterior, Infraspinatus), Gastroc M/L asymmetry, OCR-suspect book numbers — all resolved in the same muscles.json update so we don't touch the file twice.
- **Research must precede the patch.** No muscle gets a new dose until the authority for it is named.
- **Unknown-source behavior: deprecate all.** If repo history can't produce the original source for NeuroInject's current doses, every muscle is re-dosed from the chosen authority (or flagged "limited evidence"). Safety over churn. No back-dated citations.
- **No-authority behavior: no dose, "Consult supervisor" callout.** Muscles with no US guideline coverage do not display a number. They show a "Limited evidence — consult supervisor / institutional protocol" callout that replaces the dose chip. No fallback to Jost in primary UI.
- **FDA badge format: per-brand + age-specific text.** Verbose over lossy. Example badge: "Botox: FDA adult upper limb · Xeomin: FDA adult upper limb · Dysport: FDA pediatric lower limb, adult off-label". Accuracy is the point; if the text gets long, the UI wraps or truncates with tap-to-expand — details are a planning concern.

## Dependencies / Assumptions

- Assumes Simpson 2016 AAN guideline covers most off-label spasticity muscles NeuroInject includes. If gaps are large, Mayo BoNT Handbook becomes a bigger player.
- Assumes FDA prescribing information for Botox/Xeomin/Dysport is freely accessible via DailyMed or manufacturer sites.
- Assumes the Muscle model's existing typed `Dosage` class can be extended with source fields without major refactor.
- Assumes no immediate legal/compliance review is required for citing these sources (medical education fair use).

## Outstanding Questions

### Deferred to Planning

- **[Affects R7][Technical]** Should source attribution live on the `Dosage` class (one source per dose object) or on each brand field (separate source for Botox vs Xeomin vs Dysport since FDA approvals differ by brand)? Likely per-brand since FDA labels differ.
- **[Affects R7][Technical]** Schema migration strategy for existing `muscles.json` — additive field only (so old app versions still work) vs breaking change?
- **[Affects R5][Needs research]** Do Simpson 2016 AAN guideline doses explicitly cite units per brand, or are they brand-agnostic with a conversion note?
- **[Affects R4][Needs research]** Is there a newer AAN update since 2016 (e.g., 2022 update) that should replace Simpson 2016 as the authority?
- **[Affects R3][Needs research]** Does the Toronto Spasticity Institute protocol (Mayer/Esquenazi) count as a US-applicable reference? Some US residents train with it.
- **[Affects R8][Technical]** UI placement of the FDA badge — header of muscle detail page, inside the dose row, or as a separate "indication" section?
- **[Affects R8][Technical]** How the per-brand+age FDA badge text wraps or truncates on small screens; tap-to-expand vs always-expanded.
- **[Affects R6][Needs research]** For the "no US authority" muscles, which muscles specifically fall into this bucket? Likely intrinsic foot, trunk (paraspinals, QL, rect abdominis), some intrinsic hand. Enumerated during R3–R5.

## Next Steps

→ `/ce:plan` for structured implementation planning.
