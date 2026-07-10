-- v025: Expanded formal logic battery (Phase 1+2 of the expansion plan).
--
-- Taxonomy sources: LogicAsker (Wan et al., EMNLP 2024) for the fallacy
-- forms and LogicBench (Patel et al., ACL 2024) for the valid-inference
-- baseline. Prompts are ORIGINAL content (contamination resistance) — the
-- papers contribute the formal structures, never the surface text.
--
-- VERIFICATION CONTRACT: every ground truth below is machine-checked by
-- scripts/verify_logic_ground_truth.py — a complete decision procedure
-- (truth tables for propositional; exhaustive small-model search for
-- monadic FOL, complete by the finite-model property). 28/28 verified
-- before this migration was committed. The formal_spec column carries the
-- exact structure so any reader can re-derive the verdict.
--
-- AUDIT NOTE (2026-07-09): the source planning document's "Denying a
-- Conjunct" table entry (¬(P∧Q), P ⊢ Q) contradicted its own corrected
-- example. Truth-table check settled it: the classic fallacy is
-- ¬(P∧Q), ¬P ⊢ ¬Q (INVALID) and its near-twin ¬(P∧Q), P ⊢ ¬Q is VALID
-- (conjunctive syllogism). BOTH are seeded — the contrast pair is a
-- deliberate discrimination test: a model pattern-matching on "negative
-- conjunction vibes" will get one of them wrong.

ALTER TABLE tests ADD COLUMN IF NOT EXISTS formal_spec TEXT;

-- Formal specs for the existing battery (013), now first-class provenance.
UPDATE tests SET formal_spec = 'P → Q, P ⊢ Q'                    WHERE name = 'LOGIC-01 Modus Ponens' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = 'P → Q, ¬Q ⊢ ¬P'                  WHERE name = 'LOGIC-02 Modus Tollens' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = 'P → Q, Q ⊬ P'                    WHERE name = 'LOGIC-03 Affirming the Consequent (Fallacy)' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = 'P → Q, ¬P ⊬ ¬Q'                  WHERE name = 'LOGIC-04 Denying the Antecedent (Fallacy)' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = '∀x(M→P), ∀x(S→M) ⊢ ∀x(S→P)'      WHERE name = 'LOGIC-05 Syllogism - Barbara (AAA-1)' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = '∀x(P→Q), ∃xP ⊢ ∃xQ'              WHERE name = 'LOGIC-06 Syllogism - Existential Fallacy' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = '¬(P∧Q) ⟷ ¬P∨¬Q'                  WHERE name = 'LOGIC-07 Boolean Algebra - De Morgan' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = 'P∧(Q∨R) ⟷ (P∧Q)∨(P∧R)'           WHERE name = 'LOGIC-08 Boolean Algebra - Distribution' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = '(A∨B)∧(¬A∨C)∧(¬B∨¬C) — SAT'      WHERE name = 'LOGIC-09 Satisfiability' AND formal_spec IS NULL;
UPDATE tests SET formal_spec = 'P∧¬P ⊢ anything (ex falso quodlibet)' WHERE name = 'LOGIC-10 Contradiction Detection' AND formal_spec IS NULL;

