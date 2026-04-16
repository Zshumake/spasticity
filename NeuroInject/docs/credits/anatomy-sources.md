# Anatomy Reference Images — Attribution

This document provides required attribution for the anatomy reference images shown in NeuroInject.

## Wikimedia Commons — Anatomography

Most of the current anatomy images are sourced from the [Wikimedia Commons "Images of human muscles from Anatomography" category](https://commons.wikimedia.org/wiki/Category:Images_of_human_muscles_from_Anatomography).

**Upstream source:** [BodyParts3D](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/desc.html) — The Database Center for Life Science (DBCLS), Research Organization of Information and Systems, Japan.

**License:** [Creative Commons Attribution-Share Alike 2.1 Japan (CC-BY-SA 2.1 JP)](https://creativecommons.org/licenses/by-sa/2.1/jp/deed.en)

**Required attribution text:**
> BodyParts3D, © The Database Center for Life Science, licensed under Creative Commons Attribution-Share Alike 2.1 Japan

**Machine-readable manifest:** `docs/credits/anatomy-wikimedia-manifest.json` lists every harvested image with its original Wikimedia filename for full traceability.

**ShareAlike note:** Our rendered/resized versions of these images are redistributed under the same CC-BY-SA 2.1 JP license. The ShareAlike provision applies only to these images, not to the surrounding app code or the muscle metadata.

## Z-Anatomy (51 images)

The remaining 51 anatomy images are rendered from the [Z-Anatomy](https://www.z-anatomy.com/) 3D atlas using a custom Blender pipeline. Each image shows the regional skeleton in neutral grey with the target muscle highlighted in terracotta, in a clinically-relevant view.

**Source:** Z-Anatomy Startup.blend from [github.com/Z-Anatomy/Models-of-human-anatomy](https://github.com/Z-Anatomy/Models-of-human-anatomy).

**License:** [Creative Commons Attribution-Share Alike 4.0 International (CC-BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/deed.en)

**Required attribution text:**
> Z-Anatomy (Gauthier Kervyn, Lluís Vinent, Marcin Zielinski) — https://www.z-anatomy.com/ — licensed under CC-BY-SA 4.0

**Render pipeline:** `tools/render_anatomy.py` — uses Blender headless to isolate target muscle meshes, apply highlight materials, filter skeleton by regional radius, and render at 1024×1024 transparent PNG. Not run in CI; re-run manually when the source .blend or muscle map changes.

**Machine-readable manifest:** `docs/credits/anatomy-zanatomy-manifest.json`.

**ShareAlike note:** Our rendered derivative images are redistributed under CC-BY-SA 4.0. SA applies to the images only, not to the app code or muscle metadata.

## User-facing attribution

A small `ℹ About anatomy images` link is shown beneath each anatomy reference card in the app, routing to a credits screen that displays this attribution in a human-readable form.
