#!/usr/bin/env python3
"""run985_analysis.py — the PRE-REGISTERED comparison, written before the data existed.

Spec: inbox/claude-science/PREREG_run985_analysis.md (committed first, deliberately).

Usage:
  python3 run985_analysis.py <run985.csv> <powered_run_974_977.csv>
  python3 run985_analysis.py --selftest

Gate 0 runs before any comparison and can HALT. The decision rule is fixed in the spec:
a difference in EITHER direction fails the replicate — a run that comes back better is
evidence the setup changed, not a confirmation.
"""
import sys, json
import pandas as pd, numpy as np
from scipy import stats as st

ITEM, REP, PASS, INFRA = "test_id", "rep", "pass", "is_infra_error"


def item_acc(df):
    """Per-item accuracy over the reps PRESENT (ragged-safe by construction)."""
    return df.groupby(ITEM)[PASS].apply(lambda s: s.astype(bool).mean())


def is_stochastic(df):
    """True where an item's reps disagree.

    NOT REP-COUNT INVARIANT — do not compare this across runs with different rep
    counts. P(disagree) is monotone in rep count: for the baseline's own measured
    item accuracies the expected count of "stochastic" items is 21.4 at 3 reps,
    33.3 at 6, and 47.5 at 24, with stability held IDENTICAL. Comparing a 3-rep run
    to a 6-rep baseline therefore produces stoch->det flips and a significant
    McNemar with no change in underlying stability. Retained for reporting only;
    the verdict uses within_item_var() below.
    """
    return df.groupby(ITEM)[PASS].apply(lambda s: s.astype(bool).nunique() > 1)


def within_item_var(df):
    """Rep-count-invariant per-item instability: unbiased Bernoulli variance estimate.

    p_hat*(1-p_hat) is biased downward at small n; the n/(n-1) correction makes the
    estimate comparable across items with different rep counts, which is required
    because 2439 is not divisible by 6 and ragged reps are a live hypothesis.
    Items with fewer than 2 reps carry no variance information and are dropped.
    """
    def f(s):
        x = s.astype(bool).astype(float)
        n = len(x)
        if n < 2:
            return np.nan
        ph = x.mean()
        return ph * (1 - ph) * n / (n - 1)
    return df.groupby(ITEM)[PASS].apply(f)


def gate0(new, base):
    """Admissibility. Returns (report_dict, halt_reason_or_None)."""
    r = {}
    per_item = new.groupby(ITEM).size()
    r["n_rows"] = int(len(new))
    r["n_items"] = int(per_item.nunique() and new[ITEM].nunique())
    r["rows_per_item"] = sorted(per_item.unique().tolist())
    r["ragged"] = len(r["rows_per_item"]) > 1
    n = r["n_rows"]
    r["structure"] = {f"{k}_reps": (n / k if n % k else int(n / k)) for k in (1, 2, 3, 6)}
    r["divisible_by_6"] = n % 6 == 0
    r["infra_errors"] = int(new[INFRA].astype(bool).sum()) if INFRA in new else None
    r["infra_errors_baseline"] = int(base[INFRA].astype(bool).sum()) if INFRA in base else None
    shared = sorted(set(new[ITEM]) & set(base[ITEM]))
    r["n_shared_items"] = len(shared)
    r["n_items_new_only"] = int(new[ITEM].nunique() - len(shared))
    r["n_items_base_only"] = int(base[ITEM].nunique() - len(shared))
    # REP-COUNT COMPARISON. Added after a dry run in which the "new" side carried 24
    # rows per item against a 6-rep baseline: the stochastic count went 48 -> 130 and
    # I read it as collapsed stability. It was arithmetic. P(an item's reps disagree)
    # rises with rep count, and pooling heterogeneous arms inflates it further, so a
    # rep-count mismatch makes any disagreement-based stability comparison meaningless.
    bp = base.groupby(ITEM).size()
    r["baseline_rows_per_item"] = sorted(bp.unique().tolist())
    r["rep_count_matches_baseline"] = r["rows_per_item"] == r["baseline_rows_per_item"]
    halt = None
    if len(shared) == 0:
        halt = "NO SHARED ITEMS — the runs are not comparable at all; this is not a replicate."
    return r, halt, shared


