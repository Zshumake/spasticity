"""Dump ALL Z-Anatomy collections that contain mesh objects, plus their mesh
children. We'll post-process this to identify muscles vs bones vs other.

Run:
  /Applications/Blender.app/Contents/MacOS/Blender --background \\
    /tmp/zanatomy/Z-Anatomy/Startup.blend \\
    --python tools/dump_zanatomy_muscles.py
"""
import bpy
import json
from pathlib import Path

OUT = Path("/Users/zacharyshumaker/Desktop/MY INVENTIONS/SPasticity INjection/NeuroInject/tools/zanatomy_collections_with_meshes.json")

out = {}
muscle_system_coll = None
# Look for the top-level "Muscular system" collection
for c in bpy.data.collections:
    if c.name == "4: Muscular system" or c.name == "Muscular system":
        muscle_system_coll = c
        break

if muscle_system_coll:
    print(f"[dump] Found top-level: {muscle_system_coll.name}")
    # Recursively collect ALL descendant collections and their direct-mesh contents
    def walk(coll, depth=0):
        meshes_direct = [o.name for o in coll.objects if o.type == 'MESH']
        if meshes_direct:
            out[coll.name] = {
                "depth": depth,
                "direct_meshes": sorted(meshes_direct),
                "mesh_count": len(meshes_direct),
            }
        for child in coll.children:
            walk(child, depth + 1)
    walk(muscle_system_coll)
else:
    print("[dump] 'Muscular system' collection not found, dumping all with meshes")
    for c in bpy.data.collections:
        meshes_direct = [o.name for o in c.objects if o.type == 'MESH']
        if meshes_direct:
            out[c.name] = {
                "depth": -1,
                "direct_meshes": sorted(meshes_direct),
                "mesh_count": len(meshes_direct),
            }

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
print(f"[dump] {len(out)} collections with direct mesh children")
print(f"[dump] wrote to: {OUT}")
