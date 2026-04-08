#!/usr/bin/env python3
"""Remove placeholder/incorrect videoUrl values.

Two URLs were pasted across muscles that could not possibly share a
single video (e.g. pIhEW7ye744 on lat-dorsi AND biceps AND brachialis).
These are placeholder artifacts from an earlier lazy population pass.

Clear them — better to show no video than the wrong one. The 2-way
shared URLs (semimem/semitend, gastroc med/lat, soleus med/lat) are
left alone because a single video plausibly covers both heads.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"

BAD_URLS = {
    "https://www.youtube.com/watch?v=pIhEW7ye744",  # 5-way: lat-dorsi + arm flexors + fcu
    "https://www.youtube.com/watch?v=aSR096_WG2k",  # 4-way: triceps + shoulder cluster
}

data = json.loads(MUSCLES.read_text())
cleared = []
for m in data:
    if m.get("videoUrl") in BAD_URLS:
        cleared.append(m["id"])
        m["videoUrl"] = None

# Drop null videoUrl keys so the model treats them as absent
for m in data:
    if m.get("videoUrl") is None and "videoUrl" in m:
        del m["videoUrl"]

MUSCLES.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Cleared videoUrl from {len(cleared)} muscles:")
for mid in cleared:
    print(f"  - {mid}")