def analyse(new, base, shared):
    """The pre-registered tests. Paired, shared items only."""
    if INFRA in new:
        new = new[~new[INFRA].astype(bool)]
    if INFRA in base:
        base = base[~base[INFRA].astype(bool)]
    a = item_acc(base.loc[base[ITEM].isin(shared)])
    b = item_acc(new.loc[new[ITEM].isin(shared)])
    idx = a.index.intersection(b.index)
    d = (b.loc[idx] - a.loc[idx]).values
    n = len(d)
    out = {"n_items_analysed": int(n),
           "baseline_mean_acc": float(a.loc[idx].mean()),
           "run985_mean_acc": float(b.loc[idx].mean()),
           "mean_diff": float(d.mean())}
    if n > 1 and d.std(ddof=1) > 0:
        t, pv = st.ttest_rel(b.loc[idx].values, a.loc[idx].values)
        se = d.std(ddof=1) / np.sqrt(n)
        crit = st.t.ppf(0.975, n - 1)
        out.update(paired_t=float(t), paired_p=float(pv),
                   ci95=[float(d.mean() - crit * se), float(d.mean() + crit * se)])
    else:
        out.update(paired_t=None, paired_p=None, ci95=None,
                   note="zero variance or n<2 — paired t undefined")
    # Secondary: stability flip (deterministic <-> stochastic), the question CS-001 asks
    sa = is_stochastic(base.loc[base[ITEM].isin(shared)]).reindex(idx)
    sb = is_stochastic(new.loc[new[ITEM].isin(shared)]).reindex(idx)
    b10 = int((sa & ~sb).sum()); b01 = int((~sa & sb).sum())
    out.update(stoch_baseline=int(sa.sum()), stoch_run985=int(sb.sum()),
               flip_stoch_to_det=b10, flip_det_to_stoch=b01)
    if b10 + b01 > 0:
        out["mcnemar_p_REPORT_ONLY"] = float(st.binomtest(b10, b10 + b01, 0.5).pvalue)
    else:
        out["mcnemar_p_REPORT_ONLY"] = None
    out["mcnemar_caveat"] = ("NOT rep-count invariant — meaningless unless "
                             "rep_count_matches_baseline is true. Does not drive the verdict.")
    # VERDICT-DRIVING stability test: paired on rep-count-invariant per-item variance.
    va = within_item_var(base.loc[base[ITEM].isin(shared)]).reindex(idx)
    vb = within_item_var(new.loc[new[ITEM].isin(shared)]).reindex(idx)
    ok = va.notna() & vb.notna()
    dv = (vb[ok] - va[ok]).values
    out["n_items_variance"] = int(len(dv))
    out["mean_within_item_var_baseline"] = float(va[ok].mean()) if len(dv) else None
    out["mean_within_item_var_run985"] = float(vb[ok].mean()) if len(dv) else None
    if len(dv) > 1 and dv.std(ddof=1) > 0:
        tv, pvv = st.ttest_rel(vb[ok].values, va[ok].values)
        out["var_paired_t"] = float(tv); out["var_paired_p"] = float(pvv)
    else:
        out["var_paired_t"] = None; out["var_paired_p"] = None
    return out


def verdict(g0, res):
    """The decision rule, fixed in the spec BEFORE the data existed."""
    if g0["n_shared_items"] < 100:
        return "INCONCLUSIVE", "shared set < 100 items; power too low (see spec power table)", "keep provisional"
    ci = res.get("ci95")
    if ci is None:
        return "INCONCLUSIVE", "paired t undefined", "keep provisional"
    if ci[0] <= 0 <= ci[1]:
        mc = res.get("var_paired_p")
        if mc is not None and mc < 0.05:
            return ("NOT REPLICATED", "accuracy CI contains 0 but within-item variance differs "
                    f"significantly (paired p={mc:.3g}, rep-count invariant) — instability is the "
                    "finding", "keep provisional")
        return ("REPLICATED", "accuracy CI contains 0 and stability not significantly different. "
                "BOUND: at ~293 shared items this excludes a 5-point shift (power 0.81) and does "
                "NOT exclude a 2-point one (power 0.22)", "un-provisional")
    direction = "HIGHER" if res["mean_diff"] > 0 else "LOWER"
    return ("NOT REPLICATED", f"CI excludes 0 — 985 is {direction} than baseline by "
            f"{res['mean_diff']:+.4f}. A run that comes back better fails identically to one that "
            "comes back worse: it is evidence the setup changed.", "keep provisional")


