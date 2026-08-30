#!/usr/bin/env python3
"""Re-stage Gemini source images after editing picks.json.

picks.json maps each task id to the DSC frame that should be illustrated
(e.g. "fcu": "DSC_0714"). Change any value to a different frame from the same
muscle's folder under "Anatomy positioning pictures/by-muscle/", then run:

    python3 tools/gemini-illustrations/rebuild_sources.py

For every changed pick this re-exports sources/<id>.jpg from the chosen frame
and updates tasks.json / tasks.md in place (prompts are unchanged - frames
within a set share the same posture and marker, only image quality differs).
"""
import json, re, subprocess, sys
from pathlib import Path

G = Path(__file__).resolve().parent
ROOT = G.parent.parent
PHOTOS = ROOT / "Anatomy positioning pictures"

picks = json.load(open(G / "picks.json"))
tasks = json.load(open(G / "tasks.json"))

def find(frame):
    hits = [p for p in PHOTOS.rglob(frame + ".JPG") if "rejects" not in p.parts]
    hits += [p for p in PHOTOS.rglob(frame + ".JPG") if "rejects" in p.parts]
    return hits[0] if hits else None

changed = 0
for t in tasks:
    want = picks.get(t["id"])
    if not want or want == t["source_frame"]:
        continue
    src = find(want)
    if src is None:
        print(f"!! {t['id']}: frame {want} not found under {PHOTOS.name}/ - skipped")
        continue
    subprocess.run(["sips","-Z","2048","-s","format","jpeg","-s","formatOptions","85",
                    str(src), "--out", str(G / t["source"])], capture_output=True)
    old, t["source_frame"] = t["source_frame"], want
    changed += 1
    print(f"   {t['id']}: {old} -> {want}" + ("  (was a reject)" if "rejects" in src.parts else ""))

if changed:
    json.dump(tasks, open(G / "tasks.json", "w"), indent=1)
    md = (G / "tasks.md").read_text()
    for t in tasks:
        md = re.sub(rf"(## \[.\] {re.escape(t['id'])}  .*\n- \*\*Source:\*\* `{re.escape(t['source'])}`  \(frame )DSC_\d+(\))",
                    rf"\g<1>{t['source_frame']}\g<2>", md)
    (G / "tasks.md").write_text(md)
print(f"{changed} source(s) re-staged.")
