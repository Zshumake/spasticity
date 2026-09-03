#!/usr/bin/env python3
"""Apply the adjudicated clinical corrections to assets/data/muscles.json.

These corrections came back from the reflexpmr.com import as an overlay: 78
adjudicated fixes, each carrying the exact upstream string it replaces and the
citation that justifies it. Applying them HERE, upstream, is what lets the
overlay be retired — while it stands, both trees have to agree or their build
breaks (see "coordination" below).

    python3 tools/apply_corrections.py            # apply, then verify
    python3 tools/apply_corrections.py --check    # verify only; safe in CI

TWO GATES, both inherited from the overlay because both caught real misses:

1. `find` MUST match the current text. If it does not, this FAILS rather than
   skipping. Every defect this audit found was silent, and a correction that
   quietly matches nothing is another silent failure.

2. `forbid` phrases must not survive ANYWHERE in that muscle's record after
   the edit. Correcting one field is not correcting the claim: the first
   overlay pass fixed the subclavian-artery inversion in ultrasound.safetyNotes
   and left the identical claim standing in placement, so the page contradicted
   itself. Pronator teres carried the wrong probe side in three separate fields.

COORDINATION. Once these land here, the overlay's `find` strings no longer
match upstream and reflexpmr's build fails BY DESIGN — that is gate 1 doing its
job. The overlay entries have to be retired on their side in the same release.
Do not "fix" that by loosening their gate.

--check is the durable form: it asserts the corrected wording is present and no
forbidden phrase came back, which is what a later upstream edit could undo.

ROUNDS. The corrections file now holds several batches (see its $comment). An
entry marked `superseded` had its own replacement rewritten by a later round:
it is skipped by `apply` and by the presence check, but its `forbid` phrases
are still enforced. `apply` is idempotent: an entry is done when its replacement is present and
its find is gone (or survives only inside that replacement), and a deletion is
done when the text is gone and the entry carries `forbid` phrases (gate 2 then
proves the claim is absent) - so the whole file can be re-applied safely.
"""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MUSCLES = ROOT / "assets" / "data" / "muscles.json"
CORRECTIONS = ROOT / "docs" / "adjudicated-corrections.json"


def resolve(rec, path):
    """Walk a dotted field path, returning (container, key) or (None, None)."""
    parts = path.split(".")
    cur = rec
    for k in parts[:-1]:
        if not isinstance(cur, dict) or k not in cur:
            return None, None
        cur = cur[k]
    if not isinstance(cur, dict):
        return None, None
    return cur, parts[-1]


def all_strings(node):
    """Every string anywhere in a record — what the forbid gate scans."""
    if isinstance(node, str):
        yield node
    elif isinstance(node, dict):
        for v in node.values():
            yield from all_strings(v)
    elif isinstance(node, list):
        for v in node:
            yield from all_strings(v)


def apply_replace(rec, corr, errors):
    box, key = resolve(rec, corr["field"])
    if box is None or key not in box:
        errors.append(f"{corr['muscle']}/{corr['field']}: field absent")
        return False
    val = box[key]
    find, repl = corr["find"], corr.get("replace")

    # Idempotency. An entry is DONE when its replacement is present and its
    # find is gone - or when the find survives only as a substring of the
    # applied replacement. A deletion is done when the text is gone and the
    # entry carries forbid phrases (gate 2 then proves the claim is absent).
    def done_str(s):
        return repl is not None and repl in s and (find not in s or find in repl)

    if isinstance(val, str):
        if done_str(val):
            return True
        if find not in val:
            if repl is None and corr.get("forbid"):
                return True
            errors.append(f"{corr['muscle']}/{corr['field']}: find did not match")
            return False
        if repl is None:
            del box[key]
        else:
            box[key] = val.replace(find, repl)
        return True

    if isinstance(val, list):
        if any(isinstance(s, str) and done_str(s) for s in val):
            return True
        hits = [i for i, s in enumerate(val) if isinstance(s, str) and find in s]
        if not hits:
            if repl is None and corr.get("forbid"):
                return True
            errors.append(f"{corr['muscle']}/{corr['field']}: find did not match")
            return False
        for i in reversed(hits):
            if repl is None:
                # Drop the whole entry only when the correction IS the entry;
                # otherwise excise the sentence and keep the rest.
                rest = val[i].replace(find, "").strip()
                if rest:
                    val[i] = rest
                else:
                    del val[i]
            else:
                val[i] = val[i].replace(find, repl)
        return True

    errors.append(f"{corr['muscle']}/{corr['field']}: unsupported type {type(val).__name__}")
    return False


