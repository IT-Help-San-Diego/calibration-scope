#!/usr/bin/env python3
"""
framing_analysis.py — PRE-REGISTERED analysis for the sound-arg framing test.

WRITTEN BEFORE THE DATA EXISTS. That is the point: choosing an estimator after seeing
the result is how a null becomes a finding. Fixing it in code makes the choice auditable.

DECIDES: H_bias (our leading stem caused the low NONE rate) vs H_deficit (the models
genuinely cannot recognise a sound argument).

UNIT OF ANALYSIS: the (item, model) CELL, majority vote over reps.
Reps reduce measurement noise WITHIN a cell; they are NOT independent units.
This is the correction from CORRECTION_framing_test_power.md — an earlier version of
this design pre-registered "paired within item+model+rep", which counted 15 reps of
3 items as 90 observations. Cluster-aware power was 0.03, not the claimed 1.00.

INPUT CSV columns (required):
  item_id, framing (A_leading|B_neutral), model, rep, pass, expected_result
Optional: is_infra_error (rows with 1 are treated as MISSING, never as wrong)

STOPPING RULE (pre-registered, from CORRECTION_framing_test_power.md):
  NONE rate under B >= 0.50 and controls hold -> H_BIAS: reword the stem, re-run the class
  NONE rate under B <  0.30 and controls hold -> H_DEFICIT survives (framing effect bounded)
  fallacy controls DROP under B               -> INCONCLUSIVE: B traded one bias for another
  between 0.30 and 0.50                       -> INDETERMINATE: report the bound, do not pick
"""
import sys, json, math
from collections import defaultdict

BIAS_THRESHOLD = 0.50
DEFICIT_THRESHOLD = 0.30
CONTROL_DROP_TOLERANCE = 0.10   # fallacy accuracy may not fall more than this under B
ALPHA = 0.05

def read_csv(path):
    import csv
    with open(path) as f:
        rows = [dict(r) for r in csv.DictReader(f)]
    for r in rows:
        r["pass"] = int(float(r["pass"]))
        r["rep"] = int(float(r.get("rep", 0)))
        r["is_infra_error"] = int(float(r.get("is_infra_error", 0) or 0))
    return rows

def cells(rows):
    """Collapse reps -> one majority-vote outcome per (item, model, framing) cell."""
    acc = defaultdict(list)
    for r in rows:
        if r["is_infra_error"]:
            continue                      # infra failure is MISSING, never WRONG
        acc[(r["item_id"], r["model"], r["framing"])].append(r["pass"])
    out = {}
    for k, v in acc.items():
        out[k] = {"n_reps": len(v), "rate": sum(v)/len(v), "vote": int(sum(v)/len(v) >= 0.5)}
    return out

def binom_p(k, n):
    """Exact two-sided binomial test against p=0.5 (stdlib only)."""
    if n == 0:
        return 1.0
    def pmf(i):
        return math.comb(n, i) * 0.5**n
    obs = pmf(k)
    return min(1.0, sum(pmf(i) for i in range(n+1) if pmf(i) <= obs + 1e-12))

def wilson(k, n, z=1.96):
    if n == 0:
        return (0.0, 1.0)
    p = k/n; d = 1 + z*z/n
    c = (p + z*z/(2*n))/d
    h = z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))/d
    return (max(0.0, c-h), min(1.0, c+h))

