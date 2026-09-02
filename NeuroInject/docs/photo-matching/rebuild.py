#!/usr/bin/env python3
"""Regenerate the photo-matching evidence page from CURRENT state.

Reads the corrected photo ledger, the user's staged Gemini picks, and EXIF
times, and rewrites index.html. Run after any reclassification so the evidence
page never drifts from reality again:

    python3 docs/photo-matching/rebuild.py
"""
import html
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
APP = HERE.parent.parent
G = APP / "tools" / "gemini-illustrations"
US = APP / "US Pictures"
IMG = HERE / "img"

_ns = {}
exec((G / "photo-ledger.py").read_text(), _ns)
LEDGER = _ns["L"]
PICKS = set(json.load(open(G / "picks.json")).values())
EXIF = {l.split("\t")[0].replace(".JPG", ""): l.split("\t")[1].strip()[5:]
        for l in open(G / "exif.tsv") if "\t" in l}

# Rows that were corrected by the person who did the marking - the strongest
# evidence there is. Everything else rests on the timestamp+content matching.
NOTES = {
    "fcu": "USER-CONFIRMED: the FCU marker is the arm-raised set (0712-0713).",
    "fcu-fds-fdp": "USER-CONFIRMED: this scan's marker is the supinated arm-at-side set (0714-0716).",
    "fpl": "USER-CONFIRMED: the 0717-0720 set is FPL.",
    "pronator-quadratus-median-nerve": "0721 and 0722 both mark PQ at the wrist.",
    "biceps-femoris": "USER-CONFIRMED: Jun-25 retake 0763 is biceps femoris.",
    "semimembranosus": "USER-CONFIRMED: Jun-25 retake 0761 is semimembranosus.",
    "semitendinosus": "Jun-25 retake 0762.",
    "piriformis": "USER-CONFIRMED: 0504 is the piriformis marker (0502 was SI-region).",
    "fcr-palmaris-longus-phi": "USER: the 0495-0497 marker is likely FCR, not palmaris "
        "(palmaris longus is not an app muscle); frames folded into this group.",
    "palmaris-longus-phi": "No marker frames remain under this label - see the FCR row.",
}


def fig(frame, cls=""):
    if not (IMG / (frame + ".jpg")).exists():
        return ""
    grp, role = LEDGER.get(frame, ("?", "?"))
    tag = {"probe": " · live probe", "deleted": " · deleted-target"}.get(role, "")
    return (f'<figure class="{cls}"><a href="img/{frame}.jpg" target="_blank">'
            f'<img src="img/{frame}.jpg" loading="lazy"></a>'
            f'<figcaption>{frame}<span>{EXIF.get(frame, "")}{tag}</span></figcaption></figure>')


sections = []
for us in sorted(US.glob("*.jpg")):
    grp = us.stem
    frames = sorted(d for d, (m, r) in LEDGER.items()
                    if m == grp and r in ("mark", "probe", "pos"))
    cells = ""
    if (IMG / ("us_" + us.name)).exists():
        cells += (f'<figure class="us"><a href="img/us_{us.name}" target="_blank">'
                  f'<img src="img/us_{us.name}" loading="lazy"></a>'
                  f'<figcaption>ULTRASOUND<span>{us.name}</span></figcaption></figure>')
    for f in frames:
        cells += fig(f, "pick" if f in PICKS else "")
    note = NOTES.get(grp, "")
    notecls = ' class="confirmed"' if note.startswith("USER") else ""
    sections.append(
        f'<section id="{grp}"><header><h2>{grp}</h2></header>'
        f'<div class="row">{cells}</div>'
        + (f'<p class="note"{notecls}>{html.escape(note)}</p>' if note else "")
        + "</section>")

# appendix: positions + deleted-target markers
pos = "".join(fig(d) for d, (m, r) in sorted(LEDGER.items()) if r == "pos"
              and m in ("supine", "prone", "supine-knee-flexed"))
dele = "".join(fig(d) for d, (m, r) in sorted(LEDGER.items()) if r == "deleted")
appendix = (f'<section><header><h2>shared position photos</h2></header><div class="row">{pos}</div></section>'
            f'<section><header><h2>markers for deleted targets</h2></header><div class="row">{dele}</div>'
            f'<p class="note">Joint/tendon targets removed from the app.</p></section>')

page = f"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>NeuroInject photo alignment — corrected</title><style>
:root{{color-scheme:dark}}body{{background:#101418;color:#e8edf2;font:15px/1.5 -apple-system,system-ui,sans-serif;margin:0;padding:28px}}
h1{{font-size:22px;margin:0 0 4px}}.sub{{color:#93a1af;margin:0 0 26px;font-size:13.5px;max-width:940px}}
section{{background:#171d24;border:1px solid #242d37;border-radius:12px;padding:16px 18px;margin:0 0 18px}}
header{{display:flex;gap:12px;align-items:center;margin-bottom:12px}}
h2{{font-size:15.5px;margin:0;font-family:ui-monospace,monospace}}
.row{{display:flex;gap:10px;overflow-x:auto;padding-bottom:6px}}
figure{{margin:0;flex:0 0 auto;width:225px}}
figure.us{{width:300px}}
img{{width:100%;height:195px;object-fit:cover;border-radius:8px;display:block;background:#000;border:2.5px solid transparent}}
figure.us img{{object-fit:contain}}
figure.pick img{{border-color:#18A98A}}
figure.pick figcaption::before{{content:"GEMINI PICK ";color:#18A98A}}
figcaption{{font-size:10px;letter-spacing:1px;color:#93a1af;margin-top:5px;font-weight:700;font-family:ui-monospace,monospace}}
figcaption span{{display:block;font-weight:400;color:#5c6b7a}}
.note{{color:#aeb9c4;font-size:13px;margin:10px 0 0}}
.note.confirmed{{color:#18A98A}}
</style></head><body>
<h1>Photo alignment — corrected & current</h1>
<p class="sub">Rebuilt from the live ledger after the reviewer's corrections (green notes = confirmed by the person
who did the marking). Green-outlined frames are staged for Gemini right now. Regenerate this page any time with
<code>python3 docs/photo-matching/rebuild.py</code>.</p>
{''.join(sections)}
<h1 style="margin-top:34px">appendix</h1>
{appendix}
</body></html>"""
(HERE / "index.html").write_text(page)
print(f"index.html rebuilt: {len(sections)} US rows")
