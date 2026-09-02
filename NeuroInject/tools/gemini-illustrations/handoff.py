#!/usr/bin/env python3
"""One-at-a-time handoff to Gemini in Antigravity.

Serves a page that presents exactly ONE task per screen — the source photo and
its prompt — and takes the generated image back, so a full cycle is:

    1. "Copy image"  -> ⌘V into the Gemini chat in Antigravity
    2. "Copy prompt" -> ⌘V into the same message, send
    3. drag (or paste) Gemini's result onto the drop zone
       -> saved to the task's exact output path, task ticked, next task shown

Queue order: reviewer-marked regenerations first (feedback auto-appended to
the prompt), then unfinished first-pass tasks in tasks.json order. Paste the
Gem system instructions (button at the top) ONCE per Gemini session — every
per-task prompt assumes those rules are active.

Run:  python3 tools/gemini-illustrations/handoff.py       (port 8125)
"""
import html
import json
import re
import sys
import urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from task_queue import select_tasks

G = Path(__file__).resolve().parent
TASKS = json.load(open(G / "tasks.json"))
BY_ID = {t["id"]: t for t in TASKS}
SYSTEM = (G / "gem-system-instructions.md").read_text()


def status():
    f = G / "review-status.json"
    s = json.load(open(f)) if f.exists() else {}
    for t in TASKS:
        s.setdefault(t["id"], {"status": "pending", "note": "", "rounds": 0})
    return s


def queue():
    """Regenerations first, then ungenerated first-pass tasks."""
    s = status()
    return select_tasks(TASKS, s, G), s


def prompt_for(t, s):
    p = t["prompt"]
    note = s[t["id"]].get("note", "")
    if s[t["id"]]["status"] == "regenerate" and note:
        p += f"\nReviewer feedback on the previous attempt: {note}"
    return p


def mark_done(tid):
    s = status()
    if s[tid]["status"] == "regenerate":
        s[tid]["status"] = "pending"
        json.dump(s, open(G / "review-status.json", "w"), indent=1, sort_keys=True)
    md_path = G / "tasks.md"
    md = md_path.read_text()
    md = re.sub(rf"## \[.\] {re.escape(tid)}  ", f"## [x] {tid}  ", md)
    md_path.write_text(md)


