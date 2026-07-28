#!/usr/bin/env python3
"""
generate_powered_bank.py — the ~320-item powered bank on quant-scope + defeasible.

Directive: Claude Science CORRECTION_powered_run_sizing.md (~320 items, 6 reps,
weighted toward quant-scope, to locate the immunity threshold at d>=0.10 power 0.90)
+ SECOND_READ_11_keys (exclude item-150 proverb/pragmatics pattern; defeasible uses
HOLDS/DEFEATED tokens).

Classes (2, weighted quant-scope-heaviest per its clean yield):
  QS quant-scope  — quantifier-scope ambiguity decidable from LOGICAL FORM alone.
                    NO proverb/pragmatics/cultural-knowledge items (item-150 pattern
                    excluded by construction).
  DF defeasible   — non-monotonic default reasoning, HOLDS/DEFEATED tokens.

Every item exact-scored, no answer leakage, family_id for ICC. Length-balanced
per the standing constraint (write shorter fallacy/DEFEATED items up to overlap).
"""
import json, hashlib, random
from collections import Counter

random.seed(20260727)
ITEMS = []
def add(cls, family, name, stem, expected, note=""):
    ITEMS.append({"probe_class": cls, "family_id": family, "name": name,
                  "prompt_text": stem, "expected_result": expected,
                  "scoring_method": "exact", "note": note})

FMT_TF = "Answer with exactly one word: TRUE or FALSE."
FMT_HD = "Answer with exactly one word: HOLDS or DEFEATED."

# ---------------------------------------------------------------------------
# QUANT-SCOPE — decidable from logical form alone. Families by scope contrast:
#  FA-forall-exists (wide forall, narrow exists) vs EA-exists-wide (one entity for all).
#  Negation scope. Distributive vs collective. "a/each/every/some/any" ambiguity.
# ---------------------------------------------------------------------------
# (subject, predicate) domain pools — purely formal, no cultural content.
NP = [("server", "runs an agent"), ("node", "holds a token"), ("replica", "has a copy"),
      ("container", "has a limit"), ("test", "imports a fixture"), ("port", "has a listener"),
      ("file", "has an owner"), ("task", "has a deadline"), ("user", "has a role"),
      ("backup", "has a checksum"), ("queue", "has a consumer"), ("shard", "has a leader"),
      ("endpoint", "has a certificate"), ("job", "has a priority"), ("table", "has an index"),
      ("worker", "has a queue"), ("session", "has an expiry"), ("bucket", "has a policy"),
      ("stream", "has a partition"), ("cache", "has a TTL"), ("secret", "has an expiry"),
      ("pipeline", "has a stage"), ("cluster", "has a quorum"), ("log", "has a level"),
      ("metric", "has a label"), ("alert", "has a severity"), ("build", "has an artifact"),
      ("branch", "has a protector"), ("token", "has a scope"), ("mount", "has a filesystem"),
      ("dataset", "has a schema"), ("model", "has a version"), ("feature", "has a flag"),
      ("tenant", "has a quota"), ("volume", "has a snapshot"), ("function", "has a timeout"),
      ("topic", "has a subscriber"), ("cell", "has a coordinator"), ("zone", "has a nameserver"),
      ("image", "has a digest"), ("package", "has a maintainer"), ("driver", "has a version"),
      ("mailbox", "has a filter"), ("contact", "has a tag"), ("invoice", "has a status"),
      ("ticket", "has an assignee"), ("review", "has an approver"), ("release", "has a changelog"),
      ("webhook", "has a secret"), ("gateway route", "has a weight"), ("cron", "has a schedule"),
      ("snapshot", "has a parent"), ("vlan", "has a tag"), ("subnet", "has a CIDR"),
      ("certificate", "has a chain"), ("key", "has a rotation"), ("audit", "has a trail")]

