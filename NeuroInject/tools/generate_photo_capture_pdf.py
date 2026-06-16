#!/usr/bin/env python3
"""Render the clinical photo capture guide as a printable PDF.

Builds a print-optimized, two-column HTML from muscles.json (same shot list and
filename convention as the markdown guide) and converts it to
docs/clinical-photo-guide.pdf using headless Chrome.

Re-run after editing muscle data: python3 tools/generate_photo_capture_pdf.py
"""

import html
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
ROOT = TOOLS.parent
sys.path.insert(0, str(TOOLS))

# Reuse the single source of truth for the convention + region logic.
from generate_photo_capture_guide import (  # noqa: E402
    DATA,
    NEEDLE_RE,
    PHOTOS_PER_MUSCLE,
    REGION_ORDER,
    SLOTS,
    clip,
    region_of,
)

OUT_PDF = ROOT / "docs" / "clinical-photo-guide.pdf"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"


def compact(m, key):
    """Short, print-friendly guidance per shot (the app holds the full text)."""
    if key == "position":
        pl = m.get("placement") or []
        return clip(pl[0], 150) if pl else ""
    if key == "probe":
        # One annotated surface photo: blue bar = probe, red dot = needle.
        parts = []
        hint = m.get("probePlacementHint")
        if hint:
            parts.append(clip(hint, 130))
        pl = m.get("placement") or []
        hits = [s for s in pl if NEEDLE_RE.search(s)]
        if hits:
            parts.append("Needle: " + clip(hits[0], 130))
        if not m.get("ultrasound"):
            parts.append("No US — red dot only; blue bar optional.")
        return " ".join(parts)
    if key == "us":
        us = m.get("ultrasound") or {}
        if not us:
            return "Optional — not typically ultrasound-guided."
        vs = us.get("viewSteps") or []
        depth = f" Depth ≈ {us['depth']}." if us.get("depth") else ""
        return (clip(vs[0], 130) + depth) if vs else depth.strip()
    return ""


def esc(s):
    return html.escape(s or "")


CSS = """
@page { size: letter; margin: 0.55in 0.5in; }
* { box-sizing: border-box; }
body { font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
       color: #1a1512; font-size: 9.5px; margin: 0; }
code { font-family: 'SF Mono', Menlo, Consolas, monospace; }

.cover { text-align: center; padding: 26px 0 16px; border-bottom: 2px solid #E17055; }
.cover h1 { font-size: 26px; margin: 0; }
.cover .sub { color: #E17055; font-weight: 700; letter-spacing: 1.5px;
              margin: 5px 0 14px; text-transform: uppercase; font-size: 10px; }
.cover .big { font-size: 15px; font-weight: 700; margin: 6px 0 14px; }
.legend { display: flex; gap: 18px; justify-content: center; font-size: 10px; margin-bottom: 12px; }
.legend .dot { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:5px; vertical-align: middle; }
.dot.position{background:#00B894} .dot.us{background:#D4A017}
/* Annotation convention, drawn literally: blue bar = probe, red dot = needle. */
.probemark { display:inline-block; position:relative; width:22px; height:8px;
             background:#0984E3; border-radius:2px; margin-right:8px;
             vertical-align:middle; }
.probemark .ndot { position:absolute; right:-4px; top:-4px; width:8px; height:8px;
                   border-radius:50%; background:#D63031;
                   border:1px solid #fff; }
.note { max-width: 6.4in; margin: 0 auto; font-size: 9px; color: #555; line-height: 1.55; }
.note code { color:#C05A44; }

.region { break-before: page; }
.region h2 { font-size: 15px; color: #E17055; border-bottom: 1px solid #E0D5CC;
             padding-bottom: 4px; margin: 0 0 10px; }
.region h2 .count { font-size: 9px; color: #999; font-weight: 400; }

.cards { column-count: 2; column-gap: 16px; }
.card { break-inside: avoid; border: 1px solid #E0D5CC; border-radius: 5px;
        padding: 7px 8px; margin-bottom: 8px; }
.cardhead { display:flex; align-items:baseline; gap:6px; flex-wrap: wrap; }
.mname { font-weight: 700; font-size: 11px; }
.mid { font-size: 8px; color: #999; }
.optflag { font-size: 7.5px; color:#9b1b6b; background:#f6e9f2; padding:1px 4px; border-radius:3px; }
.pat { font-size: 8px; color:#7A6E64; font-style: italic; margin: 1px 0 5px; }

.shot { display:flex; gap:6px; padding: 3px 0; border-top: 1px dashed #eee; }
.box { flex:none; width:11px; height:11px; border:1.4px solid #999; border-radius:2px; margin-top:1px; }
.shot.position .box{border-color:#00B894} .shot.probe .box{border-color:#0984E3}
.shot.us .box{border-color:#D4A017}
.shothead { display:flex; gap:6px; align-items:baseline; flex-wrap: wrap; }
.lbl { font-weight:600; font-size:9px; }
.fn { font-size:8px; color:#C05A44; }
.guide { font-size:8px; color:#555; line-height:1.35; margin-top:1px; }
"""


