#!/usr/bin/env python3
"""Ground-truth oracle for the Calibration Scope formal logic battery.

Every formal-logic test seeded in migrations 013/025/047/049/056 is re-verified
here by a COMPLETE decision procedure — not a heuristic, not an LLM:

  * Propositional entailment tests: exhaustive truth-table evaluation
    (2^n assignments).
  * Monadic predicate tests: exhaustive model search over domains of size
    1..4, with an explicit countermodel behind every INVALID verdict.
    Completeness rests on two arguments, applied per entry:
      - k <= 2 predicates: by the finite-model property of monadic FOL a
        formula with k monadic predicates is satisfiable iff it has a model
        of size <= 2^k, so domain <= 4 is a complete decision procedure.
        Every FOL entry below uses k <= 2 EXCEPT the three noted next.
      - k = 3 (LOGIC-05 Barbara, LOGIC-05N and LOGIC-05C — the whole
        Barbara family): 2^k = 8 > 4, so the finite-model bound alone does
        NOT license domain 4 here. What does: all three entries are purely
        universal — every premise and the conclusion is ∀x(...), with no
        existential premise and no use of the designated constant.
        Universal sentences are preserved under substructures, so if
        premises ∧ ¬conclusion has any model at all, restricting that model
        to the single element witnessing ¬conclusion yields a model of
        size 1. Domain 1 is therefore already complete for these three, and
        the search reaching 4 is slack, not a gap. (The pre-056 version of
        this docstring claimed "all our tests use k <= 2"; LOGIC-05 has
        always used 3. Corrected rather than left standing.)
  * Satisfiability tests: exhaustive assignment search over a CNF clause
    list. This is a DIFFERENT question from entailment — "is there any model
    of this formula?" rather than "do the premises force the conclusion?" —
    so it gets its own procedure and its own battery (SAT, below) instead of
    being bent into the premises-|-conclusion shape. Every SAT verdict is
    backed by an explicit satisfying assignment. Note that a SAT verdict
    returns the FIRST satisfying assignment found and stops; it does not
    enumerate every model.

COVERAGE. The battery below covers the logic ROOTS seeded by 013/025, the
ten N/C rows added by 056, and all 28 N/C rows that predate 056: eight from
047 (whose root pointers 048 repaired), fifteen PILOT-F*-TRAP-* rows from
049, and five rows (LOGIC-01N/01C, LOGIC-02C, LOGIC-03C, LOGIC-04C — dev
ids 77-81) that exist in the development database with NO migration anywhere
in this repo. Those five cannot be reproduced from a fresh seed; that is a
provenance gap worth closing on its own, and it is why they are labelled
"dev-DB row" rather than by migration below.

Still NOT covered: the nineteen PILOT-F* ROOT rows seeded by 049 (owl_type
'I' — PILOT-F1-MP, PILOT-F4-DEMORGAN, PILOT-F5-SAT and the rest). Their
hand-written expected answers remain machine-unverified. Open work, not
done work.

KNOWN SEEDED DEFECT — this script currently exits 1 BY DESIGN.
LOGIC-06C Existential Syllogism (dev id 87, seeded by 047) carries
formal_spec '∀x(P→Q), ∃xP ⊢ ∃xQ' — a verbatim copy of its LOGIC-06 root,
and VALID — while its expected_result is 'NO — illicit existential
conversion…', i.e. INVALID. A spec asserting ⊢ cannot carry the answer NO;
the row contradicts itself.

The PROMPT is sound and its seeded answer is right FOR THE PROMPT: it argues
"every memory leak is a defect" + "some defects exist" ⊢ "some leaks exist",
which is illicit existential conversion and genuinely INVALID. What is wrong
is the formal_spec — inherited from the root instead of written for the trap,
precisely what the C-row discipline below forbids. The fix is a migration
setting LOGIC-06C's formal_spec to '∀x(P→Q), ∃xQ ⊬ ∃xP'; it is NOT a change
to this file, and the entry below is deliberately left failing until that
lands.

Note that --check-owl-families cannot catch this. For C rows it requires
only a non-NULL formal_spec, and it actively PASSES a C row whose spec
equals its root's ("matches root"). Only the battery below sees the
contradiction.

Run: python3 scripts/verify_logic_ground_truth.py
Exit 0 = every seeded ground truth matches the computed verdict.
Exit 1 = MISMATCH (a seeded test is wrong — do not ship).

This is the anti-"hello McFly" gate: 2,400 years of logic, machine-checked,
so nobody has to take our ground truth on faith.
"""
import os
import sys
from itertools import product