def analyze(rows):
    C = cells(rows)
    items = sorted({k[0] for k in C})
    models = sorted({k[1] for k in C})
    exp = {r["item_id"]: r["expected_result"] for r in rows}
    none_items = [i for i in items if exp.get(i) == "NONE"]
    ctrl_items = [i for i in items if exp.get(i) != "NONE"]

    res = {"n_none_items": len(none_items), "n_control_items": len(ctrl_items),
           "n_models": len(models), "n_cells_per_framing": len(none_items)*len(models)}

    # ---- PRIMARY: McNemar on NONE cells, A vs B ----
    b01 = b10 = 0; pairs = []
    for i in none_items:
        for m in models:
            a = C.get((i, m, "A_leading")); b = C.get((i, m, "B_neutral"))
            if a is None or b is None:
                continue
            pairs.append((i, m, a["vote"], b["vote"], a["rate"], b["rate"]))
            if a["vote"] == 0 and b["vote"] == 1: b01 += 1
            elif a["vote"] == 1 and b["vote"] == 0: b10 += 1
    res["mcnemar"] = {"n_pairs": len(pairs), "B_better": b01, "A_better": b10,
                      "p": binom_p(b01, b01+b10) if (b01+b10) else 1.0}

    # ---- rates ----
    def rate(items_, fr):
        v = [C[(i, m, fr)]["rate"] for i in items_ for m in models if (i, m, fr) in C]
        return sum(v)/len(v) if v else float("nan")
    def votes(items_, fr):
        v = [C[(i, m, fr)]["vote"] for i in items_ for m in models if (i, m, fr) in C]
        return sum(v), len(v)
    res["none_rate_A"] = rate(none_items, "A_leading")
    res["none_rate_B"] = rate(none_items, "B_neutral")
    kA, nA = votes(none_items, "A_leading"); kB, nB = votes(none_items, "B_neutral")
    res["none_wilson_B"] = wilson(kB, nB)
    res["control_rate_A"] = rate(ctrl_items, "A_leading")
    res["control_rate_B"] = rate(ctrl_items, "B_neutral")
    res["control_drop"] = res["control_rate_A"] - res["control_rate_B"]

    # ---- SECONDARY: paired test on cell RATES (calibrated; FP 0.043-0.046 in simulation) ----
    d = [b - a for (_, _, _, _, a, b) in pairs]
    if len(d) > 1:
        mean = sum(d)/len(d)
        sd = math.sqrt(sum((x-mean)**2 for x in d)/(len(d)-1))
        se = sd/math.sqrt(len(d)) if sd > 0 else 0.0
        res["paired_rates"] = {"mean_diff": mean, "sd": sd,
                               "t": (mean/se if se > 0 else float("inf") if mean else 0.0),
                               "df": len(d)-1}
    # ---- leave-one-item-out sensitivity (REQUIRED with any positive) ----
    loo = {}
    for drop in none_items:
        sub = [p for p in pairs if p[0] != drop]
        x = sum(1 for p in sub if p[2] == 0 and p[3] == 1)
        y = sum(1 for p in sub if p[2] == 1 and p[3] == 0)
        loo[drop] = {"B_better": x, "A_better": y, "p": binom_p(x, x+y) if (x+y) else 1.0}
    res["leave_one_out"] = loo
    res["loo_fragile"] = any(v["p"] >= ALPHA for v in loo.values()) and res["mcnemar"]["p"] < ALPHA

    # ---- VERDICT ----
    controls_hold = res["control_drop"] <= CONTROL_DROP_TOLERANCE
    if not controls_hold:
        v = ("INCONCLUSIVE", "fallacy controls dropped under neutral framing "
             f"({res['control_drop']:+.3f} > {CONTROL_DROP_TOLERANCE}); B traded one bias for another. "
             "Redesign the neutral stem.")
    elif res["none_rate_B"] >= BIAS_THRESHOLD:
        v = ("H_BIAS", f"NONE rate rose to {res['none_rate_B']:.3f} under neutral framing. "
             "The sound-arg difficulty was OUR STEM. Reword and re-run the whole class before "
             "it enters any powered bank.")
    elif res["none_rate_B"] < DEFICIT_THRESHOLD:
        v = ("H_DEFICIT_SURVIVES", f"NONE rate {res['none_rate_B']:.3f} under neutral framing. "
             "The deficit is not explained by our wording. Sound-arg graduates, with the framing "
             "effect bounded — this is NOT proof of a reasoning deficit, only failure to explain it away.")
    else:
        v = ("INDETERMINATE", f"NONE rate {res['none_rate_B']:.3f} sits between the pre-registered "
             f"thresholds ({DEFICIT_THRESHOLD}-{BIAS_THRESHOLD}). Report the bound; do not pick a hypothesis.")
    res["verdict"], res["verdict_reason"] = v
    if res["loo_fragile"]:
        res["verdict_reason"] += (" WARNING: leave-one-item-out shows the significance depends on a "
                                  "single item. Treat as a pilot signal, not a class verdict.")
    return res

