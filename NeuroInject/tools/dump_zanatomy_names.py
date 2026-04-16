"""Dump every muscle object name from Z-Anatomy's Startup.blend.

Run via Blender headless:
  /Applications/Blender.app/Contents/MacOS/Blender --background \\
    /tmp/zanatomy/Z-Anatomy/Startup.blend \\
    --python tools/dump_zanatomy_names.py

Outputs muscle-name list to tools/zanatomy_muscle_names.txt.
"""
import bpy
import re
import os
from pathlib import Path

OUT = Path("/Users/zacharyshumaker/Desktop/MY INVENTIONS/SPasticity INjection/NeuroInject/tools/zanatomy_muscle_names.txt")

# Collect object names that look like muscles.
# Z-Anatomy uses Terminologia Anatomica 2 — Latin names like:
#   "Musculus flexor carpi radialis"
#   "Musculus biceps brachii caput longum"
# But also has English fallbacks and collection-level names.

musculus_pattern = re.compile(r"(?i)muscul")

all_names = sorted(set(o.name for o in bpy.data.objects))
muscles = [n for n in all_names if musculus_pattern.search(n)]

# Also dump all collection names (useful for Skeleton, Myology, etc.)
collections = sorted(set(c.name for c in bpy.data.collections))

OUT.parent.mkdir(parents=True, exist_ok=True)
with open(OUT, "w") as f:
    f.write(f"# Total objects: {len(all_names)}\n")
    f.write(f"# Objects matching 'muscul': {len(muscles)}\n")
    f.write(f"# Collections: {len(collections)}\n\n")
    f.write("## Collections\n")
    for c in collections:
        f.write(f"  {c}\n")
    f.write("\n## Muscle objects\n")
    for m in muscles:
        f.write(f"  {m}\n")

print(f"[dump_zanatomy_names] total objects: {len(all_names)}")
print(f"[dump_zanatomy_names] muscle-named objects: {len(muscles)}")
print(f"[dump_zanatomy_names] collections: {len(collections)}")
print(f"[dump_zanatomy_names] wrote to: {OUT}")