def main(argv):
    new = pd.read_csv(argv[0]); base_all = pd.read_csv(argv[1])
    base = base_all[(base_all["model"] == "google/gemma-4-e2b") & (base_all["carrier"] == "baseline")]
    g0, halt, shared = gate0(new, base)
    print("=== GATE 0 ===");  print(json.dumps(g0, indent=1))
    if halt:
        print("\nHALT:", halt); return 2
    res = analyse(new, base, shared)
    print("\n=== PRE-REGISTERED TESTS ==="); print(json.dumps(res, indent=1))
    v, why, action = verdict(g0, res)
    print(f"\n=== VERDICT: {v} ===\n  {why}\n  site sentence: {action}")
    return 0


def selftest():
    """Each case proves the harness reaches the pre-registered verdict, including the
    one that matters most: a BETTER replicate must FAIL."""
    rng = np.random.default_rng(7)

    def mk(items, reps, p, seed_shift=0.0):
        rows = []
        for i in items:
            base_p = 0.5 + 0.4 * ((hash(i) % 100) / 100 - 0.5) + seed_shift
            for r in range(reps):
                rows.append({ITEM: i, REP: r, PASS: rng.random() < np.clip(p if p is not None else base_p, 0, 1),
                             INFRA: False, "model": "google/gemma-4-e2b", "carrier": "baseline"})
        return pd.DataFrame(rows)

    items = [f"IT-{i:03d}" for i in range(150)]
    cases = []
    b = mk(items, 6, 0.77)
    cases.append(("identical distribution -> REPLICATED", mk(items, 6, 0.77), b, "REPLICATED"))
    cases.append(("985 much BETTER -> NOT REPLICATED", mk(items, 6, 0.95), b, "NOT REPLICATED"))
    cases.append(("985 much WORSE -> NOT REPLICATED", mk(items, 6, 0.55), b, "NOT REPLICATED"))
    small = [f"IT-{i:03d}" for i in range(40)]
    cases.append(("tiny overlap -> INCONCLUSIVE", mk(small, 6, 0.77), b, "INCONCLUSIVE"))
    # THE CASE THAT WOULD HAVE CAUGHT MY DRY-RUN ERROR. Same per-item accuracy, fewer
    # reps (3 vs 6) — the spec's own leading hypothesis for 2439 = 3 x 813. The old
    # disagreement-based secondary test returns a significant McNemar here purely
    # because P(reps disagree) falls with rep count, so it would call a genuinely
    # identical run NOT REPLICATED. The variance-based test must NOT.
    cases.append(("SAME stability, 3 reps not 6 -> REPLICATED", mk(items, 3, 0.77), b, "REPLICATED"))
    ok = 0
    for name, nn, bb, want in cases:
        g0, halt, shared = gate0(nn, bb)
        if halt:
            got = "HALT"
        else:
            got = verdict(g0, analyse(nn, bb, shared))[0]
        flag = "PASS" if got == want else "FAIL"
        ok += got == want
        print(f"  [{flag}] want {want:15s} got {got:15s} — {name}")
    # ragged + no-overlap gates
    rag = pd.concat([mk(items[:10], 6, 0.7), mk(items[10:20], 3, 0.7)])
    g0, _, _ = gate0(rag, b)
    r_ok = g0["ragged"] is True
    print(f"  [{'PASS' if r_ok else 'FAIL'}] ragged reps detected: {g0['rows_per_item']}")
    g0b, haltb, _ = gate0(mk([f"ZZ-{i}" for i in range(50)], 6, 0.7), b)
    h_ok = haltb is not None
    print(f"  [{'PASS' if h_ok else 'FAIL'}] zero-overlap HALTs")
    total = len(cases) + 2; got_all = ok + r_ok + h_ok
    print(f"\nself-test: {got_all}/{total} passed")
    return 0 if got_all == total else 1


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--selftest":
        sys.exit(selftest())
    if len(args) != 2:
        print(__doc__); sys.exit(64)
    sys.exit(main(args))
