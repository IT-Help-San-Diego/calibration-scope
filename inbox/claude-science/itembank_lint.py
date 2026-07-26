#!/usr/bin/env python3
"""
itembank_lint.py — pre-administration QA for calibration-scope item banks.

WHY THIS EXISTS
Every defect this checks for is one the project ALREADY SHIPPED and had to catch after the fact:
  * LOGIC-01N used "exactly when" keyed as a biconditional; LOGIC-03N used "precisely when" keyed as
    one-directional. Same phrasing, opposite ground truth. A subject (Replit) caught it mid-run.
  * Two item_id strings each mapped to two different items in the 64-item bank (found only in
    trial-level analysis, after 1,024 trials had been administered).
  * Three grader bugs of the exact-match class (Unicode quotes, prompt-echo, exact-match-on-explanation)
    — 8 adversarial items + LOGIC-01N scored 0% for a scoring reason, not a capability reason.
At 64 items these were catchable by hand. At 500 they are not. This runs in seconds.

USAGE
  python3 itembank_lint.py pack1.txt pack2.txt ...          # lint administered packs
  python3 itembank_lint.py --keys keys.json pack*.txt       # also cross-check the answer key

EXIT CODE: 0 = clean, 1 = at least one ERROR. WARNs do not fail the run.
NO DEPENDENCIES (stdlib only) so it can run in CI or on the box.
"""
import sys, re, json, hashlib, unicodedata
from collections import defaultdict, Counter

# Verdict vocabularies the grader knows. Keep in sync with src/executor/scoring.rs TOKENS.
VERDICT_SETS = [
    {"FOLLOWS","DOESNOTFOLLOW"}, {"VALID","INVALID"}, {"YES","NO"},
    {"APPROVE","DENY","ESCALATE"}, {"SAT","UNSAT"}, {"TRUE","FALSE"},
    {"CONFIRMED","NONE"},
]
ALL_TOKENS = sorted({t for s in VERDICT_SETS for t in s}, key=len, reverse=True)

# Phrases that make a conditional BIDIRECTIONAL. If a stem contains one of these and the key
# expects the converse-error answer, the item is ambiguous -- this is the LOGIC-01N/03N defect.
IFF_CUES = [r"\bexactly when\b", r"\bprecisely when\b", r"\bif and only if\b", r"\biff\b",
            r"\bjust in case\b", r"\bwhen and only when\b", r"\bexactly if\b"]
ONEWAY_CUES = [r"\bif\b", r"\bwhen\b", r"\bwhenever\b", r"\bonly if\b"]

def norm_text(s):
    """Normalise the way the grader does, so we detect what IT would see."""
    s = unicodedata.normalize("NFKC", s)
    for a,b in [("\u2018","'"),("\u2019","'"),("\u201c",'"'),("\u201d",'"'),
                ("\u2013","-"),("\u2014","-"),("\u2212","-")]:
        s = s.replace(a,b)
    return s

def admin_of(path):
    """Group packs by ADMINISTRATION. Item numbers are re-randomised per admin BY DESIGN
    (--shuffle), so a number->stem map is only meaningful within one administration.
    Filename convention: <date>-channel-<X>-admin<N>-batch<NN>-seed<S>.txt"""
    b = path.split("/")[-1]
    m = re.search(r"channel-([A-Za-z0-9']+)-admin(\d+)", b)
    if m: return f"channel-{m.group(1)}/admin{m.group(2)}"
    m = re.search(r"seed(\d+)", b)
    return f"seed{m.group(1)}" if m else b   # fall back to seed, then filename

def parse_pack(text):
    """Return [(num, stem)] for [NN] ... items. Multi-line stems are joined."""
    text = norm_text(text)
    items, cur, num = [], [], None
    for line in text.splitlines():
        m = re.match(r"^\[(\d{1,3})\]\s*(.*)$", line)
        if m:
            if num is not None: items.append((num, " ".join(cur).strip()))
            num, cur = m.group(1), [m.group(2)]
        elif num is not None:
            cur.append(line)
    if num is not None: items.append((num, " ".join(cur).strip()))
    return items

def expected_vocab(stem):
    """Which verdict set does the stem instruct the subject to use?"""
    up = stem.upper()
    hits = [s for s in VERDICT_SETS if sum(1 for t in s if re.search(rf"\b{t}\b", up)) >= 2]
    return hits[0] if len(hits) == 1 else (hits if hits else None)

