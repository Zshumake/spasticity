#!/usr/bin/env python3
"""Convert the 3D anatomy renders from PNG to WebP, keeping every one of them.

The renders are the single largest thing in the app: 204 files, 89 MB, which
is most of a ~110 MB download. They are stylised illustrations that are
mostly transparent (73-98% of pixels), which is exactly the case PNG handles
badly and WebP handles well — around 10% of the size at a quality where the
error is invisible, with the alpha channel preserved EXACTLY.

    python3 tools/optimize_anatomy.py            # convert, then verify
    python3 tools/optimize_anatomy.py --check    # report only, change nothing

WHAT THIS DELIBERATELY DOES NOT TOUCH: the ultrasound scans in
assets/images/clinical and the highlight masks in assets/images/us_reference.
The scans are the clinical evidence and the masks are alpha data that must
stay pixel-exact and aligned to their scan — neither gets lossy compression.

Alpha is checked for EXACT equality on every file; a single differing alpha
byte fails the run rather than shipping a mask-like asset that shifted.
"""
import argparse
import json
import sys
from pathlib import Path

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
ANATOMY = ROOT / "assets" / "images" / "anatomy"
MUSCLES = ROOT / "assets" / "data" / "muscles.json"
QUALITY = 95
# Judged only over pixels that are actually drawn; fully transparent pixels
# carry arbitrary colour and would flatter the number.
MAX_RMSE = 4.0


def convert(png: Path, write: bool):
    src = cv2.imread(str(png), cv2.IMREAD_UNCHANGED)
    if src is None:
        return None, f"unreadable: {png.name}"
    ok, enc = cv2.imencode(".webp", src, [cv2.IMWRITE_WEBP_QUALITY, QUALITY])
    if not ok:
        return None, f"encode failed: {png.name}"
    dec = cv2.imdecode(enc, cv2.IMREAD_UNCHANGED)
    if dec is None or dec.shape != src.shape:
        return None, f"round-trip changed shape: {png.name}"

    if src.ndim == 3 and src.shape[2] == 4:
        if not np.array_equal(src[:, :, 3], dec[:, :, 3]):
            return None, f"ALPHA CHANGED: {png.name}"
        drawn = src[:, :, 3] > 8
    else:
        drawn = np.ones(src.shape[:2], bool)

    if drawn.any():
        d = (src[:, :, :3].astype(int) - dec[:, :, :3].astype(int))[drawn]
        rmse = float(np.sqrt((d ** 2).mean()))
        if rmse > MAX_RMSE:
            return None, f"rmse {rmse:.2f} over budget: {png.name}"
    else:
        rmse = 0.0

    if write:
        (png.with_suffix(".webp")).write_bytes(enc.tobytes())
    return (png.stat().st_size, len(enc), rmse), None


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="report what would happen; write nothing")
    args = ap.parse_args()

    pngs = sorted(p for p in ANATOMY.iterdir() if p.suffix.lower() == ".png")
    if not pngs:
        print("no PNG renders left to convert")
        return 0

    before = after = 0
    worst = 0.0
    errors = []
    for p in pngs:
        res, err = convert(p, write=not args.check)
        if err:
            errors.append(err)
            continue
        b, a, rmse = res
        before += b
        after += a
        worst = max(worst, rmse)

    if errors:
        print("REFUSING — conversion failed on:", file=sys.stderr)
        for e in errors[:10]:
            print("  " + e, file=sys.stderr)
        # Roll back anything written this run so the tree is never half-converted.
        if not args.check:
            for p in pngs:
                p.with_suffix(".webp").unlink(missing_ok=True)
        return 1

    mb = lambda n: n / 1024 / 1024
    print(f"{len(pngs)} renders: {mb(before):.1f} MB -> {mb(after):.1f} MB "
          f"({100 * after / before:.1f}%), worst RGB rmse {worst:.2f}, alpha exact")
    if args.check:
        print("(--check: nothing written)")
        return 0

    # Repoint the corpus, then drop the PNGs only once every WebP exists.
    data = json.loads(MUSCLES.read_text())
    repointed = 0
    for rec in data:
        imgs = rec.get("anatomyImages") or {}
        for view, fn in list(imgs.items()):
            if fn.lower().endswith(".png"):
                webp = fn[:-4] + ".webp"
                if (ANATOMY / webp).exists():
                    imgs[view] = webp
                    repointed += 1
    MUSCLES.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")

    dropped = 0
    for p in pngs:
        if p.with_suffix(".webp").exists():
            p.unlink()
            dropped += 1
    print(f"repointed {repointed} references, removed {dropped} PNG originals "
          f"(recoverable from git history)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
