"""Batch-render anatomy reference images from Z-Anatomy's Startup.blend.

For each muscle in tools/muscle_render_map.json:
  1. Hide everything
  2. Show the skeleton (grey)
  3. Show the target muscle mesh(es) (terracotta)
  4. Position the camera to frame the muscle + surrounding context
  5. Render to assets/images/anatomy/<muscle-id>.png

Run:
  /Applications/Blender.app/Contents/MacOS/Blender --background \\
    /tmp/zanatomy/Z-Anatomy/Startup.blend \\
    --python tools/render_anatomy.py -- [--only <muscle-id>]
"""
import bpy
import json
import math
import os
import sys
from mathutils import Vector
from pathlib import Path

# -----------------------------------------------------------------
# Create a fresh scene to bypass Z-Anatomy's custom overrides
# (compositor setup, view-layer config, etc.)
# -----------------------------------------------------------------
src_scene = bpy.context.window.scene
print(f"[render] source scene: {src_scene.name}")
# Check if "RenderScene" exists, remove it
if "RenderScene" in bpy.data.scenes:
    bpy.data.scenes.remove(bpy.data.scenes["RenderScene"])
# Make a fresh one
bpy.ops.scene.new(type='NEW')
bpy.context.window.scene.name = "RenderScene"
print(f"[render] active scene: {bpy.context.window.scene.name}")

ROOT = Path("/Users/zacharyshumaker/Desktop/MY INVENTIONS/SPasticity INjection/NeuroInject")
MAP_FILE = ROOT / "tools" / "muscle_render_map.json"
OUT_DIR = ROOT / "assets" / "images" / "anatomy"
MANIFEST_FILE = ROOT / "docs" / "credits" / "anatomy-wikimedia-manifest.json"

# Which muscles already have Wikimedia images — skip them by default
already_covered = set()
if MANIFEST_FILE.exists():
    try:
        for img in json.loads(MANIFEST_FILE.read_text()).get("images", []):
            already_covered.add(img["id"])
    except Exception as e:
        print(f"[warn] couldn't parse Wikimedia manifest: {e}")

render_map = json.loads(MAP_FILE.read_text())

# Optional --only <muscle-id> to render just one for testing
only_id = None
try:
    dd = sys.argv.index("--")
    user_args = sys.argv[dd + 1:]
    if "--only" in user_args:
        only_id = user_args[user_args.index("--only") + 1]
except (ValueError, IndexError):
    pass

OUT_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------------------------------------------
# Materials
# -----------------------------------------------------------------
def make_material(name: str, rgba: tuple, roughness: float = 0.6) -> bpy.types.Material:
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = rgba
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        # Ensure fully opaque — Z-Anatomy may have alpha on its meshes
        if "Alpha" in bsdf.inputs:
            bsdf.inputs["Alpha"].default_value = 1.0
    # Force opaque blend mode
    mat.surface_render_method = 'DITHERED' if hasattr(mat, 'surface_render_method') else None
    mat.use_backface_culling = False
    return mat


def apply_material(obj, mat):
    """Replace all materials on an object's mesh, and override via object slots
    to defeat any existing per-object slot overrides."""
    # Clear data-level materials
    if obj.data.materials:
        obj.data.materials.clear()
    obj.data.materials.append(mat)
    # Also override via object material slots — some Z-Anatomy objects use this
    for slot in obj.material_slots:
        slot.link = 'OBJECT'
        slot.material = mat


GREY_MAT = make_material("Bone_Grey", (0.88, 0.84, 0.78, 1.0), roughness=0.8)
HIGHLIGHT_MAT = make_material("Muscle_Highlight", (0.88, 0.44, 0.34, 1.0), roughness=0.55)

# -----------------------------------------------------------------
# Camera setup — one global camera we reposition per muscle
# -----------------------------------------------------------------
scene = bpy.context.window.scene  # Use the new RenderScene
# Use or create a render camera
cam_obj = bpy.data.objects.get("RenderCamera")
if cam_obj is None:
    cam_data = bpy.data.cameras.new(name="RenderCamera")
    cam_obj = bpy.data.objects.new("RenderCamera", cam_data)
    scene.collection.objects.link(cam_obj)
cam_obj.data.lens = 50  # normal lens
scene.camera = cam_obj

# Add a sun light for illumination
sun_obj = bpy.data.objects.get("RenderSun")
if sun_obj is None:
    sun_data = bpy.data.lights.new(name="RenderSun", type="SUN")
    sun_data.energy = 4.0
    sun_obj = bpy.data.objects.new("RenderSun", sun_data)
    scene.collection.objects.link(sun_obj)
sun_obj.location = (2, -3, 4)
sun_obj.rotation_euler = (math.radians(45), math.radians(30), 0)

# -----------------------------------------------------------------
# Scene collection lookups (in the original Startup scene)
# -----------------------------------------------------------------
# Find the "Skeletal system" collection — we'll show its meshes as bones
skeleton_coll = None
muscle_coll = None
for c in bpy.data.collections:
    if c.name.endswith("Skeletal system"):
        skeleton_coll = c
    if c.name.endswith("Muscular system"):
        muscle_coll = c

