---
title: Dose Sources Discovery — Phase 1 Audit
type: audit
phase: 1
plan: docs/plans/2026-04-19-001-feat-dosage-authority-reconciliation-plan.md
status: draft
date: 2026-04-19
authors:
  - Phase 1 research agent
reviewers:
  - "[NEEDS CLINICAL AUTHOR SIGN-OFF]"
---

# Dose Sources Discovery — Phase 1 Audit

This audit is the Phase 1 deliverable of the [Dosage Authority Reconciliation plan](../plans/2026-04-19-001-feat-dosage-authority-reconciliation-plan.md). It answers three questions the plan depends on:

1. **What happened to AAN Simpson 2016?** (Is there a replacement?)
2. **What US-applicable sources can we actually cite per-muscle?**
3. **What is the current FDA approval status for each brand × age × extremity combination for spasticity?**

The phase is **research-only**. No code, no data changes. The plan does not proceed to Phase 2 until this audit is reviewed and signed off by the clinical author.

Items flagged `[NEEDS CLINICAL AUTHOR CONFIRMATION]` could not be resolved from public sources alone and require expert judgment before the Phase 2 authority assignment begins.

---

## Executive summary — three findings that materially reshape the plan

### Finding 1. AAN Simpson 2016 was retired **April 7, 2025**. No replacement has been published.

The guideline's retirement is confirmed directly on the AAN guideline page (<https://www.aan.com/Guidelines/home/GuidelineDetail/735>) with the explicit statement that "its recommendations and conclusions are no longer considered valid and no longer supported by the AAN." Multiple targeted searches (2022–2026) surface no successor AAN document on botulinum neurotoxin for spasticity as of April 2026. AANEM, which previously endorsed Simpson 2016, has not issued a standalone BoNT-spasticity position to fill the gap.

### Finding 2. Simpson 2016 NEVER contained per-muscle dose ranges anyway.

This is the most important finding of Phase 1 and it inverts the brainstorm's assumption. The AAN guideline (even when active) published only **brand-level effectiveness ratings** — Level A/B/C/U per brand per indication — with no per-muscle dosing. From the guideline itself: upper-limb spasticity got Level A for Botox, Dysport, and Xeomin; Level B for Myobloc. Lower-limb got Level A for Botox and Dysport; "insufficient evidence" for Xeomin and Myobloc. **Nowhere does it say "inject X units into the flexor carpi radialis."**

This means NeuroInject's per-muscle doses have never had an AAN-equivalent US authority. They have always had to come from:

- FDA prescribing information (for labeled muscles)
- Peer-reviewed systematic reviews and consensus papers (for broader coverage)
- Clinical textbooks
- Manufacturer injector materials

The plan's Phase 2 authority assignment must be rebuilt around this reality, not around a phantom Simpson-2016-is-the-authority assumption.

### Finding 3. The 2026-04-15 audit commit's "Albanese 2021" citation is most likely misattributed.

The only 2021 peer-reviewed consensus paper that publishes per-muscle dose tables for both dystonia and spasticity is **Dressler D, et al.** (not Albanese) in *Journal of Neural Transmission* 128(3):321–335 (DOI 10.1007/s00702-021-02312-4, PMID 33635442). Albanese is not an author on that paper. Albanese is well-known for earlier dystonia consensus work (2011, 2015), but no spasticity consensus in 2021 under his authorship appears in the literature.

Two possibilities:
- (a) The commit author meant Dressler 2021 and mis-typed the first author's name.
- (b) A different Albanese 2021 paper was consulted that does not appear in PubMed / PMC searches.

Either way, the citation that currently "grounds" the 2026-04-15 audit needs clinical-author clarification before Phase 2 can assign Dressler 2021 as an authority.

---

## FDA approval matrix (2026)

Every cell cites the approval year + press release or FDA source. "✗" means the combination is not approved in the US (it may be approved elsewhere; that is out of scope per brainstorm R10).

