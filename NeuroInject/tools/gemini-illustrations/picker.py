#!/usr/bin/env python3
"""Source-photo picker for the Gemini illustration tasks.

For every task this shows the muscle's ultrasound image next to EVERY photo
that could plausibly mark that muscle — the whole candidate pool from the same
body region, across sessions, including markers assigned to neighbouring
muscles, deleted-target markers, and quarantined rejects. Click a photo to make
it that task's staged Gemini source: picks.json is updated, the 2048 px source
is re-exported, and tasks.json / tasks.md are kept in sync — no separate
rebuild step needed.

Run:  python3 tools/gemini-illustrations/picker.py        (port 8124)
Then open http://127.0.0.1:8124
"""
import html
import json
import re
import subprocess
import sys
import urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

G = Path(__file__).resolve().parent
ROOT = G.parent.parent                      # NeuroInject app root
PHOTOS = ROOT / "Anatomy positioning pictures"
IMG = ROOT / "docs" / "photo-matching" / "img"
US = ROOT / "US Pictures"

TASKS = json.load(open(G / "tasks.json"))
BY_ID = {t["id"]: t for t in TASKS}
EXIF = {l.split("\t")[0].replace(".JPG", ""): l.split("\t")[1].strip()[5:]
        for l in open(G / "exif.tsv") if "\t" in l}
_ns = {}
exec((G / "photo-ledger.py").read_text(), _ns)
LEDGER = _ns["L"]                            # DSC -> (muscle-group, role)

# ---- candidate pools: body region per marker group --------------------------
REGION = {
    "pec-major": "chest", "pec-major-pec-minor": "chest",
    "lat-dorsi": "axilla-back", "lat-dorsi-serratus-anterior": "axilla-back",
    "teres-major-serratus-anterior": "axilla-back",
    "biceps-brachii-brachialis": "arm-anterior", "brachialis": "arm-anterior",
    "triceps": "arm-posterior", "triceps-long-lateral": "arm-posterior",
    "brachioradialis": "forearm-radial", "brachioradialis-2": "forearm-radial",
    "ecrl-ecrb": "forearm-radial",
    "pronator-teres-fcr-phi": "forearm-volar", "fcr-palmaris-longus-phi": "forearm-volar",
    "palmaris-longus-phi": "forearm-volar", "fcu": "forearm-volar",
    "fcu-fds-fdp": "forearm-volar", "fpl": "forearm-volar",
    "pronator-quadratus-median-nerve": "forearm-volar",
    "interossei-adductor-pollicis-fpb": "hand", "hand-lumbricals": "hand",
    "piriformis": "gluteal", "si-joint": "gluteal", "ischial-tuberosity": "gluteal",
    "adductor-longus-brevis-magnus": "thigh-medial", "gracilis-adductor-magnus": "thigh-medial",
    "pectineus": "thigh-medial", "iliopsoas-sartorius": "thigh-medial",
    "rectus-femoris-vastus-intermedius": "thigh-anterior",
    "vastus-lateralis-intermedius": "thigh-anterior", "vastus-medialis": "thigh-anterior",
    "suprapatellar": "thigh-anterior", "it-band": "thigh-anterior",
    "biceps-femoris": "thigh-posterior", "semitendinosus": "thigh-posterior",
    "semimembranosus": "thigh-posterior",
    "gastrocnemius-lateral-soleus": "calf", "gastrocnemius-medial-soleus": "calf",
    "fhl": "calf", "fdl-tibialis-posterior": "calf", "peroneal-tendons": "calf",
    "tibialis-anterior-posterior": "shin", "ehl-edl-tibialis-anterior": "shin",
    "scm": "neck", "scalenes-anterior-middle": "neck", "upper-trapezius": "neck",
    "levator-scapulae": "neck", "trapezius-splenius-capitis-semispinalis-capitis": "neck",
}

# US image shown as anatomical reference per task. For marker tasks the
# ledger group name IS the US filename (that is how the scans were named),
# so resolve through the group rather than guessing by prefix.
US_FOR = {}
for t in TASKS:
    grp = LEDGER.get(t["source_frame"], ("", ""))[0]
    for stem in (grp, t["id"]):
        if stem and (US / (stem + ".jpg")).exists():
            US_FOR[t["id"]] = stem + ".jpg"
            break


def task_group(t):
    """The ledger marker-group a task's current frame belongs to."""
    return LEDGER.get(t["source_frame"], ("", ""))[0]


def pool_for(task):
    """All frames plausibly marking this task's muscle, pick first."""
    if task["mode"] == "position":
        frames = [d for d, (m, r) in LEDGER.items() if r == "pos"]
    else:
        grp = task_group(task) or task["id"]
        region = REGION.get(grp)
        frames = [d for d, (m, r) in LEDGER.items()
                  if r in ("mark", "probe", "deleted") and REGION.get(m) == region]
    frames = sorted(set(frames) | {task["source_frame"]})
    cur = task["source_frame"]
    return [cur] + [f for f in frames if f != cur]


def ensure_thumb(frame):
    dst = IMG / (frame + ".jpg")
    if dst.exists():
        return True
    hits = list(PHOTOS.rglob(frame + ".JPG"))
    if not hits:
        return False
    subprocess.run(["sips", "-Z", "760", "-s", "format", "jpeg", "-s",
                    "formatOptions", "70", str(hits[0]), "--out", str(dst)],
                   capture_output=True)
    return dst.exists()


