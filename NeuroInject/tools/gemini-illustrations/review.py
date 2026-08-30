#!/usr/bin/env python3
"""Review UI for the Gemini-generated illustrations.

Serves a local page pairing every task's SOURCE photo with the GENERATED
illustration the agent wrote into output/, and lets the reviewer act on each:

    Approve      -> status "approved"; tasks.md checkbox becomes [x]
    Regenerate   -> status "regenerate" with an optional feedback note; the bad
                    image is archived to output/rejected/<id>-round<N>.png so
                    the slot reads "awaiting regeneration"; tasks.md gets [R]

State lives in review-status.json — the SAME file the Antigravity agent reads
to find regeneration work (see README.md, "Regeneration pass"). The reviewer's
note is appended to the prompt on the redo, so write what was wrong ("left/right
flipped", "extra fingers", "probe bar drifted distally").

Run:  python3 tools/gemini-illustrations/review.py        (port 8123)
Then open http://127.0.0.1:8123
"""
import html
import json
import re
import shutil
import sys
import urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

G = Path(__file__).resolve().parent
TASKS = json.load(open(G / "tasks.json"))
BY_ID = {t["id"]: t for t in TASKS}
STATUS_FILE = G / "review-status.json"
MARK = {"approved": "x", "regenerate": "R", "pending": " "}


def load_status():
    s = json.load(open(STATUS_FILE)) if STATUS_FILE.exists() else {}
    for t in TASKS:
        s.setdefault(t["id"], {"status": "pending", "note": "", "rounds": 0})
    return s


def save_status(s):
    json.dump(s, open(STATUS_FILE, "w"), indent=1, sort_keys=True)
    # Mirror into tasks.md so the checklist stays the single visible truth.
    md_path = G / "tasks.md"
    md = md_path.read_text()
    for t in TASKS:
        md = re.sub(
            rf"## \[.\] {re.escape(t['id'])}  ",
            f"## [{MARK[s[t['id']]['status']]}] {t['id']}  ",
            md,
        )
    md_path.write_text(md)


def orphan_outputs():
    """Files in output/ that no task claims — usually a misnamed save."""
    claimed = {Path(t["output"]).name for t in TASKS}
    return sorted(
        p.name
        for p in (G / "output").glob("*")
        if p.is_file() and p.name not in claimed
    )


def render():
    s = load_status()
    done = sum(1 for v in s.values() if v["status"] == "approved")
    redo = sum(1 for v in s.values() if v["status"] == "regenerate")
    have = sum(1 for t in TASKS if (G / t["output"]).exists())
    rows = []
    # regenerate first (they need eyes), then pending-with-output, then rest
    def key(t):
        v = s[t["id"]]
        gen = (G / t["output"]).exists()
        return {"regenerate": 0, "pending": 1 if gen else 2, "approved": 3}[v["status"]] if v["status"] != "pending" or True else 9
    ordered = sorted(TASKS, key=lambda t: (
        {"regenerate": 0, "pending": 1, "approved": 3}[s[t["id"]]["status"]]
        - (0 if (G / t["output"]).exists() else -1 if s[t["id"]]["status"] == "pending" else 0),
        t["id"]))
    for t in ordered:
        v = s[t["id"]]
        out = G / t["output"]
        gen_cell = (
            f'<a href="/{t["output"]}?t={int(out.stat().st_mtime)}" target="_blank">'
            f'<img src="/{t["output"]}?t={int(out.stat().st_mtime)}"></a>'
            if out.exists()
            else '<div class="ph">not generated yet</div>'
            if v["rounds"] == 0 and v["status"] != "regenerate"
            else '<div class="ph redo">awaiting regeneration<br>'
                 f'<small>round {v["rounds"]} archived</small></div>'
        )
        note = html.escape(v.get("note", ""))
        rows.append(f"""
<section class="s-{v['status']}" id="{t['id']}">
 <header><h2>{t['id']}</h2><span class="chip mode">{t['mode']}</span>
   <span class="chip st">{v['status']}</span></header>
 <div class="pair">
   <figure><a href="/{t['source']}" target="_blank"><img src="/{t['source']}"></a>
     <figcaption>SOURCE · {t['source_frame']}</figcaption></figure>
   <figure>{gen_cell}<figcaption>GENERATED · {Path(t['output']).name}</figcaption></figure>
 </div>
 <div class="controls">
   <button class="ok" onclick="mark('{t['id']}','approved')">Approve</button>
   <button class="bad" onclick="mark('{t['id']}','regenerate')">Regenerate</button>
   <input id="note-{t['id']}" placeholder="what's wrong? (sent to Gemini on the redo)" value="{note}">
 </div>
</section>""")
    orphans = orphan_outputs()
    orphan_html = (
        '<p class="orphan">⚠ unclaimed files in output/ (misnamed?): '
        + ", ".join(f"<code>{html.escape(o)}</code>" for o in orphans) + "</p>"
        if orphans else ""
    )
    return f"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Illustration review</title><style>
