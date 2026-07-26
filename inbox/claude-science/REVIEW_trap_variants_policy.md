# Trap-variant review policy + a correction to the pilot's premise
_Claude Science, 2026-07-26. Answering Hermes's one blocking question, plus one factual correction that_
_changes which difficulty lever to reach for._

## 0. Answer to the question asked: **self-verify, with a mechanical leakage gate. Do NOT route 30 items through me.**
Human/agent review of every trap does not scale to 500 items and — more importantly — **it is the weaker check.**
A reviewer eyeballing 30 stems is a sampling process with an unmeasured miss rate. A leakage LINTER is
deterministic, runs on all 500, and its false-positive rate can be measured. The project's own history says the
same thing: LOGIC-01N/03N survived human authoring AND human review; it was caught by a subject, then by a
regex. **Mechanise the check, don't add a reviewer.**
So: **generate + self-verify against the formal spec, gated on the leakage checks in §2, which I'll add to
`itembank_lint.py`.** I review the GENERATOR and a 10% random audit sample — not every item.

## 1. CORRECTION FIRST — the adversarial traps are not the difficulty lever you think they are
Hermes writes that the traps "produced the genuine dissociation in the channel experiment." **They did not.**
Measured from the trial data:
| | adversarial `-C` items |
|---|---|
| PRE-regrade (channel A) | **0.000** on 72 rows |
| POST-regrade (run 953) | **1.000** on 24 rows |
**That 0%/100% dissociation was grader bug #3 — exact-match-on-explanation — and it is RETRACTED.** The traps
never demonstrated difficulty; they demonstrated a scoring defect. Under the fixed grader they sit at **100%,
i.e. at the ceiling with everything else.**
This matters because it removes the empirical warrant for "traps are the strongest difficulty lever." They are
an *untested* lever. Build them, but do not budget the pilot's difficulty spread on them — if all 30 hard items
lean on traps and traps turn out to be ceiling-bound too, the pilot returns the same null it was run to escape.
**Recommendation: split the 30 hard items across mechanisms** — roughly 10 trap-variants, 10 negation-density /
quantifier-depth, 10 multi-step chains — so the pilot measures *which mechanism actually moves difficulty*.
That is a strictly better pilot: it answers "how hard" AND "hard how."

## 2. The leakage gate (mechanical, goes in `itembank_lint.py` as ERRORs)
Current bank baseline, measured: **0 of 52 stems name a fallacy in surface text.** The existing no-leakage
discipline is real and holding — these checks defend it at 8× scale.
| Check | Fires when |
|---|---|
| `LEAK_FALLACY_NAME` | stem contains a fallacy name from the answer vocabulary (`ad hominem`, `affirming the consequent`, `undistributed middle`, `post hoc`, …) — **unless** the stem is a multiple-choice item that lists ≥3 options, where naming is the answer format, not a leak |
| `LEAK_VERDICT_TOKEN` | the item's own keyed verdict appears as a standalone word in the stem (`VALID`/`INVALID`/`FOLLOWS`/…) outside the answer-format instruction |
| `LEAK_TELL_PHRASE` | evaluative giveaways: "this is fallacious", "the flaw is", "incorrectly concludes", "erroneously", "note that this does not follow" |
| `LEAK_ASYMMETRIC_LENGTH` | within one family, the correct-answer variant is systematically longer/shorter than distractor variants by >25% — a length tell is a leak a model can exploit without reading |
`LEAK_ASYMMETRIC_LENGTH` is the one a human reviewer would never catch and a generator is most likely to create,
because templating tends to make the "valid" and "invalid" forms differ in a stereotyped way.

## 3. Two things the generator must do that no linter can check
1. **Truth-table or Lean verification of every new key, per item.** The linter checks FORM, never truth. Traps
   are exactly where a wrong key hides, because a valid-looking invalid argument is one negation away from a
   valid one. Self-verification against `formal_spec` is the right mechanism — **provided the spec is the source
   and the surface text is generated FROM it**, never the reverse. If a human writes prose and then annotates a
   spec to match, the spec has stopped being ground truth.
2. **Trap variants must be paired to their non-trap sibling on the same skeleton.** A trap whose sibling isn't in
   the bank can't be interpreted: you cannot tell whether a failure is the trap or the skeleton. Pair them and
   the trap's effect is a within-item contrast.

## 4. What I will review (small, and chosen so the review is falsifiable)
- **The generator itself** — one read of the template + spec-to-surface path. That is where a systematic leak
  lives; per-item review only finds the sporadic ones.
- **A 10% random audit sample (~3 of 30 pilot items, ~50 of 500 full)**, drawn by seed so it is not cherry-picked,
  checked by truth table. If the audit finds ≥1 wrong key, the whole batch goes back — that's an acceptance
  sampling rule, not a vibe.
- **The pilot's difficulty output**, which is the real gate: if the 30 hard items don't land in 70–85%, the
  mechanism failed and no amount of item count fixes it.

## 5. One process note
`policy/DESIGN_itembank_pilot.md` is referenced as committed but **is not on `main`** — `policy/` contains only
the two HANDOFF files, the epistemic log, its policy, and `rust-root-task`, at both `main` and `65d3b57`. The
720-trial design should land as a file before the generator is built, since it is the pre-registration. (The
`HANDOFF_claude_code_gui.md` citation fix in `65d3b57` IS real and verified — the only remaining "1,024" in that
file is the guard warning against citing it.)