| Brand (generic) | Adult upper limb | Adult lower limb | Pediatric UL (≥2y) | Pediatric LL (≥2y) |
|---|---|---|---|---|
| **BOTOX** (onabotulinumtoxinA) AbbVie | ✓ **2010-03-09** | ✓ **2016-01-22** | ✓ **2019-06-21** (no CP exclusion noted in that approval) | ✓ **2019-10** / expanded 2020; **excl CP** |
| **Dysport** (abobotulinumtoxinA) Ipsen | ✓ **2015-07-16** | ✓ **2017-06-16** | ✓ **2019-09-25**; **excl CP** | ✓ **2016**; **includes CP** |
| **Xeomin** (incobotulinumtoxinA) Merz | ✓ **2015-12-23** | ✗ **NOT FDA APPROVED** (approved Canada Dec 2024, UK approved; Merz has not filed a US BLA for adult LL spasticity as of April 2026) | ✓ **2020**; **excl CP** | ✗ **NOT FDA APPROVED** |
| **Myobloc / Neurobloc** (rimabotulinumtoxinB) Solstice | ✗ (cervical dystonia + sialorrhea only) | ✗ | ✗ | ✗ |
| **Daxxify** (daxibotulinumtoxinA) Revance | ✗ (glabellar lines + cervical dystonia only, 2022/2023) | ✗ | ✗ | ✗ |

Implications for NeuroInject:

- **Xeomin is off-label for ALL adult lower-limb use in the US.** NeuroInject must badge every Xeomin × lower-limb muscle accordingly.
- **Xeomin is off-label for ALL pediatric lower-limb use.** Same badging rule.
- **No BoNT brand has cerebral-palsy coverage on Xeomin or BOTOX pediatric LL labels.** Only Dysport covers pediatric CP. Residents treating CP with BOTOX or Xeomin are off-label.
- **Myobloc and Daxxify are out of scope for spasticity entirely** — no spasticity indications exist for either brand.
- **Adult lower-limb spasticity with Xeomin is specifically a Canada/UK-approved, US-off-label configuration.** A resident using the app could easily miss this.

DailyMed authoritative URLs (for verbatim indication-text extraction in Phase 2):

- BOTOX: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=BOTOX> (resolves to current label; store the setid at extract time).
- Dysport: <https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=97513722-8426-4ce3-b85d-0e08e436a140>
- Xeomin: <https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=ccdc3aae-6e2d-4cd0-a51c-8375bfee9458>

**[NEEDS CLINICAL AUTHOR CONFIRMATION]** The BOTOX pediatric UL (2019-06-21) and pediatric LL (2019-10) approvals may have the CP-exclusion applied asymmetrically across UL vs LL. Two sources I consulted were inconsistent. Clinical author should pull the current BOTOX SPL from DailyMed and verify which pediatric approvals explicitly exclude CP.

---

## Candidate authorities — analysis

Each candidate is assessed on four dimensions: (a) US applicability, (b) per-muscle dose specificity, (c) currency, (d) peer-review status.

### Tier 1 — FDA Prescribing Information (DailyMed)

- **Scope:** Brand-specific indication text + dose ranges for labeled muscles only.
- **US applicable:** ✓ (by definition).
- **Per-muscle specificity:** Partial — labels list specific muscles in tables (typically for UL flexor group; LL calf group).
- **Currency:** Current (DailyMed refreshes per label revision).
- **Peer-review:** FDA review.
- **Coverage gap:** Most muscles NeuroInject displays are NOT on any FDA label (e.g., adductor group, gluteals, paraspinals, most intrinsic hand and foot muscles). For these, Tier 1 has nothing to say.

### Tier 2 — Peer-reviewed systematic reviews

**Esquenazi 2013 (Nalysnyk, Papapetropoulos, Rotella, Simeone, Alter, Esquenazi)**
"OnabotulinumtoxinA muscle injection patterns in adult spasticity: a systematic literature review." *BMC Neurol.* 2013;13:118. DOI 10.1186/1471-2377-13-118. PMID 24011236. PMC3848723.

- **Scope:** 70 studies (28 RCTs + 5 non-random + 37 single-arm), 2,163 adult patients. **BOTOX (onabotulinumtoxinA) only** — not other brands.
- **US applicable:** ✓ (lead author Esquenazi is at MossRehab Philadelphia; trials drawn from US-inclusive literature).
- **Per-muscle specificity:** Yes — reports injection frequency per muscle plus dose ranges (5–200 U UL; 10–400 U LL).
- **Currency:** 2013; pre-dates 2016-2026 FDA label expansions (especially pediatric approvals and adult LL). Needs pairing with more recent sources for fill-in.
- **Peer-review:** ✓
- **Coverage gap:** Does not cover abobotulinumtoxinA or incobotulinumtoxinA. Does not cover pediatric spasticity. Does not cover novel muscles introduced in 2021+ treatment patterns.
- **Plan fit:** Strong Tier 2 for adult onabotulinumtoxinA across most NeuroInject upper-limb and lower-limb muscles. Weak for brand-equivalence questions.

