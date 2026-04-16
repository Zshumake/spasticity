"""Dump all skeleton mesh names to see groupings (upper limb, lower limb, etc)."""
import bpy
import json
from pathlib import Path

OUT = Path("/Users/zacharyshumaker/Desktop/MY INVENTIONS/SPasticity INjection/NeuroInject/tools/zanatomy_skeleton_mesh_names.txt")

skeleton_coll = None
for c in bpy.data.collections:
    if c.name.endswith("Skeletal system"):
        skeleton_coll = c
        break

meshes = sorted([o.name for o in skeleton_coll.all_objects if o.type == 'MESH'])

with open(OUT, "w") as f:
    for m in meshes:
        f.write(f"{m}\n")
print(f"[dump] {len(meshes)} skeleton meshes written to {OUT}")

# Also dump collection names that contain "bone", "limb", "pelvi", "skull"
relevant_colls = []
for c in bpy.data.collections:
    nl = c.name.lower()
    if any(kw in nl for kw in ["bone", "limb", "pelvi", "skull", "vertebra", "cranium", "hand", "foot", "arm", "leg", "thigh", "femur", "humerus", "radius", "ulna", "tibia", "fibula"]):
        relevant_colls.append((c.name, len(list(c.all_objects))))

print(f"\n[dump] {len(relevant_colls)} possibly-skeletal collections")
for n, count in sorted(relevant_colls)[:50]:
    print(f"  {count:6d}  {n}")
