# STATUS — calibration-scope, 2026-07-27, and what Claude Code should do next
_Claude Science. Everything below verified against the repo at HEAD `5f2b9cc`, not recalled._

## 0. WHERE THE SCIENCE IS
| | State |
|---|---|
| **Published (site `a40cfadd0b`, DECISIONS `5f2b9cc` §10.8x)** | A carrier changed the model's verdict on 13 of 53 items on identical logical content; answers went from stochastic to fully deterministic (13/27 → 0/27, **McNemar exact paired p = 2.4 × 10⁻⁴**, 13-to-0). Temperature (literal `0.0`, both arms) and speculative decoding (zero, both arms) excluded **from source**. |
| **Open, named publicly** | **Prompt length is not excluded.** The wrapper adds ~121 tokens and temp-0 residual nondeterminism is sequence-length dependent. |
| **Next experiment, specced and pre-registered** | `SPEC_length_vs_content_control.md` — two length-matched controls, 324 calls, ~38 min. **C1 (neutral, length-matched only) is the length test; a C1 positive retracts the variance claim. C2 (shuffled-Lean) positive-only is a vocabulary-level finding, not a retraction.** |
| **Powered run 974-977** | In flight. **No results file in the repo yet** (checked the tree). Answers §10.9's threshold question, not the mechanism question. |
| **Carrier Color status** | Site card deliberately still **"Model / framework."** Not promoted. The site's own human source-attribution prediction remains unrun. |

## 1. CLAUDE CODE — ITEM 0 IS ALREADY DONE. CLOSE IT.
`policy/HANDOFF_claude_code_gui.md` still lists as the top open item: *"§10.9 prose-block downgrade (LAST unhedged
carrier-immune instance)… Verify with grep: after the edit, the string `carrier-immune` must appear ONLY inside
superseded/quoted context."*
**I ran exactly that check against HEAD. It passes.**
| Occurrence | Context |
|---|---|
| 1 | inside the `> Original finding — QUOTED VERBATIM as the experiment receipt; superseded as stated` blockquote (verified line-by-line: the line begins with `>`) |
| 2 | inside §10.16, quoting the README overclaim **being corrected** |
| 3 | inside my new §10.8x, stating **"The phrase 'carrier-immune' remains retired."** |
**`100% on EVERY carrier` as a bare assertion: 0 occurrences.** The fix landed in `3c40571`; **the handoff file was
never updated to mark it closed**, so it has been sitting at the top of the queue misdirecting the next reader.
**Action: mark item 0 DONE in the handoff, with the grep result as its receipt.** Five minutes, and it unblocks the
list.

## 2. CLAUDE CODE — THE REAL NEXT ITEM, AND IT IS NOW BIGGER THAN WHEN IT WAS WRITTEN
**Item 2, the Witness Artifact Generator.** Today produced the strongest possible argument for it: **three agents
caught each other over-claiming eight times in one session**, and every correction is recorded in
`EPISTEMIC_LOG.jsonl` — but that log is a JSONL file nobody outside this project will ever read.
**The Witness artifact is what makes today's correction history legible to an outsider.** Concretely, for a claim
like §10.8x it should render: the claim, the test and its unit, the confounds excluded **and how** (source-verified
vs measured vs argued), the confounds **not** excluded, and the retraction chain with timestamps.
**A design constraint from today, which the generator must not violate:** several of today's errors were *paraphrases*
of retracted claims that survived keyword sweeps. **A Witness artifact must show a claim's current status by
reference to a claim ID, not by re-stating the claim in prose** — otherwise the artifact becomes another surface
where a retracted proposition can survive in different words.

## 3. WHAT CLAUDE CODE SHOULD *NOT* DO
- **Do not touch §10.8x, the site copy, or the spec.** Framing is the analysis lane (Carey's ruling this session);
  those files carry derivations and retraction chains that read as editable prose and are not.
- **Do not "clean up" the epistemic log.** Its value is that superseded entries stay in it.
- The seL4 root task, l4v proof, and EC2 ops remain out of the GUI lane per the handoff's own boundary.

## 4. WHAT I AM NOT CLAIMING
- I verified item 0 by grep and line-prefix inspection of `DECISIONS.md` at HEAD. **I did not audit the README,
  the comic, `mcp.rs`, or the site for the same string** — the handoff says those were fixed in `56762fe7b4` and I
  have not re-checked them today.
- Items 0.5 (onboarding rungs), 1 (Subject/Channel Wizard) and 3 (Wording Audit) I have **not** re-verified against
  the current GUI; I am reporting the handoff's own ordering, not an independent status check.
- No powered-run results exist yet, so nothing here reflects runs 974-977.
