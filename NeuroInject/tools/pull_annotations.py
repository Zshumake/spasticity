#!/usr/bin/env python3
"""Merge structure letters and presentation crops authored in the app.

    python3 tools/pull_annotations.py ~/Downloads/us-annotations.json
    python3 tools/pull_annotations.py --check      # validate what is committed

The app's Label & crop screen exports the whole merged corpus, not a patch, so
the exported file can replace the asset wholesale. This script is the gate
between that export and the committed asset.

WHY A GATE. These coordinates are only meaningful against one exact image. A
letter at (480, 220) names a structure in a 960x720 frame; the same numbers in
a differently sized scan point at nothing in particular, silently. Every defect
this corpus has produced was silent, so the rules below FAIL rather than skip:

  1. every scan key names a file that exists in assets/images/clinical/
  2. every letter is inside its scan's pixel bounds
  3. letters are unique within a scan, single characters, and named
  4. a crop lies inside the frame and keeps a usable area
  5. `kind` is one of the known structure kinds

Nothing here re-cuts an image. A crop is four numbers the app applies at paint
time to the scan AND its mask through one transform; the files on disk keep
their chrome, their burned labels and their alignment.
"""
import argparse
import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSET = ROOT / "assets" / "data" / "us-annotations.json"
SCANS = ROOT / "assets" / "images" / "clinical"
KINDS = {"artery", "nerve", "bone", "muscle", "other"}
MIN_CROP = 40


def image_size(path: Path):
    """(width, height) from the file header. No dependency on purpose: this
    runs in CI and on a fresh checkout, and a validator that needs a wheel
    installed is a validator that gets skipped."""
    b = path.read_bytes()
    if b[:8] == b"\x89PNG\r\n\x1a\n":
        w, h = struct.unpack(">II", b[16:24])
        return w, h
    if b[:2] == b"\xff\xd8":
        i = 2
        while i < len(b) - 9:
            if b[i] != 0xFF:
                i += 1
                continue
            marker = b[i + 1]
            if 0xC0 <= marker <= 0xCF and marker not in (0xC4, 0xC8, 0xCC):
                h, w = struct.unpack(">HH", b[i + 5:i + 9])
                return w, h
            i += 2 + struct.unpack(">H", b[i + 2:i + 4])[0]
    raise ValueError(f"cannot read image dimensions: {path}")


def validate(doc):
    errors = []
    scans = doc.get("scans")
    if not isinstance(scans, dict):
        return ["top level has no `scans` object"], 0, 0
    letters = crops = 0
    for name, entry in sorted(scans.items()):
        where = f"{name}"
        path = SCANS / name
        if not path.exists():
            errors.append(f"{where}: no such scan in assets/images/clinical/")
            continue
        try:
            w, h = image_size(path)
        except ValueError as e:
            errors.append(f"{where}: {e}")
            continue

        crop = entry.get("crop")
        if crop is not None:
            if (not isinstance(crop, list) or len(crop) != 4
                    or not all(isinstance(v, (int, float)) for v in crop)):
                errors.append(f"{where}: crop must be [x, y, w, h]")
            else:
                x, y, cw, ch = crop
                if cw < MIN_CROP or ch < MIN_CROP:
                    errors.append(
                        f"{where}: crop {cw:g}x{ch:g} is smaller than {MIN_CROP}px")
                elif x < 0 or y < 0 or x + cw > w or y + ch > h:
                    errors.append(
                        f"{where}: crop [{x:g},{y:g},{cw:g},{ch:g}] leaves the {w}x{h} frame")
                else:
                    crops += 1

        seen = set()
        for l in entry.get("labels") or []:
            letter = str(l.get("letter", "")).strip()
            tag = f"{where}/{letter or '?'}"
            if len(letter) != 1 or not letter.isalpha():
                errors.append(f"{tag}: letter must be a single letter")
            elif letter.upper() in seen:
                errors.append(f"{tag}: duplicate letter on this scan")
            else:
                seen.add(letter.upper())
            if not str(l.get("name", "")).strip():
                errors.append(f"{tag}: has no structure name")
            kind = l.get("kind")
            if kind not in KINDS:
                errors.append(f"{tag}: unknown kind {kind!r} (expected one of {sorted(KINDS)})")
            x, y = l.get("x"), l.get("y")
            if not isinstance(x, (int, float)) or not isinstance(y, (int, float)):
                errors.append(f"{tag}: x/y must be numbers")
            elif not (0 <= x < w and 0 <= y < h):
                errors.append(
                    f"{tag}: point ({x:g},{y:g}) is outside the {w}x{h} frame")
            else:
                letters += 1
    return errors, letters, crops


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("export", nargs="?",
                    help="us-annotations.json exported from the app")
    ap.add_argument("--check", action="store_true",
                    help="validate the committed asset; write nothing")
    args = ap.parse_args()

    if args.check or not args.export:
        if not ASSET.exists():
            print(f"no {ASSET.relative_to(ROOT)} yet — nothing to check")
            return 0
        doc = json.loads(ASSET.read_text())
        errors, letters, crops = validate(doc)
        src = ASSET
    else:
        src = Path(args.export).expanduser()
        doc = json.loads(src.read_text())
        errors, letters, crops = validate(doc)

    if errors:
        print(f"REFUSING — {len(errors)} problem(s) in {src}:", file=sys.stderr)
        for e in errors:
            print(f"  {e}", file=sys.stderr)
        return 1

    scans = doc.get("scans", {})
    annotated = sum(1 for v in scans.values() if v.get("labels") or v.get("crop"))
    print(f"ok: {annotated} scan(s) annotated — {letters} letter(s), {crops} crop(s)")

    if args.check or not args.export:
        return 0

    # Preserve the asset's own header comment rather than the app's shorter one:
    # the file on disk is the documented artefact.
    existing = json.loads(ASSET.read_text()) if ASSET.exists() else {}
    out = {
        "$comment": existing.get("$comment", doc.get("$comment", [])),
        "scans": {k: scans[k] for k in sorted(scans)},
    }
    ASSET.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
    print(f"wrote {ASSET.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