### Tier 2 — Peer-reviewed consensus guidelines

**Dressler 2021**
Dressler D, Altavista MC, Altenmueller E, et al. "Consensus guidelines for botulinum toxin therapy: general algorithms and dosing tables for dystonia and spasticity." *J Neural Transm (Vienna).* 2021 Mar;128(3):321-335. DOI 10.1007/s00702-021-02312-4. PMID 33635442.

- **Scope:** Dystonia + spasticity. Publishes per-muscle dose tables derived from 1,593 spasticity injections across 31 target muscles in 240 patients.
- **US applicable:** Partially — international authorship (Europe-heavy). Not a US-specific guideline.
- **Per-muscle specificity:** ✓ Strong — explicit dosing tables.
- **Currency:** 2021; most recent spasticity-dosing consensus that includes tables.
- **Peer-review:** ✓
- **Coverage gap:** International (not US-regulatory). Does not map 1:1 to FDA indications.
- **Plan fit:** Strong Tier 3 (because international), but its dose tables are the most comprehensive peer-reviewed source available. Cite as "international consensus" alongside FDA labels for muscles the labels don't cover.
- **[NEEDS CLINICAL AUTHOR CONFIRMATION]** Whether the 2026-04-15 audit's "Albanese 2021" citation was actually Dressler 2021 (most likely) or a different paper.

**Wissel 2009**
Wissel J, Ward AB, Erztgaard P, et al. "European consensus table on the use of botulinum toxin type A in adult spasticity." *J Rehabil Med.* 2009;41(1):13–25. DOI 10.2340/16501977-0303. PMID 19197564.

- **Scope:** European consensus, 28 clinicians from 16 countries.
- **US applicable:** **✗ European.** Per brainstorm R5 ("Out of scope — non-US guidelines"), Wissel 2009 should not be a primary authority in NeuroInject.
- **Per-muscle specificity:** ✓
- **Plan fit:** **Drop.** Leave out of the authority hierarchy. Cite only in the comparison report as historical context.

### Tier 3 — Peer-reviewed textbook

**Truong, Dressler, Hallett, Zachary (eds.). "Manual of Botulinum Toxin Therapy." 3rd edition. Cambridge University Press, 2024. ISBN 9781009098663.**

- **Scope:** Practical injection guide with illustrations, per-muscle dosing tables across all current toxin formulations.
- **US applicable:** Partially — international editors (UC-Riverside / Hannover Medical School / NIH / UC-Irvine). Hallett is NIH-based, which anchors some US credibility.
- **Per-muscle specificity:** ✓ (per publisher description).
- **Currency:** 2024; the most recent textbook treatment.
- **Peer-review:** Edited volume, peer-accountable.
- **Plan fit:** Strong Tier 3 textbook. This is what the brainstorm referred to as "Mayo BoNT Handbook" — almost certainly a misattribution. The Mayo Clinic does not publish a BoNT handbook under that title; the Cambridge Manual is the authoritative reference work of this class.
- **[NEEDS CLINICAL AUTHOR CONFIRMATION]** That the Cambridge Manual 3e (2024) is the intended tier-3 textbook, not some other work they had in mind.

### Tier 4 — Society endorsements

**AANEM endorsement of AAN Simpson 2016.**

- AANEM endorsed Simpson 2016 but did not issue a standalone BoNT-spasticity position.
- Since Simpson 2016 is retired, the endorsement is functionally retired too.
- **Plan fit:** Do not rely on AANEM as a named authority. Note the endorsement history in the credits page for completeness.

### Tier 5 — Manufacturer injector guides

**Allergan/AbbVie BOTOX PI and HCP dosing materials; Ipsen Dysport injector guide; Merz Xeomin injector guide.**

- These ARE the Tier 1 FDA Prescribing Information for the on-label indications. The "injector guide" format is a Tier 5 repackaging that manufacturers distribute for clinical education.
- **Plan fit:** When citing a dose on the FDA label, prefer DailyMed (Tier 1) over the manufacturer guide (Tier 5) — same content, higher regulatory provenance.
- Manufacturer materials that go beyond the label (e.g., injection-pattern suggestions for off-label muscles) are **industry-sponsored** and must be flagged as such in the UI if cited.

