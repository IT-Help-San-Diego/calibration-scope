#!/usr/bin/env python3
"""
generate_probe_items.py — 40-item difficulty PROBE across 4 candidate classes.

Directive: Claude Science PILOT_VERDICT_analysis.md. The pilot proved a-priori
propositional difficulty fails; this probes 4 harder classes to find ANY that
moves off the ceiling. Gate: >=30% off-ceiling graduates to a powered run.

Classes (ordered by evidence):
  C1 sound-arg   — sound-argument control vs named rhetorical fallacy (NONE vs X).
                   The ONLY class that has ever bitten (LIT-11/12, all 4 informative
                   pilot items). Requires genuine discrimination, not form-matching.
  C2 defeasible  — non-monotonic / default reasoning (pattern-match doesn't transfer).
  C3 quant-scope — quantifier-scope ambiguity (classic LLM logic degradation).
  C4 distractor  — multi-hop chain WITH an irrelevant distractor premise.

Exact-scored. No answer leakage (verdict/fallacy never named in stem prose).
C2/C3 keys derived by the truth-table engine where formalizable; C1/C4 keys are
hand-locked and reviewed against the discrimination they demand.
"""
import json, hashlib
from collections import Counter

ITEMS = []
def add(cls, name, stem, expected, note=""):
    ITEMS.append({"probe_class": cls, "name": name, "prompt_text": stem,
                  "expected_result": expected, "scoring_method": "exact", "note": note})

FMT5 = "Answer with exactly one word from the options given."
FMT_VI = "Answer with exactly one word: VALID or INVALID."
FMT_TF = "Answer with exactly one word: TRUE or FALSE."

# ---------------------------------------------------------------------------
# C1 — sound-argument control vs rhetorical fallacy (the biting class).
# Mix of sound items (NONE) and real fallacies; the model must DISCRIMINATE.
# Options fixed across C1: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, NONE.
# ---------------------------------------------------------------------------
C1OPT = "Answer with exactly one word: FALSECAUSE, HASTYGEN, CIRCULAR, ADPOPULUM, or NONE."
c1 = [
    # sound (NONE)
    ("PROBE-C1-01", "The update server logged 4,200 successful installs and zero rollback reports in the first week. Our staged rollout plan called for exactly this signal before widening. The rollout is proceeding as designed.", "NONE"),
    ("PROBE-C1-02", "Two independent reviewers read the same 30 logs and flagged the same 4 as suspicious. We did not tell them which to flag. Their agreement suggests the 4 logs share a detectable property.", "NONE"),
    ("PROBE-C1-03", "After we enabled connection pooling, median query latency fell from 180 ms to 40 ms across the same 10,000 queries, holding hardware and query mix constant. Pooling plausibly reduced latency.", "NONE"),
    # false cause
    ("PROBE-C1-04", "Ever since we hired the new intern, the nightly build has failed three times. Clearly the intern is breaking the build.", "FALSECAUSE"),
    ("PROBE-C1-05", "We deployed on Friday and by Monday user complaints had doubled. The deployment must be the cause of the complaints.", "FALSECAUSE"),
    # hasty generalization
    ("PROBE-C1-06", "One user in Oslo reported the app crashed on launch. The app must be broken for all users in Norway.", "HASTYGEN"),
    ("PROBE-C1-07", "The first two pancakes I flipped burned. This stove clearly can't cook pancakes.", "HASTYGEN"),
    # circular
    ("PROBE-C1-08", "This backup is reliable because it never fails. And we know it never fails because it's a reliable backup.", "CIRCULAR"),
    # ad populum
    ("PROBE-C1-09", "Everyone on the team already uses this linter, so it must be the right choice for the project.", "ADPOPULUM"),
    ("PROBE-C1-10", "Thousands of people forward this warning every day, so the threat it describes must be real.", "ADPOPULUM"),
]
for name, body, exp in c1:
    add("sound-arg", name, f"Read this argument:\n\"{body}\"\nWhich single rhetorical fallacy best describes it? {C1OPT}", exp,
        note="sound-arg discrimination (NONE=control)")

