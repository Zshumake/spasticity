#!/usr/bin/env python3
"""Normalize referenceImages entries to bare filenames.

The detail page prepends 'assets/images/us_reference/' when loading each
entry, so any JSON value that already includes that prefix ends up as
a double-prefixed 404. Fix: strip the prefix everywhere, keep only the
filename.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"

data = json.loads(MUSCLES.read_text())
fixed = 0
for m in data:
    refs = m.get("referenceImages", [])
    if not refs:
        continue
    new = []
    for r in refs:
        bare = r.split("/")[-1]  # keep only the filename
        if bare != r:
            fixed += 1
        new.append(bare)
    m["referenceImages"] = new

MUSCLES.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Normalized {fixed} referenceImages entries to bare filenames.")
