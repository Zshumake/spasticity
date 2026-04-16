#!/usr/bin/env python3
"""Harvest muscle anatomy images from Wikimedia Commons Anatomography category.

Downloads rendered images (bones + highlighted muscle) from the Life Science
Database Archive (BodyParts3D) via Wikimedia Commons. Licensed CC-BY-SA 2.1 JP.

Source category:
  https://commons.wikimedia.org/wiki/Category:Images_of_human_muscles_from_Anatomography

Technique: hit the API once per file to get the 1024px-thumbnail URL, then
fetch the image from upload.wikimedia.org. Sleep between requests to avoid
429 rate limiting. ~5 seconds per file = ~85 seconds for 17 images.

Usage:
  python3 tools/harvest_wikimedia_anatomy.py
"""
from __future__ import annotations

import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ANATOMY_DIR = ROOT / "assets" / "images" / "anatomy"
MUSCLES_JSON = ROOT / "assets" / "data" / "muscles.json"

UA = "NeuroInjectHarvest/1.0 (educational use; github.com/Zshumake/spasticity)"

# muscle_id → (Wikimedia filename, caption)
HARVEST = {
    # Posterior leg compartment
    "gastrocnemius-medial":    ("Posterior compartment of leg - gastrocnemius.png",   "Posterior leg · gastrocnemius highlighted"),
    "gastrocnemius-lateral":   ("Gastrocnemius muscle - posterior view.png",          "Posterior leg · gastrocnemius highlighted"),
    "soleus-medial":           ("Posterior compartment of leg - soleus.png",          "Posterior leg · soleus highlighted"),
    "soleus-lateral":          ("Soleus muscle - posterior view.png",                 "Posterior leg · soleus highlighted"),
    "fdl":                     ("Posterior compartment of leg - flexor digitorum longus.png", "Deep posterior leg · FDL highlighted"),
    "fhl":                     ("Posterior compartment of leg - flexor hallucis longus.png",  "Deep posterior leg · FHL highlighted"),
    "tibialis-posterior":      ("Posterior compartment of leg - tibialis posterior.png", "Deep posterior leg · tibialis posterior"),
    # Anterior leg compartment
    "tibialis-anterior":       ("Anterior compartment of leg - Tibialis anterior.png",       "Anterior leg · tibialis anterior"),
    "edl":                     ("Anterior compartment of leg - Extensor digitorum longus.png", "Anterior leg · EDL highlighted"),
    "ehl":                     ("Anterior compartment of leg - Extensor hallucis longus.png",  "Anterior leg · EHL highlighted"),
    # Lateral leg compartment (peroneals)
    "peroneus-longus":         ("Lateral compartment of leg - Fibularis longus.png",  "Lateral leg · fibularis/peroneus longus"),
    # Face
    "masseter":                ("Masseter muscle - lateral view.png",                 "Lateral face · masseter highlighted"),
    "temporalis":              ("Temporal muscle - lateral view.png",                 "Lateral face · temporalis highlighted"),
    "corrugator-supercilii":   ("Corrugator supercilii muscle frontal.png",           "Frontal face · corrugator supercilii"),
    "procerus":                ("Procerus muscle frontal.png",                        "Frontal face · procerus highlighted"),
    "mentalis":                ("Mentalis frontal.png",                               "Frontal face · mentalis highlighted"),
    # Neck
    "scm":                     ("Sternomastoid muscle lateral.png",                   "Lateral neck · SCM highlighted"),
}


def api_thumb_url(filename: str, width: int = 1024) -> str | None:
    """Ask the Wikimedia API for the 1024px-wide thumbnail URL."""
    api = ("https://commons.wikimedia.org/w/api.php?"
           "action=query&format=json"
           "&titles=" + urllib.parse.quote(f"File:{filename}") +
           f"&prop=imageinfo&iiprop=url&iiurlwidth={width}")
    req = urllib.request.Request(api, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=20) as r:
        data = json.load(r)
    for _, p in data.get("query", {}).get("pages", {}).items():
        ii = p.get("imageinfo")
        if ii:
            return ii[0].get("thumburl")
    return None


def fetch_with_retry(url: str, out_path: Path, max_retries: int = 3) -> int:
    last_err = None
    for attempt in range(max_retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
            out_path.write_bytes(data)
            return len(data)
        except urllib.error.HTTPError as e:
            last_err = e
            if e.code == 429 and attempt < max_retries - 1:
                wait = 15 * (attempt + 1)  # 15, 30, 45
                print(f"    (429 — waiting {wait}s before retry {attempt+2})")
                time.sleep(wait)
                continue
            raise
        except urllib.error.URLError as e:
            last_err = e
            if attempt < max_retries - 1:
                time.sleep(10)
                continue
            raise
    raise RuntimeError(f"max retries exceeded: {last_err}")


def main():
    ANATOMY_DIR.mkdir(parents=True, exist_ok=True)
    muscles = json.loads(MUSCLES_JSON.read_text())
    muscle_ids = {m["id"] for m in muscles}
    unknown = set(HARVEST.keys()) - muscle_ids
    if unknown:
        print(f"ERROR: unknown muscle IDs: {sorted(unknown)}")
        return 1

    print(f"Harvesting {len(HARVEST)} images to {ANATOMY_DIR}/\n")
    manifest = []
    total_bytes = 0
    success = failed = skipped = 0

    for muscle_id, (wikimedia_name, caption) in HARVEST.items():
        out_path = ANATOMY_DIR / f"{muscle_id}.png"
        if out_path.exists():
            print(f"  ✓ {muscle_id:24s} (already downloaded)")
            manifest.append({"id": muscle_id, "file": f"{muscle_id}.png",
                             "caption": caption, "source": wikimedia_name})
            skipped += 1
            continue
        try:
            url = api_thumb_url(wikimedia_name, width=1024)
            if not url:
                print(f"  ✗ {muscle_id:24s} — no thumburl for {wikimedia_name!r}")
                failed += 1
                continue
            n = fetch_with_retry(url, out_path)
            total_bytes += n
            manifest.append({"id": muscle_id, "file": f"{muscle_id}.png",
                             "caption": caption, "source": wikimedia_name})
            success += 1
            print(f"  ↓ {muscle_id:24s} {n/1024:6.1f} KB")
            # Space requests to stay under Wikimedia rate limits
            time.sleep(5)
        except Exception as e:
            print(f"  ✗ {muscle_id:24s} failed: {type(e).__name__}: {e}")
            failed += 1
            # After a failure, cool down extra to let rate limit recover
            time.sleep(15)

    # Manifest + attribution
    manifest_path = ROOT / "docs" / "credits" / "anatomy-wikimedia-manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps({
        "source": "Wikimedia Commons — Category:Images_of_human_muscles_from_Anatomography",
        "upstream_source": "BodyParts3D, The Database Center for Life Science (DBCLS)",
        "license": "CC-BY-SA 2.1 JP",
        "attribution": "BodyParts3D, © The Database Center for Life Science, licensed under Creative Commons Attribution-Share Alike 2.1 Japan",
        "images": manifest,
    }, indent=2) + "\n")

    print(f"\nSuccess: {success}   Skipped (already had): {skipped}   Failed: {failed}")
    print(f"Downloaded bytes: {total_bytes/1024:.1f} KB")
    print(f"Manifest: {manifest_path.relative_to(ROOT)}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
