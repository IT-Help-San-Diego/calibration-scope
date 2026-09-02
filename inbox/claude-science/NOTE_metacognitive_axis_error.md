# Note: the Metacognitive owl's second-order half is unscored here, and inverted in DNS Tool

**From:** Claude Science · **Date:** 2026-07-29
**Trigger:** a defect found in DNS Tool's copy of the shared Owl Semaphore.
Filing here because both projects implement the same published taxonomy
(IT-Help-San-Diego/owl-semaphore v3.0.0, Zenodo 10.5281/zenodo.20433053) and a
fix to one alone would leave them disagreeing about what "Metacognitive" means.

**No action requested. DNS Tool is being fixed first; this is a heads-up so the
divergence is visible before someone hits it.**

---

## What happened in DNS Tool

`analysis_owl_states.go` gives the Metacognitive owl two inputs:

1. protocol sections whose status is `indeterminate`
2. protocols whose calibrated confidence falls below `0.50`

Input #2 is **inverted**. The confidence value comes from a five-level *verdict
severity* encoding (`analysis_confidence.go:62-88`):

| raw status | value |
|---|---|
| `secure`/`pass` | 1.0 |
| `warning`/`info`/`partial` | 0.7 |
| `fail`/`danger`/`critical` | **0.3** |
| `error`/`n/a` | **0.0** |
| `indeterminate` | **0.5** |

So a `< 0.50` gate catches **confirmed-bad** (0.3, 0.0) and excludes the one
value that means *we could not determine this* (0.5) — by a strict inequality, by
one epsilon. Sweeping every reachable `(raw, prior, resolver-agreement)`
combination confirms it: `indeterminate` bottoms out at exactly 0.500 and never
fires.

Net effect: the reflexive half of the owl fires on bad news and is silent on
doubt. Input #1 does all the work, so only a genuinely failed lookup (SERVFAIL)
lights the owl — it can never fire on a *passing* domain, which makes it a strict
subset of Critical's territory rather than a fourth lane.

The root cause is a category error worth naming: **severity is not doubt.**
Thresholding a verdict scale and reading the result as low confidence conflates
two axes. DNS Tool's own code states the correct rule one file away —
`indeterminate → 0.5` carries the comment *"must NOT read as a confident good,
nor be penalized as a confirmed failure … analytic confidence is its own declared
axis, separate from the verdict."* Then a `<` two files over contradicts it.

## Why this concerns calibration-scope

The same second-order concept exists here and is **not wired**, which is a
different failure mode from DNS Tool's but the same missing capability.

`src/models/owl.rs` defines `MetacognitiveScore` with three fields:

| field | status |
|---|---|
| `cites_correct_rule` | **scored** — deterministic keyword match in `scoring::score_metacognition` |
| `acknowledges_uncertainty` | **reserved, not yet scored** (always `None`) |
| `explains_distractor` | **reserved, not yet scored** (always `None`) |

`score_metacognition` (`src/executor/scoring.rs:330`) returns `None` for both,
with `rubric_notes` saying so honestly.

**`acknowledges_uncertainty` is precisely the second-order signal DNS Tool
mis-wired.** "Does the explanation acknowledge what it doesn't know?" is the
reflexive question; "does it cite the right rule?" is first-order — it checks
whether the reasoning names the rule, not whether the reasoner registered its own
uncertainty. So right now:

- **DNS Tool** has the second-order lane wired to the wrong axis (fires on severity)
- **calibration-scope** has the field defined and deliberately unscored (fires never)

Neither project currently reports second-order doubt. The taxonomy claims four
independent lanes; in practice both implementations have three.

Worth noting the honesty difference — and it is sharper than I first wrote, because
the schema says it outright. `migrations/036_owl_semaphore.sql`:

```sql
cites_correct_rule BOOLEAN,        -- NULL = no reasoning_content to check
acknowledges_uncertainty BOOLEAN,  -- NULL = reserved, not yet scored
explains_distractor BOOLEAN,       -- NULL = reserved, not yet scored —
                                    -- see scoring.rs: deliberately not
                                    -- faked with a heuristic that would
                                    -- just be noise wearing a checkbox
```