def restage(task, frame):
    """Make `frame` the task's staged source; sync picks/tasks files."""
    hits = list(PHOTOS.rglob(frame + ".JPG"))
    if not hits:
        return False
    subprocess.run(["sips", "-Z", "2048", "-s", "format", "jpeg", "-s",
                    "formatOptions", "85", str(hits[0]), "--out",
                    str(G / task["source"])], capture_output=True)
    old = task["source_frame"]
    task["source_frame"] = frame
    json.dump(TASKS, open(G / "tasks.json", "w"), indent=1)
    picks = json.load(open(G / "picks.json"))
    picks[task["id"]] = frame
    json.dump(picks, open(G / "picks.json", "w"), indent=1, sort_keys=True)
    md = (G / "tasks.md").read_text().replace(
        f"`{task['source']}`  (frame {old})",
        f"`{task['source']}`  (frame {frame})")
    (G / "tasks.md").write_text(md)
    return True


def render():
    rows = []
    for t in sorted(TASKS, key=lambda x: (x["mode"], x["id"])):
        cells = []
        usimg = US_FOR.get(t["id"])
        if usimg and (IMG / ("us_" + usimg)).exists():
            cells.append(
                f'<figure class="us"><img src="/docs/photo-matching/img/us_{usimg}" loading="lazy">'
                f'<figcaption>ULTRASOUND<span>{html.escape(usimg)}</span></figcaption></figure>')
        for f in pool_for(t):
            if not ensure_thumb(f):
                continue
            grp, role = LEDGER.get(f, ("?", "?"))
            sel = " sel" if f == t["source_frame"] else ""
            flag = {"deleted": " · deleted-target", "probe": " · live probe"}.get(role, "")
            mine = " (assigned here)" if grp == task_group(t) and role != "deleted" else ""
            cells.append(
                f'<figure class="cand{sel}" onclick="pick(\'{t["id"]}\',\'{f}\')">'
                f'<img src="/docs/photo-matching/img/{f}.jpg" loading="lazy">'
                f'<figcaption>{f}<span>{EXIF.get(f, "")} · {html.escape(grp)}{flag}{mine}</span>'
                f'</figcaption></figure>')
        covered = [a.replace("-probe.jpg", "").replace("pos-", "").replace(".jpg", "")
                   for a in t["copy_to_assets"]]
        cov = (f'<span class="chip cov">also covers: {", ".join(c for c in covered if c != t["id"])}</span>'
               if len(covered) > 1 else "")
        rows.append(
            f'<section id="{t["id"]}"><header><h2>{t["id"]}</h2>'
            f'<span class="chip">{t["mode"]}</span>'
            f'<span class="chip cur">pick: {t["source_frame"]}</span>{cov}</header>'
            f'<div class="row">{"".join(cells)}</div></section>')
    return f"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Source picker</title><style>
:root{{color-scheme:dark}}body{{background:#101418;color:#e8edf2;font:15px/1.5 -apple-system,system-ui,sans-serif;margin:0;padding:26px}}
h1{{font-size:21px;margin:0 0 2px}}.sub{{color:#93a1af;font-size:13px;margin:0 0 22px;max-width:960px}}
section{{background:#171d24;border:1px solid #242d37;border-radius:12px;padding:14px 16px;margin:0 0 16px}}
header{{display:flex;gap:10px;align-items:center;margin-bottom:10px}}
h2{{font-size:15px;margin:0;font-family:ui-monospace,monospace}}
.chip{{font-size:10.5px;font-weight:700;letter-spacing:1px;text-transform:uppercase;border-radius:99px;padding:2px 10px;border:1px solid #33404e;color:#93a1af}}
.chip.cur{{color:#18A98A;border-color:#18A98A;text-transform:none}}
.row{{display:flex;gap:10px;overflow-x:auto;padding-bottom:6px}}
figure{{margin:0;flex:0 0 auto;width:210px;cursor:default}}
figure.us{{width:280px}}
figure.cand{{cursor:pointer}}
img{{width:100%;height:180px;object-fit:cover;border-radius:8px;display:block;background:#000;border:2.5px solid transparent}}
figure.us img{{object-fit:contain}}
figure.cand:hover img{{border-color:#4aa3d8}}
figure.cand.sel img{{border-color:#18A98A}}
figure.cand.sel figcaption::before{{content:"✔ STAGED ";color:#18A98A;font-weight:700}}
figcaption{{font-size:10px;letter-spacing:.6px;color:#93a1af;margin-top:5px;font-weight:700;font-family:ui-monospace,monospace}}
figcaption span{{display:block;font-weight:400;color:#5c6b7a}}
</style></head><body>
<h1>Choose each task's Gemini source — full candidate pools</h1>
<p class="sub">Every row shows the ultrasound reference, then ALL photos from that body region that could plausibly
mark the muscle — including frames assigned to neighbouring muscles, deleted-target markers, live-probe shots and
quarantined rejects. <b>Click a photo to stage it</b>: picks.json, sources/ and tasks are updated instantly (green = staged).
Prompts are unchanged by a swap.</p>
{''.join(rows)}
<script>
async function pick(id, frame){{
  await fetch('/pick',{{method:'POST',headers:{{'Content-Type':'application/json'}},
    body:JSON.stringify({{id,frame}})}});
  location.href='#'+id; location.reload();
}}
</script></body></html>"""


class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=str(ROOT), **k)

    def do_GET(self):
        if urllib.parse.urlparse(self.path).path in ("/", "/index.html"):
            body = render().encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            super().do_GET()

    def do_POST(self):
        if self.path != "/pick":
            self.send_error(404)
            return
        req = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))
        t = BY_ID.get(req.get("id"))
        ok = bool(t) and restage(t, req.get("frame", ""))
        self.send_response(200 if ok else 400)
        self.send_header("Content-Length", "2")
        self.end_headers()
        self.wfile.write(b"ok" if ok else b"no")

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8124
    print(f"Picker: http://127.0.0.1:{port}")
    ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