# ---------------- SELF-TESTS: run with no argument ----------------
def _synth(n_none, n_ctrl, models, reps, pA_none, pB_none, p_ctrl_A, p_ctrl_B, seed=0):
    import random
    rng = random.Random(seed); rows = []
    for idx in range(n_none + n_ctrl):
        iid = f"I{idx:02d}"; is_none = idx < n_none
        exp_ = "NONE" if is_none else "FALSECAUSE"
        for m in range(models):
            for fr, p in (("A_leading", pA_none if is_none else p_ctrl_A),
                          ("B_neutral", pB_none if is_none else p_ctrl_B)):
                for r in range(reps):
                    rows.append({"item_id": iid, "framing": fr, "model": f"m{m}", "rep": r,
                                 "pass": 1 if rng.random() < p else 0,
                                 "expected_result": exp_, "is_infra_error": 0})
    return rows

def _selftest():
    ok = True
    # T1 strong bias effect -> H_BIAS
    r = analyze(_synth(10, 10, 2, 6, 0.14, 0.85, 0.98, 0.97, seed=1))
    t1 = r["verdict"] == "H_BIAS"; ok &= t1
    print(f"  T1 strong framing effect -> H_BIAS: {r['verdict']} {'PASS' if t1 else 'FAIL'}")
    # T2 no effect -> H_DEFICIT_SURVIVES (null control: must NOT invent a bias)
    r = analyze(_synth(10, 10, 2, 6, 0.14, 0.14, 0.98, 0.98, seed=2))
    t2 = r["verdict"] == "H_DEFICIT_SURVIVES"; ok &= t2
    print(f"  T2 null control       -> H_DEFICIT: {r['verdict']} {'PASS' if t2 else 'FAIL'}")
    # T3 controls collapse under B -> INCONCLUSIVE, even with a big NONE rise
    r = analyze(_synth(10, 10, 2, 6, 0.14, 0.85, 0.98, 0.40, seed=3))
    t3 = r["verdict"] == "INCONCLUSIVE"; ok &= t3
    print(f"  T3 controls collapse  -> INCONCLUSIVE: {r['verdict']} {'PASS' if t3 else 'FAIL'}")
    # T4 mid-range -> INDETERMINATE (must not pick a side)
    r = analyze(_synth(10, 10, 2, 6, 0.14, 0.40, 0.98, 0.98, seed=4))
    t4 = r["verdict"] == "INDETERMINATE"; ok &= t4
    print(f"  T4 mid-range          -> INDETERMINATE: {r['verdict']} {'PASS' if t4 else 'FAIL'}")
    # T5 CLUSTERING: reps must NOT inflate n_pairs. 3 items x 2 models x 30 reps = 6 pairs, not 180.
    r = analyze(_synth(3, 3, 2, 30, 0.14, 0.85, 0.98, 0.98, seed=5))
    t5 = r["mcnemar"]["n_pairs"] == 6; ok &= t5
    print(f"  T5 reps are NOT units : n_pairs={r['mcnemar']['n_pairs']} (must be 6) {'PASS' if t5 else 'FAIL'}")
    # T6 infra errors are MISSING, not WRONG
    rows = _synth(4, 4, 2, 6, 0.90, 0.90, 0.98, 0.98, seed=6)
    for x in rows[:20]:
        x["pass"] = 0; x["is_infra_error"] = 1
    r = analyze(rows)
    t6 = r["none_rate_A"] > 0.7; ok &= t6
    print(f"  T6 infra=missing      : none_rate_A={r['none_rate_A']:.2f} (>0.7) {'PASS' if t6 else 'FAIL'}")
    # T7 leave-one-out fragility is detected at n=3
    r = analyze(_synth(3, 3, 2, 15, 0.14, 0.85, 0.98, 0.98, seed=7))
    print(f"  T7 LOO reported at n=3: fragile={r['loo_fragile']} (informational)")
    print("SELF-TEST:", "ALL PASS" if ok else "FAILURES PRESENT")
    return ok

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(0 if _selftest() else 1)
    out = analyze(read_csv(sys.argv[1]))
    print(json.dumps(out, indent=1, default=str))
    print("\nVERDICT:", out["verdict"])
    print(out["verdict_reason"])
