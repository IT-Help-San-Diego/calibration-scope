# PUBLIC REPO — critical embarrassment scan (do these before strangers read deeper)
_Claude Science, 2026-07-25. Triggered by Carey: "now that the repo is public, hit the critical most embarrassing things first."_
_Scanned all 260 files on main + every public surface (README, site/*.html, assets/*.html)._

## SEVERITY 1 — CRITICAL (fix first): the README overclaims a result our OWN audit downgraded
**File:** README.md, "results" block.
**The claim (public):** "big models (nemotron 30B, Fable 5) are carrier-immune (100% on every
carrier)... Immunity tracks capability/headroom, not substrate."
**Why it's the most embarrassing thing in the repo:** it is a STATED-vs-ACTUAL gap in our own shop
window — the exact sin the instrument exists to catch, on the front page.
- "100% on every carrier" = 1.0 at tiny N with NO confidence interval — a ceiling artifact. This
  session's own power analysis proved near-ceiling gaps are statistically compressed and NOT resolvable
  without N ~= 420 (paired design). The fine-grained carrier ordering was quarantined as NOT statistically
  supported (see EPISTEMIC_LOG + DECISIONS §10.8).
- "Immunity tracks capability, not substrate" is stated as FACT; it is a HYPOTHESIS the powered
  experiment has not run yet.
- A stranger who reads README then DECISIONS/epistemic log sees the contradiction directly.
**Fix (downgrade to what the data licenses — do NOT delete the finding):**
  OLD: "carrier-immune (100% on every carrier)... Immunity tracks capability, not substrate."
  NEW: "Larger models show no carrier sensitivity we can resolve at current N (at/near ceiling); the
  small e2b shows a candidate drop (99%->91%). Whether this reflects a real capability threshold is what
  the pre-registered paired-design experiment (N~=420) is built to answer — not yet a settled result."
This turns a liability into a DEMONSTRATION of the method: we hold our own claims to the standard we
measure others by. Stronger front page than a false 100%.
**Also scan for and same-treatment any sibling overclaims:** any bare "100%", "proven", "immune",
"first", "never/always" in README/site that rests on small-N or unrun experiments. "Every number is a
real sealed run" is fine for PROVENANCE but must not be read as licensing over-strong INTERPRETATIONS.

## SEVERITY 2 — none found in these classes (good news, recorded so it's not re-checked blind)
- **Committed secrets: NONE.** No real .env (only would-be .example), no .pem/.key/id_rsa, no
  sk-/AKIA/ghp_/xox tokens, no BEGIN PRIVATE KEY in any of the 260 files or any public HTML. Clean.
- **Profanity in PUBLIC copy: NONE.** README, site/index, site/lessons, 404 all clean. (Carey-voice in
  DECISIONS is internal and not a public-embarrassment issue.)
- **Placeholders: BENIGN.** The two "placeholder" hits are HTML input attributes
  (placeholder="Type or paste your prompt..."), not unfinished content.

## SEVERITY 3 — verify before public trust (not embarrassing, but do it)
- README lists specific model names + numbers (nemotron 30B, Fable 5, e2b 99->91). Confirm each traces
  to a sealed run id in the DB before they stay in public copy — same rule as the DOI/ID verification.
- "What it caught in its first week (real examples)" — confirm each example is a real committed receipt,
  not a paraphrase, since it's a public credibility claim.

## Method note
This scan is filename + content pattern matching, not a guarantee. It catches the obvious classes
(secrets, profanity, placeholders, quantified overclaims). It does NOT catch subtle factual errors in
prose — those need the same live-verification discipline applied per claim. Severity 1 is the one that
matters today; it is squarely the project's own ethos applied to itself.