INSERT INTO tests (name, axis, prompt_text, expected_result, scoring_method, trials_per_run, formal_spec)
VALUES
  -- ── Propositional fallacies (LogicAsker items 3–5) ──────────────────
  (
    'LOGIC-11 Affirming a Disjunct (Fallacy)',
    'reasoning',
    'Premise 1: The outage was caused by a hardware failure or a configuration error.
Premise 2: The outage was caused by a hardware failure.
Conclusion: The outage was not caused by a configuration error.
Is this argument valid? (Note: "or" here is inclusive.) Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    'P ∨ Q, P ⊬ ¬Q'
  ),
  (
    'LOGIC-12 Denying a Conjunct (Fallacy)',
    'reasoning',
    'Premise 1: It is not the case that both the firewall is enabled and the VPN is active.
Premise 2: The firewall is not enabled.
Conclusion: The VPN is not active.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '¬(P∧Q), ¬P ⊬ ¬Q'
  ),
  (
    'LOGIC-13 Conjunctive Syllogism',
    'reasoning',
    'Premise 1: It is not the case that both the primary server and the backup server are offline.
Premise 2: The primary server is offline.
Conclusion: The backup server is not offline.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '¬(P∧Q), P ⊢ ¬Q — the VALID near-twin of LOGIC-12; the pair discriminates pattern-matching from reasoning'
  ),
  (
    'LOGIC-14 Illicit Commutativity (Fallacy)',
    'reasoning',
    'Premise: If a certificate is expired, then the TLS handshake fails.
Conclusion: If the TLS handshake fails, then the certificate is expired.
Does the conclusion follow from the premise? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    'P → Q ⊬ Q → P'
  ),

  -- ── Valid propositional baselines (LogicBench; Resolution = GPT-4o 4%) ──
  (
    'LOGIC-15 Resolution',
    'reasoning',
    'Premise 1: The alert came from the scanner or from the honeypot.
Premise 2: The alert did not come from the scanner, or the incident is critical.
Conclusion: The alert came from the honeypot, or the incident is critical.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '(P∨Q) ∧ (¬P∨R) ⊢ Q∨R — hardest valid rule in LogicAsker (GPT-4o: 4%)'
  ),
  (
    'LOGIC-16 Disjunctive Syllogism',
    'reasoning',
    'Premise 1: The ticket was closed by the technician or by the automation bot.
Premise 2: The ticket was not closed by the technician.
Conclusion: The ticket was closed by the automation bot.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '(P∨Q) ∧ ¬P ⊢ Q'
  ),
  (
    'LOGIC-17 Constructive Dilemma',
    'reasoning',
    'Premise 1: If the disk is full, then writes fail.
Premise 2: If the network is down, then syncs fail.
Premise 3: The disk is full or the network is down.
Conclusion: Writes fail or syncs fail.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '(P→Q) ∧ (R→S) ∧ (P∨R) ⊢ Q∨S'
  ),
  (
    'LOGIC-18 Destructive Dilemma',
    'reasoning',
    'Premise 1: If the patch was applied, then the version number changed.
Premise 2: If the service was restarted, then the uptime counter reset.
Premise 3: The version number did not change, or the uptime counter did not reset.
Conclusion: The patch was not applied, or the service was not restarted.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '(P→Q) ∧ (R→S) ∧ (¬Q∨¬S) ⊢ ¬P∨¬R'
  ),

  -- ── Predicate-logic fallacies (LogicAsker items 6–17; the 0% zone) ──
  (
    'LOGIC-19 Existential Fallacy (Fallacy)',
    'reasoning',
    'Premise 1: Every process that leaks memory eventually gets killed by the watchdog.
Premise 2: No process currently leaks memory.
Conclusion: No process eventually gets killed by the watchdog.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P→Q), ¬∃xP ⊬ ¬∃xQ — processes may be killed for other reasons'
  ),
  (
    'LOGIC-20 Illicit Major (Fallacy)',
    'reasoning',
    'Premise 1: Every phishing email contains a suspicious link.
Premise 2: Some emails contain a suspicious link.
Conclusion: Some emails are phishing emails.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P→Q), ∃xQ ⊬ ∃xP — a newsletter can carry an odd link without being phishing'
  ),
  (
    'LOGIC-21 Undistributed Middle (Fallacy)',
    'reasoning',
    'Premise 1: All compromised accounts show unusual login times.
Premise 2: The account "jsmith" shows unusual login times.
Conclusion: The account "jsmith" is compromised.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P→Q), Q(a) ⊬ P(a) — night-shift workers log in at unusual times too'
  ),
  (
    'LOGIC-22 Universal Denying the Antecedent (Fallacy)',
    'reasoning',
    'Premise 1: Every device on the guest network is bandwidth-limited.
Premise 2: The printer is not on the guest network.
Conclusion: The printer is not bandwidth-limited.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P→Q), ¬P(a) ⊬ ¬Q(a) — Gemini-1.5 & Llama3 scored 0% on the existential variant (LogicAsker)'
  ),
  (
    'LOGIC-23 Existential Denying the Antecedent (Fallacy)',
    'reasoning',
    'Premise 1: For at least one machine in the fleet, if it runs the legacy agent, then it reports stale metrics.
Premise 2: The build server does not run the legacy agent.
Conclusion: The build server does not report stale metrics.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∃x(P→Q), ¬P(a) ⊬ ¬Q(a) — LogicAsker: Gemini-1.5 = 0%, Llama3 = 0% (total blindness)'
  ),
  (
    'LOGIC-24 Existential Affirming the Consequent (Fallacy)',
    'reasoning',
    'Premise 1: For at least one host, if it is quarantined, then it is unreachable.
Premise 2: The mail server is unreachable.
Conclusion: The mail server is quarantined.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∃x(P→Q), Q(a) ⊬ P(a)'
  ),
  (
    'LOGIC-25 Universal Affirming a Disjunct (Fallacy)',
    'reasoning',
    'Premise 1: Every alert is logged to the SIEM or forwarded to the on-call phone. (Inclusive or: both can happen.)
Premise 2: The disk-space alert was logged to the SIEM.
Conclusion: The disk-space alert was not forwarded to the on-call phone.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P∨Q), P(a) ⊬ ¬Q(a)'
  ),
  (
    'LOGIC-26 Universal Illicit Commutativity (Fallacy)',
    'reasoning',
    'Premise: For every request, if it lacks a valid token, then it is rejected.
Conclusion: For every request, if it is rejected, then it lacks a valid token.
Does the conclusion follow from the premise? Answer with exactly one word: VALID or INVALID.',
    'INVALID',
    'exact',
    3,
    '∀x(P→Q) ⊬ ∀x(Q→P) — requests are also rejected for rate limits, malformed bodies, …'
  ),

  -- ── Valid FOL baselines (LogicBench items 32–36) ─────────────────────
  (
    'LOGIC-27 Universal Instantiation',
    'reasoning',
    'Premise: Every container in the cluster runs a health probe.
Conclusion: The "postgres" container in the cluster runs a health probe.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '∀xP(x) ⊢ P(a)'
  ),
  (
    'LOGIC-28 FOL Modus Tollens',
    'reasoning',
    'Premise 1: Every signed commit passes the integrity check.
Premise 2: Commit 4f2a did not pass the integrity check.
Conclusion: Commit 4f2a is not a signed commit.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    '∀x(P→Q), ¬Q(a) ⊢ ¬P(a)'
  ),
  (
    'LOGIC-29 Existential Generalization',
    'reasoning',
    'Premise: The laptop "shoreline-03" is running an outdated kernel.
Conclusion: At least one machine is running an outdated kernel.
Is this argument valid? Answer with exactly one word: VALID or INVALID.',
    'VALID',
    'exact',
    3,
    'P(a) ⊢ ∃xP(x)'
  )
ON CONFLICT DO NOTHING;
