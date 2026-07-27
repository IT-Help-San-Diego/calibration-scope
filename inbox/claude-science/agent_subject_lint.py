#!/usr/bin/env python3
"""
agent_subject_lint.py — enforce the agent-as-subject rule mechanically.

Rule (Claude Science / Hermes, 2026-07-27): every correction entry in an
epistemic log names an AGENT as its grammatical subject. "the harness was
wrong" must read "I wrote a harness that was wrong".

Rationale: this rule was adopted in prose. Every prose rule set on 2026-07-27
was violated by its own author within hours, including inside the memo that
stated it. A rule without a checker is a preference.

Usage:  python3 agent_subject_lint.py EPISTEMIC_LOG.jsonl [--strict]
Exit:   0 clean, 1 violations found, 2 usage error.
"""
import json, re, sys

CORRECTIVE = {"correct", "retract", "supersede", "quarantine", "flag_databug"}
# An agent subject: first person, or a named agent, in the FIRST clause.
AGENT = re.compile(
    r"^\W*("
    r"i\b|my\b|mine\b|myself\b|we\b|our\b|"
    r"claude[- ]science|claude[- ]code|hermes|carey|the auditor"
    r")", re.I)
# Artifact-shaped subjects: a filename, a code path, a section marker, a table
# column, a quoted claim — the constructions that file a defect under no one.
ARTIFACT = re.compile(
    r"^\W*("
    r"[\w./-]+\.(md|py|rs|json|jsonl|csv|sql|html|css|js|png|yaml|toml)\b|"
    r"(§|section\s+)\d|the\s+(grader|harness|bank|chart|log|item|run|report|table|figure|spec|site|copy|code|lint|tool|pipeline|executor|dashboard|migration)\b|"
    r"['\"\u201c]"
    r")", re.I)

def subject_span(text, n=90):
    """The opening of the target field — where the grammatical subject sits."""
    return (text or "").strip()[:n]

def check(entry):
    """Return (verdict, evidence). verdict in {ok, violation, unclear}."""
    if entry.get("action") not in CORRECTIVE:
        return "n/a", ""
    head = subject_span(entry.get("target", ""))
    if not head:
        return "violation", "(empty target)"
    if AGENT.match(head):
        return "ok", head
    if ARTIFACT.match(head):
        return "violation", head
    return "unclear", head

def main(argv):
    if len(argv) < 2:
        print(__doc__); return 2
    strict = "--strict" in argv
    rows = [json.loads(l) for l in open(argv[1]) if l.strip()]
    tally = {"ok": 0, "violation": 0, "unclear": 0, "n/a": 0}
    bad = []
    for i, e in enumerate(rows, 1):
        v, ev = check(e)
        tally[v] += 1
        if v == "violation" or (strict and v == "unclear"):
            bad.append((i, e.get("ts_utc", "?")[:10], v, ev))
    total_corr = tally["ok"] + tally["violation"] + tally["unclear"]
    print(f"corrective entries: {total_corr}  (of {len(rows)} total)")
    print(f"  agent-subject   : {tally['ok']}")
    print(f"  artifact-subject: {tally['violation']}   <- rule violations")
    print(f"  unclear         : {tally['unclear']}")
    if total_corr:
        print(f"  compliance      : {tally['ok']/total_corr:.0%}")
    for i, ts, v, ev in bad:
        print(f"  [{v:9s}] line {i:3d} {ts}  {ev}")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
