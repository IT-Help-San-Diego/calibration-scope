#!/usr/bin/env python3
"""Run the DB-dependent gates against a database built from ZERO.

WHY THIS EXISTS. Every other check in this repo runs against the development
database, which has accumulated state — and test ids in it are whatever the
sequence happened to assign months ago. That hides a specific, repeatedly-fatal
class of bug: a migration that references a row by RAW ID.

Migration 057 fixed LOGIC-06C with `WHERE id = 87`. That row is id 87 here and
id 60 in a fresh seed, so on any fresh install the UPDATE matched zero rows —
and a zero-row UPDATE is not an error. 057 reported success, changed nothing,
and left a self-contradicting row in place. The local battery stayed green at
67/67 the whole time because locally the row really was fixed. Only a
fresh-seed environment could see it, and the only fresh-seed environment we had
was CI. When CI went down, so did the ability to catch this.

Migration 048 had already fixed this exact class once and written the rule in
its own header — "never reference another row by raw id; always resolve through
a stable natural key (name)." Nothing enforced it, so it came back nine
migrations later. This script is the enforcement.

WHAT IT DOES. Creates a scratch database, applies every migration in order,
runs the DB-dependent gates against it, and drops the scratch database. The
development database is never written to — it is read only to discover the
connection parameters.

WHAT IT DOES NOT COVER. Lighthouse and CodeQL are CI-only and are not
replicated here. This closes the migration/ground-truth gap, not the whole of
CI. Nor does it use sqlx's migration runner: it applies the .sql files in
filename order, which matches what sqlx::migrate! does for this repo's
migrations but would diverge if one ever needed sqlx-specific handling.

Run: python3 scripts/fresh_seed_check.py
Exit 0 = a fresh install of this repo produces a consistent instrument.
Exit 1 = it does not. Do not ship.
Exit 2 = the check could not run (no DATABASE_URL, no psycopg2, etc).
"""
import glob
import os
import re
import subprocess
import sys

SCRATCH_DB = "cs_freshseed_check"
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def die(msg, code=2):
    print(f"[ERROR] {msg}", file=sys.stderr)
    sys.exit(code)


def swap_db(url, name):
    """Point a libpq URL at a different database, leaving credentials intact."""
    return re.sub(r"/[^/?]+(\?|$)", "/" + name + r"\1", url)


def main():
    try:
        import psycopg2
        from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
    except ImportError:
        die("psycopg2 not installed — pip install psycopg2-binary --break-system-packages")

    live = os.environ.get("DATABASE_URL")
    if not live:
        die("DATABASE_URL not set. On this machine it lives only in the launchd plist:\n"
            "  export DATABASE_URL=\"$(/usr/libexec/PlistBuddy -c "
            "'Print :EnvironmentVariables:DATABASE_URL' "
            "~/Library/LaunchAgents/ai.hermes.calibration-scope-dashboard.plist)\"")

    live_name = re.search(r"/([^/?]+)(\?|$)", live)
    live_name = live_name.group(1) if live_name else "?"
    # Refuse to operate on the real database under any circumstance. The whole
    # value of this script is that it cannot damage what it is checking.
    if live_name == SCRATCH_DB:
        die(f"DATABASE_URL already points at {SCRATCH_DB!r} — refusing to run so the "
            "scratch database is never confused with a real one.")

    admin_url = swap_db(live, "postgres")
    scratch_url = swap_db(live, SCRATCH_DB)
    print(f"live database : {live_name} (read-only — never written by this script)")
    print(f"scratch       : {SCRATCH_DB}")

    admin = psycopg2.connect(admin_url)
    admin.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    failures = 0
    try:
        with admin.cursor() as cur:
            cur.execute(f"DROP DATABASE IF EXISTS {SCRATCH_DB}")
            cur.execute(f"CREATE DATABASE {SCRATCH_DB}")
        print("scratch database created")

        files = sorted(glob.glob(os.path.join(HERE, "migrations", "*.sql")))
        if not files:
            die("no migrations found — run this from a checkout of the repo")
        conn = psycopg2.connect(scratch_url)
        applied = 0
        try:
            for f in files:
                with conn.cursor() as cur:
                    try:
                        cur.execute(open(f, encoding="utf-8").read())
                        conn.commit()
                        applied += 1
                    except Exception as e:  # noqa: BLE001 — report and stop, don't mask
                        conn.rollback()
                        print(f"[FAIL] migration {os.path.basename(f)}: "
                              f"{str(e).strip().splitlines()[0][:200]}")
                        failures += 1
                        break
        finally:
            conn.close()
        print(f"migrations    : {applied}/{len(files)} applied")
        if failures:
            print("\nA migration failed on a FRESH database. It may still succeed on an "
                  "existing one, which is exactly how this class of bug hides.")
            return 1

        # The DB-dependent gate. Run as a subprocess so its own exit code and
        # output are the verdict — no reimplementation of the rules here.
        env = dict(os.environ, DATABASE_URL=scratch_url)
        print("\n--- owl family consistency, against the fresh seed ---")
        r = subprocess.run(
            [sys.executable, os.path.join(HERE, "scripts", "verify_logic_ground_truth.py"),
             "--check-owl-families"],
            env=env, cwd=HERE, capture_output=True, text=True)
        tail = [ln for ln in r.stdout.splitlines() if ln.strip()]
        for ln in tail:
            if ln.startswith("[FAIL]") or "consistent" in ln:
                print(ln)
        if r.returncode != 0:
            failures += 1
            print("\nThis passes locally and fails here => the defect is environment-crossing. "
                  "The usual cause is a migration that pinned a raw id.")
    finally:
        with admin.cursor() as cur:
            cur.execute(f"DROP DATABASE IF EXISTS {SCRATCH_DB}")
        admin.close()
        print("\nscratch database dropped")

    print("FRESH-SEED CHECK: PASS" if not failures else "FRESH-SEED CHECK: FAIL")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
