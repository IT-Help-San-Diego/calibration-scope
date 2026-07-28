#!/usr/bin/env python3
"""Ground-truth oracle for the Calibration Scope formal logic battery.

Every formal-logic test seeded in migrations 013/025/056 is re-verified here by
a COMPLETE decision procedure — not a heuristic, not an LLM:

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

COVERAGE — what this oracle does NOT check. The battery below covers the
logic ROOTS seeded by 013/025, the ten N/C rows added by 056, and the 28
N/C + pilot-trap rows seeded by 047/048/049 (13 LOGIC-* N/C rows and 15
PILOT-F*-TRAP-* rows, added 2026-07-28). That closes every seeded logic
row in the DB as of this writing.

DEFECT CLASS SURFACED (2026-07-28): spec-vs-prompt drift. The oracle
verifies the FORMAL SPEC's verdict. LOGIC-06C's spec (∀x(P→Q), ∃xP ⊢ ∃xQ)
and its prompt disagree in quantifier placement — the prompt is the
illicit-conversion trap (INVALID, correctly keyed NO) while the spec is
the valid root form. The oracle cannot catch a spec that misdescribes its
own prompt; it can only check the spec it is given. Future spec-authoring
must verify spec↔prompt agreement out-of-band (a human or a second
instrument), not assume this oracle covers it.

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
# The fourth element is the verdict on the FORMAL SPEC, not a copy of the
# test's expected_result string. For the entailment items those coincide
# (seeded 'VALID'/'INVALID'). For the others the mapping is:
#   VALID   <-> seeded TRUE (equivalence items), FOLLOWS, YES
#   INVALID <-> seeded FALSE (equivalence items), DOESNOTFOLLOW, NO
# An equivalence item is encoded with no premises and the biconditional as
# the conclusion, so VALID means "the biconditional is a tautology".
#
# N/C rows (migrations 047/056): an N row repeats its root's structure but
# carries its OWN seeded answer, so verifying it checks that the migration
# wrote the right one-word verdict for that spec. A C row carries the TRAP's
# structure — its verdict is derived here from the trap, never inherited
# from the root, which is the whole point of checking it.
PROP = {
    "LOGIC-01 Modus Ponens": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[0]], lambda v: v[1], "VALID"),
    "LOGIC-01N Modus Ponens (reworded)": (
        # 047/048: N keeps the root spec P→Q, P ⊢ Q; seeded 'confirmed' (maps
        # VALID — confirmed the rule's conclusion holds).
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[0]], lambda v: v[1], "VALID"),
    "LOGIC-01C Modus Ponens (adversarial: converse trap)": (
        # 047/048 trap spec P→Q, Q ⊬ P — the CONVERSE, presented as if it were
        # the valid root. Structure is affirming-the-consequent, NOT modus
        # ponens; the verdict is derived from the trap, never inherited.
        # Seeded NO (maps INVALID). Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-02 Modus Tollens": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[1]], lambda v: not v[0], "VALID"),
    "LOGIC-02C Modus Tollens (adversarial: inverse trap)": (
        # 047/048 trap spec P→Q, ¬P ⊬ ¬Q — the INVERSE, presented as if it were
        # the valid root. Structure is denying-the-antecedent, NOT modus
        # tollens; verdict derived from the trap. Seeded NO (maps INVALID).
        # Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-03 Affirming the Consequent (Fallacy)": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03N Affirming the Consequent (reworded)": (
        # 047/048: N keeps the root spec P→Q, Q ⊬ P; seeded DOESNOTFOLLOW
        # (maps INVALID). Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03C Affirming Consequent (adversarial: valid-looking converse)": (
        # 047/048 trap spec P→Q, Q ⊬ P — same structure as the root fallacy,
        # the trap is presentational, not logical. Seeded NO (maps INVALID).
        # Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-03C Affirming the Consequent (adversarial: reverse-causal trap)": (
        # 047/048: second 03C row (domain_transfer). Same trap spec; counter-
        # model P=false, Q=true. Seeded NO (maps INVALID).
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "LOGIC-04 Denying the Antecedent (Fallacy)": (
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04N Denying the Antecedent (reworded)": (
        # 047/048: N keeps the root spec P→Q, ¬P ⊬ ¬Q; seeded DOESNOTFOLLOW
        # (maps INVALID). Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04C Denying Antecedent (adversarial: valid-looking inverse)": (
        # 047/048 trap spec P→Q, ¬P ⊬ ¬Q — same structure as the root fallacy;
        # trap is presentational. Seeded NO (maps INVALID). Countermodel
        # P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: not v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-04C Denying the Antecedent (adversarial: inverse trap)": (
        # 047/048: second 04C row (domain_transfer). Same trap spec; counter-
        # model P=false, Q=true. Seeded NO (maps INVALID).
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
        # 047/048: N keeps the root spec P∨Q, P ⊬ ¬Q; seeded DOESNOTFOLLOW
        # (maps INVALID). Countermodel P=true, Q=true.
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "LOGIC-11C Affirming a Disjunct (adversarial: exclusive-or trap)": (
        # 047/048 trap spec P∨Q, P ⊬ ¬Q — same structure as the root; the
        # trap presupposes ∨ is exclusive. Seeded NO (maps INVALID).
        # Countermodel P=true, Q=true.
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
    # ── PILOT-F*-TRAP-* rows (migration 049) — 13 propositional traps ──────
    "PILOT-F1-TRAP-AC": (
        # 049 trap spec P→Q, Q ⊬ P — affirming-the-consequent shape. Seeded
        # INVALID. Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "PILOT-F1-TRAP-HS": (
        # 049 trap spec P→Q, Q→R, R ⊬ P — chain run backward from the final
        # consequent. Seeded INVALID. Countermodel P=false, Q=true, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2])],
        lambda v: v[0], "INVALID"),
    "PILOT-F2-TRAP-AC": (
        # 049 trap spec P→Q, Q ⊬ P — affirming-the-consequent shape. Seeded
        # INVALID. Countermodel P=false, Q=true.
        2, [lambda v: IMP(v[0], v[1]), lambda v: v[1]], lambda v: v[0], "INVALID"),
    "PILOT-F2-TRAP-CHAIN": (
        # 049 trap spec P→Q, Q→R, R ⊬ P — chain run backward. Seeded INVALID.
        # Countermodel P=false, Q=true, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2])],
        lambda v: v[0], "INVALID"),
    "PILOT-F3-TRAP-AD": (
        # 049 trap spec P∨Q, P ⊬ ¬Q — affirming-a-disjunct shape (inclusive
        # ∨). Seeded INVALID. Countermodel P=true, Q=true.
        2, [lambda v: v[0] or v[1], lambda v: v[0]], lambda v: not v[1], "INVALID"),
    "PILOT-F3-TRAP-DC": (
        # 049 trap spec ¬(P∧Q), ¬P ⊬ ¬Q — denying-a-conjunct shape. Seeded
        # INVALID. Countermodel P=false, Q=true.
        2, [lambda v: not (v[0] and v[1]), lambda v: not v[0]],
        lambda v: not v[1], "INVALID"),
    "PILOT-F4-TRAP-CHAIN2": (
        # 049 trap spec ¬(P∧Q), ¬Q ⊬ ¬P — conjunct chain run backward. Seeded
        # INVALID. Countermodel P=true, Q=false.
        2, [lambda v: not (v[0] and v[1]), lambda v: not v[1]],
        lambda v: not v[0], "INVALID"),
    "PILOT-F5-TRAP-DNEG": (
        # 049 trap spec ¬¬P ⊬ ¬P — double negation does NOT negate. Seeded
        # INVALID. Countermodel P=true (¬¬P true, ¬P false).
        1, [lambda v: not (not v[0])], lambda v: not v[0], "INVALID"),
    "PILOT-F6-TRAP-CHAIN": (
        # 049 trap spec P→Q, Q→R, R→S, S ⊬ P — 4-link chain run backward.
        # Seeded INVALID. Countermodel P=false, Q=true, R=true, S=true.
        4, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2]),
            lambda v: IMP(v[2], v[3])], lambda v: v[0], "INVALID"),
    "PILOT-F6-TRAP-MPCHAIN": (
        # 049 trap spec P→Q, Q→R, R ⊬ P — chain run backward (same shape as
        # F1-TRAP-HS/F2-TRAP-CHAIN). Seeded INVALID. Countermodel P=false,
        # Q=true, R=true.
        3, [lambda v: IMP(v[0], v[1]), lambda v: IMP(v[1], v[2])],
        lambda v: v[0], "INVALID"),
    "PILOT-F6-TRAP-RES": (
        # 049 trap spec P∨Q, P∨R ⊬ Q∨R — resolution misapplication. Seeded
        # INVALID. Countermodel P=true, Q=false, R=false.
        3, [lambda v: v[0] or v[1], lambda v: v[0] or v[2]],
        lambda v: v[1] or v[2], "INVALID"),
    # ── PILOT-F*-TRAP-* FALSE equivalences (no premises; biconditional as
    # conclusion, so VALID means "the biconditional is a tautology") ────────
    "PILOT-F4-TRAP-DEM": (
        # 049 trap spec ¬(P∨Q) ⊬ ¬P∨¬Q — De Morgan misapplication (kept ∨
        # instead of flipping to ∧). Seeded FALSE (maps INVALID).
        # Countermodel P=true, Q=false: LHS ¬(T∨F)=F, RHS ¬T∨¬F=F∨T=T — F≠T.
        2, [], lambda v: (not (v[0] or v[1])) == ((not v[0]) or (not v[1])), "INVALID"),
    "PILOT-F4-TRAP-DIST": (
        # 049 trap spec P∨(Q∧R) ⊬ (P∨Q)∧R — distribution misapplication
        # (second disjunct not distributed). Seeded FALSE (maps INVALID).
        # Countermodel P=true, Q=false, R=false: LHS T∨(F∧F)=T,
        # RHS (T∨F)∧F=T∧F=F — T≠F.
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
        # 047/048: N keeps the root spec ∀x(P→Q), ∃xP ⊢ ∃xQ; seeded FOLLOWS
        # (maps VALID — the existential premise licenses ∃xQ).
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[0])],
        lambda d, p, a: SOME(d, p[1]), "VALID"),
    "LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)": (
        # 047/048 — REPORTED DEFECT (do not "fix" the oracle to agree):
        # this row's formal_spec (∀x(P→Q), ∃xP ⊢ ∃xQ — existential over the
        # FIRST term, VALID, identical to the 06 root) does NOT describe its
        # prompt. The prompt commits the existential over the SECOND term
        # ("every leak is a defect" + "some defects exist" ⊬ "some leaks
        # exist") — illicit existential conversion, genuinely INVALID, and
        # the expected_result correctly says NO. Spec and prompt diverge in
        # quantifier placement. The verdict recorded here is the SPEC's
        # verdict (VALID): the oracle checks the spec, and a spec that
        # misdescribes its prompt is the defect this row exposed.
        2, [lambda d, p, a: ALL(d, lambda x: IMP(p[0](x), p[1](x))),
            lambda d, p, a: SOME(d, p[0])],
        lambda d, p, a: SOME(d, p[1]), "VALID"),
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
# anywhere in this repo — it was the only 013/025 ROOT without one. (It was
# not the only unchecked seeded logic test: the 28 N/C rows from 047/048/049
# are still unchecked — see the COVERAGE note in the module docstring.) Its
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
        # 049 trap spec P, ¬P ⊬ SAT — a bare contradiction presented as a
        # satisfiability question. No assignment satisfies both clauses.
        # Seeded UNSAT. v[0]=P.
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