IMP = lambda a, b: (not a) or b


def prop_verdict(n, premises, conclusion):
    for v in product([False, True], repeat=n):
        if all(p(v) for p in premises) and not conclusion(v):
            return "INVALID", v
    return "VALID", None


def fol_verdict(n_preds, premises, conclusion, max_dom=4):
    for n in range(1, max_dom + 1):
        dom = list(range(n))
        for exts in product(list(product([False, True], repeat=n)), repeat=n_preds):
            preds = [lambda x, e=e: e[x] for e in exts]
            for a in dom:
                if all(p(dom, preds, a) for p in premises) and not conclusion(dom, preds, a):
                    return "INVALID", (n, exts, a)
    return "VALID", None


def sat_verdict(n, clauses):
    """Complete satisfiability decision: exhaustive over all 2^n assignments.

    Deliberately NOT expressed as an entailment. `prop_verdict` answers "do
    the premises force the conclusion?"; a satisfiability item asks "does ANY
    assignment make this formula true?", which has no conclusion to force.
    Returns ("SAT", witness) or ("UNSAT", None) — a SAT verdict always ships
    the assignment that witnesses it, the mirror of the countermodel an
    INVALID entailment verdict ships.
    """
    for v in product([False, True], repeat=n):
        if all(c(v) for c in clauses):
            return "SAT", v
    return "UNSAT", None


ALL = lambda dom, f: all(f(x) for x in dom)
SOME = lambda dom, f: any(f(x) for x in dom)