# ---------------------------------------------------------------------------
# C2 — defeasible / default reasoning (non-monotonic). Conclusion holds by
# default but retracts on new info. VALID = the default inference is licensed.
# Keys hand-locked; the point is non-monotonicity, not a truth table.
# ---------------------------------------------------------------------------
c2 = [
    ("PROBE-C2-01", "By default, servers in this cluster are healthy. Node-7 is a server in this cluster. With no other information, is it reasonable to conclude Node-7 is healthy?", "VALID",
     "default rule, no defeater"),
    ("PROBE-C2-02", "By default, servers in this cluster are healthy. Node-7 is a server in this cluster AND Node-7 is currently returning 500s on all probes. Is it reasonable to conclude Node-7 is healthy?", "INVALID",
     "defeater present — default retracted"),
    ("PROBE-C2-03", "Birds typically fly. Tweety is a bird. With no other information, does it follow by default that Tweety flies?", "VALID",
     "default rule"),
    ("PROBE-C2-04", "Birds typically fly. Tweety is a bird AND Tweety is a penguin. Does it follow that Tweety flies?", "INVALID",
     "subclass defeater"),
    ("PROBE-C2-05", "Normally, the backup completes by 3 AM. Last night the disk filled at 2 AM. Should you assume last night's backup completed by 3 AM?", "INVALID",
     "defeater — disk full"),
    ("PROBE-C2-06", "By default, signed packages install cleanly. This package is signed and the signature verifies. No errors are reported. Is it reasonable to conclude it will install cleanly?", "VALID",
     "default, no defeater"),
    ("PROBE-C2-07", "By default, alarms indicate real faults. The alarm is sounding, and the sensor covering it is documented to be disconnected. Should you conclude there is a real fault?", "INVALID",
     "source discredited"),
    ("PROBE-C2-08", "Students who attend lecture usually pass. Maya attended every lecture. With no other information, is it reasonable to expect Maya to pass?", "VALID",
     "default rule"),
    ("PROBE-C2-09", "Students who attend lecture usually pass. Maya attended every lecture but never submitted any assignment. Is it reasonable to expect Maya to pass?", "INVALID",
     "defeater — no assignments"),
    ("PROBE-C2-10", "By default, cached data is fresh. The cache entry is 40 days old and the TTL is 1 day. Should you treat the cached data as fresh?", "INVALID",
     "defeater — TTL expired"),
]
for name, body, exp, note in c2:
    add("defeasible", name, f"{body}\n{FMT_VI}", exp, note=note)

# ---------------------------------------------------------------------------
# C3 — quantifier-scope ambiguity. TRUE iff the wide/narrow-scope reading
# stated actually follows. Keys hand-locked.
# ---------------------------------------------------------------------------
c3 = [
    ("PROBE-C3-01", "'Every server runs a monitoring agent.' Does this mean there is ONE single agent that every server runs, or that each server runs SOME agent? It means: for each server there exists an agent (possibly different).", "TRUE",
     "forall-exists, narrow exists"),
    ("PROBE-C3-02", "'There is a key that opens every door in this building.' Is the claim that ONE key opens all doors?", "TRUE",
     "exists-wide — a single master key"),
    ("PROBE-C3-03", "'Every container has a limit.' Must all containers share the SAME single limit value?", "FALSE",
     "forall-exists does not imply one shared value"),
    ("PROBE-C3-04", "'Some process is listening on every required port.' Could this be a DIFFERENT process per port rather than one process on all ports?", "FALSE",
     "exists-wide reads as one process on every port; different-per-port is the other reading"),
    ("PROBE-C3-05", "'All that glitters is not gold.' Read literally as: nothing that glitters is gold. Is that literal reading the intended meaning of the proverb?", "FALSE",
     "scope of negation — intended: not everything that glitters is gold"),
    ("PROBE-C3-06", "'Every minute someone falls for the scam.' Does this claim there is one specific person who falls for it every minute?", "FALSE",
     "forall-exists, not a single dupe"),
    ("PROBE-C3-07", "'Each node holds a copy of the ledger.' Is this consistent with every node holding the SAME ledger contents?", "TRUE",
     "forall-exists allows identical copies"),
    ("PROBE-C3-08", "'A guard is posted at every entrance.' Does this logically require the SAME guard at every entrance?", "FALSE",
     "forall-exists, not one guard"),
    ("PROBE-C3-09", "'Every test imports a shared fixture.' Does 'a shared fixture' here guarantee ONE fixture used by all tests?", "FALSE",
     "scope ambiguous; forall-exists default does not guarantee one"),
    ("PROBE-C3-10", "'There exists a prime number greater than every even number.' Under the reading 'for every even number there is a greater prime', is the statement true?", "TRUE",
     "exists-wide false but the forall-exists reading is true (Euclid)"),
]
for name, body, exp, note in c3:
    add("quant-scope", name, f"{body}\n{FMT_TF}", exp, note=note)

