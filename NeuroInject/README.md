# NeuroInject — Spasticity Injection Guide

A Flutter reference app for clinicians performing botulinum toxin injections for
spasticity and dystonia. It pairs a pattern-first workflow ("what posture do you
see?") with per-muscle injection guidance, anatomy reference images, ultrasound
notes, adjacent-structure safety callouts, and a dilution/dose calculator.

> [!WARNING]
> **Clinical decision-support tool for qualified injectors only.** This app is an
> educational reference, **not** a substitute for clinical training, judgment, or
> the product labeling. Always verify doses against current prescribing
> information and your institution's protocols before injecting. Botulinum toxin
> brands are **not interchangeable 1:1** (see [Dosing](#dosing)). The authors make
> no warranty as to accuracy or fitness for clinical use.

---

## What it does

- **Pattern-first landing.** Start from a spasticity/dystonia pattern (e.g.
  *Flexed Elbow*, *Clenched Fist*, *Equinovarus*) and see the muscles that drive
  it. 29 patterns across upper extremity, lower extremity, trunk, and cervical
  regions.
- **Per-muscle guidance.** Each of the 68 muscles has localization landmarks,
  step-by-step needle placement, setup notes, an anatomy reference image,
  ultrasound guidance (probe, orientation, view steps, depth), clinical pearls,
  a supplies checklist, related muscles, and video links where available.
- **Danger zones.** Adjacent-structure hazards (nerves, vessels, viscera,
  diffusion risks) render in a dedicated amber safety callout, visually separated
  from general teaching pearls.
- **Dose calculator.** Dilution → concentration → injection-volume math with
  brand-aware presets for Botox, Dysport, Xeomin, and Myobloc, plus a
  units-per-0.1 mL readout and a dilution reference table.
- **Quality-of-life.** Light/dark themes, full-text search, favorites, and
  recently-viewed history.

## Content scope

| Region | Muscles |
| --- | --- |
| Upper extremity (incl. trunk) | 18 |
| Lower extremity (incl. trunk) | 33 |
| Cervical | 7 |
| Face / neck | 10 |
| **Total** | **68** |

Muscle metadata is derived from clinical reference texts. Anatomy images are
sourced and attributed separately — see [Image credits](#image-credits).

## Dosing

Doses are stored **per brand**, never as a bare unit count, because
onabotulinumtoxinA (Botox), incobotulinumtoxinA (Xeomin), and abobotulinumtoxinA
(Dysport) are **not 1:1 equivalent** — Dysport runs roughly 2.5–3× the unit count
of Botox/Xeomin for a comparable effect. The UI always shows the brand alongside
the number. Treat all values as starting references to be confirmed against
current labeling.

## Getting started

Requires the Flutter SDK (Dart `^3.11.0`).

```bash
flutter pub get
flutter run            # pick a device, or:
flutter run -d chrome  # web
flutter run -d macos   # desktop
```

Supported targets: Android, iOS, macOS, Linux, Windows, and web.

## Testing

```bash
flutter test       # model tests + a widget smoke test
flutter analyze    # static analysis (clean)
```

## Architecture

- **State:** [`provider`](https://pub.dev/packages/provider) — `MuscleDataProvider`
  plus theme, favorites, and recently-viewed managers (`ChangeNotifier`).
- **Routing:** [`go_router`](https://pub.dev/packages/go_router) — dashboard,
  muscle groups, muscle detail, and the calculator.
- **Data:** JSON assets loaded at runtime; no network dependency for core content.

```
lib/
  main.dart            App entry + provider wiring
  router.dart          go_router routes
  models/              Muscle, Dosage, SpasticityPattern, UE classification
  data/                Asset loaders + providers
  screens/             Dashboard, muscle detail, calculator
  widgets/             Anatomy diagram, US gallery, safety callout, syringe, …
  theme/               Theming + favorites/recently-viewed managers
assets/
  data/                muscles.json, patterns.json, ue_pattern_classification.json
  images/anatomy/      Per-muscle anatomy reference renders
tools/                 Content-pipeline scripts (anatomy rendering, data audits, migrations)
docs/                  Plans, brainstorms, and image-source credits
```

### Data model

`assets/data/muscles.json` is the source of truth for muscle content. Each entry is
parsed by `Muscle.fromJson` ([lib/models/muscle.dart](lib/models/muscle.dart)) and
includes `landmarks`, `placement`, `setup`, `ultrasound`, brand-specific `dosage`,
`pearls`, `dangerZones`, `spasticityPatterns`, `anatomyImages`, and `supplies`.
The model tolerates legacy shapes (e.g. a bare string dose is read as Botox, a
list `anatomyImages` as `{anterior: …}`) to keep older data loadable during
migrations.

## Tooling

`tools/` holds the Python scripts used to build and maintain content — anatomy
image harvesting/rendering (Wikimedia + Z-Anatomy via Blender), data audits, and
field migrations (e.g. `migrate_remaining_danger_zones.py`, which reclassifies
safety-critical pearls into `dangerZones`). These are authoring tools, not part of
the shipped app.

## Image credits

Anatomy reference images are redistributed under their original licenses. Full,
machine-readable attribution is in [`docs/credits/`](docs/credits/).

- **Wikimedia Commons — Anatomography**, upstream **BodyParts3D** © The Database
  Center for Life Science (DBCLS), licensed **CC-BY-SA 2.1 JP**.
- **Z-Anatomy** (Gauthier Kervyn, Lluís Vinent, Marcin Zielinski),
  https://www.z-anatomy.com/ — licensed **CC-BY-SA 4.0**.

The ShareAlike provision applies to these images (and our rendered derivatives),
**not** to the surrounding app code or muscle metadata.

## License

No open-source license is granted for the application code at this time
(`publish_to: none`); it is a private clinical tool. Bundled anatomy images retain
their respective CC-BY-SA licenses as noted above.
