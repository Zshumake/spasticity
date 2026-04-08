#!/usr/bin/env python3
"""Interactive tool to paste YouTube URLs for muscles that don't have one.

Usage:
    python3 tools/add_video_urls.py

For each muscle without a videoUrl, shows:
  - muscle id + name + group
  - a helpful YouTube search URL you can click to find candidates
  - a prompt to paste the chosen URL (or skip / quit)

Accepted inputs at each prompt:
  <paste a youtube URL>   — validates it parses a video ID, assigns, saves
  s or [enter]            — skip this muscle, move to next
  b                       — go back to the previous muscle
  q                       — save and quit
  l                       — list remaining muscles
  ?                       — show help

The file is saved after every successful assignment, so it's safe to
ctrl-C mid-session. Re-run the script to pick up where you left off.
"""
from __future__ import annotations

import json
import sys
import urllib.parse
import webbrowser
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"


def extract_video_id(url: str) -> Optional[str]:
    """Return the YouTube video ID from any common URL form, or None."""
    url = url.strip()
    if not url:
        return None
    # Bare ID (11 chars, alphanum + - _)
    if len(url) == 11 and all(c.isalnum() or c in "-_" for c in url):
        return url
    try:
        u = urllib.parse.urlparse(url)
    except Exception:
        return None
    if "youtube" not in u.netloc and "youtu.be" not in u.netloc:
        return None
    # youtube.com/watch?v=ID
    qs = urllib.parse.parse_qs(u.query)
    if "v" in qs and qs["v"]:
        return qs["v"][0]
    # youtu.be/ID
    if u.netloc == "youtu.be" and u.path:
        return u.path.lstrip("/").split("/")[0]
    # youtube.com/embed/ID or /shorts/ID
    parts = [p for p in u.path.split("/") if p]
    if parts and parts[0] in ("embed", "shorts", "v"):
        if len(parts) > 1:
            return parts[1]
    return None


def canonical_url(video_id: str) -> str:
    return f"https://www.youtube.com/watch?v={video_id}"


def search_url(muscle_name: str) -> str:
    q = urllib.parse.quote(
        f"{muscle_name} botulinum toxin injection ultrasound guided spasticity"
    )
    return f"https://www.youtube.com/results?search_query={q}"


def save(data):
    MUSCLES.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def print_help():
    print(
        "\nCommands:"
        "\n  <paste URL>  assign and move to next"
        "\n  s  or enter  skip this muscle"
        "\n  b            go back to previous muscle"
        "\n  o            open the YouTube search page in your browser"
        "\n  l            list remaining unvideoed muscles"
        "\n  q            save and quit"
        "\n  ?            show this help\n"
    )


def main():
    data = json.loads(MUSCLES.read_text())
    pending = [m for m in data if not m.get("videoUrl")]
    if not pending:
        print("All 47 muscles already have a videoUrl. Nothing to do.")
        return 0

    print(f"{len(pending)} muscles need a videoUrl.")
    print("Type '?' at any prompt for help.\n")

    i = 0
    assigned = 0
    while i < len(pending):
        m = pending[i]
        search = search_url(m["name"])
        print(f"\n[{i + 1}/{len(pending)}] {m['id']}")
        print(f"  name:  {m['name']}")
        print(f"  group: {m['group']}")
        print(f"  pattern: {m.get('pattern', '')[:80]}")
        print(f"  search: {search}")

        try:
            raw = input(f"  paste URL for {m['id']}  (enter=skip, b=back, o=open search, q=quit, ?=help): ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\nInterrupted. Saving and quitting.")
            save(data)
            break

        if raw == "" or raw.lower() == "s":
            i += 1
            continue
        if raw.lower() == "q":
            save(data)
            print("Saved. Quitting.")
            break
        if raw.lower() == "b":
            i = max(0, i - 1)
            continue
        if raw.lower() == "o":
            webbrowser.open(search)
            continue
        if raw.lower() == "l":
            print("\nRemaining:")
            for j, mm in enumerate(pending[i:], start=i + 1):
                print(f"  {j:2d}. {mm['id']:30s} {mm['name']}")
            continue
        if raw == "?":
            print_help()
            continue

        vid = extract_video_id(raw)
        if not vid:
            print(f"  ✗ Couldn't parse a YouTube video ID from: {raw!r}")
            print("    Try pasting a full youtube.com/watch?v=... URL, a youtu.be/... URL, or the bare 11-char ID.")
            continue

        # Write back into the real data structure (pending is a list of refs)
        m["videoUrl"] = canonical_url(vid)
        save(data)
        assigned += 1
        print(f"  ✓ Saved: {m['id']} → {canonical_url(vid)}")
        i += 1

    print(f"\nDone. Assigned {assigned} video URLs.")
    remaining = sum(1 for mm in data if not mm.get("videoUrl"))
    print(f"{remaining} muscles still without a video.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
