#!/usr/bin/env python3
"""
carrier_analysis.py — PRE-REGISTERED analysis for the powered carrier run (970-973).
Written 2026-07-27, BEFORE any of runs 970-973 produced output. Commit this before the CSV lands.

PRIMARY TEST (declared): paired t on CELL PASS-RATES, family-clustered.
  unit = (family, model); value = mean pass rate over that family's items x 6 reps
  contrast = baseline carrier vs Lean carrier, paired within unit
  Rationale (simulated 2026-07-27): rate-based beats vote-then-McNemar roughly 2x in
  resolution (d=0.05: power 0.87 vs 0.59) and is calibrated (null FPR 0.044-0.055).
SECONDARY (robustness, reported always): vote-then-McNemar at (item,model) level.
GATES that run BEFORE any verdict is read.
"""
import sys, json
import numpy as np, pandas as pd
from scipy import stats as st

ALPHA = 0.05
LENGTH_LEAK_CEILING = 0.874   # measured: best length-only rule on the powered quant-scope bank
SPEARMAN_GATE = 0.30          # |rho| above this at baseline => length is scoring the class

def gate_integrity(d):
    """Hard stops. Returns list of blocking problems."""
    stop = []
    need = {"item_id","family_id","probe_class","model","carrier","rep","pass","expected_result"}
    missing = need - set(d.columns)
    if missing: stop.append(f"MISSING COLUMNS: {sorted(missing)}")
    if stop: return stop
    if "is_infra_error" in d.columns:
        n_infra = int(d.is_infra_error.sum())
        if n_infra: stop.append(f"INFRA ERRORS PRESENT: {n_infra} rows — must be treated as MISSING, not as failures")
    carriers = sorted(d.carrier.unique())
    if len(carriers) != 2: stop.append(f"expected 2 carriers, got {carriers}")
    # every (item,model) must appear under BOTH carriers — paired design invariant
    cnt = d.groupby(["item_id","model"])["carrier"].nunique()
    unpaired = int((cnt < 2).sum())
    if unpaired: stop.append(f"UNPAIRED CELLS: {unpaired} (item,model) cells lack both carriers")
    return stop

def gate_length_leak(d, item_len):
    """A length-only rule scores 0.874 on the powered quant-scope bank. If the models are
    exploiting it, the class's off-ceiling yield is illusory. Immune to the CARRIER contrast
    (length is constant within item across arms) but threatens the ABSOLUTE rate."""
    out = {}
    base = d[d.carrier == d.carrier.min()]
    for cls, g in base.groupby("probe_class"):
        r = g.groupby("item_id")["pass"].mean()
        L = r.index.map(item_len)
        ok = ~pd.isna(L)
        if ok.sum() < 8:
            out[cls] = {"n": int(ok.sum()), "note": "too few items for a correlation"}
            continue
        rho, p = st.spearmanr(np.asarray(L)[ok], r.values[ok])
        out[cls] = {"n": int(ok.sum()), "baseline_acc": float(r.mean()),
                    "spearman_len_vs_pass": float(rho), "p": float(p),
                    "length_leak_binds": bool(abs(rho) >= SPEARMAN_GATE and p < ALPHA),
                    "near_length_ceiling": bool(r.mean() >= LENGTH_LEAK_CEILING - 0.05)}
    return out

def primary_family_clustered(d):
    """Unit of analysis = (family, model). Items within a family share a template and are
    NOT independent (this project has been bitten by ignoring clustering three times)."""
    cell = d.groupby(["family_id","model","carrier"])["pass"].mean().unstack("carrier")
    cell = cell.dropna()
    if cell.shape[1] != 2: return {"error": f"expected 2 carrier columns, got {list(cell.columns)}"}
    a, b = cell.columns[0], cell.columns[1]
    diff = cell[a] - cell[b]
    t = st.ttest_rel(cell[a], cell[b])
    w = st.wilcoxon(cell[a], cell[b]) if (diff != 0).any() else None
    return {"unit": "(family,model)", "n_units": int(len(cell)),
            "carrier_a": str(a), "carrier_b": str(b),
            "mean_a": float(cell[a].mean()), "mean_b": float(cell[b].mean()),
            "mean_drop_a_minus_b": float(diff.mean()), "sd": float(diff.std(ddof=1)),
            "t": float(t.statistic), "p": float(t.pvalue), "df": int(len(cell)-1),
            "wilcoxon_p": (float(w.pvalue) if w is not None else None),
            "ci95": [float(x) for x in st.t.interval(0.95, len(cell)-1,
                       loc=diff.mean(), scale=st.sem(diff))] if len(cell) > 1 else None}

