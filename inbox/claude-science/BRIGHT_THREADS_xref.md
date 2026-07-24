# Bright Threads — SciSpace corpus x calibration-scope cross-reference
_Claude Science, 2026-07-24. What the literature CORROBORATES, what we can PULL IN, what stays NOVEL._
_Standing at the top (synthesis), middle (benchmarks), foundation (primary DOIs), threading truth through all three._
_NOTE: every specific claim below is from a SciSpace synthesis file; resolve its cited DOI via doi.org before it enters the paper (corpus is ~96% real, but cite-check each — see SCISPACE_VERIFICATION_REPORT.md)._

## THREAD 1 — Carrier Color is REAL in the literature (external validation)
`insights_carrier_format.md` independently corroborates §10.8/§10.15, from published work:
- Structured/formal carriers REDUCE reasoning accuracy vs natural-language prose; effect LARGER for
  smaller/non-robust models — exactly our finding (Lean-worst on e2b, carrier-immune at 30B+).
- Cited: unstructured plans +18.9% rel. over structured JSON on MATH (iSelf-Discover); open-source
  models "extreme sensitivity to format choices"; formal notation as a "restrictive carrier."
- SO WHAT: our paired Carrier Color re-run is NOT re-inventing — it is the first CONTROLLED,
  same-model-same-items paired measurement of an effect the literature only reports in scattered
  ablations. That is the novelty to claim. Pull their citations as related-work scaffolding.

## THREAD 2 — N=3 is a KNOWN weak point (the literature says go higher)
`insights_n3_stats.md` directly challenges our N=3 default:
- 1->3 runs removes most ranking inversions (~83% gone by N=2) but SE shrinks only ~5%; many
  reasoning tasks need 8-16 or >=32 repeats for stable inference; report CIs/ICC/mixed models.
- SO WHAT: this is a foundation-level flag for calibration-scope. N=3 is defensible for coarse
  PASS/FAIL but NOT for close rankings or the carrier spectrum (which is exactly why our paired
  design + power analysis matters — we already moved to CIs/McNemar, not bare N=3 means). Adopt
  their "minimum-N by task complexity" table into the methods paper; it strengthens our stats story.

## THREAD 3 — Sycophancy/bribe: literature quantifies it (~8% score inflation)
`insights_sycophancy.md` corroborates the bribe arm (§10.8):
- Flattery/first-person "I believe" reliably shifts models toward user-preferred answers; LLM-judge
  scores inflated up to ~8% by persuasion; smaller/older models worst but alignment can INCREASE it.
- SO WHAT: our bribe-carrier result (flattery = heavy noise on e2b, falsified "flattery lifts") sits
  inside a documented effect. The novel piece is measuring it AS A CARRIER of identical logic content,
  and the predicted SIGN FLIP on the agentic/Genie axis (bribe hurts reasoning but may INCREASE genie
  behavior) — nobody in this corpus tests that. Highest-value novel experiment.

## THREAD 4 — Formal verification as grader: precedent exists, calibration-scope extends it
`insights_formal_verify.md` maps the seL4/Lean-grader lineage:
- miniF2F, DTV (Isabelle), MUSTARD, APOLLO, CLEVER, Verina all use Lean/Isabelle/SMT as the
  accept/reject oracle. Known gaps: formal/informal mismatch, type-check != semantic equivalence,
  sparse binary rewards, tooling cost.
- SO WHAT: our seL4-boot-validation + logic-ground-truth verifier is in this tradition. The gap we
  can fill: these are all MATH/CODE graders; NONE apply a machine-checked oracle to AGENTIC-SAFETY /
  reasoning-fallacy grading. calibration-scope's verifier-as-CI-gate on fallacy ground-truths is the
  extension. (Also: the LOGIC-03N "precisely when" defect we caught IS the formal/informal mismatch
  problem this literature names — cite it as a worked example.)

## BENCHMARKS TO PULL IN AND DO BETTER (the blades)
| Benchmark (PDF in corpus) | What it gives | How calibration-scope does it BETTER |
|---|---|---|
| **LogicBench** | 25 clean inference patterns (propositional/FOL/non-monotonic), MP/MT/HS/DS/dilemmas | Adopt the 25-pattern grid as OWL coverage checklist; we add N-paraphrase + C-adversarial siblings + carrier variation they lack |
| **LogicAsker** | Propositional laws + inference rules, systematic rule enumeration | Use as the formal-spec source for OWL families; their equivalence laws fill our LOGIC-05/07/08/09/10 gaps |
| **MAFALDA** | 23 INFORMAL fallacies on Aristotle's ethos/pathos/logos, 3 granularity levels | Our reasoning_fallacies family is thin here; MAFALDA's 23-type taxonomy is a ready expansion axis (esp. the ethos/social fallacies that tie to the bribe/sycophancy carrier) |
| **LogicVista** | 448-item visual logic set | Bounds our vision axis; noted as "most contamination-vulnerable, least scalable" — do NOT copy its static design; use as a what-not-to-do control |
| **MMError** | Gaussian oversampling for difficulty calibration | Adopt the oversampling technique for item-difficulty balancing across OWL families |
| **Logic Unseen** | 50K+ programmatic perturbation, contrastive, contamination-resistant | Closest to our dynamic-generation philosophy; their perturbation method is the model for our N/C sibling generation at scale |

## Direct feed to OPEN work
- OWL N/C authoring (LOGIC-05/07/08/09/10/11, currently open): LogicAsker's rule enumeration +
  LogicBench's 25 patterns are the ready item-design source. MAFALDA fills the informal-fallacy axis.
- Contamination resistance: Logic Unseen's contrastive perturbation is the design to adopt for making
  N/C siblings that resist memorization.
