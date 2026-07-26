# Prompt provenance — self-report is necessary and NOT sufficient
_Claude Science, 2026-07-26. Written from Carey's realization that subjects' system prompts must be declared._
_Grounded in the repo's own migration history, read first-hand from ~/Documents/GitHub/calibration-scope._

## 0. THE REALIZATION IS RIGHT, AND THE PROJECT ALREADY HAS THE SCAR
Carey: *"We need the user to be honest with us about what their system prompts are in each of the systems we are
testing."* Correct — and the repo proves the stakes, because **this failure already happened here.**
`migrations/046_quarantine_leaked_scaffold_runs.sql`, verbatim from the file:
> *"scaffolded runs (load_mode = 'scaffolded') with a non-empty scaffold_supplement had each test's formal_spec
> appended to the model's system prompt. The formal_spec IS the ground-truth answer … those runs were handed an
> answer key — their scores are not honest capability measurements."*
**Every sealed scaffolded run predating the fix was quarantined.** An extra system-prompt layer silently converted
a capability test into an open-book exam.
**And here is why self-report alone would not have saved us: nobody lied.** No user misreported anything. The
harness did it, unconditionally, in code. `answer_leak_contamination` is one of only two quarantine reasons in the
entire schema — and it is a *prompt-layer* contamination. That is the empirical case for treating prompt
provenance as a measured variable rather than a declared one.

## 1. WHAT THE SCHEMA CAN AND CANNOT RECORD (verified, not assumed)
| Field | Exists? | What it captures |
|---|---|---|
| `test_runs.scaffold_supplement` | **YES** (mig 029) | the supplement **WE** inject |
| `test_runs.load_mode` | **YES** (mig 030) | `clean-room` / `scaffolded` |
| `tests.fallacy_tag` | **YES** (mig 029) | targeted fallacy |
| **subject's own system prompt** | **NO** | — |
| **`channel`** | **NO** — grep finds it in zero migrations | (Claude Code's flag confirmed) |
**So the schema records the layer we add and is blind to the layers the subject already carries.** For API runs
that is fine — we author the whole prompt. For manual-chat runs the subject arrives wearing a **vendor system
prompt we cannot see** and possibly **user custom instructions**, and none of it is recorded anywhere.

## 2. WHY SELF-REPORT IS NECESSARY BUT NOT SUFFICIENT
Necessary: without a declaration there is not even a claim to audit. Insufficient, for four reasons — none of
which require anyone to lie:
1. **Vendor prompts are unpublished and change without notice.** A subject in a chat UI cannot report what it was
   not told. This is the §10.14 confound, still open.
2. **Users do not know their own stack.** Custom instructions, memory features, retrieved context, and per-thread
   preambles all layer in. Earlier this session Carey's own bot silently auto-loaded a different model than the one
   selected — a stack surprise, not dishonesty.
3. **The harness is a layer too**, and it is the one that already contaminated us.
4. **A declaration is a claim about a hidden state, and this project's rule is that such claims get verified.**
   We do not accept `status: PASS` from a file; we should not accept `system_prompt: none` from a form.

## 3. THE FIX — declare it, hash it, AND detect it
### 3a. Declare (schema, Hermes's lane)
Add to `test_runs`:
- `subject_prompt_declared text` — verbatim, when the operator can supply it
- `subject_prompt_sha256 text` — hash, so drift between administrations is detectable even if text is withheld
- `subject_prompt_source text` — enum: `authored_by_us` | `operator_declared` | `vendor_unknown` | `undeclared`
- `channel text` — the missing column, since channel and prompt-layering are entangled
**`vendor_unknown` and `undeclared` are first-class values, not failures.** A run honestly marked
`vendor_unknown` is usable with a stated caveat; a run marked `none` that had a hidden layer is corrupt. The
enum's job is to make the *unknown* auditable rather than to pretend it away.
### 3b. Detect (my lane — this is the part self-report cannot do)
Two mechanical detectors, both computable with data we already collect:
- **Token/latency signature.** From `SPEC_reconciliation_cost.md`: an extra instruction layer costs completion
  tokens even when accuracy is unchanged. A run declared single-layer whose token distribution matches the
  layered arms is **evidence of an undeclared layer.** This turns the reconciliation-cost experiment into a
  *calibration of the detector*, which is a second reason to run it.
- **Behavioural canary items.** A small fixed set whose response is known to differ under a system prompt
  (e.g. an item that asks for a bare token — an unprompted model complies, a scaffolded one adds preamble).
  Administer with every run. Divergence from the declared condition flags the run for audit.
### 3c. Refuse, don't guess
Extend the quarantine vocabulary with `prompt_provenance_unknown`. Precedent exists: the schema already
quarantines rather than deletes, and `answer_leak_contamination` shows the mechanism works.

## 4. THE HARDER PROBLEM CAREY JUST NAMED — and the signature that separates it
Carey: *"That's also me taking a test about to fail it because I disagree with the logical choices and the
question itself. I know damn well the answer if the test maker hadn't fucked up the logic."*
**This project has a recorded instance.** LOGIC-03N: the item said "revokes a key **precisely when** reported
compromised" — a biconditional marker — and was keyed as a one-directional conditional. Replit answered
**correctly for the item as worded** and was **scored as a miss** until adjudicated. Sibling item LOGIC-01N used
"exactly when" and *was* keyed as a biconditional: same marker, opposite keys. **Verified by truth table, both
readings, at the time.**
That is Carey's experience exactly: a right answer scored wrong because the instrument was broken.
**The discriminating signature, and it is computable:**
| | stronger model | weaker model |
|---|---|---|
| **genuinely hard item** | better | worse |
| **defective item** | ~equally wrong | ~equally wrong |
Capability does not help you answer a question whose key is wrong. **Checked on the pilot:** all four varying
items show the *capability* signature (e2b 0.50–0.92, nemotron 1.00) — no defect signature present. But only 4 of
64 items varied at all, so that test is near-powerless; it is worth having as a standing check, not as evidence.
**Standing rule proposed:** any item where models of clearly different capability fail at statistically
indistinguishable rates is **flagged for key review before it counts as difficulty.** That is the automated
version of what Replit did by hand, and per the log it is the only defect class in this project ever caught by a
*subject* rather than by an author.

## 5. THE DEEPER POINT, STATED ONCE
An instrument that cannot tell *"the subject is wrong"* from *"the question is wrong"* will publish the second as
the first, every time, and the more capable the subject the more likely it is the instrument at fault. Carey's
insight is that **the subject's disagreement is data**, not noise. The mechanisms above are how it becomes data:
declare the layers, hash them, detect the undeclared ones, and treat capability-independent failure as a defect
signal rather than a difficulty measurement.