def secondary_vote_mcnemar(d):
    """Declared secondary. Majority-vote each cell to a bit, then McNemar. Lossy by design —
    reported for robustness, never as the primary."""
    v = (d.groupby(["item_id","model","carrier"])["pass"].mean() >= 0.5).unstack("carrier").dropna()
    if v.shape[1] != 2: return {"error": "need exactly 2 carriers"}
    a, b = v.columns[0], v.columns[1]
    b01 = int((~v[a] & v[b]).sum()); b10 = int((v[a] & ~v[b]).sum())
    p = st.binomtest(b10, b01+b10, 0.5).pvalue if (b01+b10) else 1.0
    return {"n_pairs": int(len(v)), "a_only": b10, "b_only": b01, "p": float(p)}

def per_class(d):
    out = {}
    for cls, g in d.groupby("probe_class"):
        cell = g.groupby(["family_id","model","carrier"])["pass"].mean().unstack("carrier").dropna()
        if cell.shape[1] != 2: continue
        a, b = cell.columns[0], cell.columns[1]
        t = st.ttest_rel(cell[a], cell[b])
        out[cls] = {"n_units": int(len(cell)), "mean_a": float(cell[a].mean()),
                    "mean_b": float(cell[b].mean()),
                    "drop": float((cell[a]-cell[b]).mean()), "p": float(t.pvalue)}
    return out

def per_model(d):
    """The capability question section 10.9 actually asks: does the DROP differ by model?"""
    out = {}
    for mdl, g in d.groupby("model"):
        cell = g.groupby(["family_id","carrier"])["pass"].mean().unstack("carrier").dropna()
        if cell.shape[1] != 2: continue
        a, b = cell.columns[0], cell.columns[1]
        t = st.ttest_rel(cell[a], cell[b])
        out[mdl] = {"n_units": int(len(cell)), "baseline": float(cell[a].mean()),
                    "carrier": float(cell[b].mean()), "drop": float((cell[a]-cell[b]).mean()),
                    "p": float(t.pvalue)}
    if len(out) == 2:
        (m1, r1), (m2, r2) = list(out.items())
        out["_interaction_note"] = ("Compare drops directly ONLY with an interaction test on the "
            "paired differences; two separately-significant drops do not establish that they DIFFER.")
    return out

def interaction(d):
    """Does the carrier drop DIFFER between models? Unpaired test on per-family drops."""
    per = {}
    for mdl, g in d.groupby("model"):
        cell = g.groupby(["family_id","carrier"])["pass"].mean().unstack("carrier").dropna()
        if cell.shape[1] == 2:
            per[mdl] = (cell[cell.columns[0]] - cell[cell.columns[1]])
    if len(per) != 2: return {"note": "needs exactly 2 models"}
    (m1, d1), (m2, d2) = list(per.items())
    common = d1.index.intersection(d2.index)
    t = st.ttest_rel(d1.loc[common], d2.loc[common])   # families shared -> paired
    return {"model_a": m1, "model_b": m2, "n_families": int(len(common)),
            "drop_a": float(d1.loc[common].mean()), "drop_b": float(d2.loc[common].mean()),
            "difference": float((d1.loc[common]-d2.loc[common]).mean()),
            "t": float(t.statistic), "p": float(t.pvalue),
            "interpretation": ("A significant interaction is the ONLY result that licenses "
                               "'carrier sensitivity differs by model'. Section 10.9's claim needs THIS, "
                               "not two separate within-model tests.")}

def defect_triage(d):
    """Standing rule: capability-INDEPENDENT failure is a DEFECT signal, not difficulty."""
    r = d.groupby(["item_id","model"])["pass"].mean().unstack("model")
    if r.shape[1] < 2: return {"note": "needs >=2 models"}
    zeros = r.index[(r == 0).all(axis=1)].tolist()
    return {"n_items_failing_ALL_models": len(zeros), "items": zeros[:40],
            "action": "REVIEW KEYS before reporting these as difficulty (2 of 11 probe items had construct defects)"}

def analyse(path):
    d = pd.read_csv(path); d.columns = [c.strip() for c in d.columns]
    stop = gate_integrity(d)
    if stop: return {"BLOCKED": stop}
    if "is_infra_error" in d.columns: d = d[~d.is_infra_error.astype(bool)]
    item_len = {}
    try:
        bank = json.load(open("powered_bank_base.json"))
        bank = bank.get("items", bank) if isinstance(bank, dict) else bank
        item_len = {x["name"]: len(x["prompt_text"]) for x in bank}
    except Exception:
        pass
    res = {"n_rows": int(len(d)), "n_items": int(d.item_id.nunique()),
           "n_families": int(d.family_id.nunique()), "n_models": int(d.model.nunique()),
           "primary_family_clustered": primary_family_clustered(d),
           "secondary_vote_mcnemar": secondary_vote_mcnemar(d),
           "per_class": per_class(d), "per_model": per_model(d),
           "model_interaction": interaction(d), "defect_triage": defect_triage(d)}
    if item_len: res["gate_length_leak"] = gate_length_leak(d, item_len)
    p = res["primary_family_clustered"].get("p")
    drop = res["primary_family_clustered"].get("mean_drop_a_minus_b")
    if p is None:
        res["verdict"] = "ERROR"
    elif p < ALPHA and drop > 0:
        res["verdict"] = "CARRIER_EFFECT_PRESENT"
        res["verdict_reason"] = (f"Carrier reduced accuracy by {drop:.3f} at family level (p={p:.4g}). "
            "Read per_model and model_interaction before attributing this to capability.")
    elif p < ALPHA and drop < 0:
        res["verdict"] = "CARRIER_IMPROVED_ACCURACY"
        res["verdict_reason"] = f"Unexpected direction: carrier arm scored {abs(drop):.3f} HIGHER (p={p:.4g}). Check carrier application before interpreting."
    else:
        res["verdict"] = "NO_RESOLVABLE_CARRIER_EFFECT"
        res["verdict_reason"] = (f"drop={drop:.3f}, p={p:.4g}. At n={res['primary_family_clustered']['n_units']} "
            "family-model units this design resolves d>=0.05 at power ~0.78; a null here does NOT establish immunity below that.")
    return res

