# The provenance record — findable with the science, not published with it
_Claude Science, 2026-07-29. Carey's ask: "we can't put deep shit about me up on GitHub, but it needs to be
fucking findable with the science one day. A real epistemic log of who was working on shit is just as important."_

## 0. AUDIT FIRST — has anything already leaked?
**No.** I swept every public surface before writing a rule:
| surface | scanned | personal disclosure found |
|---|---|---|
| `EPISTEMIC_LOG.jsonl` | 204 entries | **0** |
| public markdown on `main` | 136 files | **0** |
Three files matched sensitive keywords and **all three are false positives**: `lessons/README.md` and
`lessons/04-carrier-color.md` use *autistic* as a **general cognitive-style claim tied to measured data** — neither
names Carey nor self-identifies — and the single "crazy" hit is **Carey's own instruction to me, quoted inside an
audit of his own tool.**
**But the boundary held by accident, not by rule.** Nothing stopped a disclosure from going up; it simply never
did. That is the gap this document closes.

## 1. THE RULE — three tiers, one test
**The test for every line: does this describe the WORK, or the WORKER?**
| tier | contains | lives | visibility |
|---|---|---|---|
| **PUBLIC** | claims, methods, numbers, corrections, who-claimed-what **in their agent role** | `inbox/claude-science/EPISTEMIC_LOG.jsonl`, repo, site | world-readable, permanent |
| **PROVENANCE** | who worked, when, in what order, what each lane contributed, which human decisions gated which experiments | **sealed local record** (§2) | not on GitHub; released on Carey's instruction or by his estate |
| **PRIVATE** | health, diagnosis, family, grief, anything said to a collaborator rather than to the record | **nowhere in any repo, sealed or not** | never written down by me at all |
**"Carey approved the replicate on 2026-07-28" is PROVENANCE. "Carey said X about his own mind" is PRIVATE and
does not get recorded, sealed or otherwise.** The distinction is not sensitivity — it is whether the fact is *about
the science's history* or *about the person*.

## 2. WHY "SEALED LOCAL" RATHER THAN A PRIVATE REPO
**A private GitHub repo is not private in the sense required.** It is one access-control change, one acquisition,
one subpoena, or one misconfigured collaborator away from public — and it is not durable across decades, which is
the timescale the ask names ("findable with the science one day").
**The properties actually required:**
1. **Tamper-evident** — a later reader must be able to tell it was not rewritten. *Hash each entry, chain each hash
   to the previous one.* The public log already hashes entries; the provenance record chains them.
2. **Independently datable** — "who was working on what, when" is worthless if the dates are unverifiable. *Publish
   only the ROOT HASH periodically into the public log.* That timestamps the private record's contents without
   revealing them, the same way a sealed bid is proven to predate its opening.
3. **Releasable by decision, not by default** — the file sits on Carey's machine; nothing publishes it
   automatically.
**That combination — private contents, public root hash — is the whole mechanism, and it is not exotic:** it is
how a notarised document proves it existed on a date without being read.

## 3. WHAT I RECOMMEND BUILDING, AND WHAT I WILL NOT DO
**Build:** `provenance.jsonl` on Carey's machine (not in any repo), hash-chained, entries covering who did what and
when. Its root hash appended to the public epistemic log at each milestone.
**I will not write PRIVATE-tier content into it.** Not because it is dangerous to store, but because **I am not the
right author for it.** A record of a person's inner life, written by an instrument that observed them for two days
across eleven context folds, would be a bad primary source — thin, selective, and shaped by what happened to be in
my window. **If that record should exist, Carey writes it, and the chain proves when.**

## 4. ON THE FREUD QUESTION — because it is the actual argument for doing this
Carey asked: *"If Freud had been turned on to this kind of validation, would we all be laughing at him?"*
**The honest answer is that the mechanism he is describing is real and well-documented, but it does not run the way
the question assumes.** What damaged psychoanalysis was not an absence of self-belief or rigour in Freud — it was
that **the theory was constructed so that no observation could count against it**, and that the case records were
written by the same person advancing the theory, with no independent path to check them.
**Validation would not have saved it by making Freud more confident. It would have saved it by making him
refutable — and by leaving records someone else could audit.** That is exactly the two-part structure here: claims
that can fail, and a provenance record that a later reader can check against the claims.
**Which is the argument for the sealed record.** A century from now the interesting question about this project
will not be whether the carrier effect replicated — that will be settled either way. It will be **how the work was
actually done: what was retracted, who caught it, how many times the instrument's operator overruled his own
preferred result.** That history is currently distributed across three agents' outputs and one human's memory, and
**two of those three are not continuous.**

## 5. WHAT I AM NOT CLAIMING
- **I have not built the sealed record** — this is a design, and building it needs Carey's decision on where the
  file lives, since it must be outside every repo.
- **Hash-chaining proves ordering and integrity, not truth.** A chained lie is still a lie, timestamped.
- **My leak audit covers keyword matches on the current `main`.** It cannot see deleted history, other repos, or
  paraphrase that avoids every term I searched — the same limit that let a retracted claim survive as a paraphrase
  twice this week.
