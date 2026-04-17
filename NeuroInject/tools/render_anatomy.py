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
# Deep clinical red — matches anatomy-atlas convention for highlighted muscles.
# RGB (0.50, 0.05, 0.07) ≈ hex #800C12 — saturated, dark, fully opaque, matte.
# Because the world light is bright white, base colors get washed toward their
# highlight; darker source values land at a truer clinical red.
HIGHLIGHT_MAT = make_material("Muscle_Highlight", (0.50, 0.05, 0.07, 1.0), roughness=0.75)

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

# Brighten the world background itself — this gives omnidirectional
# ambient light that fills in all sides of the muscle regardless of
# camera angle, so posterior/lateral views don't come out silhouetted.
world_local = scene.world or bpy.data.worlds.new("RenderWorld")
scene.world = world_local
world_local.use_nodes = True
bg_node = world_local.node_tree.nodes.get("Background")
if bg_node:
    bg_node.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    # Moderate world light — enough to keep posterior view legible, low enough
    # to preserve color saturation on the highlighted muscle.
    bg_node.inputs["Strength"].default_value = 0.55

# Plus a top-down sun for directional shading so the model doesn't
# look flat. Boosted energy compensates for the lower world light so
# surfaces remain well-lit while keeping muscle colors saturated.
sun_data = bpy.data.lights.new(name="SunKey", type="SUN")
sun_data.energy = 3.5
sun_obj = bpy.data.objects.new("SunKey", sun_data)
scene.collection.objects.link(sun_obj)
sun_obj.location = (0, 0, 5)
sun_obj.rotation_euler = (math.radians(20), math.radians(15), 0)
# Keep placeholder names so the visibility loop doesn't break
sun_front = sun_back = sun_side = sun_top = sun_obj

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
    # Upper limb: radius/ulna/humerus + pectoral girdle + INDIVIDUAL hand bones
    # ("Right hand" provides real hand bone meshes since "Bones of upper limb"
    # only contains rolled-up .j grouping meshes for the hand)
    "upper_limb":      ["Bones of upper limb", "Bones of pectoral girdle", "Right hand"],
    "forearm_hand":    ["Bones of upper limb", "Right hand"],
    # Lower limb: pull in individual foot bones via "Right foot"
    "lower_limb":      ["Bones of lower limb", "Right foot"],
    "leg_foot":        ["Bones of lower limb", "Right foot"],
    "foot":            ["Bones of lower limb", "Right foot"],
    "head":            ["Bones of cranium"],
    "face":            ["Bones of cranium"],
    # Neck: cranium + vertebral column + pectoral girdle (clavicle/scapula
    # for SCM insertion) + upper thorax (sternum for SCM, ribs for scalenes)
    "neck":            ["Bones of cranium", "Bones of vertebral column",
                        "Bones of pectoral girdle", "Bones of thorax"],
    "cervical":        ["Bones of cranium", "Bones of vertebral column",
                        "Bones of pectoral girdle", "Bones of thorax"],
    "shoulder":        ["Bones of upper limb", "Bones of pectoral girdle", "Bones of thorax"],
    # Chest/back include "Bones of upper limb" because pec major, lat dorsi,
    # and trapezius all insert on the humerus (via tendons that cross the
    # chest-to-arm region boundary).
    "chest":           ["Bones of thorax", "Bones of pectoral girdle",
                        "Bones of upper limb"],
    "back":            ["Bones of thorax", "Bones of vertebral column",
                        "Bones of pectoral girdle", "Bones of upper limb"],
    "trunk":           ["Bones of thorax", "Bones of vertebral column", "Bony pelvis"],
    "lumbar":          ["Bones of vertebral column", "Bony pelvis"],
    "hip":             ["Bones of lower limb", "Bony pelvis", "Right foot"],
    "thigh":           ["Bones of lower limb", "Bony pelvis"],
}

# "Right hand" and "Right foot" collections contain individual hand/foot
# bones but also non-bone elements (muscles, ligaments, joint capsules).
# Filter to keep only things that are clearly bony.
_NON_BONE_KEYWORDS = (
    "muscle", "muscul", "tendon", "fascia", "ligament", "capsule",
    "retinaculum", "aponeurosis", "lumbrical", "interosseous", "flexor",
    "extensor", "abductor", "adductor", "opponens", "palmaris",
    "head of fcr", "head of fcu",  # just in case
)

def _is_bone_like(name: str) -> bool:
    nl = name.lower()
    if any(k in nl for k in _NON_BONE_KEYWORDS):
        return False
    # Skip empty .j/.i grouping meshes that Z-Anatomy uses as parents
    # (heuristic: they exist but have no bone-specific keyword)
    return True

region_meshes = {}
for region, coll_names in SKELETON_REGION_COLLS.items():
    meshes = []
    seen = set()
    for cname in coll_names:
        c = bpy.data.collections.get(cname)
        if not c:
            continue
        for o in c.all_objects:
            if o.type != 'MESH' or o.name in seen:
                continue
            # Skip muscles/ligaments etc when the collection isn't
            # a pure-bone collection (e.g. "Right hand", "Right foot")
            if cname in ("Right hand", "Right foot"):
                if not _is_bone_like(o.name):
                    continue
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

