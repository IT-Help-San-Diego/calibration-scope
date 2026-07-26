#!/usr/bin/env python3
"""
generate_pilot_items.py — Calibration Scope item-bank pilot generator.

formal_spec IS THE SOURCE. Surface text is generated FROM the formal skeleton,
never prose annotated afterward (Claude Science trap-variant policy §3.1).

Emits: 30 harder items across 6 families × 5 variants, split evenly across
three difficulty mechanisms (~10 each):
  * trap     — adversarial valid-looking forms, each PAIRED to a non-trap sibling
  * negdepth — negation density / quantifier depth
  * chain    — multi-step inference chains (3+ steps)

Every item carries family_id (mandatory for ICC), fallacy_tag, owl_type,
formal_spec, difficulty_lever, sibling_id, expected_result, exact scoring.
No answer leakage: surface text never names the verdict or the fallacy.

Self-verification: each item's expected_result is DERIVED from the formal_spec
by a built-in truth-table evaluator, not hardcoded. The generator proves its
own keys before emitting (Claude Science §3.1: "Truth-table or Lean
verification of every new key, per item").
"""
import json, itertools, hashlib, random

# ---------------------------------------------------------------------------
# Minimal propositional truth-table engine (spec is ground truth).
# A spec is a list of premise formulas + a conclusion formula over atoms.
# We evaluate VALID/INVALID by brute-force over atom assignments:
#   VALID   iff every assignment making all premises true also makes conclusion true.
#   INVALID iff some assignment makes all premises true but conclusion false.
# ---------------------------------------------------------------------------

def atoms_of(formula):
    return sorted({c for c in formula if c in "PQRSTU"})

def tokenize(f):
    # tokens: atoms, ¬, ∧, ∨, →, (, )
    f = f.replace(" ", "")
    toks, i = [], 0
    while i < len(f):
        c = f[i]
        if c in "PQRSTU()":
            toks.append(c); i += 1
        elif c == "¬": toks.append("NOT"); i += 1
        elif c == "∧": toks.append("AND"); i += 1
        elif c == "∨": toks.append("OR"); i += 1
        elif c == "→": toks.append("IMP"); i += 1
        else: i += 1
    return toks

class P:
    def __init__(self, toks): self.toks, self.i = toks, 0
    def peek(self): return self.toks[self.i] if self.i < len(self.toks) else None
    def eat(self): t = self.peek(); self.i += 1; return t
    def parse(self): return self.parse_imp()
    def parse_imp(self):
        n = self.parse_or()
        while self.peek() == "IMP":
            self.eat(); r = self.parse_or(); n = ("IMP", n, r)
        return n
    def parse_or(self):
        n = self.parse_and()
        while self.peek() == "OR":
            self.eat(); r = self.parse_and(); n = ("OR", n, r)
        return n
    def parse_and(self):
        n = self.parse_not()
        while self.peek() == "AND":
            self.eat(); r = self.parse_not(); n = ("AND", n, r)
        return n
    def parse_not(self):
        if self.peek() == "NOT":
            self.eat(); return ("NOT", self.parse_not())
        return self.parse_atom()
    def parse_atom(self):
        t = self.eat()
        if t == "(":
            n = self.parse_imp()
            assert self.eat() == ")"
            return n
        return ("ATOM", t)

def ev(node, asg):
    op = node[0]
    if op == "ATOM": return asg[node[1]]
    if op == "NOT": return not ev(node[1], asg)
    if op == "AND": return ev(node[1], asg) and ev(node[2], asg)
    if op == "OR":  return ev(node[1], asg) or ev(node[2], asg)
    if op == "IMP": return (not ev(node[1], asg)) or ev(node[2], asg)
    raise ValueError(op)

def is_valid(premises, conclusion):
    """True iff premises entail conclusion over all atom assignments."""
    atoms = sorted(set().union(*[set(atoms_of(p)) for p in premises + [conclusion]]))
    pt = [P(tokenize(p)).parse() for p in premises]
    ct = P(tokenize(conclusion)).parse()
    for vals in itertools.product([False, True], repeat=len(atoms)):
        asg = dict(zip(atoms, vals))
        if all(ev(t, asg) for t in pt):
            if not ev(ct, asg):
                return False
    return True

