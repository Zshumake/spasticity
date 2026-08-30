#!/usr/bin/env python3
"""Turn rough drawn lassos into baked muscle-highlight masks.

The draw-to-highlight screen exports COCO (see lib/data/coco_exporter.dart).
Each annotation is a hand-drawn outline around one muscle in one US image, and
it is *approximate* — a finger tracing a border on a phone is tens of pixels
off in places. This tool does two jobs:

  1. IDENTIFY. Snap the rough lasso onto the real muscle border. Fascia shows on
     ultrasound as a bright thin curvilinear ridge, which a Hessian ridge filter
     picks out cleanly. The lasso is then treated as a *region hint*, not a
     curve: eroded it marks "certainly muscle", dilated "certainly not", and a
     watershed floods the gap between. The two floods meet on the fascial ridge.

     Region-flooding rather than curve-fitting is what makes this robust. A
     snake pulled toward edges also has to be tethered to the drawing, so it
     inherits the drawing's error; watershed only needs the markers to be
     roughly right, so output quality barely depends on how neat the input was.

  2. TINT. Emit an 8-bit alpha field that is opaque through the muscle's bulk
     and fades to nothing before it reaches the border. Deliberately NO outline:
     where fascia is weak the border is genuinely uncertain, and a crisp line
     both claims a precision the image cannot support and puts every wobble of
     the original drawing on display.

     Fade depth scales with each muscle's own thickness. A fixed depth washes
     thin ribbon muscles (upper trapezius, scalenes) out entirely while barely
     softening a thick one.

Scans are SHARED. One transverse view usually contains several muscles — the
calf view shows medial gastrocnemius AND soleus, and the relationship between
them is itself the lesson — so muscles carrying an `ultrasoundGroup` in
muscles.json all point at one `us-<group>.jpg`, and it is the per-muscle mask
that tells them apart. Muscles without a group use their own `<id>-us.jpg`.

Output, per annotation, into assets/images/us_reference/:

    <muscleId>-us.mask.png     8-bit greyscale alpha, source-image resolution
    <muscleId>-us.preview.png  the tinted result, for eyeballing (not shipped)

The app composites the mask at runtime, so the accent colour stays themeable:
draw the US image, then draw the accent colour masked by this alpha using
BlendMode.color — which keeps the destination's luminosity and takes only the
source's hue/saturation. That is a luminance-preserving tint, so every speckle
and fascial line survives at full contrast.

Run: python3 tools/refine_highlights.py [--coco captures.json] [--preview-only]
"""

import argparse
import json
import sys
from pathlib import Path

import cv2
import numpy as np
from scipy.ndimage import gaussian_filter1d
from skimage.filters import sato
from skimage.segmentation import watershed

TOOLS = Path(__file__).resolve().parent
ROOT = TOOLS.parent
US_DIR = ROOT / "assets" / "images" / "us_reference"

# Highlight palette (user's brand colours, 2026-08-30). The mask carries its
# own colour ramp: terracotta-fill in the muscle's core, lightening toward a
# cream-mixed terracotta at the edge, so the tint literally fades to LIGHTER
# (not merely to transparent) as it approaches the border.
CORE_BGR = (0x2F, 0x50, 0xB2)      # --terracotta-fill  #B2502F
EDGE_BGR = (0xB4, 0xC9, 0xE7)      # terracotta mixed 75% toward --cream
ACCENT_BGR = CORE_BGR              # kept for the preview helper

# Opacity envelope for plain alpha compositing (srcOver in the app): strong in
# the core, still clearly visible at the edge so the lighter edge colour READS,
# then a short feather to zero right at the boundary.
ALPHA_CORE = 0.72
ALPHA_EDGE = 0.34
EDGE_FEATHER_PX = 5

# How far the drawn line is trusted to be wrong, as a fraction of the lasso's
# size. Sets the width of the collar the watershed searches.
SLACK_FRACTION = 0.06
SLACK_MIN, SLACK_MAX = 8, 45

# Fade depth as a fraction of the muscle's half-thickness. Tuned on thick
# (gastrocnemius) and thin (upper trapezius) muscles: 0.30 reads solid through
# the bulk on both and dissolves before reaching the border.
FADE_FRACTION = 0.30
FADE_MIN, FADE_MAX = 10, 90