def build_html(muscles):
    by_region = {r: [] for r in REGION_ORDER}
    for m in muscles:
        by_region[region_of(m["group"])].append(m)
    total = len(muscles)
    us_guided = sum(1 for m in muscles if m.get("ultrasound"))

    p = ["<!doctype html><html><head><meta charset='utf-8'>",
         f"<style>{CSS}</style></head><body>"]

    p.append(f"""
      <header class='cover'>
        <h1>Clinical Photo Capture Guide</h1>
        <div class='sub'>NeuroInject · Spasticity Injection Guide</div>
        <div class='big'>{total} muscles × {PHOTOS_PER_MUSCLE} photos
          = {total * PHOTOS_PER_MUSCLE} images</div>
        <div class='legend'>
          <div><span class='dot position'></span>Patient Position</div>
          <div><span class='probemark'><span class='ndot'></span></span>Probe + Needle Site</div>
          <div><span class='dot us'></span>Ultrasound Image</div>
        </div>
        <div class='note'>
          Save each photo as <code>&lt;muscleId&gt;-&lt;type&gt;.jpg</code>
          (type = <code>position</code> · <code>probe</code> · <code>us</code>)
          into <code>assets/images/clinical/</code>. JPG, landscape preferred.
          The probe + needle site is <b>one annotated photo</b>: draw a
          <b style='color:#0984E3'>blue bar</b> over the probe footprint on the
          skin and a <b style='color:#D63031'>red dot</b> at the needle insertion
          point — save it as <code>&lt;muscleId&gt;-probe.jpg</code>. The app
          auto-detects each file and shows an "N/{PHOTOS_PER_MUSCLE} captured"
          counter on the muscle. <b>{us_guided}/{total}</b> muscles are
          ultrasound-guided; for the rest, the US image is optional and the site
          photo needs only the red dot.
        </div>
      </header>
    """)

    for region in REGION_ORDER:
        ms = by_region[region]
        if not ms:
            continue
        p.append(
            f"<section class='region'><h2>{esc(region)} "
            f"<span class='count'>· {len(ms)} muscles · "
            f"{len(ms) * PHOTOS_PER_MUSCLE} photos</span></h2>"
            f"<div class='cards'>"
        )
        for m in ms:
            mid = m["id"]
            opt = ("" if m.get("ultrasound")
                   else " <span class='optflag'>not typically US-guided</span>")
            rows = []
            for key, label in SLOTS:
                rows.append(f"""
                  <div class='shot {key}'><span class='box'></span>
                    <div>
                      <div class='shothead'><span class='lbl'>{esc(label)}</span>
                        <code class='fn'>{esc(mid)}-{key}.jpg</code></div>
                      <div class='guide'>{esc(compact(m, key))}</div>
                    </div>
                  </div>""")
            p.append(f"""
              <div class='card'>
                <div class='cardhead'><span class='mname'>{esc(m['name'])}</span>
                  <code class='mid'>{esc(mid)}</code>{opt}</div>
                <div class='pat'>{esc(m.get('pattern', ''))}</div>
                {''.join(rows)}
              </div>""")
        p.append("</div></section>")

    p.append("</body></html>")
    return "\n".join(p)


def main():
    muscles = json.loads(DATA.read_text())
    html_str = build_html(muscles)

    # Start clean so a stale PDF can't masquerade as success.
    if OUT_PDF.exists():
        OUT_PDF.unlink()

    with tempfile.TemporaryDirectory() as tmp:
        html_path = Path(tmp) / "guide.html"
        html_path.write_text(html_str, encoding="utf-8")
        profile = Path(tmp) / "chrome-profile"

        cmd = [
            CHROME,
            "--headless=new",
            "--disable-gpu",
            "--no-sandbox",
            f"--user-data-dir={profile}",
            "--virtual-time-budget=8000",
            "--run-all-compositor-stages-before-draw",
            f"--print-to-pdf={OUT_PDF}",
            "--no-pdf-header-footer",
            html_path.as_uri(),
        ]
        # New headless renders + writes the PDF in a few seconds but sometimes
        # never exits. Poll for the PDF to appear and stop growing, then stop
        # Chrome ourselves rather than waiting on a long kill-timeout.
        proc = subprocess.Popen(
            cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        last = -1
        stable = 0
        for _ in range(120):  # up to ~60s safety cap
            if proc.poll() is not None:
                break
            time.sleep(0.5)
            if OUT_PDF.exists():
                size = OUT_PDF.stat().st_size
                if size > 10_000 and size == last:
                    stable += 1
                    if stable >= 3:  # ~1.5s unchanged → write finished
                        break
                else:
                    stable, last = 0, size
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()

        if not OUT_PDF.exists() or OUT_PDF.stat().st_size < 10_000:
            sys.stderr.write("Chrome did not produce a valid PDF.\n")
            return 1

    kb = OUT_PDF.stat().st_size // 1024
    print(f"Wrote {OUT_PDF.relative_to(ROOT)} ({kb} KB) — "
          f"{len(muscles)} muscles, {len(muscles) * PHOTOS_PER_MUSCLE} images.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
