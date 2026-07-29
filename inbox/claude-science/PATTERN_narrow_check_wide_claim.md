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
