#!/usr/bin/env python3
"""
pilot_analysis.py — PRE-REGISTERED analysis for the 60-item item-bank pilot.

WHY THIS EXISTS AND WHY IT IS WRITTEN BEFORE THE DATA
The pilot's whole job is to produce three numbers that decide how the 500-item bank is built:
  (1) difficulty distribution   -> is the bank off the ceiling? (target 70-85% baseline pass)
  (2) family ICC                -> sets items-per-family via DE = 1 + (m-1)*ICC
  (3) per-mechanism difficulty  -> chain vs trap vs negdepth: "hard how", not just "how hard"
Choosing the estimator after seeing the data is how a null becomes a finding. This file fixes the
estimators, the thresholds, and the go/no-go rule in advance. Run it unchanged on the real CSV.

USAGE
  python3 pilot_analysis.py pilot_results.csv
  python3 pilot_analysis.py --self-test          # validation suite, no data needed

EXPECTED COLUMNS
  item_id, family_id, difficulty_lever, model, carrier, admin, pass  (0/1)
  optional: is_infra_error (rows with 1 are treated as MISSING, never as wrong -- standing rule)

EXIT CODE: 0 = pilot supports proceeding; 1 = go/no-go rule says STOP and redesign.
Stdlib + numpy/scipy only.
"""
import sys, json, csv, math
from collections import defaultdict, Counter

# ----------------------------- PRE-REGISTERED THRESHOLDS -----------------------------
TARGET_LO, TARGET_HI = 0.70, 0.85     # desired baseline pass-rate band for the hard items
CEILING = 0.95                        # an item/set at or above this is "at the ceiling"
ICC_CAP_TABLE = [(0.20, 12), (0.35, 8), (0.50, 6), (1.01, 4)]  # ICC -> max items per family
MIN_INFORMATIVE_FRAC = 0.50           # >=50% of hard items must be off the ceiling to proceed
MIN_TRIALS_FOR_CEILING = 8            # below this, a perfect score does NOT establish a ceiling item.
# Justification (computed, not guessed): an item with TRUE p=0.75 scores perfect on 3 trials 42% of the
# time, on 6 trials 18%, on 12 trials 3%. Classifying ceiling off a 3-trial perfect score therefore
# labels a large fraction of well-calibrated items as uninformative and would STOP a healthy pilot.
# The real design gives 12 trials/item (2 models x 2 carriers x 3 reps), which is why 8 is reachable.


def wilson(k, n, z=1.96):
    if n == 0: return (float("nan"), float("nan"))
    p = k / n; d = 1 + z*z/n
    c = (p + z*z/(2*n)) / d
    h = z*math.sqrt(p*(1-p)/n + z*z/(4*n*n)) / d
    return (max(0.0, c-h), min(1.0, c+h))


def icc_anova(groups):
    """One-way random-effects ICC(1) on binary outcomes, ANOVA estimator.
    groups: {family_id: [item_mean, item_mean, ...]} -- one value per ITEM (its pass rate).
    Returns (icc, between_ms, within_ms, k_bar). Clipped to [0, 1].
    Chosen over a GLMM because it needs no optimiser, cannot fail to converge, and the
    design decision only needs ICC to ~0.1 resolution (the cap table is coarse by design)."""
    fams = {f: v for f, v in groups.items() if len(v) >= 2}
    if len(fams) < 2: return (float("nan"), float("nan"), float("nan"), float("nan"))
    N = sum(len(v) for v in fams.values()); a = len(fams)
    grand = sum(sum(v) for v in fams.values()) / N
    ssb = sum(len(v) * (sum(v)/len(v) - grand)**2 for v in fams.values())
    ssw = sum(sum((x - sum(v)/len(v))**2 for x in v) for v in fams.values())
    msb = ssb / (a - 1); msw = ssw / (N - a) if N > a else float("nan")
    # k_bar: average group size, corrected for unequal sizes (Snedecor & Cochran)
    k_bar = (N - sum(len(v)**2 for v in fams.values()) / N) / (a - 1)
    if not math.isfinite(msw) or msb + msw == 0 or k_bar <= 0: return (float("nan"), msb, msw, k_bar)
    icc = (msb - msw) / (msb + (k_bar - 1) * msw)
    return (min(1.0, max(0.0, icc)), msb, msw, k_bar)


def items_per_family(icc):
    for thresh, cap in ICC_CAP_TABLE:
        if icc < thresh: return cap
    return 4


def design_effect(icc, m):
    return 1 + (m - 1) * icc


