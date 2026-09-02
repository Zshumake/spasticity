#!/usr/bin/env python3
"""Batch-run the illustration tasks against the Gemini API (image generation).

This is the API fast lane. The same work can be done by an Antigravity agent
natively (see ANTIGRAVITY-KICKOFF.md); this script exists so the whole batch
can also run unattended with nothing but a key:

    export GEMINI_API_KEY=...        # from Google AI Studio
    python3 tools/gemini-illustrations/generate.py            # first pass
    python3 tools/gemini-illustrations/generate.py --regen    # after review

Behaviour, matching README.md exactly:
  * first pass: every task whose output file does not exist and whose review
    status is "pending" is generated once, in tasks.json order
  * --regen: ONLY tasks the reviewer marked "regenerate" are run, with the
    reviewer's note appended to the prompt; on success the status flips back
    to "pending" for re-review
  * approved tasks are never touched
  * gem-system-instructions.md is sent as the system instruction every time
  * tasks.md checkboxes are kept in sync ([ ] -> [x] means "output exists",
    review approval is tracked separately by review.py)

Stdlib only - no SDK needed. One retry on transient failures, then the task
is skipped and reported so a later run can pick it up.
"""
import argparse
import base64
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

from task_queue import select_tasks

G = Path(__file__).resolve().parent
MODEL = os.environ.get("GEMINI_IMAGE_MODEL", "gemini-3-pro-image-preview")
URL = ("https://generativelanguage.googleapis.com/v1beta/models/"
       "{model}:generateContent?key={key}")

SYSTEM = (G / "gem-system-instructions.md").read_text()


def load(name):
    return json.load(open(G / name))


def call_gemini(key, src_bytes, prompt):
    body = {
        "system_instruction": {"parts": [{"text": SYSTEM}]},
        "contents": [{
            "role": "user",
            "parts": [
                {"inline_data": {"mime_type": "image/jpeg",
                                 "data": base64.b64encode(src_bytes).decode()}},
                {"text": prompt},
            ],
        }],
        "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]},
    }
    req = urllib.request.Request(
        URL.format(model=MODEL, key=key),
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=300) as r:
        resp = json.load(r)
    for part in resp["candidates"][0]["content"]["parts"]:
        if "inlineData" in part:
            return base64.b64decode(part["inlineData"]["data"])
    raise RuntimeError("response contained no image part")


def tick(task_id, done):
    md_path = G / "tasks.md"
    md = md_path.read_text()
    md = re.sub(rf"## \[.\] {re.escape(task_id)}  ",
                f"## [{'x' if done else ' '}] {task_id}  ", md)
    md_path.write_text(md)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--regen", action="store_true",
                    help="run ONLY reviewer-marked regenerations")
    ap.add_argument("--only", help="run a single task id")
    ap.add_argument("--limit", type=int, default=0, help="stop after N generations")
    ap.add_argument("--dry-run", action="store_true",
                    help="print the plan without calling the API")
    args = ap.parse_args()

    key = os.environ.get("GEMINI_API_KEY")
    if not key and not args.dry_run:
        sys.exit("GEMINI_API_KEY is not set (or use --dry-run). "
                 "For key-less generation use Antigravity: see ANTIGRAVITY-KICKOFF.md")

    tasks = load("tasks.json")
    status = load("review-status.json") if (G / "review-status.json").exists() else {}

    mode = "regeneration" if args.regen else "first-pass"
    selected = select_tasks(tasks, status, G, mode=mode, only=args.only)
    todo = [
        (t, status.get(t["id"], {"status": "pending", "note": "", "rounds": 0}))
        for t in selected
    ]

    print(f"{mode}: {len(todo)} task(s) to generate with {MODEL}")
    failed = []
    for i, (t, st) in enumerate(todo):
        if args.limit and i >= args.limit:
            print(f"--limit {args.limit} reached, stopping")
            break
        prompt = t["prompt"]
        if args.regen and st.get("note"):
            prompt += f"\nReviewer feedback on the previous attempt: {st['note']}"
        print(f"[{i+1}/{len(todo)}] {t['id']} <- {t['source_frame']}"
              + (" (+feedback)" if args.regen and st.get("note") else ""))
        if args.dry_run:
            continue
        src = (G / t["source"]).read_bytes()
        for attempt in (1, 2):
            try:
                png = call_gemini(key, src, prompt)
                (G / t["output"]).parent.mkdir(exist_ok=True)
                (G / t["output"]).write_bytes(png)
                tick(t["id"], True)
                if args.regen:
                    status[t["id"]]["status"] = "pending"
                    json.dump(status, open(G / "review-status.json", "w"),
                              indent=1, sort_keys=True)
                print(f"    -> {t['output']} ({len(png)//1024} KB)")
                break
            except (urllib.error.URLError, urllib.error.HTTPError,
                    KeyError, RuntimeError, TimeoutError) as e:
                detail = getattr(e, "code", "") or type(e).__name__
                print(f"    attempt {attempt} failed: {detail} {e}")
                if attempt == 2:
                    failed.append(t["id"])
                else:
                    time.sleep(15)
        time.sleep(4)   # stay friendly to per-minute rate limits

    if failed:
        print(f"\nFAILED (re-run to retry): {', '.join(failed)}")
        sys.exit(1)
    print("\ndone - review the results with:  python3 review.py")


if __name__ == "__main__":
    main()
