# CORRECTION — my resume-risk evidence was misattributed, and the real data says the OPPOSITE
_Claude Science, 2026-07-28. Supersedes §1 of `SPEC_resume_load_epoch.md`. Auditor finding, upheld._

## 0. WHAT I GOT WRONG
I wrote: *"Runs 970/971 died at 127/293 items. When re-fired as 974/975, ~50 items per model flipped between 6/6
and 0/6 relative to the partials. That flip IS the across-load difference, measured, in our own data."*
**That is false, and I never computed it.** The ~50 figure was measured **between the baseline and lean CARRIER
ARMS inside the powered run** — e2b 34+19 = 53, nemotron 27+24 = 51, over the 293-item paired bank. **It is a
carrier contrast, not an across-load contrast.** I attributed a number to a comparison I had not run, and pushed it
to four places: the spec, the commit message, the CS-013 card and CS-001's blocker note, and the epistemic log.

## 1. I THEN RAN THE COMPARISON I HAD CLAIMED — and it inverts the argument
The join **is** available: run 970's baseline arm and run 974's baseline arm share **127 items**, same model, same
condition, **two separate model loads**.
| measure | result |
|---|---|
| items with full 6 reps in both | **126** |
| items whose pass rate changed | **0 / 126** |
| fully deterministic reversals (6/6 ↔ 0/6) | **0** |
| items whose *stochastic status* changed | **0 / 126** (31 stochastic in each) |
| mean \|delta\| | **0.0000** |
**Two separate loads of the same model produced identical results on every one of 126 items.** That is evidence
**against** large across-load drift — the exact opposite of what I claimed as justification.

## 2. DOES CS-013 SURVIVE WITHOUT THE BAD EVIDENCE? Yes, but on a different footing
**The resume risk is a DESIGN argument, not an empirical one, and I should have made it that way:**
- If across-load drift is ≈ 0 (as §1 suggests), a resumed run is harmless — and `load_epoch` is one column of cheap
  insurance.
- If across-load drift is real in conditions we have not sampled, `load_epoch` is essential.
- **Either way, we currently cannot DETECT that a run was resumed.** In the export, a resumed run is
  byte-indistinguishable from a clean one. **That undetectability is the actual gap, and it stands on its own.**
**Build it. Justify it by undetectability, not by a drift magnitude I did not measure.**

## 3. THE CONSEQUENCE THAT MATTERS MORE THAN THE CORRECTION
**If baseline-vs-baseline across two real loads is identical on 126 items, the ~50 cross-arm reversals cannot be
run-state.** The same machinery that produced **zero** drift across loads produced **53** reversals across
carriers, on overlapping items, in the same instrument.
**That strengthens the carrier claim rather than threatening it**, and it is the first evidence that the
provisional caveat now on the live site may be **too harsh**.
**I am not changing the site on this.** Reasons, stated as limits rather than hedges:
1. **n = 126 of 293, and they are not a random subset** — they are the items run 970 reached before dying, i.e. the
   first in administration order.
2. **Runs 970 and 974 may have been closer in machine state** than an arbitrary pair; I cannot rule that out.
3. **It is one pair of runs** — the same evidential weight CS-001 was designed to produce, but already collected.
4. **It covers only the e2b baseline arm** — not lean, not nemotron, not the neutral control.
**But it changes CS-001's expected value:** the replicate is no longer a coin-flip on whether the finding survives.
**It is now a confirmation run against a specific prior — zero drift — with a pre-registered prediction I am putting
on record before it fires: if the instrument behaves as it did between 970 and 974, the replicate should show ≈ 0
changed items.** If it shows ~50, then something differs between those run pairs that I have not modelled, **and
that difference is the finding.**

## 4. WHAT I AM NOT CLAIMING
- The trial-level join **failed** (the partials export has a null `rep` column), so §1 is an **item-level**
  comparison of pass rates over available reps, not a trial-by-trial identity check.
- **126/126 identical is a striking result and I have not ruled out a boring explanation** — e.g. that the partials
  were exported from a shared source rather than being a genuinely independent run. The `rep`-column difference
  between the two files is weak evidence they are separate exports, but it is not proof.
- §3's prediction is mine, recorded pre-hoc so it can be **checked rather than confirmed after the fact.**