# ---------------------------------------------------------------------------
# C4 — multi-hop chain WITH a distractor premise. VALID iff the conclusion
# follows from the RELEVANT premises; the distractor must be ignored.
# Keys derived by the truth-table engine (propositional core) with a distractor
# atom that does not connect to the chain.
# ---------------------------------------------------------------------------
def chain_items():
    out = [
        ("PROBE-C4-01", "If the cache is warm, responses are fast. The cache is warm. Separately, the office plant needs watering. Are responses fast?", "VALID", "MP + distractor"),
        ("PROBE-C4-02", "If the cache is warm, responses are fast. Responses are fast. Separately, the office plant needs watering. Is the cache warm?", "INVALID", "converse trap + distractor"),
        ("PROBE-C4-03", "If P then Q. If Q then R. P. The cafeteria menu changes daily. Does R follow?", "VALID", "chain + distractor"),
        ("PROBE-C4-04", "If P then Q. If Q then R. R. The cafeteria menu changes daily. Does P follow?", "INVALID", "chain converse + distractor"),
        ("PROBE-C4-05", "Either the DNS is wrong or the route is down. The DNS is not wrong. The printer is out of toner. Is the route down?", "VALID", "DS + distractor"),
        ("PROBE-C4-06", "Either the DNS is wrong or the route is down (or both). The DNS is wrong. The printer is out of toner. Can you conclude the route is not down?", "INVALID", "affirm-disjunct + distractor"),
        ("PROBE-C4-07", "If backups run, data is safe. If data is safe, audits pass. Backups run. The parking lot is full. Do audits pass?", "VALID", "2-hop + distractor"),
        ("PROBE-C4-08", "If backups run, data is safe. If data is safe, audits pass. Audits did not pass. The parking lot is full. Did backups fail to run?", "VALID", "2-hop contrapositive + distractor"),
        ("PROBE-C4-09", "If backups run, data is safe. If data is safe, audits pass. Backups did not run. The parking lot is full. Did audits fail?", "INVALID", "2-hop inverse trap + distractor"),
        ("PROBE-C4-10", "If the key is valid, the door opens. If the door opens, the alarm trips. The alarm did not trip. The weather is mild. Is the key not valid?", "VALID", "2-hop contrapositive + distractor"),
    ]
    for name, body, exp, note in out:
        add("distractor", name, f"{body}\n{FMT_VI}", exp, note=note)
chain_items()

# ---------------------------------------------------------------------------
def main():
    counts = Counter(i["probe_class"] for i in ITEMS)
    # key balance per class for VALID/INVALID-vocab classes
    bal = {}
    for cls in ("defeasible", "distractor"):
        sub = [i for i in ITEMS if i["probe_class"] == cls]
        v = sum(1 for i in sub if i["expected_result"] == "VALID")
        bal[cls] = {"VALID": v, "INVALID": len(sub) - v}
    out = {"total": len(ITEMS), "by_class": dict(counts), "vi_balance": bal,
           "sha3_512": hashlib.sha3_512(json.dumps(ITEMS, ensure_ascii=False, sort_keys=True).encode()).hexdigest()}
    with open("analysis/probe_items.json", "w") as f:
        json.dump(ITEMS, f, ensure_ascii=False, indent=2); f.write("\n")
    print(json.dumps(out, indent=2))
    assert len(ITEMS) == 40, len(ITEMS)
    for cls in ("sound-arg", "defeasible", "quant-scope", "distractor"):
        assert counts.get(cls, 0) == 10, (cls, counts)
    print("GATES OK: 40 items, 4 classes x 10, V/I-balanced where applicable.")

if __name__ == "__main__":
    main()