def lint(files, keys=None):
    findings = []       # (level, item_ref, code, message)
    stems_by_hash = defaultdict(list)
    iff_items = []      # (ref, num, cue, stem_head) -- for the cross-item consistency check
    stems_by_num  = defaultdict(set)
    total = 0

    for path in files:
        try: raw = open(path, encoding="utf-8", errors="replace").read()
        except OSError as e:
            findings.append(("ERROR", path, "UNREADABLE", str(e))); continue
        admin_key = admin_of(path)
        items = parse_pack(raw)
        if not items:
            findings.append(("WARN", path, "NO_ITEMS", "no [NN] items parsed - check format"))
        for num, stem in items:
            total += 1
            ref = f"{path.split('/')[-1]}:[{num}]"

            # --- E1: duplicate item id mapping to DIFFERENT text (the 63-vs-64 defect)
            h = hashlib.sha256(stem.encode()).hexdigest()[:16]
            stems_by_hash[h].append((admin_key, num, ref))
            stems_by_num[(admin_key, num)].add(h)

            # --- E2: biconditional cue + converse-error key (the LOGIC-01N/03N defect)
            iff = [c for c in IFF_CUES if re.search(c, stem, re.I)]
            if iff:
                iff_items.append((ref, num, iff[0], stem[:90]))
                findings.append(("WARN", ref, "IFF_CUE",
                    f"stem contains biconditional cue {iff[0]!r}. If the key expects the CONVERSE-ERROR "
                    f"answer, the item is AMBIGUOUS and measures sensitivity to the cue, not the fallacy. "
                    f"Either drop the cue or key it as a valid biconditional."))

            # --- E3: no answer-format instruction => ungradeable by exact match
            FMT_PATTERNS = (r"answer (with|exactly)|reply (with|:)|respond with|answer\b.*\bor\b"
                            r"|output only|no other text|only the (number|json|word)|"
                            r"\bin the exact form\b|number only|one word")
            if not re.search(FMT_PATTERNS, stem, re.I):
                findings.append(("ERROR", ref, "NO_FORMAT",
                    "no explicit answer-format instruction; exact-match grading will fail unpredictably"))

            # --- E4: ambiguous / mixed verdict vocabulary
            ev = expected_vocab(stem)
            if isinstance(ev, list) and len(ev) > 1:
                findings.append(("ERROR", ref, "MIXED_VOCAB",
                    f"stem offers tokens from {len(ev)} different verdict sets "
                    f"({[sorted(s) for s in ev]}); the grader cannot disambiguate"))

            # --- E5: escaped literals in the stem (the \\n leakage seen in pack batch01 [06])
            if "\\n" in stem or "\\t" in stem:
                findings.append(("WARN", ref, "ESCAPED_LITERAL",
                    "stem contains a literal backslash-n/t; the subject sees the escape, not a newline"))

            # --- E6: smart quotes / en-dashes SURVIVING normalisation (grader bug class #1)
            if re.search(r"[\u2018\u2019\u201c\u201d\u2013\u2014]", raw) and stem in norm_text(raw):
                pass  # normalised copy is clean; informational only

            # --- E7: stem asks for explanation AND a token => exact-match-on-explanation risk
            if re.search(r"\bthen name\b|\bexplain\b|\band why\b|,\s*then\b", stem, re.I) and ev:
                findings.append(("WARN", ref, "TOKEN_PLUS_PROSE",
                    "stem requests a verdict token AND free prose. This is grader-bug class #3 "
                    "(exact-match-on-explanation): the grader must extract the LEADING token, "
                    "not compare whole strings. Verify extract_verdict() handles it."))

            # --- E8: key cross-check
            if keys and num in keys:
                exp = str(keys[num]).strip().upper()
                if ev and isinstance(ev, set) and exp:
                    lead = re.split(r"[^A-Z]", exp, 1)[0]
                    if lead and lead not in {t.replace(" ","") for t in ev} and lead not in ALL_TOKENS:
                        findings.append(("ERROR", ref, "KEY_VOCAB_MISMATCH",
                            f"key {exp!r} (leading token {lead!r}) is not in the vocabulary the stem "
                            f"instructs ({sorted(ev)})"))

    # --- cross-item checks
    # --- E9: THE LOGIC-01N/03N DEFECT -- two items with biconditional cues keyed to OPPOSITE
    #          readings. Either cue alone is a WARN; an INCONSISTENT PAIR is an ERROR.
    if len(iff_items) > 1:
        if keys:
            readings = {}
            for ref, num, cue, head in iff_items:
                k = str(keys.get(num, "")).strip().upper()
                if not k: continue
                lead = re.split(r"[^A-Z]", k, 1)[0]
                if lead in {"FOLLOWS","CONFIRMED","VALID","YES"}:     readings[ref] = ("BICONDITIONAL", num, cue)
                elif lead in {"DOESNOTFOLLOW","INVALID","NO","NONE"}: readings[ref] = ("ONE_WAY", num, cue)
            if len({v[0] for v in readings.values()}) > 1:
                detail = "; ".join(f"[{v[1]}] cue={v[2]!r} -> {v[0]}" for v in readings.values())
                findings.append(("ERROR", ",".join(f"[{v[1]}]" for v in readings.values()),
                    "IFF_KEY_INCONSISTENT",
                    f"items using biconditional cues are keyed to OPPOSITE readings: {detail}. "
                    f"This is the LOGIC-01N/03N defect: the bank measures sensitivity to the cue phrase "
                    f"rather than the target fallacy. Make every iff-cued item consistent, or strip the "
                    f"cue from items meant to test the converse error."))
        else:
            findings.append(("WARN", ",".join(f"[{n}]" for _, n, _, _ in iff_items), "IFF_PAIR_UNCHECKED",
                f"{len(iff_items)} items carry biconditional cues. Re-run with --keys to check they are "
                f"keyed CONSISTENTLY -- an inconsistent pair is the LOGIC-01N/03N defect."))

    for (adm, num), hashes in stems_by_num.items():
        if len(hashes) > 1:
            findings.append(("ERROR", f"{adm}:[{num}]", "NUM_COLLISION",
                f"WITHIN administration {adm}, item number [{num}] maps to {len(hashes)} DIFFERENT stems. "
                f"Numbers must be unique inside one administration or responses cannot be scored."))
    for h, entries in stems_by_hash.items():
        by_adm = defaultdict(set)
        for adm, num, _ref in entries: by_adm[adm].add(num)
        multi = {a: ns for a, ns in by_adm.items() if len(ns) > 1}
        if multi:
            findings.append(("WARN", ";".join(f"{a}:{sorted(ns)}" for a, ns in multi.items()), "DUP_STEM",
                "identical stem appears under MULTIPLE numbers within the same administration; "
                "paired analysis will treat them as independent items"))

    return findings, total