---

## Authority hierarchy — decision table (for Phase 2)

This table replaces the brainstorm's hierarchy (which assumed Simpson 2016 was a per-muscle authority). Phase 2 uses it to assign one authority per `(muscle, brand)` cell.

| Tier | Source | When to use | When NOT to use |
|---|---|---|---|
| 1 | FDA PI from DailyMed, verbatim | The cell's brand + age + extremity is FDA-approved AND the muscle appears in the label's muscle table | — |
| 2A | Esquenazi 2013 (systematic review) | **BOTOX only**; adult spasticity; muscle covered by the review; FDA label has no entry | Other brands; pediatric use; muscles not reviewed |
| 2B | Dressler 2021 (consensus guideline) | Any brand; adult spasticity; muscle covered; FDA and Esquenazi silent | Pediatric use not in the consensus; highly brand-specific FDA question where tier 1 applies |
| 3 | Cambridge Manual of BoNT Therapy 3e (2024) | Any brand; muscle covered; tiers 1–2 silent | Pediatric spasticity specifics (confirm book covers them) |
| 4 | — (AANEM endorsement retired; skip) | — | — |
| 5 | Manufacturer injector guide | Only for anatomical clarification that doesn't set a dose (injection-site landmark detail) | Any dose range |
| Sentinel | `LimitedEvidenceDose { reason: "No established dose — consult attending" }` | No tier 1–3 source speaks to the `(muscle, brand)` cell | — |

**Hard rule:** A Jost Atlas range is NEVER assigned as a primary authority (per brainstorm R3 scope boundary). Jost continues to appear only in the comparison report as historical context.

