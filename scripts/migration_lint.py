#!/usr/bin/env python3
"""migration_lint.py — reject raw-id references to content rows.

WHY THIS EXISTS. Migration 048 fixed a raw-id reference and wrote the rule in its
own header: never reference another row by raw id. Nothing enforced it. Migration
057 reintroduced it nine migrations later with `WHERE id = 87 AND name = '...'`,
and because test ids are sequence-assigned, it silently did nothing outside the
one database where id 87 happened to be the right row. It looked fixed locally
and was broken everywhere else. Migration 060 repaired it by name.

A rule in a migration header is a comment. This makes it a rule.

The check is deliberately narrow: an UPDATE/DELETE against a CONTENT table whose
WHERE clause pins a literal id. Schema operations and sequence-safe references
are untouched. Adding `AND name = '...'` does NOT make a raw id safe — that was
exactly 057's shape, and the id clause still selects the wrong row.
"""
import re, sys, pathlib

CONTENT_TABLES = ["tests", "trial_results", "runs", "probe_items"]

# GRANDFATHERED — historical violations that must NOT be edited.
# An applied migration cannot be rewritten: changing its bytes changes its checksum
# and breaks sqlx's _sqlx_migrations table on every database that already ran it.
# Each entry names the superseding fix, so this list documents history rather than
# hiding it. Adding to this list is a decision that needs a reason, not a way to
# silence the gate — a NEW violation belongs in the migration, not here.
GRANDFATHERED = {
    "057_fix_logic_06c_spec.sql":
        "id-pinned UPDATE (WHERE id = 87) that silently no-opped outside the dev database; "
        "superseded by 060_fix_logic_06c_spec_by_name.sql, which re-applies the fix by name. "
        "Applied and immutable — do not edit.",
}
RULE = "never pin a content row by raw id — match by name/natural key (see migration 048, breached by 057, fixed by 060)"

def violations(sql, path):
    out = []
    # strip line comments so a rule QUOTED in a header is not a hit
    body = re.sub(r"--[^\n]*", "", sql)
    for m in re.finditer(r"(?is)\b(update|delete\s+from)\s+(\w+)(.*?);", body):
        verb, table, tail = m.group(1), m.group(2), m.group(3)
        if table.lower() not in CONTENT_TABLES:
            continue
        for idm in re.finditer(r"(?i)\bid\s*=\s*(\d+)", tail):
            line = body[:m.start()].count("\n") + 1
            out.append((path, line, table, idm.group(1), re.sub(r"\s+", " ", m.group(0))[:90]))
    return out

def main(paths):
    bad, waived = [], []
    for p in paths:
        v = violations(pathlib.Path(p).read_text(), p)
        if v and pathlib.Path(p).name in GRANDFATHERED:
            waived.append((pathlib.Path(p).name, len(v)))
            continue
        bad += v
    for path, line, table, idv, snip in bad:
        print(f"[FAIL] {pathlib.Path(path).name}:{line} — UPDATE/DELETE on `{table}` pinned to id = {idv}")
        print(f"       {snip}")
        print(f"       RULE: {RULE}")
    for name, n in waived:
        print(f"[WAIVED] {name} — {n} historical violation(s): {GRANDFATHERED[name]}")
    print(f"\n{len(paths)} migrations checked — {len(bad)} violation(s), {len(waived)} grandfathered")
    return 1 if bad else 0

if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--selftest":
        cases = [
            ("UPDATE tests SET formal_spec = 'x' WHERE id = 87 AND name = 'LOGIC-06C';", 1, "057's exact shape — name clause does not rescue it"),
            ("UPDATE tests SET formal_spec = 'x' WHERE name = 'LOGIC-06C';", 0, "by name — the correct form"),
            ("-- never do: UPDATE tests ... WHERE id = 87;\nUPDATE tests SET a=1 WHERE name='b';", 0, "rule quoted in a comment is not a violation"),
            ("ALTER TABLE tests ADD COLUMN id_map int;", 0, "schema op untouched"),
            ("DELETE FROM trial_results WHERE id = 5;", 1, "delete on a content table"),
            ("UPDATE _sqlx_migrations SET checksum='x' WHERE id = 3;", 0, "non-content table untouched"),
        ]
        ok = 0
        for sql, want, why in cases:
            got = len(violations(sql, "<test>"))
            flag = "PASS" if got == want else "FAIL"
            ok += got == want
            print(f"  [{flag}] want {want} got {got} — {why}")
        print(f"\nself-test: {ok}/{len(cases)} passed")
        sys.exit(0 if ok == len(cases) else 1)
    sys.exit(main(args))