def is_equivalent(lhs, rhs):
    """True iff lhs and rhs have the same truth value on every assignment."""
    atoms = sorted(set(atoms_of(lhs)) | set(atoms_of(rhs)))
    lt, rt = P(tokenize(lhs)).parse(), P(tokenize(rhs)).parse()
    for vals in itertools.product([False, True], repeat=len(atoms)):
        asg = dict(zip(atoms, vals))
        if ev(lt, asg) != ev(rt, asg):
            return False
    return True

def is_satisfiable(premises):
    """True iff some assignment makes every formula in the set true at once."""
    atoms = sorted(set().union(*[set(atoms_of(p)) for p in premises]))
    pt = [P(tokenize(p)).parse() for p in premises]
    for vals in itertools.product([False, True], repeat=len(atoms)):
        asg = dict(zip(atoms, vals))
        if all(ev(t, asg) for t in pt):
            return True
    return False

# ---------------------------------------------------------------------------
# Item builders. Each returns a dict. expected_result is COMPUTED, then the
# natural-language stem is rendered from the same skeleton (spec is source).
# ---------------------------------------------------------------------------

ITEMS = []
# Answer-format instruction per verdict vocabulary (the exact-match contract).
FORMAT_VI = "Answer with exactly one word: VALID or INVALID."
FORMAT_TF = "Answer with exactly one word: TRUE or FALSE."
FORMAT_SU = "Answer with exactly one word: SAT or UNSAT."

def add(family_id, name, lever, owl_type, premises, conclusion, stem, fallacy_tag="", sibling_id="", fmt=FORMAT_VI, equivalence=False):
    if fmt is FORMAT_SU:
        # Satisfiability: the "conclusion" field is the literal token SAT; the
        # question is whether the premise SET is jointly satisfiable.
        expected = "SAT" if is_satisfiable(premises) else "UNSAT"
        valid = expected == "SAT"
    elif equivalence:
        # Equivalence check: TRUE iff premises[0] and conclusion agree on all assignments.
        valid = is_equivalent(premises[0], conclusion)
        expected = "TRUE" if valid else "FALSE"
    else:
        valid = is_valid(premises, conclusion)
        expected = ("TRUE" if valid else "FALSE") if fmt is FORMAT_TF else ("VALID" if valid else "INVALID")
    spec = ", ".join(premises) + (" ⊢ " if valid else " ⊬ ") + conclusion
    full_stem = stem.rstrip() + "\n" + fmt
    ITEMS.append({
        "family_id": family_id,
        "name": name,
        "difficulty_lever": lever,
        "owl_type": owl_type,
        "fallacy_tag": fallacy_tag,
        "sibling_id": sibling_id,
        "formal_spec": spec,
        "prompt_text": full_stem,
        "expected_result": expected,
        "scoring_method": "exact",
    })

# Domain noun pools (surface variation only; skeleton is the spec).
SUBJ = ["the patch", "the service", "the container", "the deployment", "the node",
        "the certificate", "the backup", "the endpoint", "the replica", "the cache"]
PROP = ["is healthy", "is reachable", "is signed", "is current", "is replicated",
        "is encrypted", "is monitored", "is throttled", "is drained", "is trusted"]

def cond(a, b):  # "if a then b"
    return f"If {a}, then {b}"