def render(skip=0, forced=None):
    q, s = queue()
    total = len(TASKS)
    done = total - len([t for t in TASKS
                        if s[t["id"]]["status"] == "pending"
                        and not (G / t["output"]).exists()]) \
        - len([t for t in TASKS if s[t["id"]]["status"] == "regenerate"])
    donelist = ""
    submitted = [x for x in TASKS if (G / x["output"]).exists()]
    if submitted:
        links = " ".join(f'<a href="/?task={x["id"]}">{x["id"]}</a>' for x in submitted)
        donelist = (f'<details class="done"><summary>{len(submitted)} already submitted — '
                    f'click one to view or redo it</summary><p>{links}</p></details>')
    if forced is None and not q:
        return donelist + ("<h1>All caught up 🎉</h1><p>Nothing pending or queued for "
                "regeneration. Review results: <code>python3 review.py</code> "
                "(port 8123).</p>")
    t = BY_ID[forced] if forced in BY_ID else q[skip % len(q)]
    is_regen = s[t["id"]]["status"] == "regenerate"
    p = prompt_for(t, s)
    existing = ""
    outp = G / t["output"]
    if outp.exists():
        existing = (f'<div class="already">this task ALREADY has a submitted image '
                    f'(<a href="/{t["output"]}?t={int(outp.stat().st_mtime)}" target="_blank">view it</a>) — '
                    f'dropping a new one replaces it (old copy kept in output/replaced/)</div>')
    nav = (f'<div class="nav">'
           f'<a class="navbtn" href="/?skip={skip-1}">← previous</a>'
           f'<span class="navhint">dropping a result advances automatically — these just browse</span>'
           f'<a class="navbtn" href="/?skip={skip+1}">next →</a></div>')
    return f"""
<div class="bar"><b>{len(q)} to go</b> · {done}/{total} done ·
 showing <code>{t['id']}</code> ({(skip % len(q)) + 1} of {len(q)})
 {' · <span class="re">REGENERATION (feedback included)</span>' if is_regen else ''}</div>
{nav}

{donelist}<div class="setup"><details><summary>⚙️ once per Gemini session: paste the Gem style rules first</summary>
<button onclick="copyText('sys')">Copy system instructions</button>
<textarea id="sys" readonly>{html.escape(SYSTEM)}</textarea></details></div>

{existing}<div class="grid">
 <section>
   <h2>1 · image → Gemini</h2>
   <img id="src" src="/{t['source']}" crossorigin="anonymous">
   <div class="btns">
     <button class="big" onclick="copyImage()">📋 Copy image (then ⌘V in Gemini)</button>
     <a class="dl" href="/{t['source']}" download>or download it</a>
   </div>
   <p class="path">{t['source']} · frame {t['source_frame']}</p>
 </section>
 <section>
   <h2>2 · prompt → same message</h2>
   <button class="big" onclick="copyText('pr')">📋 Copy prompt</button>
   <textarea id="pr" readonly>{html.escape(p)}</textarea>
 </section>
 <section>
   <h2>3 · result → drop here</h2>
   <div id="drop">drag Gemini's image here<br><small>or click to pick a file · or ⌘V to paste it</small></div>
   <p class="path">saves as {t['output']}</p>
 </section>
</div>
{nav}
<script>
const TID = {json.dumps(t["id"])};
function flash(el, msg){{ const o=el.textContent; el.textContent=msg; setTimeout(()=>el.textContent=o, 1200); }}
function copyText(id){{
  navigator.clipboard.writeText(document.getElementById(id).value)
    .then(()=>flash(event.target,'✓ copied'));
}}
async function copyImage(){{
  const img=document.getElementById('src');
  const c=document.createElement('canvas'); c.width=img.naturalWidth; c.height=img.naturalHeight;
  c.getContext('2d').drawImage(img,0,0);
  const blob=await new Promise(r=>c.toBlob(r,'image/png'));
  await navigator.clipboard.write([new ClipboardItem({{'image/png':blob}})]);
  flash(event.target,'✓ image on clipboard');
}}
async function submit(file){{
  const d=document.getElementById('drop');
  d.textContent='saving…';
  const r=await fetch('/upload?id='+encodeURIComponent(TID),{{method:'POST',body:file}});
  if(r.ok){{ d.textContent='✓ saved — next task…'; setTimeout(()=>location.href='/',600); }}
  else {{ d.textContent='save failed ('+r.status+') — try again'; }}
}}
window.addEventListener('dragover',e=>e.preventDefault());
window.addEventListener('drop',e=>e.preventDefault());
const drop=document.getElementById('drop');
drop.addEventListener('dragover',e=>{{e.preventDefault();drop.classList.add('hot');}});
drop.addEventListener('dragleave',()=>drop.classList.remove('hot'));
drop.addEventListener('drop',e=>{{e.preventDefault();drop.classList.remove('hot');
  const f=e.dataTransfer.files[0];
  if(f) return submit(f);
  // A drag straight out of the Gemini panel carries a LINK, not a file.
  drop.innerHTML='that drag carried a link, not the image.<br><small>'+
    'In Gemini: right-click the image → <b>Copy Image</b>, then press <b>⌘V</b> anywhere on this page.<br>'+
    'Or save/download it, then drop the file here.</small>';
}});
drop.addEventListener('click',()=>{{
  const i=document.createElement('input'); i.type='file'; i.accept='image/*';
  i.onchange=()=>i.files[0]&&submit(i.files[0]); i.click();}});
window.addEventListener('keydown',e=>{{
  if(e.target.tagName==='TEXTAREA'||e.target.tagName==='INPUT') return;
  if(e.key==='ArrowRight') location.href='/?skip='+({skip}+1);
  if(e.key==='ArrowLeft')  location.href='/?skip='+({skip}-1);
}});
window.addEventListener('paste',e=>{{
  for(const it of e.clipboardData.items)
    if(it.type.startsWith('image/')) return submit(it.getAsFile());
  document.getElementById('drop').textContent='clipboard had no image — use Copy Image in Gemini first';
}});
</script>"""


