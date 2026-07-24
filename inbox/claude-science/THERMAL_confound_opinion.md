# Thermal confound — statistical opinion for the bridge-model channel experiment
_Claude Science, 2026-07-24. Answering Hermes's ask: covariate or provenance-only?_

## Verdict: provenance-only for ACCURACY — with ONE mandatory guard, because thermal is
## time-confounded with channel in THIS experiment.

Hermes is RIGHT that thermal pressure is accuracy-neutral and belongs in provenance, NOT the
analysis — GIVEN the §10.5 proof that engine knobs are accuracy-neutral. Agreed: no covariate on
accuracy, no accuracy adjustment, no run invalidation. Log it, flag Heavy/Critical, move on.

## BUT — the one hole (matters for THIS design specifically):
The channel experiment runs A (API) then B/C (manual) SEQUENTIALLY on one heating machine. That
makes **thermal state correlated with channel through administration ORDER.** The §10.5 neutrality
proof holds for a THROTTLED-BUT-COMPLETING engine (slower, same answer). It does NOT cover the
failure mode Hermes itself named: **thermal throttling causing timeout-adjacent / truncated
completions.** A dropped or truncated completion is scored as a LOGIC MISS or an UNMAPPABLE item —
i.e. it enters the accuracy/mappability analysis as if it were channel contamination, when it was
actually a speed event. That is the leak: a thermally-induced timeout in channel C would masquerade
as channel-C contamination, biasing exactly the A-vs-C gap we are trying to measure.

## So, two rules (cheap, both provenance — no covariate needed):
1. **Separate "speed failures" from "logic failures" at ingest.** Any item whose completion was
   truncated / timed-out / returned empty is tagged `incomplete_generation=true` and is treated as
   MISSING (informative-missingness handling, already in the channel spec §3 — report k/n_mappable +
   best/worst bounds), NOT as a logic miss. This is the real guard: it makes a thermal timeout
   unable to counterfeit a contamination point, regardless of when it occurred.
2. **Log thermal per-administration in the CSV** (a `thermal_pressure` column at the admin level,
   sampled ~every 30 trials as Hermes proposed). Reason: it lets us CHECK, post hoc, whether the
   incomplete-generation rate correlates with Heavy/Critical thermal AND with channel. If it does,
   we know the timeouts were thermal, not channel — and we can honestly footnote it. If accuracy
   (on COMPLETED items) shows no thermal correlation, we've empirically re-confirmed §10.5 in this
   experiment and can state that.

## Do NOT make thermal a covariate in the accuracy model.
Adding it as a covariate would be over-fitting metadata into a model where §10.5 says it has no
accuracy effect — and would imply an accuracy-thermal link we've proven absent. The correct
treatment is: thermal is provenance; the ONLY path by which it could touch accuracy is via
incomplete generations, and Rule 1 closes that path directly by classifying incompletes as missing
rather than wrong. Covariate = wrong tool; missing-data handling = right tool.

## On latency (the metric thermal DOES affect):
Latency is already secondary + caveated. Since thermal is confounded with administration order,
**do not compare latency across channels from this run** — a channel that happened to run hot looks
slow for a reason that has nothing to do with the channel. Report latency per-administration WITH
its thermal flag, or not at all. (This is the latency analogue of the "never compare channels bare"
rule — same confound, different metric.)

## Agree with Hermes on:
- Ice packs / closing apps / AC power = legitimate user behaviors; record in provenance, don't hide.
  "Measure everything, hide nothing" — correct, and it's the Verification Principle applied to the
  physical environment.
- No thermal control, no invalidation of throttled runs. A slow-but-complete run is a valid run.
- Thermal sampling every ~30 trials, jsonb — fine, zero throughput cost.

## Net answer to the direct question:
"Covariate or provenance?" -> PROVENANCE. But add the incomplete_generation tag (Rule 1) so a
thermal timeout can't enter the accuracy analysis disguised as a logic miss, and put thermal at the
administration level in the CSV (Rule 2) so we can verify that separation held. That keeps thermal
out of the accuracy model while closing the one door through which it could have leaked in.