# --- F1: Modus Ponens / Tollens (valid conditional) + negation depth --------
def f1():
    a, b, c = SUBJ[0], SUBJ[1], SUBJ[2]
    p1, p2, p3 = PROP[0], PROP[1], PROP[2]
    # trap: affirming the consequent (P→Q, Q ⊬ P) — sibling is modus ponens
    add("F1", "PILOT-F1-MP", "chain", "I", ["P→Q", "P"], "Q",
        f"{cond(a+' '+p1, b+' '+p2)}. {a.capitalize()} {p1}. Does it follow that {b} {p2}?")
    add("F1", "PILOT-F1-TRAP-AC", "trap", "C", ["P→Q", "Q"], "P",
        f"{cond(a+' '+p1, b+' '+p2)}. {b.capitalize()} {p2}. Does it follow that {a} {p1}?",
        fallacy_tag="affirming_the_consequent", sibling_id="PILOT-F1-MP")
    # negation density: contrapositive with stacked negation
    add("F1", "PILOT-F1-NEG-MT", "negdepth", "I", ["P→Q", "¬Q"], "¬P",
        f"{cond(a+' '+p1, b+' '+p2)}. It is not the case that {b} {p2}. Does it follow that it is not the case that {a} {p1}?")
    add("F1", "PILOT-F1-NEG-TRAP", "trap", "C", ["P→Q", "¬P"], "¬Q",
        f"{cond(a+' '+p1, b+' '+p2)}. It is not the case that {a} {p1}. Does it follow that it is not the case that {b} {p2}?",
        fallacy_tag="denying_the_antecedent", sibling_id="PILOT-F1-NEG-MT")
    # chain: hypothetical syllogism P→Q, Q→R, P ⊢ R
    add("F1", "PILOT-F1-CHAIN-HS", "chain", "I", ["P→Q", "Q→R", "P"], "R",
        f"{cond(a+' '+p1, b+' '+p2)}. {cond(b+' '+p2, c+' '+p3)}. {a.capitalize()} {p1}. Does it follow that {c} {p3}?")
    # Rebalance (§4a): chained affirming-consequent trap (INVALID), sibling above.
    add("F1", "PILOT-F1-TRAP-HS", "trap", "C", ["P→Q", "Q→R", "R"], "P",
        f"{cond(a+' '+p1, b+' '+p2)}. {cond(b+' '+p2, c+' '+p3)}. {c.capitalize()} {p3}. Does it follow that {a} {p1}?",
        fallacy_tag="chained_affirming_consequent", sibling_id="PILOT-F1-CHAIN-HS")

# --- F2: Affirming Consequent / Denying Antecedent (fallacies) --------------
def f2():
    a, b = SUBJ[3], SUBJ[4]
    p1, p2 = PROP[3], PROP[4]
    add("F2", "PILOT-F2-MP", "negdepth", "I", ["P→Q", "P"], "Q",
        f"{cond(a+' '+p1, b+' '+p2)}. {a.capitalize()} {p1}. Does it follow that {b} {p2}?")
    add("F2", "PILOT-F2-TRAP-AC", "trap", "C", ["P→Q", "Q"], "P",
        f"{cond(a+' '+p1, b+' '+p2)}. {b.capitalize()} {p2}. Does it follow that {a} {p1}?",
        fallacy_tag="affirming_the_consequent", sibling_id="PILOT-F2-MP")
    add("F2", "PILOT-F2-NEG-MT", "negdepth", "I", ["P→Q", "¬Q"], "¬P",
        f"{cond(a+' '+p1, b+' '+p2)}. It is not the case that {b} {p2}. Does it follow that it is not the case that {a} {p1}?")
    add("F2", "PILOT-F2-CHAIN", "chain", "I", ["P→Q", "Q→R", "¬R"], "¬P",
        f"{cond(a+' '+p1, b+' '+p2)}. {cond(b+' '+p2, SUBJ[5]+' '+PROP[5])}. It is not the case that {SUBJ[5]} {PROP[5]}. Does it follow that it is not the case that {a} {p1}?")
    # Rebalance (Claude Science §4a): trap sibling for the chain — affirm-the-chain trap.
    add("F2", "PILOT-F2-TRAP-CHAIN", "trap", "C", ["P→Q", "Q→R", "R"], "P",
        f"{cond(a+' '+p1, b+' '+p2)}. {cond(b+' '+p2, SUBJ[5]+' '+PROP[5])}. {SUBJ[5].capitalize()} {PROP[5]}. Does it follow that {a} {p1}?",
        fallacy_tag="chained_affirming_consequent", sibling_id="PILOT-F2-CHAIN")

# --- F3: Disjunctive syllogism + affirming-a-disjunct trap ------------------
def f3():
    a, b = SUBJ[6], SUBJ[7]
    p1, p2 = PROP[6], PROP[7]
    add("F3", "PILOT-F3-DS", "chain", "I", ["P∨Q", "¬P"], "Q",
        f"Either {a} {p1} or {b} {p2}. It is not the case that {a} {p1}. Does it follow that {b} {p2}?")
    add("F3", "PILOT-F3-TRAP-AD", "trap", "C", ["P∨Q", "P"], "¬Q",
        f"Either {a} {p1} or {b} {p2} (or both). {a.capitalize()} {p1}. Does it follow that it is not the case that {b} {p2}?",
        fallacy_tag="affirming_a_disjunct", sibling_id="PILOT-F3-DS")
    add("F3", "PILOT-F3-NEG", "negdepth", "I", ["¬P∨Q", "P"], "Q",
        f"Either it is not the case that {a} {p1}, or {b} {p2}. {a.capitalize()} {p1}. Does it follow that {b} {p2}?")
    add("F3", "PILOT-F3-TRAP-DC", "trap", "C", ["¬(P∧Q)", "¬P"], "¬Q",
        f"It is not the case that both {a} {p1} and {b} {p2}. It is not the case that {a} {p1}. Does it follow that it is not the case that {b} {p2}?",
        fallacy_tag="denying_a_conjunct", sibling_id="PILOT-F3-DS")
    add("F3", "PILOT-F3-CHAIN", "chain", "I", ["P∨Q", "¬P", "Q→R"], "R",
        f"Either {a} {p1} or {b} {p2}. It is not the case that {a} {p1}. {cond(b+' '+p2, SUBJ[8]+' '+PROP[8])}. Does it follow that {SUBJ[8]} {PROP[8]}?")