# ---------------------------------------------------------------- image prep

def image_region(gray, thresh=6):
    """Bounding box of the live scan inside a SonoSite export.

    Exports letterbox the sector in black chrome and burn labels into the
    margins. The sector is the largest contiguous bright blob; burned-in text is
    small isolated components, so a connected-component pass separates them.
    """
    m = (gray > thresh).astype(np.uint8)
    m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    n, _, stats, _ = cv2.connectedComponentsWithStats(m, 8)
    if n <= 1:
        return 0, gray.shape[0], 0, gray.shape[1]
    i = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    x, y, w, h = stats[i, :4]
    return y + 2, y + h - 2, x + 2, x + w - 2


def fascia_map(gray):
    """Per-pixel 'fascia-ness': bright thin curvilinear structure.

    Speckle is multiplicative noise that would swamp a ridge filter, so a small
    bilateral pass flattens the grain while keeping fascial edges sharp. `sato`
    is then run at several scales and maxed, so both thin aponeuroses and
    thicker fascial bands respond.
    """
    g = cv2.bilateralFilter(gray.astype(np.float32) / 255.0, 7, 0.12, 7)
    r = sato(g, sigmas=(1.0, 2.0, 3.0), black_ridges=False)
    return (r / (r.max() + 1e-9)).astype(np.float32)


# ---------------------------------------------------------------- refinement

def _poly_mask(poly, shape):
    m = np.zeros(shape, np.uint8)
    cv2.fillPoly(m, [np.round(np.asarray(poly)).astype(np.int32)], 1)
    return m


