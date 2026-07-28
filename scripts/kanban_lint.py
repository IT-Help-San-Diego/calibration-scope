#!/usr/bin/env python3
"""
kanban_lint.py - enforce the Kanban contract. Exit non-zero on violation so CI fails.

The board is JSONL (one card per line), not a JSON array, so three agents appending
different cards never conflict. A JSON array always conflicts on the closing bracket.

The rules exist because each one corresponds to a failure this project actually had:
  R1 done-needs-verifier   : NEXT_STEPS said a run was needed that had already happened.
                             A card cannot claim done without a commit/run/file to check.
  R2 verifier-must-resolve : a verifier naming a path must name a path that EXISTS ON MAIN.
                             35.8h of analysis once sat on an unmerged branch while
                             check-ins reported the lane current.
  R3 blocked-needs-blocker : a card in `blocked` must name what blocks it, or it is
                             indistinguishable from abandoned.
  R4 no-dangling-deps      : blocked_on pointing at a card id must point at a real card.
  R5 unique-ids            : duplicate ids mean two agents silently overwrote each other.
  R6 lane-known            : an unknown lane means nobody owns the card.
"""
import json, sys, os, re

COLUMNS = {"backlog", "in_flight", "blocked", "done"}
LANES = {"hermes", "claude-code", "claude-science", "carey"}
VERIFIER_KINDS = {"commit", "run", "file", "deploy"}


def load(path):
    cards = []
    for n, line in enumerate(open(path), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        try:
            cards.append((n, json.loads(line)))
        except json.JSONDecodeError as e:
            print(f"[FAIL] line {n}: not valid JSON ({e})")
            sys.exit(2)
    return cards


def check(cards, repo_root="."):
    fails = []
    ids = {}
    for n, c in cards:
        cid = c.get("id", f"<line {n}>")
        if cid in ids:
            fails.append(f"R5 duplicate id {cid} (lines {ids[cid]} and {n})")
        ids[cid] = n
        if c.get("column") not in COLUMNS:
            fails.append(f"R6 {cid}: column {c.get('column')!r} not in {sorted(COLUMNS)}")
        if c.get("lane") not in LANES:
            fails.append(f"R6 {cid}: lane {c.get('lane')!r} not in {sorted(LANES)}")

        # R1: done requires a verifier with a kind, a ref and the check that was run
        if c.get("column") == "done":
            v = c.get("verifier")
            if not v:
                fails.append(f"R1 {cid}: in `done` with no verifier - a status is not proof")
            else:
                for k in ("kind", "ref", "check"):
                    if not v.get(k):
                        fails.append(f"R1 {cid}: verifier missing {k!r}")
                if v.get("kind") not in VERIFIER_KINDS:
                    fails.append(f"R1 {cid}: verifier kind {v.get('kind')!r} not in {sorted(VERIFIER_KINDS)}")
                # R2: a file verifier must resolve on disk (i.e. be on main when CI runs)
                if v.get("kind") == "file":
                    p = os.path.join(repo_root, v["ref"])
                    if not os.path.exists(p):
                        fails.append(f"R2 {cid}: verifier file {v['ref']} does not exist on main")
                if v.get("kind") in ("commit", "deploy") and not re.fullmatch(r"[0-9a-f]{7,40}", v["ref"]):
                    fails.append(f"R2 {cid}: verifier ref {v['ref']!r} is not a commit sha")

        # R3: blocked must say what blocks it
        if c.get("column") == "blocked" and not c.get("blocked_on"):
            fails.append(f"R3 {cid}: in `blocked` with no blocked_on - indistinguishable from abandoned")

    # R4: intra-board dependencies must resolve
    for n, c in cards:
        dep = c.get("blocked_on")
        if dep and not str(dep).startswith("carey:") and dep not in ids:
            fails.append(f"R4 {c.get('id')}: blocked_on {dep!r} is not a card id on this board")
    return fails


def selftest():
    """The linter must FAIL on each violation it claims to catch, or it is decoration."""
    import tempfile
    cases = [
        ("done, no verifier", {"id": "T1", "lane": "hermes", "column": "done"}, "R1"),
        ("blocked, no blocker", {"id": "T2", "lane": "hermes", "column": "blocked"}, "R3"),
        ("dangling dep", {"id": "T3", "lane": "hermes", "column": "blocked", "blocked_on": "NOPE"}, "R4"),
        ("bad lane", {"id": "T4", "lane": "nobody", "column": "backlog"}, "R6"),
        ("file verifier that does not exist",
         {"id": "T5", "lane": "hermes", "column": "done",
          "verifier": {"kind": "file", "ref": "does/not/exist.md", "check": "x"}}, "R2"),
        ("bad sha", {"id": "T6", "lane": "hermes", "column": "done",
                     "verifier": {"kind": "commit", "ref": "not-a-sha", "check": "x"}}, "R2"),
    ]
    ok = True
    for name, card, rule in cases:
        f = tempfile.NamedTemporaryFile("w", suffix=".jsonl", delete=False)
        f.write(json.dumps(card) + "\n"); f.close()
        fails = check(load(f.name))
        hit = any(x.startswith(rule) for x in fails)
        print(f"  [{'PASS' if hit else 'FAIL'}] selftest: {name} -> expected {rule}")
        ok = ok and hit
    # and a valid card must produce NO failure
    f = tempfile.NamedTemporaryFile("w", suffix=".jsonl", delete=False)
    f.write(json.dumps({"id": "T7", "lane": "hermes", "column": "backlog"}) + "\n"); f.close()
    clean = check(load(f.name))
    print(f"  [{'PASS' if not clean else 'FAIL'}] selftest: valid card -> no failures")
    return ok and not clean


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    # Default to the board's canonical location so `python3 scripts/kanban_lint.py`
    # from the repo root works without an argument.
    default = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "policy", "kanban.jsonl")
    path = sys.argv[1] if len(sys.argv) > 1 else default
    cards = load(path)
    fails = check(cards)
    from collections import Counter
    cols = Counter(c.get("column") for _, c in cards)
    print(f"{len(cards)} cards | " + " ".join(f"{k}={v}" for k, v in sorted(cols.items())))
    for x in fails:
        print("[FAIL]", x)
    print(f"\n{len(cards) - len(fails)}/{len(cards)} cards clean" if fails else f"\nALL {len(cards)} CARDS CLEAN")
    sys.exit(1 if fails else 0)