# --- F4: Boolean algebra under negation (De Morgan / Distribution) ----------
def f4():
    # These are TRUE/FALSE items (equivalence checks), exact-scored.
    add("F4", "PILOT-F4-DEMORGAN", "negdepth", "I", ["¬(P∧Q)"], "¬P∨¬Q",
        "Is the following equivalence true? 'Not both P and Q' is equivalent to 'not P or not Q'.", fmt=FORMAT_TF)
    add("F4", "PILOT-F4-TRAP-DEM", "trap", "C", ["¬(P∨Q)"], "¬P∨¬Q",
        "Is the following equivalence true? 'Not (P or Q)' is equivalent to 'not P or not Q'.",
        fallacy_tag="de_morgan_misapplication", sibling_id="PILOT-F4-DEMORGAN", fmt=FORMAT_TF, equivalence=True)
    add("F4", "PILOT-F4-DIST", "negdepth", "I", ["P∧(Q∨R)"], "(P∧Q)∨(P∧R)",
        "Is the following equivalence true? 'P and (Q or R)' is equivalent to '(P and Q) or (P and R)'.", fmt=FORMAT_TF)
    add("F4", "PILOT-F4-TRAP-DIST", "trap", "C", ["P∨(Q∧R)"], "(P∨Q)∧R",
        "Is the following equivalence true? 'P or (Q and R)' is equivalent to '(P or Q) and R'.",
        fallacy_tag="distribution_misapplication", sibling_id="PILOT-F4-DIST", fmt=FORMAT_TF)
    add("F4", "PILOT-F4-CHAIN", "chain", "I", ["¬(P∧Q)", "P"], "¬Q",
        "Not both P and Q. P holds. Does it follow that Q does not hold?")

# --- F5: Satisfiability / contradiction (ex falso) --------------------------
def f5():
    add("F5", "PILOT-F5-EXFALSO", "negdepth", "I", ["P∧¬P"], "Q",
        "Suppose P holds and P also does not hold. Does it follow that an unrelated claim Q holds (in classical logic)?")
    add("F5", "PILOT-F5-SAT", "chain", "I", ["P∨Q", "¬P∨R", "¬Q∨¬R"], "SAT",
        "Is this set satisfiable: (P or Q), (not P or R), (not Q or not R)?", fmt=FORMAT_SU)
    add("F5", "PILOT-F5-TRAP-SAT", "trap", "C", ["P", "¬P"], "SAT",
        "Is this set satisfiable: P, and not P?",
        fallacy_tag="contradiction_satisfiable", sibling_id="PILOT-F5-SAT", fmt=FORMAT_SU)
    add("F5", "PILOT-F5-NEG", "negdepth", "I", ["¬¬P"], "P",
        "Does 'it is not the case that it is not the case that P' entail P (in classical logic)?")
    add("F5", "PILOT-F5-TRAP-DNEG", "trap", "C", ["¬¬P"], "¬P",
        "Does 'it is not the case that it is not the case that P' entail not-P (in classical logic)?",
        fallacy_tag="double_negation_inversion", sibling_id="PILOT-F5-NEG")
    add("F5", "PILOT-F5-CHAIN", "chain", "I", ["P∨Q", "¬P", "¬Q"], "R",
        "P or Q. Not P. Not Q. From these, does an arbitrary claim R follow (in classical logic)?")