if not skeleton_coll:
    print("[render] ERROR: Skeletal system collection not found")
    sys.exit(1)
if not muscle_coll:
    print("[render] ERROR: Muscular system collection not found")
    sys.exit(1)

print(f"[render] Skeletal system: found")
print(f"[render] Muscular system: found")

# Collect all skeleton meshes once (flat list). Z-Anatomy stores them
# in data but the collections may have view-layer exclusions — here we
# grab meshes directly regardless of visibility.
def collect_meshes(coll):
    out = []
    for o in coll.all_objects:
        if o.type == "MESH":
            out.append(o)
    return out

all_skeleton = collect_meshes(skeleton_coll)
all_muscles = collect_meshes(muscle_coll)
print(f"[render] skeleton meshes: {len(all_skeleton)}, muscle meshes: {len(all_muscles)}")

# Build per-region skeleton subsets by looking up specific Z-Anatomy sub-collections.
# Rather than showing all 804 skeleton meshes filtered by spatial radius, we
# explicitly pick which skeleton subsets belong to each muscle. This produces
# much cleaner "just the arm" / "just the leg" renders.
SKELETON_REGION_COLLS = {
    "upper_limb":      ["Bones of upper limb", "Bones of pectoral girdle"],
    "lower_limb":      ["Bones of lower limb"],
    "forearm_hand":    ["Bones of upper limb"],
    "leg_foot":        ["Bones of lower limb"],
    "head":            ["Bones of cranium"],
    "face":            ["Bones of cranium"],
    "neck":            ["Bones of cranium", "Bones of vertebral column"],
    "cervical":        ["Bones of cranium", "Bones of vertebral column", "Bones of pectoral girdle"],
    "shoulder":        ["Bones of upper limb", "Bones of pectoral girdle", "Bones of thorax"],
    "chest":           ["Bones of thorax", "Bones of pectoral girdle"],
    "back":            ["Bones of thorax", "Bones of vertebral column", "Bones of pectoral girdle"],
    "trunk":           ["Bones of thorax", "Bones of vertebral column", "Bony pelvis"],
    "lumbar":          ["Bones of vertebral column", "Bony pelvis"],
    "hip":             ["Bones of lower limb", "Bony pelvis"],
    "thigh":           ["Bones of lower limb", "Bony pelvis"],
    "foot":            ["Bones of foot", "Bones of lower limb"],
}

region_meshes = {}
for region, coll_names in SKELETON_REGION_COLLS.items():
    meshes = []
    seen = set()
    for cname in coll_names:
        c = bpy.data.collections.get(cname)
        if not c:
            continue
        for o in c.all_objects:
            if o.type == 'MESH' and o.name not in seen:
                meshes.append(o)
                seen.add(o.name)
    region_meshes[region] = meshes
    print(f"[render] region '{region}': {len(meshes)} skeleton meshes")

# LINK all skeleton + muscle objects into the new RenderScene's master
# collection so they render. Source-scene collection tree and its
# hide/exclude settings no longer affect our render.
master_coll = scene.collection
for o in all_skeleton + all_muscles:
    if o.name not in master_coll.objects:
        master_coll.objects.link(o)
print(f"[render] linked {len(all_skeleton) + len(all_muscles)} objects into RenderScene")

# Index muscles by name for fast lookup
muscle_by_name = {o.name: o for o in all_muscles}

# -----------------------------------------------------------------
# Render settings
# -----------------------------------------------------------------
scene.render.engine = "CYCLES"
# Cycles sample count — low for speed since this is diagram-quality
scene.cycles.samples = 16
scene.cycles.use_denoising = True
scene.render.film_transparent = True
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.render.resolution_x = 1024
scene.render.resolution_y = 1024
scene.render.resolution_percentage = 100
# Disable Freestyle edge rendering — Z-Anatomy ships with this enabled
# for the wireframe look which turns all meshes into hollow outlines
scene.render.use_freestyle = False
# Also disable per-view-layer freestyle
for vl in scene.view_layers:
    vl.use_freestyle = False

# World background
world = scene.world or bpy.data.worlds.new("World")
scene.world = world
if world.use_nodes:
    bg = world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs["Strength"].default_value = 0.6

# -----------------------------------------------------------------
# Helper: compute combined bounding box of a list of objects
# -----------------------------------------------------------------
def bbox_of_objects(objs):
    if not objs:
        return None, None
    mins = Vector((float("inf"),) * 3)
    maxs = Vector((float("-inf"),) * 3)
    for o in objs:
        for corner in o.bound_box:
            wc = o.matrix_world @ Vector(corner)
            for i in range(3):
                mins[i] = min(mins[i], wc[i])
                maxs[i] = max(maxs[i], wc[i])
    center = (mins + maxs) / 2
    size = maxs - mins
    return center, size