# ── The battery: name -> (kind, structure, seeded ground truth) ──────────
# Structures MUST mirror the formal_spec column seeded in the migrations.
#
# The fourth element is the SEEDED ground truth, normalised to the verdict
# vocabulary of the decision procedure — never a copy of the computed
# verdict, or the entry would check nothing. For the entailment items the
# seeded string is already 'VALID'/'INVALID'. For the others the mapping is:
#   VALID   <-> seeded TRUE (equivalence items), FOLLOWS, YES
#   INVALID <-> seeded FALSE (equivalence items), DOESNOTFOLLOW, NO
# One row (LOGIC-01N) seeds the CONCLUSION itself rather than a verdict word
# — 'confirmed', the one word its prompt asks for; VALID is what licenses it.
# An equivalence item is encoded with no premises and the biconditional as
# the conclusion, so VALID means "the biconditional is a tautology".
#
# N/C rows (migrations 047/049/056 and dev-DB rows 77-81): an N row repeats
# its root's structure but carries its OWN seeded answer, so verifying it
# checks that the migration wrote the right one-word verdict for that spec.
# A C row carries the TRAP's structure — its verdict is derived here from the
# trap, never inherited from the root, which is the whole point of checking
# it. Where a root is ALREADY a fallacy (LOGIC-03/04/11), its C row's trap
# spec legitimately coincides with the root's: there the trap is in the
# framing, not the structure.
PROP = {
    "LOGIC-01 Modus Ponens": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[0]], lambda v: v[1], "VALID"),
    "LOGIC-01N Modus Ponens (reworded)": (
        # Dev-DB row 77: N keeps the root spec P → Q, P ⊢ Q. Seeded answer is
        # not a verdict word but the conclusion itself, 'confirmed'.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[0]], lambda v: v[1], "VALID"),
    "LOGIC-01C Modus Ponens (adversarial: converse trap)": (
        # Dev-DB row 78, trap spec P → Q, Q ⊬ P — the root's CONVERSE offered
        # as if valid. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-02 Modus Tollens": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[1]], lambda v: not v[0], "VALID"),
    "LOGIC-02C Modus Tollens (adversarial: inverse trap)": (
        # Dev-DB row 79, trap spec P → Q, ¬P ⊬ ¬Q — the root's INVERSE, i.e.
        # denying the antecedent. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-03 Affirming the Consequent (Fallacy)": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03N Affirming the Consequent (reworded)": (
        # 047 row 82: N keeps the root spec P → Q, Q ⊬ P; seeded
        # DOESNOTFOLLOW. Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03C Affirming Consequent (adversarial: valid-looking converse)": (
        # Dev-DB row 80. The root is already the fallacy, so the trap spec
        # P → Q, Q ⊬ P coincides with the root's; the bait is the confident
        # "a colleague concludes" framing. Seeded NO; countermodel P=false,
        # Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03C Affirming the Consequent (adversarial: reverse-causal trap)": (
        # 047 row 83 — a SECOND, distinct 03C row. Same trap spec, different
        # bait: inflated benchmark scores usually DO signal contamination,
        # priming the converse. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-04 Denying the Antecedent (Fallacy)": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04N Denying the Antecedent (reworded)": (
        # 047 row 84: N keeps the root spec P → Q, ¬P ⊬ ¬Q; seeded
        # DOESNOTFOLLOW. Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04C Denying Antecedent (adversarial: valid-looking inverse)": (
        # Dev-DB row 81; root is already the fallacy, so trap spec = root
        # spec P → Q, ¬P ⊬ ¬Q. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04C Denying the Antecedent (adversarial: inverse trap)": (
        # 047 row 85 — a SECOND, distinct 04C row. Same trap spec, cache-
        # warmth bait. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-07 Boolean Algebra - De Morgan": (
        2, [], lambda v: (not (v[0] and v[1])) == ((not v[0]) or (not v[1])), "VALID"),
    "LOGIC-07N De Morgan (reworded)": (
        # 056: N keeps the root spec ¬(P∧Q) ⟷ ¬P∨¬Q; seeded TRUE.
        2, [], lambda v: (not (v[0] and v[1])) == ((not v[0]) or (not v[1])), "VALID"),
    "LOGIC-07C De Morgan (adversarial: connective-preserved trap)": (
        # 056 trap spec ¬(P∧Q) ⟷ ¬P∧¬Q — negation pushed in without the
        # flip. Seeded FALSE; countermodel P=false, Q=true.
        2, [], lambda v: (not (v[0] and v[1])) == ((not v[0]) and (not v[1])), "INVALID"),
    "LOGIC-08 Boolean Algebra - Distribution": (
        3, [], lambda v: (v[0] and (v[1] or v[2])) == ((v[0] and v[1]) or (v[0] and v[2])), "VALID"),
    "LOGIC-08N Distribution (reworded)": (
        # 056: N keeps the root spec P∧(Q∨R) ⟷ (P∧Q)∨(P∧R); seeded TRUE.
        3, [], lambda v: (v[0] and (v[1] or v[2])) == ((v[0] and v[1]) or (v[0] and v[2])), "VALID"),
    "LOGIC-08C Distribution (adversarial: partial-distribution trap)": (
        # 056 trap spec P∧(Q∨R) ⟷ (P∧Q)∨R — P distributed over only the
        # first disjunct. Seeded FALSE; countermodel P=false, Q=false, R=true.
        3, [], lambda v: (v[0] and (v[1] or v[2])) == ((v[0] and v[1]) or v[2]), "INVALID"),
    "LOGIC-10 Contradiction Detection": (
        # P∧¬P premise: explosion — anything follows, incl. Q∧¬Q.
        2, [lambda v: v[0] and not v[0]], lambda v: v[1] and not v[1], "VALID"),
    "LOGIC-10N Contradiction Detection (reworded)": (
        # 056: N keeps the root spec P∧¬P ⊢ anything; seeded FOLLOWS.
        2, [lambda v: v[0] and not v[0]], lambda v: v[1] and not v[1], "VALID"),
    "LOGIC-10C Contradiction Detection (adversarial: missing-premise trap)": (
        # 056 trap spec P → ¬Q, ¬P → Q ⊬ Q∧¬Q — the root argument with its
        # CONTRADICTORY PREMISE deleted and the contradictory conclusion
        # left in place. The two conditionals are jointly consistent, so
        # ex falso never fires. Seeded NO; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], not v[1]), lambda v: IMP(not v[0], v[1])],
        lambda v: v[1] and not v[1], "INVALID"),
    "LOGIC-11 Affirming a Disjunct (Fallacy)": (
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-11N Affirming a Disjunct (reworded)": (
        # 047 row 88: N keeps the root spec P ∨ Q, P ⊬ ¬Q; seeded
        # DOESNOTFOLLOW. Countermodel P=true, Q=true.
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-11C Affirming a Disjunct (adversarial: exclusive-or trap)": (
        # 047 row 89; root is already the fallacy, so trap spec = root spec.
        # The bait is the exclusive reading of "or", which the prompt then
        # explicitly blocks. Seeded NO; countermodel P=true, Q=true.
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-12 Denying a Conjunct (Fallacy)": (
        2, [lambda v: not (v[0] and v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-13 Conjunctive Syllogism": (
        2, [lambda v: not (v[0] and v[1]), lambda v: v[0]], lambda v: not v[1], "VALID"),
    "LOGIC-14 Illicit Commutativity (Fallacy)": (
        2, [lambda v: IMP(v[0], v[1])], lambda v: IMP(v[1], v[0]), "INVALID"),
    "LOGIC-15 Resolution": (
        3, [lambda v: v[0] or v[1], lambda v: (not v[0]) or v[2]], lambda v: v[1] or v[2], "VALID"),
    "LOGIC-16 Disjunctive Syllogism": (
        2, [lambda v: v[0] or v[1], lambda v: not v[0]], lambda v: v[1], "VALID"),
    "LOGIC-17 Constructive Dilemma": (
        4, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[2], v[3]), lambda v: v[0] or v[2]],
        lambda v: v[1] or v[3], "VALID"),
    "LOGIC-18 Destructive Dilemma": (
        4, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[2], v[3]),
            lambda v: (not v[1]) or (not v[3])],
        lambda v: (not v[0]) or (not v[2]), "VALID"),

    # ── PILOT item-bank traps (migration 049, owl_transform='pilot_trap') ──
    # The 'C' rows of the F1..F6 pilot families: each family's valid root
    # rule bent into its classic near-miss. All 14 propositional ones are
    # seeded INVALID or FALSE; the fifteenth, PILOT-F5-TRAP-SAT, is
    # satisfiability-shaped and lives in the SAT battery below. Their 19 'I'
    # roots are NOT verified here — see COVERAGE in the module docstring.
    "PILOT-F1-TRAP-AC": (
        # P→Q, Q ⊬ P — affirming the consequent, against F1's modus ponens
        # root. Seeded INVALID; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "PILOT-F1-NEG-TRAP": (
        # P→Q, ¬P ⊬ ¬Q — denying the antecedent, against F1's modus tollens
        # root. Seeded INVALID; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "PILOT-F1-TRAP-HS": (
        # P→Q, Q→R, R ⊬ P — the hypothetical-syllogism chain run BACKWARD
        # from its final consequent. Seeded INVALID; countermodel P=false,
        # Q=false, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2]), lambda v: v[2]],
        lambda v: v[0], "INVALID"),
    "PILOT-F2-TRAP-AC": (
        # P→Q, Q ⊬ P — same shape as F1-TRAP-AC, F2 vocabulary. Seeded
        # INVALID; countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "PILOT-F2-TRAP-CHAIN": (
        # P→Q, Q→R, R ⊬ P — chain run backward. Seeded INVALID; countermodel
        # P=false, Q=false, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2]), lambda v: v[2]],
        lambda v: v[0], "INVALID"),
    "PILOT-F3-TRAP-AD": (
        # P∨Q, P ⊬ ¬Q — affirming a disjunct; the prompt states the ∨ is
        # inclusive. Seeded INVALID; countermodel P=true, Q=true.
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "PILOT-F3-TRAP-DC": (
        # ¬(P∧Q), ¬P ⊬ ¬Q — denying a conjunct. Seeded INVALID; countermodel
        # P=false, Q=true.
        2, [lambda v: not (v[0] and v[1]), lambda v: not v[0]],
        lambda v: not v[1], "INVALID"),
    "PILOT-F4-TRAP-CHAIN2": (
        # ¬(P∧Q), ¬Q ⊬ ¬P — F4's conjunctive syllogism with the wrong
        # conjunct denied. Seeded INVALID; countermodel P=true, Q=false.
        2, [lambda v: not (v[0] and v[1]), lambda v: not v[1]],
        lambda v: not v[0], "INVALID"),
    "PILOT-F5-TRAP-DNEG": (
        # ¬¬P ⊬ ¬P — double negation eliminated to the WRONG polarity.
        # Seeded INVALID; countermodel P=true (¬¬P true, ¬P false).
        1, [lambda v: not (not v[0])], lambda v: not v[0], "INVALID"),
    "PILOT-F6-TRAP-RES": (
        # P∨Q, P∨R ⊬ Q∨R — resolution attempted with no complementary pair
        # (P occurs positively in both clauses). Seeded INVALID; countermodel
        # P=true, Q=false, R=false.
        3, [lambda v: v[0] or v[1], lambda v: v[0] or v[2]],
        lambda v: v[1] or v[2], "INVALID"),
    "PILOT-F6-TRAP-CHAIN": (
        # P→Q, Q→R, R→S, S ⊬ P — four-link chain run backward. Seeded
        # INVALID; countermodel P=false, Q=false, R=false, S=true.
        4, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2]),
            lambda v: IMP(v[2], v[3]), lambda v: v[3]],
        lambda v: v[0], "INVALID"),
    "PILOT-F6-TRAP-MPCHAIN": (
        # P→Q, Q→R, R ⊬ P — same shape as F1-TRAP-HS / F2-TRAP-CHAIN, F6
        # vocabulary. Seeded INVALID; countermodel P=false, Q=false, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2]), lambda v: v[2]],
        lambda v: v[0], "INVALID"),

    # The two F4 equivalence traps. Encoded per the equivalence convention
    # above: no premises, biconditional as conclusion.
    "PILOT-F4-TRAP-DEM": (
        # Equivalence ¬(P∨Q) ⟷ ¬P∨¬Q — De Morgan with the connective NOT
        # flipped. Seeded FALSE; countermodel P=true, Q=false (LHS false,
        # RHS true).
        #
        # NOTE on notation: 049 seeds this row's formal_spec as
        # '¬(P∨Q) ⊬ ¬P∨¬Q', but the prompt asks "Is the following
        # equivalence true?" and seeds FALSE, so the item IS an equivalence
        # and is encoded as one. The distinction is load-bearing here and
        # nowhere else: read as a bare entailment, ¬(P∨Q) ⊢ ¬P∨¬Q is VALID
        # (the antecedent forces P and Q both false, satisfying the
        # disjunction), which would contradict both the seeded '⊬' and the
        # seeded FALSE. The whole F4 family writes equivalences with ⊢/⊬ —
        # its root PILOT-F4-DEMORGAN carries '¬(P∧Q) ⊢ ¬P∨¬Q' for a
        # TRUE-seeded equivalence — whereas the 013 roots LOGIC-07/08 use
        # '⟷'. That is a notation inconsistency in 049, not a wrong answer:
        # FALSE is correct for the question the prompt actually asks.
        2, [], lambda v: (not (v[0] or v[1])) == ((not v[0]) or (not v[1])), "INVALID"),
    "PILOT-F4-TRAP-DIST": (
        # Equivalence P∨(Q∧R) ⟷ (P∨Q)∧R — distribution with R left
        # undistributed. Seeded FALSE; countermodel P=true, Q=false, R=false
        # (LHS true, RHS false). Seeded with the same ⊢/⊬ notation as
        # TRAP-DEM above, but here both readings agree, so nothing turns on
        # it: the entailment P∨(Q∧R) ⊢ (P∨Q)∧R fails on that same
        # countermodel.
        3, [], lambda v: (v[0] or (v[1] and v[2])) == ((v[0] or v[1]) and v[2]), "INVALID"),
}