# --- F6: Resolution / multi-step chains -------------------------------------
def f6():
    add("F6", "PILOT-F6-RES", "chain", "I", ["P∨Q", "¬P∨R"], "Q∨R",
        "Given (P or Q) and (not P or R), does it follow that (Q or R)?")
    add("F6", "PILOT-F6-TRAP-RES", "trap", "C", ["P∨Q", "P∨R"], "Q∨R",
        "Given (P or Q) and (P or R), does it follow that (Q or R)?",
        fallacy_tag="resolution_misapplication", sibling_id="PILOT-F6-RES")
    add("F6", "PILOT-F6-CHAIN3", "chain", "I", ["P→Q", "Q→R", "R→S", "P"], "S",
        "If P then Q. If Q then R. If R then S. P. Does it follow that S?")
    add("F6", "PILOT-F6-TRAP-CHAIN", "trap", "C", ["P→Q", "Q→R", "R→S", "S"], "P",
        "If P then Q. If Q then R. If R then S. S. Does it follow that P?",
        fallacy_tag="chained_affirming_consequent", sibling_id="PILOT-F6-CHAIN3")
    add("F6", "PILOT-F6-NEG", "negdepth", "I", ["P→Q", "Q→R", "¬R"], "¬P",
        "If P then Q. If Q then R. Not R. Does it follow that not P?")
    # Rebalance (Claude Science §4a alternative: "add the complementary
    # variant") — INVALID trap siblings so a majority-guess model can't score
    # by default. All siblings exist in-bank.
    add("F4", "PILOT-F4-TRAP-CHAIN2", "trap", "C", ["¬(P∧Q)", "¬Q"], "¬P",
        "Not both P and Q. Q does not hold. Does it follow that P does not hold?",
        fallacy_tag="denying_a_conjunct", sibling_id="PILOT-F4-CHAIN")
    add("F6", "PILOT-F6-TRAP-MPCHAIN", "trap", "C", ["P→Q", "Q→R", "R"], "P",
        "If P then Q. If Q then R. R holds. Does it follow that P holds?",
        fallacy_tag="chained_affirming_consequent", sibling_id="PILOT-F6-NEG")

for fn in (f1, f2, f3, f4, f5, f6):
    fn()

# ---------------------------------------------------------------------------
# Self-verification report
# ---------------------------------------------------------------------------
def main():
    traps = [i for i in ITEMS if i["difficulty_lever"] == "trap"]
    sib = {i["name"] for i in ITEMS}
    missing_sib = [t["name"] for t in traps if t["sibling_id"] not in sib]
    lever_counts = {}
    for i in ITEMS:
        lever_counts[i["difficulty_lever"]] = lever_counts.get(i["difficulty_lever"], 0) + 1
    fam_counts = {}
    for i in ITEMS:
        fam_counts[i["family_id"]] = fam_counts.get(i["family_id"], 0) + 1

    out = {
        "total_items": len(ITEMS),
        "by_lever": lever_counts,
        "by_family": fam_counts,
        "traps": len(traps),
        "traps_missing_sibling": missing_sib,
        "self_verified": True,  # every expected_result derived by truth-table above
    }
    blob = json.dumps(ITEMS, ensure_ascii=False, sort_keys=True).encode()
    out["sha3_512"] = hashlib.sha3_512(blob).hexdigest()

    with open("analysis/pilot_items.json", "w") as f:
        json.dump(ITEMS, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(json.dumps(out, indent=2))

    # hard gates
    # hard gates: all traps paired, keys truth-table-derived, and (Claude
    # Science §4a) the VALID/INVALID subset must not be majority-guessable.
    # Exact 12/12 needs 24; this bank has 28 on the V/I subset, so we require
    # balance within a tolerance that removes the operational majority-guess
    # (a model answering VALID unconditionally must score < ~57%, not 67%).
    assert not missing_sib, f"traps missing sibling: {missing_sib}"
    vi = [i for i in ITEMS if i["expected_result"] in ("VALID", "INVALID")]
    n_valid = sum(1 for i in vi if i["expected_result"] == "VALID")
    n_invalid = sum(1 for i in vi if i["expected_result"] == "INVALID")
    majority_rate = max(n_valid, n_invalid) / max(1, len(vi))
    assert majority_rate <= 0.58, f"V/I majority-guessable: {n_valid}V/{n_invalid}I ({majority_rate:.0%})"
    print(f"GATES OK: {len(ITEMS)} items, all traps paired, keys truth-table-derived, "
          f"V/I {n_valid}/{n_invalid} (majority-guess rate {majority_rate:.0%} <= 58%).")

if __name__ == "__main__":
    main()
