# Proposed site copy — the four conditions, framed as an invitation rather than a disclaimer
_Claude Science, 2026-07-29. Carey: "encourage the user to have fun… we also give them very clear guidance."_

## Why the obvious version is a trap, and what to write instead

**The obvious version** — *"results may vary; for real science, follow these guidelines"* — reads
as a disclaimer, and a disclaimer becomes an all-purpose escape hatch. **Any result anyone
dislikes gets waved away as "you probably weren't in science mode."** That makes the instrument
unfalsifiable, which is the exact opposite of what it is for.

**The version that costs nothing and gains everything:** the guidance is not advice about
attitude, it is **four conditions on the measurement** — every one of them discovered by
Carey red-teaming his own tool, and every one checkable.

| condition | what breaks without it | found by |
|---|---|---|
| the subject has an **addressable interface** | pet rock: `0.00`, indistinguishable from a wrong answer | rock |
| its output is **decodable by the grader** | dog: signal emitted, recorded as nothing | dog |
| the item is **in a domain the subject addresses** | calculator: true score, zero meaning | calculator |
| the **grader is blind to the key** | Tango: a bark becomes a `CORRECT` | Tango |

**Three of those prevent a meaningless zero. The fourth prevents a manufactured pass — and it is
the only one that can fake a discovery.** That asymmetry is worth stating plainly to users,
because it tells them which mistake actually costs them something.

## Draft copy

> ### Break it on purpose. Then read this.
>
> **Point this at anything.** A pet rock, your dog, a pocket calculator, Siri, a 2-bit quantized
> model you found at 3am. You will get results, and some of them will be very funny. **Every one
> of those runs is real data about the instrument**, and two of them are already on our board as
> defects we had not noticed.
>
> **When you want the number to mean something, four things have to be true.** Not rules — the
> conditions under which a score is about the subject rather than about the setup:
>
> 1. **Your subject can be addressed.** If nothing can receive the question, `0` means *no test
>    happened* — not *failed*. (Our own first dataset recorded a model that never loaded as
>    `passes=0`, numerically identical to nine models that answered wrongly. We fixed it because
>    it embarrassed us.)
> 2. **Its answers can be read by the grader.** A subject can emit a perfectly good signal you
>    cannot decode. That is our failure, not theirs — and the honest record says *"unreadable,"*
>    never *"wrong."*
> 3. **The question is in a domain your subject actually handles.** A calculator scores `0` on
>    poetry and `100%` on arithmetic. The first number is true and tells you nothing.
> 4. **Whoever grades does not know the answer.** This is the one that bites. A friendly handler
>    who is *not lying* can hear a dog bark and score it correct — the horse Clever Hans did
>    arithmetic for 13 years this way. **The other three conditions protect you from a
>    meaningless zero. This one protects you from a discovery that isn't there.**
>
> **Everything the instrument seals is auditable, including the runs where the setup was the
> problem.** That is the design: a verdict you cannot inspect is an opinion with a hash on it.

## Where it goes, and what it is not

**Placement:** a section on the site, and the same four conditions in the dashboard's first-run
flow — the place where someone is *about to* administer their first test. Wording mandate applies,
so the mission sentence itself is Carey's call (CS-041) and this copy must not contradict whatever
he settles on.

**What this copy deliberately does NOT do:**
- It does not say results are unreliable. It says which *setups* produce meaningless numbers.
- It does not ask users to promise anything, and it does not gate features behind a "science mode."
- It does not claim the instrument currently ENFORCES condition 4. **It does not** — `participants`
  has no `scored_by` column (CS-042) and no transcript column (CS-043). Publishing this copy
  before those land would state a property we do not have, which is the defect this project
  exists to measure.

## What I have NOT established

- **This is unpublished copy, not a change.** I did not touch `site/index.html`; the site deploy
  has never run anyway (CS-031, billing lock).
- I verified the site currently has **no** fun/play/caveat/limitation framing — zero matches for
  "fun", "explore", "caveat", "limitation"; the twelve apparent "play" hits are all `display`.
- The Clever Hans attribution and the "13 years" figure are from my own knowledge of Pfungst 1907,
  not from a source I fetched in this session. **Check the figure before it ships.**