# World background already configured at top of script — leave as-is

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

    # Show skeleton bones using TWO passes, both deterministic and curated:
    #
    #   1. Region bones: the curated regional skeleton (e.g. upper limb,
    #      cranium). Covers origin + insertion for ~95% of muscles.
    #   2. Explicit per-muscle extraCollections: for the handful of
    #      muscles whose tendons cross regions (iliopsoas, tfl, paraspinals,
    #      platysma), we list specific Z-Anatomy collections to add.
    #
    # No proximity/spatial filtering — it pulled in stray bones (random
    # phalanx, contralateral femur) and produced cluttered renders.
    shown_bones = 0
    shown_ids = set()

    def show_bone(o):
        nonlocal shown_bones
        if o.name in shown_ids:
            return
        o.hide_render = False
        o.hide_viewport = False
        apply_material(o, GREY_MAT)
        shown_ids.add(o.name)
        shown_bones += 1

    # Pass 1: region-curated bones (primary)
    if region and region in region_meshes:
        for o in region_meshes[region]:
            show_bone(o)

    # Pass 2: explicit extra bone collections for this specific muscle.
    # Read from the render_map config (if present).
    extras = []
    if isinstance(config, dict):
        extras = config.get("extraCollections", [])
    for cname in extras:
        c = bpy.data.collections.get(cname)
        if not c:
            continue
        for o in c.all_objects:
            if o.type != 'MESH':
                continue
            # Same filtering as region map construction
            if o.name.endswith(".l"):
                continue
            if o.name.endswith(".j") and "Bones of" in o.name:
                continue
            # Filter out non-bone meshes from "Right hand"/"Right foot" etc.
            if cname in ("Right hand", "Right foot"):
                if not _is_bone_like(o.name):
                    continue
            show_bone(o)

    # Make sure lights + camera are visible
    cam_obj.hide_render = False
    cam_obj.hide_viewport = False
    for sun in (sun_front, sun_back, sun_side, sun_top):
        sun.hide_render = False
        sun.hide_viewport = False

    # Camera framing: use the combined bounding box of everything visible
    # (muscle + region bones + extras) so distant attachment bones aren't
    # clipped off at the edge. But cap the pullback so we don't over-zoom
    # when a large region like "trunk" is in play.
    visible_objs = list(targets) + [o for o in all_skeleton if o.name in shown_ids]
    combined_center, combined_size = bbox_of_objects(visible_objs)
    if combined_center is None:
        return False

    center = target_center
    size = combined_size
    span = max(size.x, size.y, size.z)
    cam_distance = max(span * 1.4, 0.7)

    # Tighten the lens to fit the muscle
    cam_obj.data.lens = 50

    # Force depsgraph update to apply visibility changes
    bpy.context.view_layer.update()

    # ----------------------------------------------------------------
    # Render from 3 camera angles per muscle:
    #   anterior: looking from -Y toward the subject (front view)
    #   posterior: looking from +Y toward the subject (back view)
    #   lateral:  looking from +X toward the subject (right-side view)
    #
    # The offsets are proportional to the muscle's own bounding-box span,
    # so each muscle is framed appropriately regardless of size.
    # ----------------------------------------------------------------
    # cam_pos for each view is relative to the muscle's center.
    #
    # For the lateral view we orbit to the SAME SIDE as the muscle — otherwise
    # the body wall/pelvis/vertebrae occlude the target. Z-Anatomy's default
    # orientation has subject's right at world -X (we render the .r meshes),
    # so negative-X muscles are on subject's right. Camera must be on the
    # same side of 0 as the muscle's center.x — place it further out
    # along that axis.
    d = cam_distance * 0.9  # pull-back distance along the primary axis
    e = cam_distance * 0.15  # slight elevation for all views
    lateral_sign = 1.0 if center.x >= 0 else -1.0
    angles = {
        "anterior":  center + Vector(( 0.0, -d,   e)),
        "posterior": center + Vector(( 0.0,  d,   e)),
        "lateral":   center + Vector((lateral_sign * d, 0.0, e)),
    }

    rendered_any = False
    for view_name, cam_pos in angles.items():
        point_camera_at(cam_obj, center, cam_pos)
        out_path = OUT_DIR / f"{muscle_id}_{view_name}.png"
        scene.render.filepath = str(out_path)
        bpy.ops.render.render(write_still=True)
        size_kb = out_path.stat().st_size / 1024 if out_path.exists() else 0
        print(f"  ↓ {muscle_id:28s} {view_name:10s} {size_kb:6.1f} KB")
        rendered_any = True
    return rendered_any


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
    # Note: Wikimedia muscles are also re-rendered in 3 views for
    # consistency — they can supply their own single-angle image as
    # a separate slot, but the primary anatomy viewer uses Z-Anatomy
    # renders for uniform look + multi-angle support.
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