def check_results_csv(path):
    """THE ACTUAL 63-vs-64 CHECK. The defect was two DISTINCT items sharing one `item_id`
    STRING -- invisible in the packs (which carry positional numbers, not ids) and only
    visible in trial-level results. Signature: within one channel x admin, one item_id
    carries a multiple of the modal replicate count.
    Stdlib csv only. Expects columns: channel, admin, item_id."""
    import csv
    out = []
    try: rows = list(csv.DictReader(open(path, encoding="utf-8", errors="replace")))
    except OSError as e: return [("ERROR", path, "CSV_UNREADABLE", str(e))]
    need = {"channel", "admin", "item_id"}
    cols = {c.strip() for c in (rows[0].keys() if rows else [])}
    if not need <= cols:
        return [("ERROR", path, "CSV_SCHEMA", f"missing column(s) {sorted(need - cols)}; have {sorted(cols)}")]
    groups = defaultdict(Counter)
    for r in rows: groups[(r["channel"].strip(), r["admin"].strip())][r["item_id"].strip()] += 1
    for (ch, adm), counter in sorted(groups.items()):
        if not counter: continue
        modal = Counter(counter.values()).most_common(1)[0][0]
        for iid, n in sorted(counter.items()):
            if n > modal and modal and n % modal == 0:
                out.append(("ERROR", f"{ch}/admin{adm}:{iid}", "ITEM_ID_COLLISION",
                    f"item_id carries {n} rows where the modal item has {modal} "
                    f"({n // modal}x) -> {n // modal} DISTINCT items share this id string. "
                    f"THIS IS THE 63-vs-64 DEFECT: paired analysis silently merges them. "
                    f"Give each item a unique id."))
            elif n != modal:
                out.append(("WARN", f"{ch}/admin{adm}:{iid}", "REP_COUNT_ODD",
                    f"{n} rows vs modal {modal} -- uneven replication, check for dropped trials"))
    return out

def main(argv):
    keys = None
    if "--keys" in argv:
        i = argv.index("--keys"); keys = json.load(open(argv[i+1])); argv = argv[:i] + argv[i+2:]
    results = None
    if "--results" in argv:
        i = argv.index("--results"); results = argv[i+1]; argv = argv[:i] + argv[i+2:]
    files = [a for a in argv[1:] if not a.startswith("-")]
    if not files:
        print(__doc__); return 2
    findings, total = lint(files, keys)
    if results: findings += check_results_csv(results)
    errs  = [f for f in findings if f[0] == "ERROR"]
    warns = [f for f in findings if f[0] == "WARN"]
    by_code = Counter(f[2] for f in findings)
    print(f"itembank_lint: {total} items across {len(files)} file(s) -> "
          f"{len(errs)} ERROR, {len(warns)} WARN")
    for code, n in by_code.most_common(): print(f"  {code:22s} {n}")
    print()
    for lvl, ref, code, msg in errs + warns:
        print(f"[{lvl}] {ref}  {code}\n      {msg}")
    return 1 if errs else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