def selftest():
    rng = np.random.default_rng(3)
    def synth(n_fam=118, per_fam=2, reps=6, base=0.55, drop=0.0, models=("m_small","m_big"),
              drop_by_model=None, infra=0):
        rows=[]
        for mdl in models:
            dd = drop_by_model.get(mdl, drop) if drop_by_model else drop
            for f in range(n_fam):
                fp = np.clip(rng.normal(base,0.12),0.05,0.95)
                for j in range(per_fam):
                    ip = np.clip(fp+rng.normal(0,0.04),0.03,0.97)
                    for car,pp in [("baseline",ip),("lean",np.clip(ip-dd,0.02,0.98))]:
                        for rep in range(reps):
                            rows.append({"item_id":f"F{f:03d}-{j}","family_id":f"F{f:03d}",
                                "probe_class":"quant-scope" if f%3 else "defeasible","model":mdl,
                                "carrier":car,"rep":rep,"pass":int(rng.random()<pp),
                                "expected_result":"TRUE","is_infra_error":0})
        d=pd.DataFrame(rows)
        if infra: d.loc[d.sample(infra,random_state=1).index,"is_infra_error"]=1
        return d
    ok=True
    d=synth(drop=0.10); d.to_csv("/tmp/_t1.csv",index=False); r=analyse("/tmp/_t1.csv")
    c=r["verdict"]=="CARRIER_EFFECT_PRESENT"; ok&=c
    print(f"  T1 real carrier drop d=0.10   -> {r['verdict']}: {'PASS' if c else 'FAIL'}")
    d=synth(drop=0.0); d.to_csv("/tmp/_t2.csv",index=False); r=analyse("/tmp/_t2.csv")
    c=r["verdict"]=="NO_RESOLVABLE_CARRIER_EFFECT"; ok&=c
    print(f"  T2 null control d=0           -> {r['verdict']}: {'PASS' if c else 'FAIL'}")
    d=synth(drop_by_model={"m_small":0.20,"m_big":0.0}); d.to_csv("/tmp/_t3.csv",index=False); r=analyse("/tmp/_t3.csv")
    c=r["model_interaction"]["p"]<0.05; ok&=c
    print(f"  T3 drop in ONE model only     -> interaction p={r['model_interaction']['p']:.2g}: {'PASS' if c else 'FAIL'}")
    d=synth(drop=0.10, infra=40); d.to_csv("/tmp/_t4.csv",index=False); r=analyse("/tmp/_t4.csv")
    c="BLOCKED" in r; ok&=c
    print(f"  T4 infra errors present       -> {'BLOCKED' if c else 'NOT BLOCKED'}: {'PASS' if c else 'FAIL'}")
    d=synth(drop=0.10); d=d[~((d.carrier=="lean")&(d.item_id=="F000-0"))]
    d.to_csv("/tmp/_t5.csv",index=False); r=analyse("/tmp/_t5.csv")
    c="BLOCKED" in r and any("UNPAIRED" in s for s in r["BLOCKED"]); ok&=c
    print(f"  T5 unpaired cell              -> {'BLOCKED' if c else 'MISSED'}: {'PASS' if c else 'FAIL'}")
    d=synth(drop=0.10); r0=analyse("/tmp/_t1.csv")
    c=r0["primary_family_clustered"]["n_units"]==236  # 118 families x 2 models
    ok&=c
    print(f"  T6 unit is (family,model)     -> n_units={r0['primary_family_clustered']['n_units']} (must be 236): {'PASS' if c else 'FAIL'}")
    print("SELF-TEST:", "ALL PASS" if ok else "FAILURES PRESENT")
    return ok

if __name__=="__main__":
    if len(sys.argv)>1:
        print(json.dumps(analyse(sys.argv[1]), indent=1, default=str))
        r=analyse(sys.argv[1])
        if "BLOCKED" not in r: print("\nVERDICT:", r["verdict"], "\n", r.get("verdict_reason",""))
    else:
        selftest()
