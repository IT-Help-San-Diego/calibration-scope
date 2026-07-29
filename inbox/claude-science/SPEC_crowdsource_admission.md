# The SHA-3 seal does NOT survive crowdsourcing — and Carey's own complaint is the reason
_Claude Science, 2026-07-29. On the future shared database, and what a seal actually proves._

## Carey's point about download-page SHA badges applies to OUR run seals

> *"just because you find a website that gives you something to download that has one of these
> cute clever SHA seals… doesn't mean you didn't just download a hack."*

**That is exactly right, and it lands on us the moment data leaves the machine that produced it.**
There are two different things in this repo both called sealing, and only one of them survives
travelling:

| | who signs | what it proves | survives submission to a pool? |
|---|---|---|---|
| **build attestation** (`release.yml`, `actions/attest@v4`) | **GitHub OIDC — a third party** | this binary was built from this commit by this workflow | **YES** |
| **run seal** (`sha3_provenance`, per run) | **the submitter's own install** | these bytes have not changed since the submitter sealed them | **NO** |

**The run seal is self-attestation.** The submitter controls the run *and* the hash. It detects
later tampering by someone else; it cannot detect a fabricated run, a mis-graded answer, or a
hand-typed transcript. **A pool that accepts runs because they carry a SHA-3 seal is doing the
exact thing Carey is mocking.**

**This retires something I said one message ago.** I called the certificate's seal the mechanism
that makes an insult look authoritative. True — and the deeper reason is that *the seal never
attested method in the first place.* CS-046 (state what the seal attests) is therefore not a
politeness fix. **It is the precondition for crowdsourcing.**

## What CAN be checked without trusting the submitter — three of eight elements

| element | independently checkable | why |
|---|---|---|
| **stimulus hash** (`attachment_sha3`, SHA3-pinned battery) | **YES** | we hold the canonical hashes; a mismatch proves the question was swapped |
| **binary identity** (GitHub attestation) | **YES** | third-party signature; proves which build ran |
| **logical ground truth** (truth tables, finite model search) | **YES** | re-derivable from `formal_spec` by anyone — needs no trust at all |
| N=3 rep structure | partly | internally checkable, fabricable wholesale |
| the subject's actual answers | **NO** | nobody else saw the wire |
| who graded, and whether blind | **NO** | no `scored_by` column exists (CS-042) |
| subject consent | **NO** | no consent field exists (CS-047) |
| the run seal | **NO** | submitter controls run *and* seal |

**The three that verify are the three that matter for junk-filtering:** *was the question ours,
was the binary ours, is the key actually right.* That is a real admission gate and it needs no
trust in the submitter's honesty.

## The admission gate — Carey's rule, mechanized

He is right that publishing is hard and that not following directions should cost you admission.
**The way to do that without a review board is to make every criterion machine-checkable**, so
rejection is never a judgement about a person:

**HARD REJECT (mechanical, no human):**
1. stimulus hash not in the canonical set → **the question was altered**
2. binary not attested, or a build we never released → **unknown instrument**
3. `formal_spec` present and the recorded key contradicts the decision procedure → **wrong key**
4. trial/rep counts internally inconsistent → **structurally broken**

**ACCEPTED BUT QUARANTINED — visible, not pooled:**
5. any human-subject run without `scored_by` **distinct from** the administrator (CS-042)
6. any hand-administered run without a verbatim transcript (CS-043)
7. any run whose subject failed a precondition — no interface, undecodable, out-of-domain

**Quarantine rather than reject is the whole design.** A rock run is not fraud; it is a valid
observation about the *instrument*. It belongs in the record, flagged, where it teaches. Rejecting
it would throw away the data that produced four board cards today.

## What this means for the DNS tool feeding a database

Same gate, and one addition: **a submission must name its subject's substrate class** — model,
human, pipeline (Siri), instrumented sensor (DNS). Because `is_infra_error` cannot express *"a
different component answered than the one we meant to test,"* and a DNS-fed pipeline is the case
where that happens by default.

## What I have NOT established

- **No crowdsource design exists in the repo.** I searched every text file for
  crowdsource/submission/contribution/federation language; the hits are release plumbing and my
  own memos. This is a greenfield proposal, not an audit of an existing plan.
- I verified `attachment_sha3` and `sha3_provenance` exist in `executor/mod.rs` and `witness.rs`
  and that `release.yml` runs `actions/attest@v4`. **I did not verify a stimulus-hash mismatch is
  actually detected at run time** — that the column exists is not proof the check fires. Same
  distinction as `is_infra_error`, which has never been observed firing (CS-005).
- The admission gate is **my proposal**. Nothing on the board covers it.