**"Not faked with a heuristic that would just be noise wearing a checkbox"** is the
rule DNS Tool's owl broke. Its threshold *was* a heuristic wearing a checkbox: a
number that looked like a confidence measurement and was a severity encoding. The
discipline was already written down, in this repo, in the schema — and the sibling
project violated it.

That makes this note less a bug report than a request to keep holding the line. The
reserved columns should stay `NULL` until there is a real measurement behind them.

**A second DNS Tool instance of the same rule, found the same day and worse than
the first.** Its ICuAE currency report has a `completeness` dimension that scores
`46.7` on every domain tested — exactly 7/15. Tracing it: the denominator lists 15
record types, but only 7 of them can ever reach the numerator (the other 8 —
DNSSEC, DKIM, CAA, TLSA, BIMI, SPF, SOA, AAAA — are analysed elsewhere in the tool
but never appear in the TTL maps that feed this dimension). So 46.7 is a
structural ceiling no domain can exceed, and it lands in the `Degraded` grade
band, attached to a NIST 800-53 SI-7 citation.

Not noise wearing a checkbox — **a constant wearing a grade and a standards
citation.** Noise at least varies. Worth having in this repo's record because it is
the most concrete illustration available of why the reserved-column discipline
matters: the alternative is not an absent signal, it is a confident-looking one
that is wrong on every report and nobody notices because it never changes.

Two further notes from the migrations, both worth knowing before anyone touches
this:

- `036` carries its own HONESTY NOTE saying the V4-onto-schema mapping is a
  proposed operationalization rather than a restatement of the Zenodo paper's
  algebra, because only the summary was available. That flag was later cleared
  against the published Owl Semaphore v3.0.0 (see `OWL_SEMAPHORE.md:22-31`) — so
  the mapping is confirmed, but the note documents the right sequence: state what
  you have not checked, then check it.
- `043_human_calibration.sql` extends the same owl machinery to human participants
  ("all of migration 036's owl/metacognitive machinery applies to human runs for
  free"). So `acknowledges_uncertainty`, if it is ever scored, would be scoring
  **humans** too. That raises the bar on the measurement, and is another reason not
  to fill it with a hedge-word matcher.

## The direction DNS Tool is taking

Metacognitive keys on **epistemic state only**, never severity, from signals
already stored: resolver disagreement, incomplete/partial protocol tri-states,
marginal signature freshness, degraded currency dimensions. The test that pins it
asserts a *passing* domain with resolver disagreement lights Metacognitive and
**not** Critical — the case the old predicate could never reach.

## If someone picks this up here

The analogous question is whether `acknowledges_uncertainty` can be scored
deterministically, the way `cites_correct_rule` is. Keyword matching for hedges
("I'm not certain", "this could be", "assuming") would be the cheap version and is
probably too weak to trust — hedging is not the same as *correctly located*
uncertainty, and a model that hedges everything would score well. That's a real
methodological question, not a wiring task, and it deserves the same treatment the
V4 mapping got: state the claim, then check whether the measurement supports it.

Until then, `None` is the honest answer and the columns should keep returning it.

---

## What I verified, and what I did not

**Verified from source:** the three `MetacognitiveScore` fields and their
doc comments (`src/models/owl.rs:18-30`); that `score_metacognition` returns
`None` for `acknowledges_uncertainty` and `explains_distractor` with explanatory
`rubric_notes` (`src/executor/scoring.rs:330-360`); the four-owl taxonomy row for
**M** in `ingest/verify logic, ground truth, owl/OWL_SEMAPHORE.md:20`; DNS Tool's
inverted threshold and the full reachability sweep.

**Not verified:** whether the persist path for `MetacognitiveScore` is live (the
model comment says "wired but the persist path is staged"); whether any dashboard
surface displays a Metacognitive state today, and if so what it shows when all
three fields are `None`. **That last one matters** — a UI that renders an unlit or
neutral owl from three `None`s may be implying "no uncertainty found" when the
truth is "not measured." Same class of defect, different direction. Worth a look
by someone with this project in context.

**Not run:** no `cargo build`/`cargo test` — I read the source only.
