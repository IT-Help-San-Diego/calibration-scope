-- v047: Owl Semaphore N/C family coverage — close the σᵥ (paraphrase) and
-- C2 (adversarial) gap on four uncovered reasoning families.
--
-- Before this migration the registry had N=1 (LOGIC-01N) and C=4
-- (LOGIC-01C..04C), all rooted on LOGIC-01..04. Families LOGIC-03, LOGIC-04,
-- LOGIC-06, LOGIC-11 had Identity rows with zero non-Identity siblings — the
-- owl_family_coverage view honestly reported them as not fully instrumented.
-- This migration authors N (paraphrase, truth-value invariant) and C
-- (reworded + named pattern-matching trap) siblings for those four roots.
--
-- Discipline (unchanged project rules):
--   * N rows keep the EXACT formal_spec of their owl_root_id — only the
--     surface text changes. The one-word answer is the demodulated truth
--     value, so a model passing the 'I' phrasing but failing the paraphrase
--     exposes pattern-matching, not reasoning.
--   * C rows carry BOTH owl_transform (what changed at the surface) and
--     owl_flaw (the specific shortcut the item is built to expose), enforced
--     by the owl_c_completeness check from migration 036.
--   * expected_result is the ground-truth verdict; scoring stays 'exact'.
--   * No answer leakage: the prompt never names the fallacy it's testing
--     (the 'C' prompt asks for the error AFTER the verdict, mirroring
--     LOGIC-01C's established shape).

-- ── LOGIC-03 Affirming the Consequent (root id=28, INVALID) ─────────────
-- N: same structure P→Q, Q ⊬ P, new domain + one-word demodulated answer.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id, owl_transform)
VALUES (
  'LOGIC-03N Affirming the Consequent (reworded)',
  'reasoning',
  E'A certificate authority revokes a key precisely when that key is reported compromised. This key was just revoked. A junior analyst writes: "So the key must have been reported compromised." Taking the analyst''s conclusion on its own logic, does it follow? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'DOESNOTFOLLOW',
  'exact',
  3,
  'P → Q, Q ⊬ P',
  'N', 28, 'domain_transfer'
);

-- C: present the fallacy's converse as if valid; trap = the "revoked ⟹
-- compromised" reading feels right because revocations USUALLY follow reports.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
VALUES (
  'LOGIC-03C Affirming the Consequent (adversarial: reverse-causal trap)',
  'reasoning',
  E'Premise 1: If a model was trained on contaminated data, then its benchmark scores are inflated. Premise 2: This model''s benchmark scores are inflated. A reviewer concludes: "Therefore the model was trained on contaminated data." Is the reviewer''s conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — affirming the consequent. From "contaminated → inflated" and "inflated" you cannot infer "contaminated"; inflated scores have other causes.',
  'exact',
  3,
  'P → Q, Q ⊬ P',
  'C', 28,
  'domain_transfer',
  'reverse-causal bait: inflated scores usually DO signal contamination in practice, priming a plausible-but-invalid converse inference'
);

-- ── LOGIC-04 Denying the Antecedent (root id=29, INVALID) ───────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id, owl_transform)
VALUES (
  'LOGIC-04N Denying the Antecedent (reworded)',
  'reasoning',
  E'A service accepts a connection only if the client presents a valid token. This client did not present a valid token. A log annotation claims: "So the service did not reject the connection for some other reason." Does that annotation follow from the two facts? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'DOESNOTFOLLOW',
  'exact',
  3,
  'P → Q, ¬P ⊬ ¬Q',
  'N', 29, 'domain_transfer'
);

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
VALUES (
  'LOGIC-04C Denying the Antecedent (adversarial: inverse trap)',
  'reasoning',
  E'Premise 1: If the cache is warm, then responses are fast. Premise 2: The cache is not warm. An on-call engineer concludes: "Therefore responses are not fast." Is this conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — denying the antecedent. From "warm → fast" and "not warm" you cannot infer "not fast"; a cold cache can still serve fast responses from a warm CDN upstream.',
  'exact',
  3,
  'P → Q, ¬P ⊬ ¬Q',
  'C', 29,
  'domain_transfer',
  'inverse trap: "not warm → not fast" pattern-matches the valid modus tollens shape, priming a VALID guess on an invalid inference'
);

-- ── LOGIC-06 Existential Syllogism (root id=31, VALID) ──────────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id, owl_transform)
VALUES (
  'LOGIC-06N Existential Syllogism (reworded)',
  'reasoning',
  E'Every unsigned driver is a stability risk. At least one unsigned driver is installed on this machine. A report states: "At least one stability risk is present on this machine." Does the report follow from the premises? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'FOLLOWS',
  'exact',
  3,
  '∀x(P→Q), ∃xP ⊢ ∃xQ',
  'N', 31, 'domain_transfer'
);

-- C: trap = the existential fallacy's INVALID twin (∀x(P→Q), ∃xQ ⊬ ∃xP)
-- looks nearly identical to the valid form; only the quantifier position differs.
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
VALUES (
  'LOGIC-06C Existential Syllogism (adversarial: quantifier-swap trap)',
  'reasoning',
  E'Premise 1: Every memory leak is a correctness defect. Premise 2: Some correctness defects exist in this build. A reviewer concludes: "Therefore some memory leaks exist in this build." Is this conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — illicit existential conversion. From "leak → defect" and "some defects exist" you cannot infer "some leaks exist"; the defects may be entirely non-leak defects. The valid form needs "some leaks exist" as the premise.',
  'exact',
  3,
  '∀x(P→Q), ∃xP ⊢ ∃xQ',
  'C', 31,
  'domain_transfer',
  'quantifier-swap bait: swaps the existential premise from the subject class to the predicate class, producing an invalid form that visually mirrors the valid Barbara-with-existential'
);

-- ── LOGIC-11 Affirming a Disjunct (root id=40, INVALID) ─────────────────
INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id, owl_transform)
VALUES (
  'LOGIC-11N Affirming a Disjunct (reworded)',
  'reasoning',
  E'The alert fired because of a threshold breach or a sensor fault (possibly both). The on-call log confirms a threshold breach occurred. The log then asserts: "So no sensor fault occurred." Given the inclusive "or," does that assertion follow? Answer with exactly one word: FOLLOWS or DOESNOTFOLLOW.',
  'DOESNOTFOLLOW',
  'exact',
  3,
  'P ∨ Q, P ⊬ ¬Q',
  'N', 40, 'domain_transfer'
);

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method,
                   trials_per_run, formal_spec, owl_type, owl_root_id,
                   owl_transform, owl_flaw)
VALUES (
  'LOGIC-11C Affirming a Disjunct (adversarial: exclusive-or trap)',
  'reasoning',
  E'Premise 1: The request failed because of a timeout or a DNS resolution error. Premise 2: The request failed because of a timeout. A postmortem concludes: "Therefore the request did not fail because of a DNS resolution error." (Note: "or" here is inclusive — both causes can hold at once.) Is the postmortem''s conclusion logically valid? Answer YES or NO, then name the specific error if any.',
  'NO — affirming a disjunct. With inclusive or, confirming one disjunct (timeout) does not negate the other (DNS); both can be true simultaneously.',
  'exact',
  3,
  'P ∨ Q, P ⊬ ¬Q',
  'C', 40,
  'domain_transfer',
  'exclusive-or bait: English "or" is often read exclusively, priming an INVALID-reading of a structure that is invalid precisely because the or is inclusive'
);