:root{{color-scheme:dark}}body{{background:#101418;color:#e8edf2;font:15px/1.5 -apple-system,system-ui,sans-serif;margin:0;padding:26px}}
h1{{font-size:21px;margin:0 0 2px}}.sub{{color:#93a1af;font-size:13px;margin:0 0 22px}}
.orphan{{color:#E04A3F;font-size:13px}}
section{{background:#171d24;border:1px solid #242d37;border-radius:12px;padding:14px 16px;margin:0 0 16px}}
section.s-approved{{opacity:.55;border-color:#18A98A44}}
section.s-regenerate{{border-color:#E04A3F88}}
header{{display:flex;gap:10px;align-items:center;margin-bottom:10px}}
h2{{font-size:15px;margin:0;font-family:ui-monospace,monospace}}
.chip{{font-size:10.5px;font-weight:700;letter-spacing:1px;text-transform:uppercase;border-radius:99px;padding:2px 10px;border:1px solid #33404e;color:#93a1af}}
.s-approved .st{{color:#18A98A;border-color:#18A98A}}
.s-regenerate .st{{color:#E04A3F;border-color:#E04A3F}}
.pair{{display:grid;grid-template-columns:1fr 1fr;gap:12px}}
img{{width:100%;height:300px;object-fit:contain;background:#000;border-radius:8px;display:block}}
.ph{{height:300px;display:flex;flex-direction:column;align-items:center;justify-content:center;border:1px dashed #33404e;border-radius:8px;color:#5c6b7a}}
.ph.redo{{color:#E04A3F;border-color:#E04A3F66}}
figcaption{{font-size:10.5px;letter-spacing:1px;color:#93a1af;margin-top:5px;font-weight:700}}
.controls{{display:flex;gap:8px;margin-top:10px}}
button{{font:600 13px -apple-system,system-ui;border-radius:8px;border:0;padding:8px 16px;cursor:pointer}}
.ok{{background:#18A98A;color:#fff}}.bad{{background:#E04A3F;color:#fff}}
input{{flex:1;background:#101418;border:1px solid #33404e;border-radius:8px;color:#e8edf2;padding:8px 10px;font-size:13px}}
@media(max-width:760px){{.pair{{grid-template-columns:1fr}}img,.ph{{height:auto;min-height:160px}}}}
</style></head><body>
<h1>Illustration review — {have}/{len(TASKS)} generated · {done} approved · {redo} queued for regeneration</h1>
<p class="sub">Approve locks the pair. Regenerate archives the image, queues the task, and sends your note to
Gemini on the redo. Reload after the agent runs to see fresh images. State: <code>review-status.json</code>.</p>
{orphan_html}
{''.join(rows)}
<script>
async function mark(id, status){{
  const note=document.getElementById('note-'+id).value;
  await fetch('/mark',{{method:'POST',headers:{{'Content-Type':'application/json'}},
    body:JSON.stringify({{id,status,note}})}});
  location.reload();
}}
</script></body></html>"""


class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=str(G), **k)

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
        if self.path != "/mark":
            self.send_error(404)
            return
        n = int(self.headers.get("Content-Length", 0))
        req = json.loads(self.rfile.read(n))
        tid, status = req.get("id"), req.get("status")
        if tid not in BY_ID or status not in MARK:
            self.send_error(400)
            return
        s = load_status()
        v = s[tid]
        out_file = G / BY_ID[tid]["output"]
        if status == "approved" and not out_file.exists():
            # nothing to approve yet - refuse instead of poisoning the queue
            self.send_error(409, "no generated image to approve")
            return
        v["status"] = status
        v["note"] = req.get("note", "")
        if status == "regenerate":
            out = G / BY_ID[tid]["output"]
            if out.exists():  # archive the disaster, keep the slot empty
                v["rounds"] += 1
                arch = G / "output" / "rejected"
                arch.mkdir(exist_ok=True)
                shutil.move(str(out), arch / f"{tid}-round{v['rounds']}{out.suffix}")
        save_status(s)
        self.send_response(200)
        self.send_header("Content-Length", "2")
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8123
    save_status(load_status())  # materialise the file so the agent can rely on it
    print(f"Review UI: http://127.0.0.1:{port}")
    ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
