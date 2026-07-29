#!/usr/bin/env python3
"""Export stored SEC-01 security trials WITH raw_response, for offline re-score review.

WHY THIS EXISTS. Claude Science cannot reach the database, and the block is
structural rather than a missing permission:

  1. Loopback is denied at the sandbox socket layer — connecting to 127.0.0.1:5432
     or :8768 raises PermissionError(EPERM), not ECONNREFUSED. Private/reserved
     targets cannot be added to the network allowlist, so this is not grantable.
  2. DATABASE_URL exists only in the launchd plist, which is outside the granted
     host paths.

What IS available is full read/write on the repo working tree. So the durable fix
is an export any lane with DB access can run in one command, writing to a path
Claude Science can read directly. That turns "please paste the 5 e2b responses"
into a reproducible artifact.

Usage (from a shell that has DATABASE_URL):
    export DATABASE_URL="$(/usr/libexec/PlistBuddy -c \
      'Print :EnvironmentVariables:DATABASE_URL' \
      ~/Library/LaunchAgents/<calibration-scope>.plist)"
    python3 scripts/export_sec01_trials.py

SCHEMA VERIFIED against migrations before shipping, not assumed:
trial_results carries run_id/trial_num/passed/raw_response/latency_ms/detail/
created_at, is_infra_error was added by 017 to trial_results (not to test_runs),
and quantization was added by 026 to models (not to test_runs). detail is
included because 017 keys infra-error detection off it.

Writes analysis/sec01_trials_export.csv (gitignore it — raw_response is bulky,
and it is regenerable from the DB at any time).

READ-ONLY BY CONSTRUCTION: the only SQL verb here is SELECT. This script cannot
apply a re-score, by design — CS-067 rules that the apply must be additive with a
grader version recorded, and that is a separate, reviewed change.
"""
import csv
import os
import sys

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "analysis", "sec01_trials_export.csv")

# SELECT only. Joined so each row carries the model and run it came from, and
# trial_num so the paired/rep structure survives the export — the omission that
# blocked the run-985 analysis until CS-051 fixed it.
QUERY = """
SELECT t.id            AS trial_id,
       r.id            AS run_id,
       m.key           AS model_key,
       m.quantization  AS quantization,
       te.name         AS test_name,
       te.axis         AS axis,
       t.trial_num     AS trial_num,
       t.passed        AS passed,
       t.is_infra_error AS is_infra_error,
       t.latency_ms    AS latency_ms,
       t.detail        AS detail,
       t.created_at    AS created_at,
       t.raw_response  AS raw_response
  FROM trial_results t
  JOIN test_runs r  ON r.id = t.run_id
  JOIN tests    te  ON te.id = r.test_id
  JOIN models   m   ON m.id = r.model_id
 WHERE te.axis = 'security'
 ORDER BY m.key, r.id, t.trial_num
"""


def die(msg, code=2):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(code)


def main():
    try:
        import psycopg2
    except ImportError:
        die("psycopg2 not installed — pip install psycopg2-binary")
    url = os.environ.get("DATABASE_URL")
    if not url:
        die("DATABASE_URL not set. On this machine it lives only in the launchd "
            "plist; see the module docstring for the PlistBuddy incantation.")
    conn = psycopg2.connect(url)
    try:
        with conn.cursor() as cur:
            cur.execute(QUERY)
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
    finally:
        conn.close()
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(cols)
        w.writerows(rows)
    # Report the shape so the caller can sanity-check without opening the file.
    print(f"wrote {OUT}")
    print(f"rows={len(rows)} cols={len(cols)}")
    ix = {c: i for i, c in enumerate(cols)}
    models = sorted({r[ix["model_key"]] for r in rows})
    print(f"models={len(models)}")
    tests = sorted({r[ix["test_name"]] for r in rows})
    print(f"tests={tests}")
    empty = sum(1 for r in rows if not (r[ix["raw_response"]] or "").strip())
    print(f"rows_with_empty_raw_response={empty}")
    if empty:
        print("  NOTE: empty raw_response cannot be re-scored or reviewed — "
              "report these separately rather than counting them as either "
              "verdict.")


if __name__ == "__main__":
    main()