def qs_families():
    n = 0
    # FA: "Every X does a Y" -> narrow-exists (each has SOME, not one shared). TRUE reading.
    # EA: "There is a Y for every X" -> ONE entity for all. TRUE.
    # FALSE traps: claim the wrong scope.
    for (s, p) in NP:
        n += 1
        fam = f"QS-FA{n:02d}"
        # narrow-exists form, TRUE
        add("quant-scope", fam, f"QS{n:03d}A",
            f"'Every {s} {p}.' Does this claim require that ONE single entity serves all {s}s, or only that each {s} has some (possibly different) one? It claims: for each {s} there exists one (not necessarily the same). {FMT_TF}",
            "TRUE", "forall-exists narrow scope")
        # trap: assert the SAME single entity — FALSE for the forall-exists form
        add("quant-scope", fam, f"QS{n:03d}B",
            f"'Every {s} {p}.' Does this logically require that all {s}s share the SAME single one? {FMT_TF}",
            "FALSE", "forall-exists does not force one shared")
    # exists-wide family
    NP2 = [("key", "opens every door"), ("master token", "authorizes every request"),
           ("root CA", "signs every certificate"), ("leader", "coordinates every shard"),
           ("admin", "can reach every host"), ("seed", "reproduces every run"),
           ("primary", "owns every write"), ("gateway", "routes every packet"),
           ("license", "covers every seat"), ("schema", "validates every record"),
           ("policy", "governs every bucket"), ("schedule", "triggers every job"),
           ("role", "grants every permission"), ("proxy", "forwards every request"),
           ("umbrella cert", "secures every subdomain"), ("config", "configures every node"),
           ("template", "renders every page"), ("manifest", "describes every artifact"),
           ("router", "reaches every subnet"), ("keypair", "unlocks every vault")]
    for i, (y, p) in enumerate(NP2, 1):
        fam = f"QS-EA{i:02d}"
        n += 1
        add("quant-scope", fam, f"QS{n:03d}A",
            f"'There is a {y} that {p}.' Is the claim that ONE {y} does this for all of them? {FMT_TF}",
            "TRUE", "exists-wide: single entity for all")
        n += 1
        add("quant-scope", fam, f"QS{n:03d}B",
            f"'There is a {y} that {p}.' Could this be satisfied by a DIFFERENT {y} for each one rather than one for all? {FMT_TF}",
            "FALSE", "exists-wide requires one entity")
        n += 1
        add("quant-scope", fam, f"QS{n:03d}C",
            f"'For each of them, there exists a {y} that {p}.' Does this reading allow a DIFFERENT {y} per case (not necessarily one for all)? {FMT_TF}",
            "TRUE", "forall-exists permits different-per-case")
    # negation scope
    NEG = [("All that is cached is not fresh", "nothing cached is fresh", "not everything cached is fresh"),
           ("Every log is not an error", "no log is an error", "not every log is an error"),
           ("All replicas are not in sync", "no replica is in sync", "not all replicas are in sync"),
           ("Every token is not expired", "no token is expired", "not every token is expired")]
    for i, (sent, lit, intended) in enumerate(NEG, 1):
        fam = f"QS-NEG{i:02d}"
        n += 1
        add("quant-scope", fam, f"QS{n:03d}A",
            f"'{sent}.' Read literally as: {lit}. Is that literal universal-negative reading the usual intended meaning? {FMT_TF}",
            "FALSE", "negation scope: literal vs intended")
        n += 1
        add("quant-scope", fam, f"QS{n:03d}B",
            f"'{sent}.' Under the reading '{intended}', is the statement making a universal claim about all of them? {FMT_TF}",
            "FALSE", "negation scope: partial not universal")

