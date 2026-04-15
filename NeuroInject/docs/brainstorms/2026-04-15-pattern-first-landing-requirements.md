---
date: 2026-04-15
topic: pattern-first-landing
---

# Pattern-First Landing Page

## Problem Frame
Residents using NeuroInject default to browsing muscles by body region and miss the spasticity pattern system entirely — it's buried as a sidebar section that blends into navigation. The pattern system is the most clinically valuable feature (it maps clinical presentation to injection targets) but residents don't discover it. For pre-procedure planning, patterns should be the primary entry point.

## Requirements
- R1. The default landing page shows a full-screen grid of spasticity pattern cards, organized by body region (Face, Neck, Upper Extremity, Lower Extremity, Trunk)
- R2. Each pattern card displays: pattern name, one-line clinical description, and muscle count badge
- R3. Region headers visually group patterns (clear section dividers/labels)
- R4. Tapping a pattern card transitions to the filtered muscle grid showing only that pattern's muscles (reuses existing muscle card grid)
- R5. A persistent "Browse All Muscles" option remains accessible (top of page or tab) for users who want the flat grid
- R6. The existing sidebar is removed or collapsed — patterns are no longer a sidebar section
- R7. Back navigation from the filtered muscle grid returns to the pattern landing page
- R8. Search remains available and searches across both pattern names and muscle names

## Success Criteria
- Residents land on patterns by default — no discovery friction
- Time from app launch to "I know which muscles to inject for this patient's pattern" is reduced
- The old "browse by body region" workflow remains accessible but is secondary

## Scope Boundaries
- No multi-pattern selection in this iteration (future work)
- No session planning / dose calculator integration (future work)
- No body silhouette visual navigator (considered, deferred)
- Patterns data model unchanged — only UI changes

## Key Decisions
- Pattern-first landing over body-region visual navigator: simpler build, immediately solves the discoverability problem without requiring illustration assets
- Sidebar removal: patterns promoted to primary navigation replaces the sidebar's role; body-region categories become a secondary filter within "Browse All"
- Keep existing muscle card grid: no changes to how muscles are displayed once a pattern is selected

## Next Steps
→ Implement directly — scope is lightweight and well-defined
