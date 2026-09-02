#!/usr/bin/env python3
"""Record where the sonographer's burned-in text sits on each ultrasound scan.

    python3 tools/export_label_boxes.py            # write assets/data/us-label-boxes.json
    python3 tools/export_label_boxes.py --check    # report only, write nothing
    python3 tools/export_label_boxes.py --preview <dir>   # render what gets covered

WHY. Every export carries the label the sonographer typed at acquisition —
"FCU, FDS AND FDP", "FDL AND TIB POST" — burned into the pixels, overlapping
the sector rather than sitting in a margin that could be cropped away. On the
reference screens that text is useful provenance. In the identify round it is
the answer printed on the question.

So the app covers these rectangles in that one round, and only there. The scans
themselves are untouched: this writes coordinates, nothing is re-cut, and every
other surface still shows the full frame with its labels intact.

HOW. Burned glyphs are near-pure white (>= 235) where the tissue almost never
saturates, and they are small and thin. Components matching that description
are closed together into words and lines; anything too tall, too wide or too
solid to be text is left alone, so bright fascia and bone cortex are not
covered. Coverage is reported per scan — a scan whose boxes cover a large
fraction of the frame has almost certainly caught anatomy and should be looked
at with --preview rather than trusted.
"""
import argparse
import json
import sys
from pathlib import Path

import cv2
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
CLINICAL = ROOT / "assets" / "images" / "clinical"
OUT = ROOT / "assets" / "data" / "us-label-boxes.json"

WHITE = 235          # glyphs saturate; tissue essentially never does
MAX_COVERAGE = 0.09  # above this, the detector is covering more than chrome


def label_boxes(gray):
    h, w = gray.shape
    m = (gray >= WHITE).astype(np.uint8)
    n, lab, stats, _ = cv2.connectedComponentsWithStats(m, 8)
    glyphs = np.zeros_like(m)
    for i in range(1, n):
        x, y, bw, bh, area = stats[i]
        # A glyph is small, not very tall, and not a long bright streak of
        # fascia: those are wide AND thin, so bound both dimensions and area.
        if 3 <= bh <= 32 and 2 <= bw <= 260 and 6 <= area <= 4000:
            glyphs[lab == i] = 1

    # Join letters into words and words into lines, so the result is a handful
    # of rectangles rather than hundreds of specks.
    glyphs = cv2.morphologyEx(glyphs, cv2.MORPH_CLOSE, np.ones((7, 25), np.uint8))
    n2, _, st2, _ = cv2.connectedComponentsWithStats(glyphs, 8)
    boxes = []
    for i in range(1, n2):
        x, y, bw, bh, area = st2[i]
        if bh < 6 or bw < 10 or area < 60:
            continue
        x0, y0 = max(0, x - 4), max(0, y - 3)
        x1, y1 = min(w, x + bw + 4), min(h, y + bh + 3)
        boxes.append([int(x0), int(y0), int(x1 - x0), int(y1 - y0)])
    return boxes


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--preview", help="write covered copies here for eyeballing")
    args = ap.parse_args()

    scans = sorted(p for p in CLINICAL.iterdir()
                   if p.suffix.lower() in {".jpg", ".jpeg"}
                   and (p.stem.endswith("-us") or p.stem.startswith("us-")))
    out, loud = {}, []
    for p in scans:
        gray = cv2.imread(str(p), cv2.IMREAD_GRAYSCALE)
        if gray is None:
            continue
        h, w = gray.shape
        boxes = label_boxes(gray)
        cover = sum(b[2] * b[3] for b in boxes) / float(w * h)
        out[p.name] = boxes
        if cover > MAX_COVERAGE:
            loud.append((p.name, cover, len(boxes)))
        if args.preview:
            d = Path(args.preview)
            d.mkdir(parents=True, exist_ok=True)
            im = cv2.imread(str(p))
            for x, y, bw, bh in boxes:
                cv2.rectangle(im, (x, y), (x + bw, y + bh), (0, 0, 0), -1)
            cv2.imwrite(str(d / f"{p.stem}.png"), im)

    total = sum(len(v) for v in out.values())
    print(f"{len(out)} scans · {total} label boxes")
    for name, cover, n in loud:
        print(f"  LOOK AT THIS ONE: {name} covers {cover:.1%} in {n} boxes")
    if args.preview:
        print(f"previews written to {args.preview}")
    if args.check:
        print("(--check: nothing written)")
        return 1 if loud else 0

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, indent=1, sort_keys=True) + "\n")
    print(f"wrote {OUT.relative_to(ROOT)}")
    return 1 if loud else 0


if __name__ == "__main__":
    raise SystemExit(main())
