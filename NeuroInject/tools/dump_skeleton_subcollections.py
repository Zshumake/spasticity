"""Walk the Skeletal system collection tree and dump every sub-collection
with its mesh count. We want to find things like 'Upper limb bones',
'Lower limb bones', 'Skull', etc. so we can target them per-muscle.
"""
import bpy
import json
from pathlib import Path

OUT = Path("/Users/zacharyshumaker/Desktop/MY INVENTIONS/SPasticity INjection/NeuroInject/tools/zanatomy_skeleton_tree.json")

skeleton_coll = None
for c in bpy.data.collections:
    if c.name.endswith("Skeletal system"):
        skeleton_coll = c
        break

if not skeleton_coll:
    print("Skeletal system not found")
    import sys; sys.exit(1)

tree = {}

def walk(coll, path="", depth=0):
    direct_meshes = [o.name for o in coll.objects if o.type == 'MESH']
    total_meshes = len([o for o in coll.all_objects if o.type == 'MESH'])
    entry = {
        "depth": depth,
        "direct_mesh_count": len(direct_meshes),
        "total_mesh_count": total_meshes,
        "children": [c.name for c in coll.children],
    }
    if direct_meshes:
        entry["direct_meshes_sample"] = direct_meshes[:5]
    tree[f"{path}/{coll.name}" if path else coll.name] = entry
    for child in coll.children:
        walk(child, path + "/" + coll.name if path else coll.name, depth + 1)

walk(skeleton_coll)

OUT.write_text(json.dumps(tree, indent=2, ensure_ascii=False) + "\n")
print(f"[dump] {len(tree)} collections in skeleton tree")
print(f"[dump] wrote to: {OUT}")
