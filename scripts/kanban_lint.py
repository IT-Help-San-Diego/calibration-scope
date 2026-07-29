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


def cas_write_contract():
    """The contract every lane must follow when writing policy/kanban.jsonl.

    THE FAILURE THIS COMES FROM. Three lanes do read-modify-write on one JSONL file.
    In a single session the board went 22 -> 49 cards across interleaved edits, one lane
    rebuilt its edit on top of another FOUR times, a card was moved to `done` with no
    verifier between one lane's read and its write, and a card id was taken while an
    insert was guarded on it.

    THE CAUSE WAS PARTLY TOOLING, NOT THE FORMAT. A push helper that re-fetches the
    file's head sha immediately before writing makes every write succeed — which
    DEFEATS GitHub's optimistic concurrency and silently discards the other lane's edit
    to any card both had touched. Last-writer-wins by construction.

    THE CONTRACT:
      1. read the file AND keep the `sha` you read it from;
      2. write with THAT sha, never a freshly-fetched one;
      3. on HTTP 409 -> RE-READ, RE-APPLY your change, re-lint, write again.
         Never retry with a new sha: that is the bug, not the fix.

    PROVEN, not assumed: with base sha f7a886c9 and head advanced to c8da77ff by a real
    byte change, the stale-sha write was rejected 409. NOTE the invalid first attempt —
    byte-identical content is accepted WITHOUT creating a commit, so the sha never moves
    and a "stale" write still succeeds. A CAS test must change bytes to be a test at all.

    WHY NOT PER-LANE FILES: three files is three sources of truth, and this project has
    already been bitten by that — two simultaneous check-in files on two branches while
    check-ins reported the lane current. Conflict DETECTION on one file beats partition.
    """
    return {"read_sha_and_keep_it": True, "write_with_read_sha": True,
            "on_409": "re-read, re-apply, re-lint, rewrite", "never": "retry with a fresh sha"}


def count_records(path, pattern):
    """Count RECORDS matching a pattern, not regex occurrences.

    Written after I reported "two earlier entries contain X" from a sweep that
    printed "2 occurrence(s)". The pattern appeared in two lines, but ONE of
    them contained both matches and the other was the retraction quoting it —
    so the true count of offending records was one, not two.

    A match tally over a concatenated file silently overcounts whenever a single
    record contains the pattern twice, and silently miscounts whenever a record
    quotes the pattern in order to retract it. Neither failure is visible in the
    number.

    Returns (n_records, [(line_no, n_occurrences), ...]) so the caller can see
    the distribution rather than a single figure.
    """
    rx = re.compile(pattern)
    rows = []
    for i, line in enumerate(open(path)):
        if not line.strip():
            continue
        n = len(rx.findall(line))
        if n:
            rows.append((i, n))
    return len(rows), rows


def assert_added(path, expected_ids, prior_count=None):
    """Assert an intended insert actually landed. Call BEFORE pushing, never after.

    Three times in one session a guarded insert or a string replace silently did
    nothing while the surrounding narration claimed it had worked: two memo edits
    that failed on a line break, and a card insert guarded on an id that was
    already taken. In every case the cell reported success from a proxy — a
    whole-file inequality, or no check at all — instead of from the result.

    A conditional that does not fire is indistinguishable from one that fired,
    unless you assert the postcondition.
    """
    rows = [json.loads(l) for l in open(path) if l.strip()]
    ids = {r.get("id") for r in rows}
    missing = [i for i in expected_ids if i not in ids]
    if missing:
        raise AssertionError(f"insert did not land: {missing} absent from {path}")
    if prior_count is not None and len(rows) != prior_count + len(expected_ids):
        raise AssertionError(
            f"count mismatch: expected {prior_count + len(expected_ids)}, got {len(rows)}")
    return len(rows)


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

        # R7: a verifier must be SUBSTANTIVE, not merely well-formed.
        # CS-016 was closed with verifier ref 971dfc9 — a real sha, for an unrelated
        # commit (oracle coverage). R1 and R2 both passed: a sha was present and it
        # resolved. Neither rule asks whether the ref has anything to do with the card.
        # A `check` string that only restates the title, or is shorter than a sentence,
        # is the signature of a card closed on a status rather than on evidence.
        if c.get("column") == "done" and c.get("verifier"):
            chk = (c["verifier"].get("check") or "").strip()
            if len(chk) < 40:
                fails.append(f"R7 {cid}: verifier check is {len(chk)} chars - too short to describe what was checked")
            title_words = set(re.findall(r"[a-z]{4,}", (c.get("title") or "").lower()))
            chk_words = set(re.findall(r"[a-z]{4,}", chk.lower()))
            if title_words and chk_words and chk_words.issubset(title_words):
                fails.append(f"R7 {cid}: verifier check only restates the title - describes no actual check")

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
        # R7 cases: a verifier can be well-formed and still describe no check.
        ("check too short to say anything",
         {"id": "T8", "lane": "hermes", "column": "done", "title": "Do the thing",
          "verifier": {"kind": "commit", "ref": "abc1234", "check": "done"}}, "R7"),
        ("check only restates the title",
         {"id": "T9", "lane": "hermes", "column": "done",
          "title": "Sealed provenance record hash chained local file",
          "verifier": {"kind": "commit", "ref": "abc1234",
                       "check": "sealed provenance record hash chained local file"}}, "R7"),
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
    f.write(json.dumps({"id": "T7", "lane": "hermes", "column": "backlog"}) + "\n")
    f.write(json.dumps({"id": "T10", "lane": "hermes", "column": "done", "title": "Fix the widget",
                        "verifier": {"kind": "commit", "ref": "abc1234",
                                     "check": "read migration 059 on main and confirmed the infra filter is present and var_pop appears only in a comment"}}) + "\n")
    f.close()
    clean = check(load(f.name))
    print(f"  [{'PASS' if not clean else 'FAIL'}] selftest: valid card -> no failures")
    return ok and not clean


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(0 if selftest() else 1)
    # Default to the real board path relative to the repo root, so
    # `python3 scripts/kanban_lint.py` from the root Just Works. Falls back to a
    # bare kanban.jsonl for the case where the board sits beside the script.
    if len(sys.argv) > 1 and not sys.argv[1].startswith("--"):
        path = sys.argv[1]
    else:
        here = os.path.dirname(os.path.abspath(__file__))
        for cand in (os.path.join(here, "..", "policy", "kanban.jsonl"),
                     "policy/kanban.jsonl", "kanban.jsonl"):
            if os.path.exists(cand):
                path = cand
                break
        else:
            print("[FAIL] no board found (looked for policy/kanban.jsonl and kanban.jsonl)")
            sys.exit(2)
    cards = load(path)
    fails = check(cards)
    from collections import Counter
    cols = Counter(c.get("column") for _, c in cards)
    print(f"{len(cards)} cards | " + " ".join(f"{k}={v}" for k, v in sorted(cols.items())))
    for x in fails:
        print("[FAIL]", x)
    print(f"\n{len(cards) - len(fails)}/{len(cards)} cards clean" if fails else f"\nALL {len(cards)} CARDS CLEAN")
    sys.exit(1 if fails else 0)