**Hard rule:** **No mechanical brand conversion** (the 2026-04-15 audit's 1:1 Xeomin / 3:1 Dysport scheme is abandoned). If a muscle has Esquenazi 2013 coverage for BOTOX but no source for Xeomin, the Xeomin cell becomes `LimitedEvidenceDose`, not a computed value.

---

## 2026-04-15 audit citations — verification status

Commits `deeaaf2` and `e31c82c` (2026-04-15) stated: "All doses verified against Allergan PI Tables 4–5, Albanese 2021 consensus, Esquenazi 2013 systematic review, Wissel 2009 European consensus. Xeomin 1:1 and Dysport 3:1 ratios applied."

| Cited source | Verification | Plan action |
|---|---|---|
| Allergan PI Tables 4–5 | ✓ Exists (BOTOX prescribing information, AbbVie). Tables 4–5 in the current PI cover adult UL spasticity dose per muscle. | Promote to Tier 1, name the specific DailyMed setid + retrieval date in attribution. |
| Albanese 2021 consensus | ✗ **No such paper found.** The 2021 consensus is by Dressler et al., not Albanese. | **[NEEDS CLINICAL AUTHOR CLARIFICATION]** — either the attribution is a typo for Dressler 2021 (likely) or a different paper was meant. Until clarified, Phase 2 treats the citation as provisional. |
| Esquenazi 2013 systematic review | ✓ Exists. Citation is correct but attribution was incomplete (authors include Nalysnyk, Papapetropoulos, Rotella, Simeone, Alter, Esquenazi). | Promote to Tier 2A. Cite with first author and PMID. |
| Wissel 2009 European consensus | ✓ Exists. **✗ European — out of scope per brainstorm R5.** | Drop from authority hierarchy. Retain as historical context only. |
| Xeomin 1:1 ratio conversion | ✗ Not a citation; a derivation. | **Abandon.** No mechanical conversions in the reconciled data (see hierarchy hard rule). |
| Dysport 3:1 ratio conversion | ✗ Not a citation; a derivation. At the high end of the standard 2.5–3× conversion range, partially explains the "1.5–3× higher than Jost" pattern. | **Abandon.** |

---

## Likely "No US authority" muscles (preview for Phase 2)

Based on FDA label coverage + tier-2/3 source scope, these NeuroInject muscle groups are **likely** to fall into the `LimitedEvidenceDose` sentinel bucket for some or all brands. Phase 2 confirms per-cell.

- **Trunk / abdominal wall** — paraspinals (erector spinae), quadratus lumborum, rectus abdominis, obliques. Not FDA-labeled for spasticity. Esquenazi 2013 covers mostly upper and lower limb; trunk is rare. Dressler 2021 may cover; check.
- **Intrinsic foot** — flexor digitorum brevis, quadratus plantae, foot lumbricals, plantar interossei, adductor hallucis. Generally not labeled; typically covered only in textbooks.
- **Some intrinsic hand beyond labeled set** — opponens pollicis, opponens digiti minimi, palmar interossei (labeled adductor pollicis is on BOTOX UL label; most others are not).
- **Cervical paraspinals for spasticity** — cervical muscles are FDA-labeled for cervical dystonia (separate indication), not for spasticity. An SCM dose for spasticity could be flagged off-label + cite a different source than the same SCM dose for cervical dystonia.
- **Hip group beyond gluteus maximus** — gluteus medius / minimus, piriformis, TFL, iliopsoas, pectineus. Coverage in tier 2B likely; cross-check in Phase 2.
- **Face muscles (NeuroInject has 9)** — not spasticity; separate indication (cosmetic + some therapeutic). Authority for these is entirely different (FDA cosmetic labels for glabellar/crow's feet/etc.) and should probably be a separate Phase 2 sub-track.

If this list holds at ~15–20 muscles, ~10% of NeuroInject cells (68 muscles × 3 brands = 204 cells) may end up as `LimitedEvidenceDose`. This is acceptable and informative — residents are told "no US authority speaks to this" rather than given a fabricated number.

---

## Open questions for Phase 2 — clinical author sign-off required before proceeding

1. **[NEEDS CLINICAL AUTHOR CONFIRMATION]** Is "Albanese 2021" in commit `deeaaf2` a typo for Dressler 2021, or a different paper?
2. **[NEEDS CLINICAL AUTHOR CONFIRMATION]** Is the Cambridge Manual 3e (2024) the intended tier-3 textbook, or another work (e.g., Mayer & Esquenazi *Spasticity Management: A Practical Multidisciplinary Guide*, 2e 2019; Jankovic *Textbook of Movement Disorders*, etc.)?
3. **[NEEDS CLINICAL AUTHOR CONFIRMATION]** Is the current BOTOX PI pediatric UL (2019-06-21) free of a CP exclusion? Pediatric LL is explicit. Conflicting secondary reports.
4. **[PLAN CONSEQUENCE]** Given Simpson 2016's lack of per-muscle doses, the brainstorm's hierarchy of "FDA → AAN → Mayo" never actually produced a workable per-muscle decision tree. The plan should adopt the revised hierarchy in this audit. Confirm or adjust.
5. **[PLAN CONSEQUENCE]** With Wissel 2009 excluded as European and Simpson 2016 retired without per-muscle content, the **only US-applicable per-muscle source for BOTOX adult spasticity is Esquenazi 2013**. For other brands and pediatric use, there is no US-specific per-muscle source. Confirm the plan's acceptance of international Tier 2B/3 sources (Dressler 2021, Cambridge Manual 2024) as the best-available fallback.
6. **[PLAN CONSEQUENCE]** Face muscles (9 in NeuroInject) are a separate indication landscape from spasticity and may need their own Phase 2 sub-track. Confirm scope.
7. **[NEEDS CLINICAL AUTHOR INPUT]** For face muscles, which FDA labels apply — only the aesthetic glabellar/forehead/crow's feet labels, or also therapeutic labels (blepharospasm, hemifacial spasm, chronic migraine for temporalis/frontalis/etc.)?

---

## Sources

### Primary references (used for this audit)

- [AAN Practice Guideline Update Summary (Simpson 2016, retired) — Neurology DOI page](https://www.neurology.org/doi/10.1212/WNL.0000000000002560)
- [AAN Guideline page (retirement notice)](https://www.aan.com/Guidelines/home/GuidelineDetail/735)
- [Simpson 2016 full text — PMC4862245](https://pmc.ncbi.nlm.nih.gov/articles/PMC4862245/)
- [Dressler 2021 consensus guideline — PubMed 33635442](https://pubmed.ncbi.nlm.nih.gov/33635442/)
- [Esquenazi 2013 systematic review — PubMed 24011236 / PMC3848723](https://pubmed.ncbi.nlm.nih.gov/24011236/)
- [Wissel 2009 European consensus — PubMed 19197564](https://pubmed.ncbi.nlm.nih.gov/19197564/)
- [Cambridge Manual of Botulinum Toxin Therapy 3e (2024)](https://www.cambridge.org/9781009098663)
- [Dystonia Europe announcement of Manual 3e (May 2024)](https://dystonia-europe.org/2024/05/just-published-the-third-new-edition-of-the-manual-of-botulinum-toxin-therapy/)
- [DailyMed BOTOX search](https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=BOTOX)
- [DailyMed Dysport setid](https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=97513722-8426-4ce3-b85d-0e08e436a140)
- [DailyMed Xeomin setid](https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=ccdc3aae-6e2d-4cd0-a51c-8375bfee9458)

### FDA approval press releases (used for matrix)

- [AbbVie: BOTOX adult LL spasticity (2016-01-22)](https://www.prnewswire.com/news-releases/us-fda-approves-botox-onabotulinumtoxina-for-the-treatment-of-lower-limb-spasticity-in-adults-300208358.html)
- [AbbVie: BOTOX pediatric UL spasticity (2019-06-21)](https://news.abbvie.com/2019-06-21-FDA-Approves-BOTOX-R-onabotulinumtoxinA-for-Pediatric-Patients-with-Upper-Limb-Spasticity)
- [AbbVie: BOTOX pediatric LL spasticity, excluding CP (2019-10 / 2020 expansion)](https://news.abbvie.com/news/press-releases/therapeutic-area/neuroscience/fda-approves-botox-onabotulinumtoxina-for-pediatric-patients-with-lower-limb-spasticity-excluding-spasticity-caused-by-cerebral-palsy.htm)
- [Ipsen: Dysport adult LL spasticity (2017-06-16)](https://www.businesswire.com/news/home/20170616005486/en/Ipsen-Announces-FDA-Approval-of-Dysport%C2%AE-Abobotulinumtoxina-for-the-Treatment-of-Lower-Limb-Spasticity-in-Adults)
- [Ipsen: Dysport pediatric UL, excluding CP (2019-09-25)](https://www.ipsen.com/us/press-releases/ipsen-announces-fda-approval-of-dysportabobotulinumtoxina-for-the-treatment-of-upper-limbspasticity-in-children-excluding-cerebral-palsy/)
- [Ipsen: Dysport pediatric LL, includes CP (2016)](https://www.prnewswire.com/news-releases/ipsen-biopharmaceuticals-inc-announces-fda-approval-of-dysport-abobotulinumtoxina-for-the-treatment-of-lower-limb-spasticity-in-pediatric-patients-aged-two-and-older-300306718.html)
- [Merz: Xeomin pediatric UL, excluding CP (2020)](https://merztherapeutics.com/us/fda-approves-first-pediatric-indication-for-xeomin-incobotulinumtoxina-for-the-treatment-of-upper-limb-spasticity-excluding-spasticity-caused-by-cerebral-palsy/)
- [Drugs.com: Xeomin FDA approval history](https://www.drugs.com/history/xeomin.html) (failed to WebFetch; used secondary sources)
- [NeurologyLive: Dysport CP expansion context](https://www.neurologylive.com/view/abobotulinumtoxina-approved-for-pediatric-spasticity-including-in-cerebral-palsy)

### Origin documents

- [Brainstorm requirements](../brainstorms/2026-04-19-dosage-authority-reconciliation-requirements.md)
- [Phase 1 plan section](../plans/2026-04-19-001-feat-dosage-authority-reconciliation-plan.md)

---

## Phase 1 → Phase 2 handoff

**Blocking items before Phase 2 can begin:**

- Clinical author reviews and signs off on the revised authority hierarchy (see "Authority hierarchy — decision table" above).
- Clinical author resolves the 7 open questions above.
- Clinical author confirms the tier-3 textbook (Cambridge Manual 2024 vs alternative).

**Non-blocking items that can start in parallel with Phase 2:**

- Engineering: start drafting the `SourceRef` model changes and the `FdaStatus` enum based on this matrix (Phase 4 pre-work).
- Engineering: scaffold `assets/data/archive/` and commit the current `muscles.json` pre-reconciliation snapshot (Phase 5 pre-work).

Once clinical author sign-off lands, Phase 2 produces `docs/audits/2026-04-dose-authority-assignments.json` with one row per `(muscle, brand)` cell naming its authority.