PAGE = """<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Gemini handoff</title><style>
:root{color-scheme:dark}body{background:#101418;color:#e8edf2;font:15px/1.5 -apple-system,system-ui,sans-serif;margin:0;padding:22px}
h1{font-size:20px}h2{font-size:13px;letter-spacing:1.2px;text-transform:uppercase;color:#93a1af;margin:0 0 10px}
.bar{background:#171d24;border:1px solid #242d37;border-radius:10px;padding:10px 14px;margin-bottom:14px}
.bar .re{color:#E04A3F;font-weight:700}
.nav{display:flex;align-items:center;justify-content:space-between;margin:0 0 14px}
.navbtn{background:#233041;color:#e8edf2;text-decoration:none;font-weight:600;font-size:14px;
 border-radius:8px;padding:9px 18px}
.navbtn:hover{background:#2e3f55}
.navhint{color:#5c6b7a;font-size:12px}
.setup{margin-bottom:14px;font-size:13px;color:#93a1af}
.done{margin-bottom:12px;font-size:13px;color:#93a1af}
.done a{color:#4aa3d8;margin-right:10px}
.already{background:#3a2a12;border:1px solid #D79A3A;color:#f0c987;border-radius:10px;
 padding:10px 14px;margin-bottom:14px;font-size:13.5px}
.already a{color:#f0c987}
.setup textarea{margin-top:8px}
.grid{display:grid;grid-template-columns:1.2fr 1fr 1fr;gap:14px}
section{background:#171d24;border:1px solid #242d37;border-radius:12px;padding:14px}
img{width:100%;max-height:420px;object-fit:contain;background:#000;border-radius:8px}
textarea{width:100%;height:300px;background:#101418;color:#cfe0ee;border:1px solid #33404e;border-radius:8px;
 font:12px ui-monospace,monospace;padding:10px;box-sizing:border-box;resize:vertical}
button{font:600 13.5px -apple-system,system-ui;border-radius:8px;border:0;padding:9px 14px;cursor:pointer;
 background:#233041;color:#e8edf2}
button.big{width:100%;background:#18A98A;color:#fff;padding:12px;margin:10px 0 6px}
.btns{display:flex;flex-direction:column}
.dl{color:#4aa3d8;font-size:12.5px;text-align:center}
.path{font:11px ui-monospace,monospace;color:#5c6b7a;word-break:break-all}
#drop{height:300px;border:2px dashed #33404e;border-radius:10px;display:flex;flex-direction:column;
 align-items:center;justify-content:center;color:#93a1af;cursor:pointer;text-align:center}
#drop.hot{border-color:#18A98A;color:#18A98A}
@media(max-width:980px){.grid{grid-template-columns:1fr}}
</style></head><body>__BODY__</body></html>"""


class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=str(G), **k)

    def do_GET(self):
        u = urllib.parse.urlparse(self.path)
        if u.path in ("/", "/index.html"):
            qs = urllib.parse.parse_qs(u.query)
            skip = int((qs.get("skip") or ["0"])[0])
            forced = (qs.get("task") or [None])[0]
            body = PAGE.replace("__BODY__", render(skip, forced)).encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            super().do_GET()

    def do_POST(self):
        u = urllib.parse.urlparse(self.path)
        if u.path != "/upload":
            self.send_error(404)
            return
        tid = (urllib.parse.parse_qs(u.query).get("id") or [""])[0]
        t = BY_ID.get(tid)
        n = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(n) if n else b""
        # sanity: a real image, not an empty drop or an html error page
        ok_magic = data[:4] in (b"\x89PNG", b"\xff\xd8\xff\xe0", b"\xff\xd8\xff\xe1",
                                b"RIFF") or data[:5] == b"<?xml" or data[:4] == b"\xff\xd8\xff\xdb"
        if not t or len(data) < 10_000 or not ok_magic:
            self.send_error(400, "not a plausible image upload")
            return
        # Guard against the copy-paste echo: the "Copy image" button puts the
        # SOURCE on the clipboard, so a stray ⌘V submits the source photo as if
        # it were Gemini's result. Same pixel dimensions as the source is the
        # tell (canvas re-encode changes bytes but never dimensions).
        try:
            from PIL import Image
            import io
            up = Image.open(io.BytesIO(data)).size
            srcsz = Image.open(G / t["source"]).size
            if up == srcsz:
                self.send_error(409, "that looks like the source photo itself "
                                     "(same dimensions) - paste Gemini's RESULT, "
                                     "not the copied source")
                return
        except ImportError:
            pass
        out = G / t["output"]
        out.parent.mkdir(exist_ok=True)
        if out.exists():   # redo of an already-submitted task: keep the old one
            arch = G / "output" / "replaced"
            arch.mkdir(exist_ok=True)
            out.rename(arch / f"{tid}-{int(out.stat().st_mtime)}{out.suffix}")
        out.write_bytes(data)
        mark_done(tid)
        self.send_response(200)
        self.send_header("Content-Length", "2")
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8125
    print(f"Handoff: http://127.0.0.1:{port}")
    ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
