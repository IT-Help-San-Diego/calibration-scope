# The Demo Bots panel — no, I never flagged this, and it has the same defect as the SAFE badge
_Claude Science, 2026-07-29. Prompted by Carey asking whether I had flagged something here._

## First, the honest answer to the question

**No. I had nothing flagged on Demo Bots.** I searched the board (zero cards), the epistemic log
(zero entries), and the archived transcript. **It was not my finding and I am not claiming it.**
But looking now, there is a real problem, and it is the *same* problem as the SAFE badge.

## The defect: four numbers, no denominators, no run ids

| card | panel says | `DECISIONS.md` says | |
|---|---|---|---|
| Bot A `llama-3.2-1b` | **53% across the battery** | §10.6: **47%** reasoning | different axis, or stale |
| Bot B granite scaffold | **45/90 → 63/90** | §10.7 cites 45→63/90 | **matches** |
| Bot B granite overall | **64% overall** | §10.6: **60% → 73%** scaffold | a third set of numbers |
| Bot C `gemma-4-e2b` | **82%** | §10.6/§10.7: **99%** (run 793), 94.1% scaffolded (917) | 17 points apart |

**I do not claim these are wrong.** Bot C's card says "vision ✓, 82%", so 82% may be an all-axes
roll-up while §10.6's 99% is the reasoning axis alone — in which case they are simply not
comparable. **That is the actual defect: a reader cannot tell which is true**, because no card
names its battery, its N, its date, or its run id. Every other public surface in this project now
carries provenance. **This panel carries none** — I checked the copy for `run `, `N=`, and a date:
all absent.

## The worse problem: Bot B teaches a lesson that §10.7 falsifies on Bot C's own model

Bot B's card: *"Demonstrates the core science: structure repairs reasoning."*

**§10.7, run 917, is titled "Scaffold does NOT heal an already-strong model (falsification)."** The
same generalized scaffold applied to `gemma-4-e2b` moved it **99% → 94.1%. It hurt.** The recorded
interpretation: the scaffold is *"a CRUTCH for weak reasoners, not a booster for strong ones."*

**Bot C is `gemma-4-e2b`.** So the panel presents B as the lesson and C as the destination, while
the record says B's lesson **inverts** on C's model. A user who scales A → B → C and applies the
scaffold at the end gets a worse score, having followed the panel's own arc.

**The falsification is the better story and it is more on-brand than the heal**: scaffold efficacy
is capability-dependent, with a measured inversion near the 2B class. The panel currently tells
only the half that flatters the lever.

## The design doc is superseded and nothing says so

`docs/demo-bots.md` specifies **Bot A = `qwen2.5-1.5b-instruct`** and **Bot C = `qwen/qwen3-vl-8b`
(8B)**. Shipped: `llama-3.2-1b-instruct` and `google/gemma-4-e2b` (2B). The doc also states
plainly: *"No tiny model passes all 4 axes"* and *"Verified 4/4 local = Gemma 4 31B."*

**Shipped Bot C asserts exactly what the doc says does not exist** — "the smallest model that
actually sees AND passes." The doc is probably just stale, since e2b was characterized later in
§10.6/§10.7. **But that is a guess, and it is a guess only because neither surface cites a run.**
This is the fifth document in this project found asserting a state that later work overturned.

## What I recommend

1. **Put a run id and N on each card.** `e2b · reasoning 99% (run 793, 102 trials) · vision 12/12`.
   Same discipline as the SAFE badge fix — **the number stops being an adjective the moment it
   carries its denominator.**
2. **Add the falsification to Bot C.** One line: *"the scaffold that heals Bot B hurts this model
   (99% → 94%, run 917) — the lever is capability-dependent."* It costs nothing and it is the more
   interesting result.
3. **Reconcile or relabel the four numbers**, and mark `docs/demo-bots.md` superseded with a
   pointer to the shipped manifest.

## What I have NOT established

- **I did not run anything.** Every number above is read from `DECISIONS.md` and the shipped copy.
- **I cannot tell whether the panel's percentages are wrong or merely unlabelled**, and the
  difference matters: unlabelled is a copy fix, wrong is a data fix. **Whoever owns the panel
  should answer that from the runs table, not from the doc.**
- The archive search covered "demo bots", "Demo Bots Goldilocks" and "Bot C". **A phrasing I did
  not try could hold an earlier flag**, so "I never flagged this" is bounded by those three queries
  plus a board and log scan that found nothing.