def point_camera_at(cam, target_point, from_point):
    """Orient camera to look at target from given position."""
    direction = target_point - from_point
    rot_quat = direction.to_track_quat("-Z", "Y")
    cam.rotation_euler = rot_quat.to_euler()
    cam.location = from_point


# -----------------------------------------------------------------
# Render a single muscle
# -----------------------------------------------------------------
def render_muscle(muscle_id: str, config) -> bool:
    # config is either the new dict schema {"meshes": [...], "region": "..."}
    # or the old list schema [mesh_name, ...]
    if isinstance(config, list):
        mesh_names = config
        region = None
    else:
        mesh_names = config.get("meshes", [])
        region = config.get("region")

    # Find the target meshes
    targets = [muscle_by_name.get(n) for n in mesh_names]
    targets = [t for t in targets if t is not None]
    if not targets:
        print(f"  [skip] {muscle_id}: no target meshes resolved")
        return False

    # Hide ALL linked objects first. We only toggle the objects in the
    # RenderScene, since that's where rendering happens.
    for o in master_coll.objects:
        o.hide_render = True
        o.hide_viewport = True

    # Show + highlight target muscle first (so we know the center)
    for t in targets:
        t.hide_render = False
        t.hide_viewport = False
        apply_material(t, HIGHLIGHT_MAT)

    # Compute target center for regional bone selection
    target_center, target_size = bbox_of_objects(targets)
    target_span = max(target_size.x, target_size.y, target_size.z) if target_size else 0.5

    # Show skeleton bones for the muscle's anatomical region only.
    # Falls back to a spatial radius filter if no region is defined.
    shown_bones = 0
    if region and region in region_meshes:
        # Region-based: show exactly the bones that belong to this region
        for o in region_meshes[region]:
            o.hide_render = False
            o.hide_viewport = False
            apply_material(o, GREY_MAT)
            shown_bones += 1
    else:
        # Fallback: spatial radius around the target muscle
        radius = max(target_span * 3.0, 0.3)
        for o in all_skeleton:
            bc, _ = bbox_of_objects([o])
            if bc is None:
                continue
            if (bc - target_center).length < radius:
                o.hide_render = False
                o.hide_viewport = False
                apply_material(o, GREY_MAT)
                shown_bones += 1

    # Make sure lights + camera are visible
    cam_obj.hide_render = False
    cam_obj.hide_viewport = False
    sun_obj.hide_render = False
    sun_obj.hide_viewport = False

    # Camera: frame the muscle with some surrounding bone context
    center = target_center
    size = target_size
    if center is None:
        return False
    # Distance scaled to the larger horizontal dimension
    span = max(size.x, size.y, size.z)
    cam_distance = max(span * 3.5, 0.6)

    # Default viewing angle: anterior with slight elevation, rotating
    # around Z for appropriate body region
    lname = mesh_names[0].lower() if mesh_names else ""
    is_back = any(kw in lname for kw in ["trapezius", "splenius", "longissimus", "semispinalis", "erector", "latissimus", "teres", "piriformis", "gluteus"])

    # Build camera position: primarily from the -Y direction (anterior),
    # but swing around for posterior structures
    if is_back or region == "back":
        # Camera behind subject looking forward
        cam_pos = center + Vector((0.15 * span, cam_distance * 0.9, 0.1 * span))
    else:
        # Default anterior view
        cam_pos = center + Vector((0.15 * span, -cam_distance * 0.9, 0.1 * span))

    point_camera_at(cam_obj, center, cam_pos)

    # Tighten the lens to fit the muscle
    # (orthographic-ish feel — good for diagrams)
    cam_obj.data.lens = 50

    # Force depsgraph update to apply visibility changes
    bpy.context.view_layer.update()


    # Render
    out_path = OUT_DIR / f"{muscle_id}.png"
    scene.render.filepath = str(out_path)
    bpy.ops.render.render(write_still=True)
    size_kb = out_path.stat().st_size / 1024 if out_path.exists() else 0
    print(f"  ↓ {muscle_id:28s} {size_kb:6.1f} KB  ({len(targets)} mesh{'es' if len(targets) > 1 else ''})")
    return True


# -----------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------
print(f"[render] Target dir: {OUT_DIR}")
print(f"[render] {len(already_covered)} muscles already covered by Wikimedia (skipped)")
print()

rendered = 0
skipped = 0
failed = 0

todo = [(mid, config) for mid, config in render_map.items()]
if only_id:
    todo = [(mid, config) for mid, config in todo if mid == only_id]
    if not todo:
        print(f"[render] --only {only_id}: no match in render_map")
        sys.exit(1)

for mid, config in todo:
    if only_id is None and mid in already_covered:
        skipped += 1
        continue
    try:
        ok = render_muscle(mid, config)
        if ok:
            rendered += 1
        else:
            failed += 1
    except Exception as e:
        print(f"  [ERR] {mid}: {type(e).__name__}: {e}")
        failed += 1

print()
print(f"[render] Rendered: {rendered}, skipped: {skipped}, failed: {failed}")