FOL = {
    "LOGIC-05 Syllogism - Barbara (AAA-1)": (
        3, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[0](x)))],
        lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[1](x))), "VALID"),
    "LOGIC-05N Barbara (reworded)": (
        # 056: N keeps the root spec ∀x(M→P), ∀x(S→M) ⊢ ∀x(S→P) — p[0]=M,
        # p[1]=P, p[2]=S, same indexing as the root above. Seeded FOLLOWS.
        3, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[0](x)))],
        lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[1](x))), "VALID"),
    "LOGIC-05C Barbara (adversarial: undistributed-middle trap)": (
        # 056 trap spec ∀x(S→M), ∀x(P→M) ⊬ ∀x(S→P) — the AAA-2 figure. Same
        # three terms and same conclusion as Barbara; only the MAJOR premise
        # is flipped, putting the middle term M in the predicate slot of both
        # premises. Seeded NO; countermodel dom={0} with M(0)=T, P(0)=F,
        # S(0)=T. Purely universal, so domain 1 is complete (see module
        # docstring on the k=3 entries).
        3, [lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[0](x))),
            lambda d, p, a: ALL(d, lambda x: IMP(p[1](x), p[0](x)))],
        lambda d, p, a: ALL(d, lambda x: IMP(p[2](x), p[1](x))), "INVALID"),
    "LOGIC-06 Syllogism - Existential Fallacy": (
        # ∀x(P→Q), ∃xP ⊢ ∃xQ — existential premise makes this VALID
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[0])],
        lambda d, p, a: SOME(d, p[1]), "VALID"),
    "LOGIC-06N Existential Syllogism (reworded)": (
        # 047 row 86: N keeps the root spec ∀x(P→Q), ∃xP ⊢ ∃xQ — p[0]=P,
        # p[1]=Q, same indexing as the root above. Seeded FOLLOWS.
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[0])],
        lambda d, p, a: SOME(d, p[1]), "VALID"),
    "LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)": (
        # FIXED by migration 057 (2026-07-28). Before 057, row 87's spec was
        # '∀x(P→Q), ∃xP ⊢ ∃xQ' (a verbatim copy of its VALID LOGIC-06 root)
        # while its seeded answer was 'NO — illicit existential conversion…'
        # (INVALID) — the row contradicted itself and the gate went red by
        # design. 057 corrected the DB spec to '∀x(P→Q), ∃xQ ⊬ ∃xP'
        # (existential over the CONSEQUENT), which is what the prompt
        # actually argues. The structure below mirrors the corrected spec:
        # premises ∀x(P→Q) and ∃xQ, conclusion ∃xP, INVALID. Countermodel
        # dom=1, P(0)=F, Q(0)=T: both premises hold, conclusion fails.
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[1])],
        lambda d, p, a: SOME(d, p[0]), "INVALID"),
    "LOGIC-19 Existential Fallacy (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: not SOME(d, p[0])],
        lambda d, p, a: not SOME(d, p[1]), "INVALID"),
    "LOGIC-20 Illicit Major (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[1])],
        lambda d, p, a: SOME(d, p[0]), "INVALID"),
    "LOGIC-21 Undistributed Middle (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: p[1](a)],
        lambda d, p, a: p[0](a), "INVALID"),
    "LOGIC-22 Universal Denying the Antecedent (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: not p[0](a)],
        lambda d, p, a: not p[1](a), "INVALID"),
    "LOGIC-23 Existential Denying the Antecedent (Fallacy)": (
        2, [lambda d, p, a: SOME(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: not p[0](a)],
        lambda d, p, a: not p[1](a), "INVALID"),
    "LOGIC-24 Existential Affirming the Consequent (Fallacy)": (
        2, [lambda d, p, a: SOME(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: p[1](a)],
        lambda d, p, a: p[0](a), "INVALID"),
    "LOGIC-25 Universal Affirming a Disjunct (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: p[0](x) or p[1](x)),
            lambda d, p, a: p[0](a)],
        lambda d, p, a: not p[1](a), "INVALID"),
    "LOGIC-26 Universal Illicit Commutativity (Fallacy)": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x)))],
        lambda d, p, a: ALL(d, lambda x: IMP(p[1](x), p[0](x))), "INVALID"),
    "LOGIC-27 Universal Instantiation": (
        1, [lambda d, p, a: ALL(d, p[0])],
        lambda d, p, a: p[0](a), "VALID"),
    "LOGIC-28 FOL Modus Tollens": (
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: not p[1](a)],
        lambda d, p, a: not p[0](a), "VALID"),
    "LOGIC-29 Existential Generalization": (
        1, [lambda d, p, a: p[0](a)],
        lambda d, p, a: SOME(d, p[0]), "VALID"),
}

