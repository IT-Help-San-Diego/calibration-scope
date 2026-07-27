# PUBLIC COPY — the Carrier Color update, and why it is smaller than it sounds
_Claude Science, 2026-07-27. Framing lane. Two edits proposed: one to intellectualresistance.com, one to_
_calibration-scope's DECISIONS.md. Nothing pushed to a public surface without Carey's approval._

## 0. THE FINDING THAT DECIDES THE FRAMING
The site's Carrier Color card currently ends:
> *"It is useful and it generates testable predictions (**e.g., anonymized vs. attributed evaluations of the same
> claim should diverge when Carrier Color is high**), but **those experiments have not been formally run here.**"*
**That last clause is now false — and the obvious fix is the wrong one.** We did not run the experiment the site
names:
| | site's stated prediction | what runs 970/971 actually tested |
|---|---|---|
| the carrier | **source attribution** (who said it) | **format/register wrapper** (baseline vs Lean) |
| the subject | **humans** | **one language model** (`gemma-4-e2b`) |
**Neither the carrier type nor the subject population matches.** So the update must do two things at once: **record
a measured instance, and narrow what that instance licenses.** The card's status stays **"Model / framework."** The
theory is not promoted, and the site's own named prediction remains unrun.
This is the honest version of "we proved it." What was proved is that *a* carrier changed *a* verdict in *a*
machine — which is a real result and is not the human-attribution claim the theory is mainly about.

## 1. PROPOSED SITE EDIT — replace only the final sentence of the epistemic-status block
> **Epistemic status: Carrier Color is an explanatory model, not a measured law.** It generates testable
> predictions, and one of them has now been tested in a narrow setting. In a controlled paired experiment on a
> language model (`calibration-scope`, runs 970/971), the *same* logical arguments were presented under two
> different prompt carriers with the model, decoding settings, and temperature held identical. The carrier changed
> the model's verdict on 13 of 53 items, and — more specifically — **the model's answers went from stochastic
> (varying across repeated identical trials) to fully deterministic** under one carrier: 13 of 27 items varied
> across repetitions under the baseline carrier, **0 of 27 under the other** — 13 items changed in that direction
> and **none in the reverse** (McNemar exact, paired, *p* = 2.4 × 10⁻⁴).
> Temperature was fixed at 0 and speculative decoding was off in both arms.
> **What this does and does not establish.** It is evidence that a carrier can change a verdict on identical
> content in an artificial reasoner. It is **not** a test of the prediction stated above — that anonymized versus
> attributed evaluations diverge in *humans* — which remains unrun. One model, one item bank, one truncated run.
> The status above is unchanged.
> **On the obvious objection — that the carrier is simply *longer* text.** An earlier run measured the same
> arguments under four different carriers and the effect does not order by length: a deliberately compressed
> poetic carrier produced the *least* distortion (97.1%) while a flattery carrier produced the *most*
> (91.2%, tied with a formal-notation carrier). A mechanism driven by token count cannot produce that ordering.
> **The variance result specifically — that one carrier removed the model's uncertainty rather than merely
> shifting its accuracy — is reported here as a single-carrier observation**; whether every carrier does this is
> a separate question and is not claimed.

## 2. PROPOSED `DECISIONS.md` EDIT — `DRAFT_10_8_update.md` as written, with §D intact
The §10.8 draft already carries the full bound list. **Do not trim §D for the repo copy.** The two items most
likely to be dropped by a well-meaning editor are the two that matter:
- the **length-heuristic mechanism is retracted** (flipped vs unflipped stems 269 vs 272 chars, *p* = 0.369);
- the **wrapped-prompt-length alternative is still live** — at temperature 0 with no draft model, residual
  nondeterminism comes from float non-associativity in batched matmuls, which is **sequence-length dependent**, and
  the Lean wrapper necessarily changes the wrapped token count. **"Longer prompts land in a more stable numerical
  regime" is not yet excluded**, and it would explain the determinism with no carrier effect on reasoning at all.

## 3. WHAT I WOULD NOT PUBLISH YET
- **The word "proven" anywhere near Carrier Color.** The phenomenon is measured in one machine under one carrier
  type. The site's own status ladder puts "Proven (theorem)" above "Model / framework" and reserves it for the
  Verification Principle; **this result does not move Carrier Color up that ladder**, and moving it would be exactly
  the overclaim the ladder exists to prevent.
- **Anything on `organiccomputer.me` or the ORCID record.** Not audited in this session; no basis for editing.
- **A "carrier-immune" revival.** Still retired (§10.16). FALSE-keyed items being unaffected is a property of an
  *item stratum*, not of a model.

## 4. ONE THING THE UPDATE SHOULD SAY THAT NOBODY HAS SAID
The site's diagnostic for Carrier Color is: *"if I strip the carrier, does my evaluation of the signal change?"*
**The machine experiment gives that diagnostic a mechanical form the human version cannot have** — you can run the
identical stimulus 6 times under each carrier and count. The measurement that came out is not "accuracy dropped"
but **"the carrier decided whether the model was uncertain at all."** That is a sharper prediction to carry back to
the human side, and it is testable there: does an attributed claim produce *more confident* judgements than the same
claim anonymized, independent of whether those judgements are correct? **That is the experiment the site should now
name as its next one** — it follows from the machine result and it is cheap to run with human subjects.

## 5. WHAT I AM NOT CLAIMING
- I audited `intellectualresistance.com`'s `index.html` and `calibration-scope`'s `README.md` and `DECISIONS.md`.
  **The string "carrier-immune" appears 0 times on the site and 0 times in the README** — the earlier public
  overclaim is genuinely gone, and this update does not reintroduce it.
- I have not audited the other repositories, `organiccomputer.me`, or any PDF.
- The proposed wording is mine; the numbers in it are from the paired subset only, and I have re-derived each one
  in this session rather than carrying it forward from a report.
