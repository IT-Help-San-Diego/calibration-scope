# The abuse question, answered on Carey's rule: best practices, educational exploration allowed
_Claude Science, 2026-07-29. Carey: "call out assholes who would try to abuse this to prove their
girlfriend's stupid… all you're going to do is not get a great answer yourself."_

## The self-defeating argument is TRUE and it is NOT the whole answer

Carey's read is right about the numbers: garbage in produces a number about the setup, not the
subject, and the person learns nothing. **For every abuse case that ends at a bad number, that is
the complete answer and no policy is needed.**

**The girlfriend case does not end at a bad number, and I checked why.** Three findings from the
source, in order of how much they matter:

1. **`participants.display_name` is `TEXT NOT NULL`.** A real name is *required* to run a human
   trial. There is no consent field, no anonymization, no pseudonym option — zero matches for
   `consent`, `anonym`, `pseudonym`, `initials` in migration 043.
2. **Human runs get a witness certificate.** `witness.rs`: *"Human-participant runs (model_id
   NULL, participant_id set) now get a certificate too."* It carries the participant field.
3. **That certificate is designed to travel.** Its own header: a self-contained HTML file, zero
   JS, no external resources, so it *"renders identically under any CSP, from `file://`, or
   **pasted into a mail**."*

**So the instrument will hand someone a sealed, self-verifying, mailable certificate with their
girlfriend's name on it and a failing score.** The seal is the problem, not the score — a bad
number is forgettable, and **a bad number with a SHA-3 hash and a golden-ratio certificate looks
like a finding.** The cryptography was built to make verdicts trustworthy; against a named human
subject it makes an insult look authoritative.

**This is the same asymmetry as Tango, pointed at a person.** Tango manufactures a false positive
about a dog. This manufactures a *credentialed* false negative about someone who never agreed to
be measured.

## The answer, on Carey's rule

**"Get good best practices, educational exploration allowed"** resolves this cleanly, and it does
not require a code of conduct, a moralizing paragraph, or gating anything.

**Educational exploration is allowed — including on people.** Human calibration is real science
and already runs; the four conditions already tell users when a score is meaningful. Nothing here
should discourage someone from testing themselves, their study group, or a willing friend.

**The best practice is a schema property, not a request.** Three changes, all cheap, all in the
same spirit as `is_infra_error`:

1. **`participants.consented BOOLEAN NOT NULL DEFAULT false`**, and **the witness certificate
   refuses to render a name when it is false** — it renders `participant #7` instead. The run
   still happens, the data still counts, the science is unaffected. What you cannot get is a
   *sealed document with an unconsenting person's name on it.* That is a one-line refusal in
   `witness.rs`, not a policy.
2. **Make anonymous the default path.** `display_name` should accept `anon-<n>` without friction
   so the honest choice is the easy one.
3. **State on the certificate what the seal attests.** The seal proves *this run produced this
   result on this instrument* — it does **not** attest that the test was valid, the subject
   consented, or the grader was blind. **A certificate that does not say what it certifies is
   exactly the gap between stated and true that this project measures.** This is the one I would
   do first: it costs a text line and it defuses the entire abuse class, because a certificate
   that says *"attests execution, not validity"* is useless as an insult.

## Why this is better than a conduct policy

A conduct policy asks people to behave. **A schema that will not seal a non-consenting name
does not need them to.** And item 3 is not even a restriction — it is an accuracy fix we would
want regardless, because right now a reader of that certificate will infer more than the seal
supports, and *that inference is our error, not theirs.*

## What I have NOT established

- **I have not seen a rendered certificate.** Whether `display_name` appears as a visible label
  is read from `witness.rs`'s `participant: Option<String>` and its `is_human` branch, not from
  output. **Check a real certificate before acting on point 1.**
- I have not checked whether the first-run UI already prompts for consent in a way the schema
  does not record. If it does, that is undocumented in the schema, which is its own defect.
- The `consented` column and the render-refusal are **my proposals.** Nothing on the board covers
  them; the closest cards are CS-042 (scorer blinding) and CS-043 (transcripts), and neither
  touches consent.
- Whether a name in a *local-only* database matters is arguable. **The certificate is the reason
  it does** — it is explicitly built to leave the machine.
