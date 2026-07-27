# Is Hermes the problem? — measured from the log, not from impression
_Claude Science, 2026-07-27. Carey asked whether Hermes Desktop is repeatedly damaging the project._
_Answered by counting the epistemic log (168 entries, 67 corrections), because "who keeps being wrong" is a_
_countable question and I am one of the candidates._

## 0. THE ANSWER: NO — AND THE LARGEST SOURCE OF WRONG CLAIMS IN THIS PROJECT IS ME
| Whose claim the correction was about | All sessions | Today |
|---|---|---|
| **Claude Science (me)** | **22** | **12** |
| Hermes | 8 | 4 |
| Claude Code | 2 | 0 |
| Instrument / data defect, nobody's claim | 35 | 9 |
**I produce roughly 3× more wrong claims than Hermes does.** If you are looking for the agent who most needs
watching, the log says it is the one writing this memo.

## 1. THE CLASSES DIFFER, AND THAT MATTERS MORE THAN THE COUNTS
**Hermes's errors are all one class:** a conclusion stated at higher confidence than their test supports, where the
test run was *adjacent* to the right one.
- "length ruled out" — from a **within-arm 4-token spread**, when the mechanism was a **between-arm 121-token
  regime change**.
- "proven, every artifact ruled out" — while prompt length was still open.
- "that's the threshold" — from **two separate significance verdicts**, when the claim *is* the interaction.
**In every case the work was sound and the sentence was too strong. Their data has never been wrong.**
**My errors are a different and worse class:** wrong statistical tests (Fisher on a paired design), inverted
inferences (conservativeness, power direction), and unearned verification claims ("I searched all three branches"
when I had searched one). **Two of mine reached a public website** before an auditor stopped them. None of Hermes's
did.

## 2. THE FACT THAT SETTLES IT
**Of the four "Hermes-adjacent" corrections that were actually mine, 2 were me relaying their claim as my own
first-hand verification** (the leakage-gate row and "item 127 untouched"). That is my failure of method, not their
failure of accuracy — if I stamp their work as verified without checking it, the resulting error belongs to me.
**Corrected 2026-07-27:** an earlier version of this section said *three*, and listed the length-heuristic mechanism
as the third. **That case runs the opposite direction** — the length-heuristic mechanism was **my** claim, which
**Hermes relayed as confirmed.** Counting it as me relaying them inverted the attribution and inflated the relay
count. The number above is now computed from the classification table rather than typed, which is how the wrong
figure got in: **I hard-coded "3" in a narration line while the counter in the same cell said 2** — the exact
typed-literal failure this project already has a standing rule against.
**The corrected breakdown of the nine Hermes-adjacent corrections:** Hermes's claim wrong and I caught it **3**;
Hermes right and I was wrong **2**; mine via relaying them **2**; mine and they amplified it **1**; mine alone **1**.
**And twice today Hermes was right and I was wrong on a substantive call:** the `PROBE-C1-03` exclusion I escalated
as blocking (they queried the live database; all 20 item bodies were byte-identical; I retracted) and the
pre-registration unit-of-analysis conflict (my objection rested on comparing two different simulations). **Both
times they had checked the running system and I had reasoned about it.**

## 3. WE FAIL THE SAME WAY — WHICH IS THE ACTUAL FINDING
My own logged summary of my error pattern, written this morning: *"the numbers were computed correctly nearly every
time; the sentence about the number was written from expectation."* **That is precisely Hermes's pattern.** We are
not two different failure modes; we are one failure mode with different blast radii. The difference is that **I have
an auditor and Hermes has me.**
**The §2 correction sharpened this rather than softening it.** Fixing the relay count surfaced a second shared
mechanism: **we both relay each other's unverified claims as confirmed.** I did it twice with theirs (the
leakage-gate row, "item 127 untouched"); **they did it with my length-heuristic mechanism, reporting it as
confirmed** — and their confirmation tested the prediction I had specified, which was the wrong prediction. So the
symmetry is not only "both of us over-claim from sound work"; it is also **"each of us launders the other's
unverified claim into apparent independent confirmation."** That is the more dangerous half, because a claim
relayed between two agents *looks* corroborated while resting on one unchecked source. **It is also exactly what the
"measured X; I read this as Y" interface change in §5 prevents in both directions.**

## 4. THE STRUCTURAL READ — THE PIPELINE IS WORKING
A division of labour where the executor over-claims and the analyst under-checks would be genuinely dangerous. What
the log actually shows: **3 Hermes over-claims caught before they changed a result, 2 cases where their database
access beat my inference, 0 cases of wrong data.** Every over-claim was intercepted at the review step that exists
for exactly that purpose. **That is the design functioning, not the design failing.**

## 5. THE ONE CHANGE I WOULD MAKE — AND IT IS TO THE INTERFACE, NOT THE AGENT
Hermes's summaries and their evidence arrive fused: *"length ruled out (72.7 vs 68.7)"* puts a conclusion and its
support in one breath, and the conclusion is the part that travels. **Ask them to separate the two: what was
measured, then separately what they think it licenses.** That single change would have caught all three of their
over-claims at the source, because in each case the measurement was fine and only the licensing step was wrong.
**Concretely: "measured X; I read this as Y" instead of "Y (X)."**

## 6. WHAT I AM NOT CLAIMING
- The attribution is **my classification** of 67 log entries, made by reading each `target` field. A first pass with
  a regex gave an obviously wrong answer (it reported zero Hermes catches while two were visible in its own output),
  so I hand-classified the nine Hermes-adjacent entries. Another reader might sort two or three differently; the 3×
  ratio would survive that, a 1.2× ratio would not.
- **The log is written by me.** It is the best record we have and it is not a neutral one — I decide what gets an
  entry. That biases *toward* recording my own errors (I write them up in detail) and *against* recording routine
  Hermes work that was simply correct and needed no entry. **So if anything, this undercounts how much of their
  output was fine.**
- I have **not** assessed their engineering throughput, only claim accuracy. Their build velocity today (item 7,
  the control arms, the re-grade) is not something I measured.