def refine_mask(poly, fascia, slack=None):
    """Flood from inside and outside the lasso; they meet on the fascial ridge."""
    shape = fascia.shape
    m = _poly_mask(poly, shape)
    if m.sum() < 25:
        return np.zeros(shape, bool)
    if slack is None:
        slack = int(np.clip(SLACK_FRACTION * np.sqrt(m.sum()), SLACK_MIN, SLACK_MAX))

    def disc(r):
        return cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * r + 1,) * 2)

    sure_fg = cv2.erode(m, disc(slack))
    if sure_fg.sum() < 50:                       # lasso thinner than the collar
        sure_fg = cv2.erode(m, disc(max(2, slack // 3)))
    sure_bg = 1 - cv2.dilate(m, disc(slack))

    markers = np.zeros(shape, np.int32)
    markers[sure_bg > 0] = 1
    markers[sure_fg > 0] = 2

    # Blur the ridge map slightly so broken fascia still forms a continuous
    # barrier rather than letting the flood leak through the gaps.
    elev = cv2.GaussianBlur(fascia, (0, 0), 1.5)
    return watershed(elev / (elev.max() + 1e-9), markers) == 2


def smooth_mask(mask, sigma=4.0):
    """Re-fill the mask from its own smoothed contour.

    Watershed follows every ridge fragment, so its raw border is ragged. Real
    muscle borders are smooth; keeping the raggedness reads as noise.
    """
    m = (mask.astype(np.uint8)) * 255
    m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((7, 7), np.uint8))
    m = cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((5, 5), np.uint8))
    cs, _ = cv2.findContours(m, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    if not cs:
        return mask
    c = max(cs, key=cv2.contourArea).squeeze(1).astype(np.float64)
    if len(c) < 8:
        return mask
    c[:, 0] = gaussian_filter1d(c[:, 0], sigma, mode="wrap")
    c[:, 1] = gaussian_filter1d(c[:, 1], sigma, mode="wrap")
    return _poly_mask(c, mask.shape).astype(bool)


# --------------------------------------------------------------- alpha field

def falloff_alpha(mask):
    """Depth field t (0 at border -> 1 in the core), smoothstepped.

    Drives BOTH the colour ramp (edge colour -> core colour) and the opacity
    envelope. Built from the distance transform so it follows the muscle's own
    shape rather than a blurred silhouette.
    """
    d = cv2.distanceTransform(mask.astype(np.uint8), cv2.DIST_L2, 5)
    depth = float(np.clip(d.max() * FADE_FRACTION, FADE_MIN, FADE_MAX))
    x = np.clip(d / depth, 0, 1)
    t = x * x * (3 - 2 * x)                       # smoothstep: uniform fill
    return cv2.GaussianBlur(t, (0, 0), 2.0)       # with a soft edge, no fade


def opacity_envelope(mask, t):
    """Uniform tint (design decision 2026-08-30, after trying every kind of
    gradient): the falloff band only softens the border - inside it the
    highlight is constant density."""
    return t


def preview(gray, t_field, a_field, strength=0.9):
    """Approximate the app's BlendMode.color compositing: keep the scan's
    luminosity (echotexture), take terracotta's hue/saturation."""
    bgr = cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)
    lab = cv2.cvtColor(bgr, cv2.COLOR_BGR2LAB).astype(np.float32)
    tgt = cv2.cvtColor(np.uint8([[CORE_BGR]]), cv2.COLOR_BGR2LAB)[0, 0].astype(np.float32)
    w = np.clip(a_field, 0, 1) * strength
    lab[..., 1] = lab[..., 1] * (1 - w) + tgt[1] * w
    lab[..., 2] = lab[..., 2] * (1 - w) + tgt[2] * w
    return cv2.cvtColor(lab.astype(np.uint8), cv2.COLOR_LAB2BGR)


# ---------------------------------------------------------------------- i/o

def canvas_to_image(poly, canvas_wh, image_wh, fit="cover"):
    """Map canvas-local capture coords onto source-image pixels.

    MUST match how DrawingCanvas displays the asset, or every polygon lands in
    the wrong place. It currently uses BoxFit.cover (drawing_canvas.dart), which
    scales by the LARGER ratio and crops the overflow — so parts of the image
    are off-canvas and the offsets are negative. `contain` is offered for when
    that widget changes; the two differ only by min/max.
    """
    cw, ch = canvas_wh
    iw, ih = image_wh
    if cw <= 0 or ch <= 0 or iw <= 0 or ih <= 0:
        return np.asarray(poly, float)
    s = (max if fit == "cover" else min)(cw / iw, ch / ih)
    off_x = (cw - iw * s) / 2.0
    off_y = (ch - ih * s) / 2.0
    p = np.asarray(poly, float)
    return np.c_[(p[:, 0] - off_x) / s, (p[:, 1] - off_y) / s]


def scan_for(muscle_id, images_dir):
    """Resolve a muscle's scan the same way the app does.

    One transverse view usually contains several muscles, so muscles carrying an
    `ultrasoundGroup` share `us-<group>.jpg`; the rest have their own
    `<id>-us.jpg`. Their masks stay per-muscle either way — the mask is what
    separates one muscle from its neighbours in a shared view.
    """
    for m in _muscles():
        if m.get("id") != muscle_id:
            continue
        g = m.get("ultrasoundGroup")
        cand = images_dir / (f"us-{g}.jpg" if g else f"{muscle_id}-us.jpg")
        return cand if cand.exists() else None
    return None


_MUSCLE_CACHE = []


def _muscles():
    if not _MUSCLE_CACHE:
        f = ROOT / "assets" / "data" / "muscles.json"
        if f.exists():
            _MUSCLE_CACHE.extend(json.loads(f.read_text()))
    return _MUSCLE_CACHE


def load_jobs(coco_path, images_dir):
    """Flatten a COCO export into (muscleId, image_path, polygon, canvas) jobs."""
    doc = json.loads(Path(coco_path).read_text())
    cats = {c["id"]: c["name"] for c in doc.get("categories", [])}
    imgs = {i["id"]: i for i in doc.get("images", [])}
    jobs = []
    for a in doc.get("annotations", []):
        img = imgs.get(a["image_id"])
        if img is None:
            continue
        seg = a.get("segmentation") or []
        if not seg or len(seg[0]) < 6:
            continue
        flat = seg[0]
        poly = np.asarray(flat, float).reshape(-1, 2)
        muscle = cats.get(a["category_id"], f"cat{a['category_id']}")
        path = images_dir / Path(img["file_name"]).name
        if not path.exists():
            path = scan_for(muscle, images_dir) or path
        jobs.append({
            "muscle": muscle,
            "image": path,
            "poly": poly,
            "canvas": (img.get("width", 0), img.get("height", 0)),
        })
    return jobs


def bake(job, out_dir, write_preview=True):
    """Refine one annotation and write its mask (and preview)."""
    gray = cv2.imread(str(job["image"]), cv2.IMREAD_GRAYSCALE)
    if gray is None:
        return f"SKIP {job['muscle']}: image not found ({job['image'].name})"

    y0, y1, x0, x1 = image_region(gray)
    crop = gray[y0:y1, x0:x1]

    poly = canvas_to_image(job["poly"], job["canvas"], (gray.shape[1], gray.shape[0]))
    poly = poly - np.array([x0, y0])               # into crop coords

    mask = smooth_mask(refine_mask(poly, fascia_map(crop)))
    if mask.sum() < 50:
        return f"SKIP {job['muscle']}: refinement produced an empty mask"

    t_field = falloff_alpha(mask)
    a_field = opacity_envelope(mask, t_field)

    # Write at full source-image resolution so the app can letterbox it exactly
    # like the photo it overlays.
    full = np.zeros(gray.shape, np.float32)
    full[y0:y1, x0:x1] = t_field
    full_alpha = np.zeros(gray.shape, np.float32)
    full_alpha[y0:y1, x0:x1] = a_field

    out_dir.mkdir(parents=True, exist_ok=True)
    # The mask carries the colour ramp itself: BGR interpolated from EDGE to
    # CORE by the same normalised depth that drives the alpha, so the app can
    # composite it directly (BlendMode.color, no colour filter) and the tint
    # lightens toward the border.
    # White RGB + alpha: the app stamps the accent colour (terracotta) with a
    # luminosity-preserving blend, so echotexture stays fully readable.
    a8 = (np.clip(full_alpha, 0, 1) * 255).astype(np.uint8)
    bgra = np.dstack([np.full_like(a8, 255)] * 3 + [a8])
    cv2.imwrite(str(out_dir / f"{job['muscle']}-us.mask.png"), bgra)
    if write_preview:
        # Previews live OUTSIDE the asset tree - us_reference/ is a declared
        # pubspec asset dir, so anything written there ships in the app bundle.
        pv = ROOT / "docs" / "mask-previews"
        pv.mkdir(parents=True, exist_ok=True)
        cv2.imwrite(str(pv / f"{job['muscle']}-us.preview.png"),
                    preview(gray, full, full_alpha))
    cov = 100.0 * mask.sum() / mask.size
    return f"ok   {job['muscle']:<26} {cov:5.1f}% of scan   <- {job['image'].name}"


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--coco", default=str(ROOT / "captures.json"),
                    help="COCO export from the captures-review screen")
    ap.add_argument("--images", default=str(ROOT / "assets" / "images" / "clinical"),
                    help="directory holding the bundled US scans")
    ap.add_argument("--out", default=str(US_DIR))
    ap.add_argument("--no-preview", action="store_true")
    args = ap.parse_args()

    coco = Path(args.coco)
    if not coco.exists():
        # The app's export button downloads a timestamped file - grab the
        # newest one rather than making the user copy it around.
        dl = sorted(Path.home().glob("Downloads/neuroinject-captures-*.json"),
                    key=lambda p: p.stat().st_mtime)
        if dl:
            coco = dl[-1]
            print(f"Using newest export: {coco}")
        else:
            print(f"No COCO export at {coco} and none in ~/Downloads.\n"
                  f"Export one from the captures screen (/captures) first.",
                  file=sys.stderr)
            return 1

    try:
        jobs = load_jobs(coco, Path(args.images))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError) as e:
        print(f"{coco} is not a readable COCO export: {e}", file=sys.stderr)
        return 1
    if not jobs:
        print("COCO export contains no usable annotations.", file=sys.stderr)
        return 1

    print(f"Baking {len(jobs)} highlight(s) -> {args.out}\n")
    bad = 0
    for j in jobs:
        line = bake(j, Path(args.out), write_preview=not args.no_preview)
        if line.startswith("SKIP"):
            bad += 1
        print("  " + line)
    print(f"\n{len(jobs) - bad} baked, {bad} skipped.")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