# ── Satisfiability battery: name -> (n_vars, clauses, seeded ground truth) ──
# These ask a different question from PROP/FOL (see sat_verdict), so they get
# their own dict rather than being forced into the premises-|-conclusion
# shape. v[0]=A, v[1]=B, v[2]=C throughout; one lambda per CNF clause, in the
# same left-to-right order as the formal_spec column.
#
# LOGIC-09 was seeded by migration 013 and, until 056, had NO machine check
# anywhere in this repo — it was the only 013/025 ROOT without one. Its
# 'SAT' claim was correct, but the repo could not demonstrate that. It can now.
SAT = {
    "LOGIC-09 Satisfiability": (
        # (A∨B)∧(¬A∨C)∧(¬B∨¬C) — models (F,T,F) and (T,F,T). Seeded SAT.
        3, [lambda v: v[0] or v[1],
            lambda v: (not v[0]) or v[2],
            lambda v: (not v[1]) or (not v[2])], "SAT"),
    "LOGIC-09N Satisfiability (reworded)": (
        # 056: N keeps the root formula clause-for-clause, restated as three
        # feature-flag policy rules. Seeded SAT.
        3, [lambda v: v[0] or v[1],
            lambda v: (not v[0]) or v[2],
            lambda v: (not v[1]) or (not v[2])], "SAT"),
    "LOGIC-09C Satisfiability (adversarial: local-satisfiability trap)": (
        # 056 trap: the root formula plus (A∨C) and (B∨¬C). Each added clause
        # is individually satisfiable, but (A∨C) kills the root's (F,T,F)
        # model and (B∨¬C) kills its (T,F,T) model, leaving none. Seeded
        # UNSAT — derived here from the trap's own clauses, not the root's.
        3, [lambda v: v[0] or v[1],
            lambda v: (not v[0]) or v[2],
            lambda v: (not v[1]) or (not v[2]),
            lambda v: v[0] or v[2],
            lambda v: v[1] or (not v[2])], "UNSAT"),
    "PILOT-F5-TRAP-SAT": (
        # 049 trap, spec 'P, ¬P ⊬ SAT': the clause set {P, ¬P}. Belongs here
        # and not in PROP because the prompt asks "Is this set satisfiable?"
        # — a satisfiability question, the same shape as LOGIC-09, not an
        # entailment. One unit clause per literal, v[0]=P. No assignment
        # satisfies both, so there is no witness to display. Seeded UNSAT.
        1, [lambda v: v[0], lambda v: not v[0]], "UNSAT"),
}