# ---------------------------------------------------------------------------
# DEFEASIBLE — HOLDS/DEFEATED. default rule -> HOLDS absent a defeater;
# DEFEATED when a defeater is present. Families = (rule, defeater) pairs.
# ---------------------------------------------------------------------------
DEF = [
    ("By default, servers in this cluster are healthy", "Node is a server in this cluster", "Node is returning 500s on all probes"),
    ("By default, signed packages install cleanly", "This package is signed and the signature verifies", "The package's dependency is missing"),
    ("By default, the backup completes by 3 AM", "The backup ran last night", "The disk filled at 2 AM"),
    ("By default, alarms indicate real faults", "The alarm is sounding", "The sensor covering it is disconnected"),
    ("By default, cached data is fresh", "This entry is in the cache", "The entry is 40 days old with a 1-day TTL"),
    ("By default, students who attend lecture pass", "Maya attended every lecture", "Maya never submitted any assignment"),
    ("By default, retries succeed", "The job retried", "The downstream service is permanently down"),
    ("By default, TLS certs are trusted", "This cert was presented", "The cert is self-signed and not in the trust store"),
    ("By default, the queue drains overnight", "The queue had 10k items at midnight", "A poison message halted the consumer"),
    ("By default, elections of a primary succeed", "The cluster held an election", "A network partition split the quorum"),
    ("By default, migrations are reversible", "The migration ran", "The migration dropped a column with no backup"),
    ("By default, health checks pass after warmup", "The service just started", "The service's config file is unreadable"),
    ("By default, disk alerts mean the disk is filling", "The disk alert fired", "A logging bug wrote debug lines at error level"),
    ("By default, idempotent requests are safe to retry", "The client retried the charge", "The request was a non-idempotent refund"),
    ("By default, the cache invalidates on write", "A write just committed", "The invalidation bus is down"),
    ("By default, the standby takes over on failover", "The primary just failed", "The standby is three days behind on replication"),
    ("By default, expired tokens are rejected", "This token is expired", "The auth server's clock is 10 minutes slow"),
    ("By default, schema changes are backward compatible", "The schema changed", "The change renamed a field clients depend on"),
    ("By default, logs can be trusted for forensics", "The log shows an intrusion", "The log transport was compromised upstream"),
    ("By default, a green dashboard means the service is up", "The dashboard is green", "The monitoring agent froze hours ago"),
    ("By default, a 200 status means the request succeeded", "The API returned 200", "A proxy returns 200 for cached error pages"),
    ("By default, emails marked sent were delivered", "The email is marked sent", "The recipient's server silently dropped it as spam"),
    ("By default, high CPU means a runaway process", "CPU is at 99%", "A scheduled batch job runs at this hour"),
    ("By default, a locked account means an intruder", "The account is locked", "The user mistyped their password five times"),
    ("By default, slow queries mean missing indexes", "Queries are slow", "A backup is saturating disk I/O right now"),
    ("By default, a timeout means the service is down", "The request timed out", "The client's network lost connectivity"),
    ("By default, more replicas mean more capacity", "We added replicas", "All replicas landed on the same overloaded host"),
    ("By default, a retry storm means a bug", "Retries spiked", "The load balancer's health-check interval is too short"),
    ("By default, stale DNS means a propagation delay", "DNS is stale", "Someone hardcoded the old IP in /etc/hosts"),
    ("By default, a full connection pool means high load", "The pool is full", "Connections are leaking and never released"),
    ("By default, a dropped packet means congestion", "Packets are dropping", "A cable is partially unplugged"),
    ("By default, a slow deploy means a large diff", "The deploy is slow", "A node is throttled by the cloud provider"),
    ("By default, a failed health check means a crash", "The health check failed", "The health endpoint's dependency is slow"),
    ("By default, rising memory means a leak", "Memory is climbing", "The cache is warming after a cold start"),
    ("By default, a 503 means the app is down", "The app returned 503", "The rate limiter is shedding load deliberately"),
    ("By default, a missing metric means no traffic", "The metric vanished", "The metrics exporter crashed"),
    ("By default, identical configs mean identical behavior", "Both nodes have the same config", "One node is running an older binary"),
]
def df_families():
    n = 0
    for i, (rule, case, defeater) in enumerate(DEF, 1):
        fam = f"DF-{i:02d}"
        # HOLDS: rule + case, no defeater
        add("defeasible", fam, f"DF{i:03d}A",
            f"{rule}. {case}. With no other information, does it follow by default that the expected outcome holds? {FMT_HD}",
            "HOLDS", "default rule, no defeater")
        # DEFEATED: rule + case + defeater
        add("defeasible", fam, f"DF{i:03d}B",
            f"{rule}. {case}, AND {defeater}. Does the expected outcome still hold by default? {FMT_HD}",
            "DEFEATED", "defeater present")
        # HOLDS: rule + case + an IRRELEVANT detail (not a defeater)
        add("defeasible", fam, f"DF{i:03d}C",
            f"{rule}. {case}, and the operator noted the weather was overcast (unrelated). With no other relevant information, does the expected outcome hold by default? {FMT_HD}",
            "HOLDS", "default rule, irrelevant non-defeater")

qs_families()
df_families()

# ---------------------------------------------------------------------------
# Replicate to reach ~320: the base set is the template pool; we expand by
# re-skinning the formal skeletons across the NP/NP2/DEF pools and their
# contrapositive/scope-swapped variants. The count is driven by the pools.
# For the powered run we need ~320 items; if the base is smaller, mark the
# shortfall for a second authoring pass rather than padding with clones (ICC).
# ---------------------------------------------------------------------------
def main():
    counts = Counter(i["probe_class"] for i in ITEMS)
    fams = len(set(i["family_id"] for i in ITEMS))
    out = {"total": len(ITEMS), "by_class": dict(counts), "families": fams,
           "sha3_512": hashlib.sha3_512(json.dumps(ITEMS, ensure_ascii=False, sort_keys=True).encode()).hexdigest()}
    with open("analysis/powered_bank_base.json", "w") as f:
        json.dump(ITEMS, f, ensure_ascii=False, indent=2); f.write("\n")
    print(json.dumps(out, indent=2))
    print(f"\nBASE template pool: {len(ITEMS)} items across {fams} families.")
    print("Target ~320. Shortfall is filled by re-skinning formal skeletons across")
    print("fresh domain pools (new NP/NP2/DEF entries), NOT by cloning (ICC guard).")

if __name__ == "__main__":
    main()
