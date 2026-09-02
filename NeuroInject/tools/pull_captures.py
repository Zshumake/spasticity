#!/usr/bin/env python3
"""Pull drawn lassos out of the running app and stage them for the bake.

The captures live in the browser's localStorage (shared_preferences on web).
Rather than making the author find a downloaded JSON, this reconciles whatever
the app currently holds against the committed source of truth:

    docs/highlight-captures.json   <- newest lasso per (muscle, scan)

and writes a COCO file containing ONLY the outlines that changed, so the bake
touches nothing it doesn't have to.

    # 1. in the app's browser console (or via a browser tool):
    #    fetch('http://127.0.0.1:8126/', {method:'POST',
    #      body: localStorage.getItem('flutter.highlight_captures_v1')})
    python3 tools/pull_captures.py --serve            # receives one POST
    python3 tools/pull_captures.py --from raw.json    # or read a saved dump

Then bake what changed:

    python3 tools/refine_highlights.py --coco docs/pending-captures.coco.json

DEDUPE KEY IS (muscleId, imageRef), NOT muscleId. A muscle scanned from two
windows — tibialis posterior anterior vs medial — has one lasso per window and
both must survive; keying on muscleId alone would silently drop one.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TRUTH = ROOT / "docs" / "highlight-captures.json"
PENDING = ROOT / "docs" / "pending-captures.coco.json"


def key(c):
    return (c["muscleId"], c["imageRef"])


def receive(port=8126):
    """Accept one POSTed localStorage blob and return its text."""
    import http.server

    box = {}

    class H(http.server.BaseHTTPRequestHandler):
        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            box["body"] = self.rfile.read(n).decode()
            self.send_response(200)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(b"ok")
            raise KeyboardInterrupt

        def log_message(self, *a):
            pass

    print(f"listening on http://127.0.0.1:{port}/ for one POST ...")
    try:
        http.server.HTTPServer(("127.0.0.1", port), H).serve_forever()
    except KeyboardInterrupt:
        pass
    return box.get("body")


def parse(raw):
    """shared_preferences stores the list JSON-encoded inside a JSON string."""
    val = json.loads(raw)
    if isinstance(val, str):
        val = json.loads(val)
    return val


def newest_per_view(captures):
    latest = {}
    for c in sorted(captures, key=lambda c: c["createdAt"]):
        latest[key(c)] = c
    return latest


def to_coco(captures):
    cats, imgs, anns, img_ids = [], [], [], {}
    for i, c in enumerate(captures, 1):
        cats.append({"id": i, "name": c["muscleId"]})
        k = (c["imageRef"], c["canvasW"], c["canvasH"])
        if k not in img_ids:
            img_ids[k] = len(img_ids) + 1
            imgs.append({"id": img_ids[k], "file_name": c["imageRef"],
                         "width": c["canvasW"], "height": c["canvasH"]})
        anns.append({"id": i, "image_id": img_ids[k], "category_id": i,
                     "segmentation": [[x for p in c["polygon"] for x in p]]})
    return {"categories": cats, "images": imgs, "annotations": anns}


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument("--serve", action="store_true",
                     help="listen on :8126 for one POSTed localStorage blob")
    src.add_argument("--from", dest="path", help="read a saved dump instead")
    ap.add_argument("--port", type=int, default=8126)
    args = ap.parse_args()

    raw = receive(args.port) if args.serve else Path(args.path).read_text()
    if not raw:
        print("no data received")
        return 1

    latest = newest_per_view(parse(raw))
    old = {key(c): c for c in json.loads(TRUTH.read_text())} if TRUTH.exists() else {}

    changed = [c for k, c in latest.items()
               if k not in old or old[k]["id"] != c["id"]]
    # Anything the app no longer holds is KEPT: the committed file is the
    # record, and a cleared browser profile must not delete drawn work.
    absent = [k for k in old if k not in latest]

    merged_map = dict(old)
    merged_map.update(latest)
    merged = sorted(merged_map.values(),
                    key=lambda c: (c["muscleId"], c["imageRef"]))
    TRUTH.write_text(json.dumps(merged, indent=1))
    PENDING.write_text(json.dumps(to_coco(changed)))

    print(f"{len(merged)} outlines held ({len(latest)} came from the app)")
    for c in sorted(changed, key=lambda c: c["muscleId"]):
        print(f"  changed  {c['muscleId']:<26} <- {Path(c['imageRef']).name}")
    for m, ref in sorted(absent):
        print(f"  kept     {m:<26} <- {Path(ref).name} (not in app storage)")
    if not changed:
        print("  nothing new to bake")
        return 0
    print(f"\nbake them:\n  python3 tools/refine_highlights.py --coco {PENDING.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