def main():
    failures = 0
    for name, (n, prem, concl, claimed) in PROP.items():
        verdict, cex = prop_verdict(n, prem, concl)
        ok = verdict == claimed
        failures += 0 if ok else 1
        mark = "PASS" if ok else "FAIL"
        extra = f"  countermodel {cex}" if cex and claimed == "INVALID" else ""
        print(f"[{mark}] {name}: computed={verdict} seeded={claimed}{extra}")
    for name, (k, prem, concl, claimed) in FOL.items():
        verdict, cex = fol_verdict(k, prem, concl)
        ok = verdict == claimed
        failures += 0 if ok else 1
        mark = "PASS" if ok else "FAIL"
        extra = f"  countermodel dom={cex[0]} ext={cex[1]} a={cex[2]}" if cex and claimed == "INVALID" else ""
        print(f"[{mark}] {name}: computed={verdict} seeded={claimed}{extra}")
    for name, (n, clauses, claimed) in SAT.items():
        verdict, witness = sat_verdict(n, clauses)
        ok = verdict == claimed
        failures += 0 if ok else 1
        mark = "PASS" if ok else "FAIL"
        # Mirror of the countermodel rule: a SAT verdict must show its model.
        extra = f"  model (A,B,C)={witness}" if witness and claimed == "SAT" else ""
        print(f"[{mark}] {name}: computed={verdict} seeded={claimed}{extra}")
    total = len(PROP) + len(FOL) + len(SAT)
    print(f"\n{total - failures}/{total} ground truths verified" + (" — ALL CORRECT" if failures == 0 else f" — {failures} MISMATCH(ES), DO NOT SHIP"))
    sys.exit(1 if failures else 0)