def apply_add(rec, corr, errors):
    box, key = resolve(rec, corr["field"])
    if box is None:
        errors.append(f"{corr['muscle']}/{corr['field']}: parent object absent")
        return False
    text = corr["text"]
    cur = box.get(key)
    if cur is None:
        box[key] = [text]
    elif isinstance(cur, list):
        if text not in cur:
            cur.append(text)
    elif isinstance(cur, str):
        if text not in cur:
            box[key] = [cur, text]
    else:
        errors.append(f"{corr['muscle']}/{corr['field']}: cannot add to {type(cur).__name__}")
        return False
    return True


def check_forbidden(muscles, corrections):
    """Gate 2: no forbidden phrase may survive anywhere in the muscle."""
    by = {m["id"]: m for m in muscles}
    bad = []
    for corr in corrections:
        for phrase in corr.get("forbid") or []:
            rec = by.get(corr["muscle"])
            if rec is None:
                continue
            for s in all_strings(rec):
                if phrase.lower() in s.lower():
                    bad.append((corr["muscle"], phrase, s[:90]))
                    break
    return bad


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--check", action="store_true",
                    help="verify the applied state; make no edits")
    ap.add_argument("--corrections", default=str(CORRECTIONS))
    args = ap.parse_args()

    doc = json.loads(Path(args.corrections).read_text())
    corrections = doc["corrections"]
    muscles = json.loads(MUSCLES.read_text())
    by = {m["id"]: m for m in muscles}

    unknown = sorted({c["muscle"] for c in corrections} - set(by))
    if unknown:
        print(f"corrections name muscles that do not exist: {unknown}", file=sys.stderr)
        return 1

    if args.check:
        missing = []
        for c in corrections:
            rec = by[c["muscle"]]
            want = c["text"] if c.get("op") == "add" else c.get("replace")
            if want is None or c.get("superseded"):
                continue
            if not any(want in s for s in all_strings(rec)):
                missing.append(f"{c['muscle']}/{c['field']}")
        bad = check_forbidden(muscles, corrections)
        for m in missing:
            print(f"  MISSING corrected text: {m}")
        for muscle, phrase, ctx in bad:
            print(f"  FORBIDDEN phrase survives in {muscle}: {phrase!r}\n      in: {ctx}...")
        if missing or bad:
            print(f"\nFAIL: {len(missing)} missing, {len(bad)} forbidden phrases present")
            return 1
        print(f"OK: all {len(corrections)} corrections present, no forbidden phrase survives")
        return 0

    errors, applied = [], 0
    for c in corrections:
        if c.get("superseded"):
            continue
        rec = by[c["muscle"]]
        ok = apply_add(rec, c, errors) if c.get("op") == "add" else apply_replace(rec, c, errors)
        applied += 1 if ok else 0

    if errors:
        print("REFUSING TO WRITE — corrections did not match:", file=sys.stderr)
        for e in errors:
            print("  " + e, file=sys.stderr)
        return 1

    bad = check_forbidden(muscles, corrections)
    if bad:
        print("REFUSING TO WRITE — a corrected claim survives elsewhere in the record:",
              file=sys.stderr)
        for muscle, phrase, ctx in bad:
            print(f"  {muscle}: {phrase!r}\n      still in: {ctx}...", file=sys.stderr)
        return 1

    MUSCLES.write_text(json.dumps(muscles, indent=2, ensure_ascii=False) + "\n")
    tiers = {}
    for c in corrections:
        tiers[c.get("tier")] = tiers.get(c.get("tier"), 0) + 1
    print(f"applied {applied}/{len(corrections)} corrections to {MUSCLES.relative_to(ROOT)}")
    print("  by tier: " + ", ".join(f"tier {k}: {v}" for k, v in sorted(tiers.items())))
    print("  forbid gate: clean")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