def stratification_report(rows):
    """Show what trials/item each reading granularity gives, and which are POWERED.
    Exists because 'read difficulty per carrier per model' silently returns to 6 trials/item
    even when the run has 24 — the granularity, not the run size, sets the power."""
    rows = [r for r in rows if str(r.get("is_infra_error", "0")).strip() not in ("1", "True", "true")]
    out = []
    for label, keyf in [("fully pooled", lambda r: ()),
                        ("per model", lambda r: (r.get("model", ""),)),
                        ("per carrier", lambda r: (r.get("carrier", ""),)),
                        ("per carrier x model", lambda r: (r.get("model", ""), r.get("carrier", "")))]:
        counts = defaultdict(Counter)
        for r in rows: counts[keyf(r)][r["item_id"].strip()] += 1
        per = [n for cell in counts.values() for n in cell.values()]
        if not per: continue
        med = sorted(per)[len(per)//2]
        out.append({"granularity": label, "n_cells": len(counts), "median_trials_per_item": med,
                    "powered_for_ceiling": med >= MIN_TRIALS_FOR_CEILING,
                    "p_perfect_if_true_p_085": round(0.85 ** med, 4)})
    return out


def analyze(rows):
    """rows: list of dicts. Returns the full pre-registered result dict."""
    # standing rule: infra errors are MISSING, never wrong
    n_raw = len(rows)
    rows = [r for r in rows if str(r.get("is_infra_error", "0")).strip() not in ("1", "True", "true")]
    n_infra = n_raw - len(rows)

    per_item = defaultdict(list)
    meta = {}
    for r in rows:
        iid = r["item_id"].strip()
        per_item[iid].append(int(float(r["pass"])))
        meta.setdefault(iid, {"family_id": r.get("family_id", "").strip(),
                              "lever": r.get("difficulty_lever", "").strip()})
    item_rate = {i: sum(v)/len(v) for i, v in per_item.items()}
    item_n = {i: len(v) for i, v in per_item.items()}

    # ---- INTEGRITY GUARD: refuse a name-keyed CSV that silently merges distinct tests.
    # This is the 63-vs-64 defect, which cost 1,024 trials before it was found in post-hoc
    # analysis. It presents two ways, both detected here:
    #   (a) one item_id carrying conflicting metadata  -> two different tests share a display name
    #   (b) one item_id carrying a MULTIPLE of the modal trial count -> same, seen only in the counts
    conflicts = defaultdict(set)
    for r in rows:
        iid = r["item_id"].strip()
        conflicts[iid].add((r.get("family_id", "").strip(), r.get("difficulty_lever", "").strip()))
    merged_meta = {i: sorted(s) for i, s in conflicts.items() if len(s) > 1}
    modal_n = Counter(item_n.values()).most_common(1)[0][0] if item_n else 0
    merged_count = {i: n for i, n in item_n.items()
                    if modal_n and n > modal_n and n % modal_n == 0}
    if merged_meta or merged_count:
        raise SystemExit(
            "FATAL: item_id collision — the CSV is keyed on a NON-UNIQUE identifier (display name?).\n"
            f"  conflicting metadata under one id: {merged_meta or 'none'}\n"
            f"  id(s) carrying a multiple of the modal {modal_n} trials: {merged_count or 'none'}\n"
            "  This is the 63-vs-64 defect: distinct tests merge into one pseudo-item, inflating\n"
            "  trials/item, corrupting the per-item pass rate, and giving ICC a phantom item.\n"
            "  FIX: emit the CSV keyed on test_id (the primary key), never the display name.")

    # (1) difficulty distribution
    rates = sorted(item_rate.values())
    n_items = len(rates)
    # An item counts as AT CEILING only if it scored at/above CEILING **and** carried enough trials
    # for that to mean anything. Under-powered items are reported separately, never silently counted.
    at_ceiling = [i for i, p in item_rate.items()
                  if p >= CEILING and item_n[i] >= MIN_TRIALS_FOR_CEILING]
    unresolved = [i for i, p in item_rate.items()
                  if p >= CEILING and item_n[i] < MIN_TRIALS_FOR_CEILING]
    in_band = [i for i, p in item_rate.items() if TARGET_LO <= p <= TARGET_HI]
    informative = [i for i, p in item_rate.items() if p < CEILING]  # observed variation = usable
    overall_k = sum(sum(v) for v in per_item.values()); overall_n = sum(len(v) for v in per_item.values())

    # (2) family ICC -- one value per ITEM, grouped by family
    groups = defaultdict(list)
    for i, p in item_rate.items():
        fam = meta[i]["family_id"]
        if fam: groups[fam].append(p)
    icc, msb, msw, kbar = icc_anova(groups)
    cap = items_per_family(icc) if math.isfinite(icc) else None

    # (3) per-mechanism difficulty
    by_lever = defaultdict(list)
    for i, p in item_rate.items():
        lev = meta[i]["lever"] or "unspecified"
        by_lever[lev].append(p)
    mech = {}
    for lev, ps in sorted(by_lever.items()):
        k = sum(round(p*item_n[i]) for i, p in item_rate.items() if (meta[i]["lever"] or "unspecified") == lev)
        n = sum(item_n[i] for i in item_rate if (meta[i]["lever"] or "unspecified") == lev)
        lo, hi = wilson(int(k), int(n))
        mech[lev] = {"n_items": len(ps), "trials": int(n), "pass_rate": (k/n) if n else float("nan"),
                     "wilson95": [lo, hi], "n_at_ceiling": sum(1 for p in ps if p >= CEILING)}

    # (4) key balance is a property of the BANK, reported for the record
    return {
        "n_rows_raw": n_raw, "n_infra_dropped": n_infra,
        "n_items": n_items, "trials": int(overall_n),
        "overall_pass_rate": overall_k/overall_n if overall_n else float("nan"),
        "difficulty": {
            "median_item_rate": rates[n_items//2] if n_items else float("nan"),
            "min": rates[0] if n_items else float("nan"), "max": rates[-1] if n_items else float("nan"),
            "n_at_ceiling": len(at_ceiling), "frac_at_ceiling": len(at_ceiling)/n_items if n_items else float("nan"),
            "n_perfect_but_underpowered": len(unresolved),
            "median_trials_per_item": sorted(item_n.values())[len(item_n)//2] if item_n else 0,
            "n_in_target_band": len(in_band), "n_informative": len(informative),
            "frac_informative": len(informative)/n_items if n_items else float("nan"),
        },
        "icc": {"value": icc, "ms_between": msb, "ms_within": msw, "k_bar": kbar,
                "n_families": len(groups), "recommended_items_per_family": cap,
                "design_effect_at_cap": design_effect(icc, cap) if cap and math.isfinite(icc) else None,
                "n_eff_per_500": (500 / design_effect(icc, cap)) if cap and math.isfinite(icc) else None},
        "mechanisms": mech,
    }


def go_no_go(res):
    """PRE-REGISTERED decision rule. Returns (proceed: bool, reasons: list[str])."""
    r, why = True, []
    d = res["difficulty"]
    if d.get("median_trials_per_item", 0) < MIN_TRIALS_FOR_CEILING:
        why.append(
            f"WARN: median {d['median_trials_per_item']} trials/item is below {MIN_TRIALS_FOR_CEILING}; "
            f"{d.get('n_perfect_but_underpowered', 0)} items scored perfect but cannot be distinguished from "
            f"p~0.75 at this trial count. Ceiling fractions below are LOWER bounds on difficulty, and the "
            f"go/no-go verdict is provisional. Re-run with >=12 trials/item before locking the bank design.")
    if not math.isfinite(d["frac_informative"]) or d["frac_informative"] < MIN_INFORMATIVE_FRAC:
        r = False; why.append(
            f"STOP: only {d['frac_informative']*100:.0f}% of items are off the ceiling "
            f"(need >={MIN_INFORMATIVE_FRAC*100:.0f}%). The harder mechanisms did not produce difficulty; "
            f"more items will not fix this.")
    else:
        why.append(f"OK: {d['frac_informative']*100:.0f}% of items are off the ceiling.")
    if d["n_in_target_band"] == 0:
        why.append(f"WARN: no item lands in the {TARGET_LO:.0%}-{TARGET_HI:.0%} target band; "
                   f"difficulty may be bimodal (trivial or impossible) rather than graded.")
    icc = res["icc"]["value"]
    if not math.isfinite(icc):
        r = False; why.append("STOP: ICC not estimable (need >=2 families with >=2 items each).")
    else:
        why.append(f"OK: family ICC = {icc:.3f} -> cap {res['icc']['recommended_items_per_family']} items/family "
                   f"(design effect {res['icc']['design_effect_at_cap']:.2f}, "
                   f"n_eff ~{res['icc']['n_eff_per_500']:.0f} for a 500-item bank).")
    levs = {k: v for k, v in res["mechanisms"].items() if k != "unspecified"}
    if levs:
        best = min(levs.items(), key=lambda kv: kv[1]["pass_rate"])
        worst = max(levs.items(), key=lambda kv: kv[1]["pass_rate"])
        why.append(f"MECHANISM: hardest = {best[0]} ({best[1]['pass_rate']:.1%}), "
                   f"easiest = {worst[0]} ({worst[1]['pass_rate']:.1%}). Build the bank on the hardest.")
        if all(v["pass_rate"] >= CEILING for v in levs.values()):
            r = False; why.append("STOP: every mechanism is at the ceiling. None of the three levers worked.")
    return r, why


# --------------------------------- VALIDATION SUITE ---------------------------------
def _self_test():
    import numpy as np
    rng = np.random.default_rng(953)
    ok = True

    def synth(n_fam, per_fam, reps, base_p, fam_sd, lever_shift=None, seed=0):
        rr = np.random.default_rng(seed); out = []
        lb = math.log(base_p/(1-base_p))
        for f in range(n_fam):
            u = rr.normal(0, fam_sd)
            for j in range(per_fam):
                lev = ["chain", "trap", "negdepth"][j % 3]
                shift = (lever_shift or {}).get(lev, 0.0)
                p = 1/(1+math.exp(-(lb + u + shift)))
                for k in range(reps):
                    out.append({"item_id": f"F{f}-I{j}", "family_id": f"F{f}", "difficulty_lever": lev,
                                "model": "m", "carrier": "base", "admin": "1",
                                "pass": int(rr.random() < p), "is_infra_error": "0"})
        return out

    # T1: ICC RECOVERY -- the load-bearing validation. An ICC estimator that cannot recover a
    # known injected value is worthless, and the whole items-per-family decision rests on it.
    print("T1  ICC recovery (injected family SD -> estimated ICC)")
    for fam_sd, label in [(0.0, "no clustering"), (1.0, "moderate"), (2.0, "strong")]:
        ests = []
        for s in range(12):
            res = analyze(synth(8, 6, 3, 0.75, fam_sd, seed=100+s))
            ests.append(res["icc"]["value"])
        m = float(np.nanmean(ests))
        print(f"      fam_sd={fam_sd:.1f} ({label:14s}) -> mean ICC {m:.3f}")
        if fam_sd == 0.0 and m > 0.20: ok = False; print("      FAIL: no-clustering case should give ICC near 0")
        if fam_sd == 2.0 and m < 0.25: ok = False; print("      FAIL: strong clustering should give clearly positive ICC")
    # monotonicity is the property the cap table actually depends on
    m0 = float(np.nanmean([analyze(synth(8,6,3,0.75,0.0,seed=200+s))["icc"]["value"] for s in range(12)]))
    m1 = float(np.nanmean([analyze(synth(8,6,3,0.75,1.0,seed=300+s))["icc"]["value"] for s in range(12)]))
    m2 = float(np.nanmean([analyze(synth(8,6,3,0.75,2.0,seed=400+s))["icc"]["value"] for s in range(12)]))
    print(f"      monotonic: {m0:.3f} < {m1:.3f} < {m2:.3f} -> {m0 < m1 < m2}")
    if not (m0 < m1 < m2): ok = False; print("      FAIL: ICC must increase with injected clustering")

    # T2: CEILING DETECTION -- the go/no-go must STOP on a ceiling-bound bank
    print("T2  ceiling detection")
    res = analyze(synth(6, 5, 12, 0.995, 0.2, seed=7)); go, why = go_no_go(res)   # 12 trials/item = real design
    print(f"      ceiling bank -> frac_informative {res['difficulty']['frac_informative']:.2f}, proceed={go}")
    if go: ok = False; print("      FAIL: must STOP on a ceiling-bound bank")
    res = analyze(synth(6, 5, 12, 0.75, 0.4, seed=8)); go2, _ = go_no_go(res)     # 12 trials/item = real design
    print(f"      off-ceiling bank -> frac_informative {res['difficulty']['frac_informative']:.2f}, proceed={go2}")
    if not go2: ok = False; print("      FAIL: must PROCEED on an off-ceiling bank")

    # T2b: UNDER-POWERED trial count must WARN (and say so), not silently mislabel
    print("T2b under-powered trial count warns")
    res = analyze(synth(6, 5, 3, 0.75, 0.4, seed=8)); _, why_u = go_no_go(res)
    warned = any("below" in w and "trials/item" in w for w in why_u)
    print(f"      3 trials/item -> perfect-but-underpowered items: {res['difficulty']['n_perfect_but_underpowered']}, warned={warned}")
    if not warned: ok = False; print("      FAIL: must warn when trials/item is too few to classify ceiling")

    # T3: MECHANISM SEPARATION -- can it see which lever is hardest?
    print("T3  mechanism separation (trap injected as hardest)")
    res = analyze(synth(8, 6, 4, 0.80, 0.3, lever_shift={"trap": -1.4, "chain": 0.0, "negdepth": 0.5}, seed=11))
    order = sorted(res["mechanisms"].items(), key=lambda kv: kv[1]["pass_rate"])
    print("      " + " < ".join(f"{k} {v['pass_rate']:.2f}" for k, v in order))
    if order[0][0] != "trap": ok = False; print("      FAIL: injected-hardest mechanism not recovered")

    # T6: NAME-JOIN COLLISION must be FATAL, not silently merged (the 63-vs-64 defect)
    print("T6  item_id collision is fatal")
    d = synth(4, 4, 6, 0.75, 0.3, seed=23)
    for r in d:
        if r["item_id"] == "F1-I1": r["item_id"] = "F0-I0"   # two distinct tests, one id
    try:
        analyze(d); print("      FAIL: collision not detected"); ok = False
    except SystemExit as e:
        good = "63-vs-64" in str(e); print(f"      raised SystemExit, names the defect: {good}")
        if not good: ok = False
    d2 = synth(4, 4, 6, 0.75, 0.3, seed=24)   # clean control
    try:
        analyze(d2); print("      clean data passes the guard: True")
    except SystemExit:
        print("      FAIL: guard fires on clean data"); ok = False

    # T7: STRATIFICATION report must mark the under-powered granularity
    print("T7  stratification flags under-powered granularity")
    # Real design: 2 models x 2 carriers x 6 reps = 24 rows/item. synth() emits `reps` rows per
    # item TOTAL, so ask for 24 and label them into the four cells, 6 apiece.
    d = synth(6, 5, 24, 0.80, 0.3, seed=31)
    for i, r in enumerate(d):
        cell = i % 4
        r["model"] = ["e2b", "nemotron"][cell % 2]; r["carrier"] = ["base", "lean"][cell // 2]
    strat = {s["granularity"]: s for s in stratification_report(d)}
    for g in ["fully pooled", "per model", "per carrier x model"]:
        s = strat[g]; print(f"      {g:22s} {s['median_trials_per_item']:2d} trials/item  powered={s['powered_for_ceiling']}")
    if strat["per carrier x model"]["powered_for_ceiling"]: ok = False; print("      FAIL: finest slice should be flagged")
    if not strat["fully pooled"]["powered_for_ceiling"]: ok = False; print("      FAIL: pooled should be powered")

    # T4: INFRA ERRORS ARE MISSING, NEVER WRONG (standing rule)
    print("T4  infra errors treated as missing")
    d = synth(4, 4, 3, 0.9, 0.3, seed=13)
    for r in d[:10]: r["is_infra_error"] = "1"; r["pass"] = 0
    res = analyze(d)
    print(f"      dropped {res['n_infra_dropped']} infra rows of {res['n_rows_raw']}")
    if res["n_infra_dropped"] != 10: ok = False; print("      FAIL: infra rows not dropped")

    # T5: ICC NOT ESTIMABLE -> must STOP, not silently proceed
    print("T5  ICC inestimable -> STOP")
    d = [r for r in synth(1, 6, 3, 0.75, 0.5, seed=17)]
    go3, why3 = go_no_go(analyze(d))
    print(f"      single family -> proceed={go3}")
    if go3: ok = False; print("      FAIL: must STOP when ICC cannot be estimated")

    print("\nSELF-TEST:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


def main(argv):
    if "--self-test" in argv: return _self_test()
    if len(argv) < 2: print(__doc__); return 2
    rows = list(csv.DictReader(open(argv[1], encoding="utf-8", errors="replace")))
    strat = stratification_report(rows)
    res = analyze(rows)
    res["stratification"] = strat
    go, why = go_no_go(res)
    bad = [s["granularity"] for s in strat if not s["powered_for_ceiling"]]
    if bad:
        why.append("GRANULARITY: ceiling/difficulty may be read at " +
                   ", ".join(s["granularity"] for s in strat if s["powered_for_ceiling"]) +
                   f" — but NOT at {', '.join(bad)} (fewer than {MIN_TRIALS_FOR_CEILING} trials/item there; "
                   f"an item with true p=0.85 reads as perfect "
                   f"{[s['p_perfect_if_true_p_085'] for s in strat if not s['powered_for_ceiling']][0]:.0%} "
                   f"of the time). Slicing finer does not add power, it removes it.")
    res["go_no_go"] = {"proceed": go, "reasons": why}
    print(json.dumps(res, indent=2, default=float))
    print("\n" + ("PROCEED" if go else "STOP") + " — pre-registered rule:")
    for w in why: print("  -", w)
    return 0 if go else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
