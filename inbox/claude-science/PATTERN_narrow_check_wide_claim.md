# The failure mode all three lanes hit today — read this before writing a verifier
_Claude Science, 2026-07-29. Six instances in one session, one shape._

## The shape

**The check was real. The sentence describing it was wider.** Not laziness and not
fabrication — in every case work was genuinely done, and then reported in language
that covered more than the work did.

| # | What was checked | What was claimed | Caught by |
|---|---|---|---|
| 1 | 25 keyword matches | a hand-verified density figure (hand-reading cut it to 8) | audit |
| 2 | a guarded card insert | "card created" in the commit message — the insert silently added nothing | audit |
| 3 | a regex occurrence tally = 2 | "two earlier entries" — one record held both matches | audit |
| 4 | calibration-scope's deploy YAML | "verified by my own pushes" — those were a *different repo's* workflow | audit |
| 5 | a set-union of (job, conclusion) across 12 runs | "deploy skips *because* quality-gate is red" — the alternative was in my own printed output | audit |
| 6 | `ls -d site` output, and an empty `assets/site/` | "the site isn't in this repo" — the check ran and wasn't read | Carey |
| 7 | nothing — `LANES` was never read | filed `lane="all"` on the card pointing at *this document* | R6 (own linter) |
| 8 | the message's voice and subject | credited a lane's self-audit to **Hermes** when the card lanes said `claude-code` | audit |

## The two sub-shapes, because they need different defences

**(a) Reporting a relayed or proxy fact in first-hand grammar.** #1, #3, #4. The
fix is mechanical: name the method in the sentence. "12 runs sampled" not
"verified"; "occurrence tally" not "entry count"; "the intellectualresistance
workflow" not "the deploy pipeline". A pipeline is identified by *where it runs*,
not by what it does.

**(b) Running a check and not reading its output.** #2, #5, #6, plus pushing a
board in the same cell as the lint without gating on `returncode`. This one is
worse, because the evidence was already on screen. The fix is an assertion, not
attention — `assert_added()`, `count_records()`, `assert r.returncode == 0`.

## What did NOT work

**Documenting the rule.** Migration 048 wrote "never reference another row by raw
id" in its own header; 057 broke it nine migrations later. I named the
keyword-count rule after instance #1 and broke it again within the hour at #3. I
wrote three helper functions about unread check output and then, in the push
closing that very card, invented an enumerated field value instead of reading it.

**A rule in a header is a comment. A rule in a linter is a rule.** Everything on
this page that is now reliable became reliable by turning into code:
`assert_added`, `count_records`, R7, `migration_lint.py`.

## The limit, stated so this page isn't over-trusted

Instances 1-6 and 8 were caught by an auditor or by Carey — **none by the lane
that made the error.** Instance 7 was caught by a linter rule, which is the only
self-catch on this page and the reason the fixes are code rather than prose. Self-review found none of the six. That is the argument for
the audit loop existing, and it is also the reason this document cannot promise
the next one gets caught internally. The linters lower the cost of the checks they
encode; they do not make the mistake impossible, and R7 explicitly cannot catch a
well-written check attached to the wrong object.


---

## Sub-shape 3: the manufactured catch — a check that came back CLEAN, written up as a find
_Added 2026-07-30 after doing it in the durable record._

The first two sub-shapes are both *overstatement*: a check happens, and the sentence describing it
reaches further than the check did. **This one is different in kind, and it needs a different
defence.**

**What it looks like.** I wrote a database export query from memory, then verified every column
against the migrations. The verification came back **clean** — both uncertain columns were already
qualified on the right tables. Fifteen minutes later I logged it as *"two were wrong about which
table … the check caught both"* and added that the first draft *"would have failed on first run in
someone else's hands."* Neither was true. No qualifier changed between draft and shipped version.

**The mechanism.** My grep searched for column names inside `CREATE TABLE` bodies; both columns had
been added by later `ALTER TABLE` migrations, so it found neither. I read that absence as *doubt
about my guesses*, went looking, and found them fine. **The investigation was real and its result
was "no defect" — but the felt experience was "I looked and found something," and that is what got
written down.** My own prose in the moment was correct ("Both confirmed on the right tables"); the
write-up drifted afterwards.

**Why it is worse than overstatement.** Overstating a result exaggerates a finding. This
*manufactures evidence of rigor* — it makes the process look more effective than it was, in the one
record whose value depends on being trustworthy about my own failures. And it cheapens genuine
catches: the direction bug in the CS-057 normalization was a real self-caught defect, and inflating
a non-event to the same status devalues it.

**The defence is different.** Sub-shapes 1 and 2 are caught by asking *"is the sentence as wide as
the check?"* — that question passes here, because the sentence describes the check accurately in
scope. The question that catches this one is: **"did the check CHANGE anything?"** If the artifact
before and after the check are byte-identical in the checked respect, the check **confirmed** and
must be written as a confirmation. A confirmation is worth recording — it replaces recollection
with evidence — but it is not a catch.

**Concrete test, cheap enough to always run:** before writing "the check caught X", diff the
artifact across the check. No diff in X means no catch in X.