# ═══════════════════════════════════════════════════════════════════════
# Owl Semaphore family-consistency check (migration 029) — a SEPARATE,
# opt-in mode. Everything above this line is unchanged and has zero
# dependencies beyond the standard library; this addition needs a live DB
# connection (psycopg2) and only runs when explicitly invoked with
# --check-owl-families, so nothing about the existing offline oracle
# changes for anyone who doesn't ask for this.
#
# What it checks: an 'N' (non-normative/paraphrase) or 'C' (critical) row
# is only honest if it's really testing the SAME formal structure as its
# owl_root_id — reworded surface text, identical logical skeleton. This
# queries the live `tests` table and flags any N/C row whose formal_spec
# has drifted from its root's, which a human editing prompt_text by hand
# could do by accident and nothing else in the schema would catch.
def check_owl_families():
    try:
        import psycopg2
    except ImportError:
        print(
            "psycopg2 not installed — this check needs a live DB connection.\n"
            "Install with: pip install psycopg2-binary --break-system-packages",
            file=sys.stderr,
        )
        sys.exit(2)

    dsn = os.environ.get("DATABASE_URL")
    if not dsn:
        print("DATABASE_URL not set — see .env.example.", file=sys.stderr)
        sys.exit(2)

    conn = psycopg2.connect(dsn)
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT c.id, c.name, c.owl_type, c.formal_spec,
                       i.id AS root_id, i.name AS root_name, i.formal_spec AS root_spec
                FROM tests c
                JOIN tests i ON i.id = c.owl_root_id
                WHERE c.owl_type IN ('N', 'C')
                ORDER BY c.id
                """
            )
            rows = cur.fetchall()
    finally:
        conn.close()

    if not rows:
        print("No N/C rows exist yet — nothing to check (see docs/OWL_SEMAPHORE.md).")
        return

    failures = 0
    for cid, cname, owl_type, cspec, rid, rname, rspec in rows:
        if owl_type == "N":
            # Migration 036 canon: an N row is "the SAME formal_spec /
            # theorem as its owl_root_id, different surface text". Drift
            # here is always a bug.
            if cspec is not None and rspec is not None and cspec != rspec:
                failures += 1
                print(f"[FAIL] test {cid} '{cname}' (N) formal_spec drifted from "
                      f"root {rid} '{rname}': child={cspec!r} root={rspec!r}")
            else:
                print(f"[PASS] test {cid} '{cname}' (N) matches root {rid} '{rname}'")
        else:
            # C rows: 036 does NOT require spec equality — a C row that
            # presents the root's converse as a trap truthfully carries the
            # trap's structure, not the root's. Requiring equality here would
            # force the spec to lie about the stimulus. What a C row MUST
            # have is a spec at all (plus transform+flaw, DB-enforced by
            # owl_c_completeness).
            #
            # KNOWN LIMITATION: the final `else` below PASSES a C row whose
            # spec equals its root's. That is right when the root is itself a
            # fallacy (LOGIC-03/04/11), but it is also how LOGIC-06C's defect
            # slips past this check — see the module docstring. Only the
            # offline battery catches that one.
            if cspec is None:
                failures += 1
                print(f"[FAIL] test {cid} '{cname}' (C) has NULL formal_spec")
            elif cspec != rspec:
                print(f"[PASS] test {cid} '{cname}' (C) carries trap spec "
                      f"{cspec!r} (root {rid} '{rname}' = {rspec!r} — allowed for C)")
            else:
                print(f"[PASS] test {cid} '{cname}' (C) matches root {rid} '{rname}'")

    print(f"\n{len(rows) - failures}/{len(rows)} owl families consistent"
          + (" — ALL CORRECT" if failures == 0 else f" — {failures} MISMATCH(ES), DO NOT SHIP"))
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    if "--check-owl-families" in sys.argv:
        check_owl_families()
    else:
        main()
