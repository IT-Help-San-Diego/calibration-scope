#!/usr/bin/env python3
"""ui_lint.py — static guards for the shipped HTML surfaces.

WHY THIS EXISTS. CS-027 found the same defect twice in one day by accident: an
element styled to look clickable, with a handler the mouse could reach and the
keyboard could not. The sweep that closed it found seven more. A sweep finds the
ones present today; only a rule keeps the eighth from landing tomorrow.

PATTERN_narrow_check_wide_claim.md makes the argument this file is the answer to:
migration 048 wrote its rule in its own header and 057 broke it nine migrations
later. A rule in a comment is a comment. So the two rules this file enforces are
the two that were, until now, only comments in the markup they govern.

DELIBERATE LIMIT, stated so a green run is not over-read: this is a STATIC check
over markup. It cannot see controls built at runtime by app.js — the model-row
listbox (CS-037) is invisible to it — and it cannot see cursor:pointer applied
via a CSS class. It catches the shape that regressed in practice: an inline
onclick on something that is not a control. The live DOM audit in CS-027's card
is the wider net; this is the one that runs in a second with no browser.
"""
import re, sys, pathlib

# Tags the browser already makes focusable and operable by keyboard.
NATIVE = {"a", "button", "input", "select", "textarea", "summary", "label", "option", "details"}
INTERACTIVE_ROLES = {
    "button", "link", "tab", "checkbox", "radio", "menuitem", "option", "switch",
    "treeitem", "combobox", "slider", "spinbutton", "textbox",
    "menuitemcheckbox", "menuitemradio",
}
# Either the page loads the bundle that carries the shared activator, or it
# carries its own copy. This literal appears in both; see assets/app.js.
ACTIVATOR_MARKERS = ("app.min.js", "getAttribute('role') !== 'button'")

R1 = "an onclick on a non-interactive tag needs role=\"...\" AND tabindex=\"0\" — mouse-only otherwise"
R2 = "a page using role=\"button\" must ship the keyboard activator (app.min.js, or its own copy)"
R3 = "#context-flip must not carry an inline style= — it outranks the canonical geometry in app.css"

TAG_RE = re.compile(r"<([a-zA-Z][\w-]*)((?:\"[^\"]*\"|'[^']*'|[^>\"'])*)>")


def strip_noise(html):
    """Remove comments and script bodies, preserving offsets so line numbers hold.

    A rule QUOTED in a comment must not be a hit — that is the mistake this very
    file's header would otherwise trigger, and the same case migration_lint.py
    carries. Script bodies go because markup-shaped strings inside JS are not
    markup; the cost is that runtime-built controls are out of scope, which the
    module docstring states rather than hides.
    """
    def blank(m):
        return re.sub(r"[^\n]", " ", m.group(0))
    html = re.sub(r"<!--.*?-->", blank, html, flags=re.S)
    html = re.sub(r"<script\b[^>]*>.*?</script\s*>", blank, html, flags=re.S | re.I)
    return html


def attrs_of(blob):
    out = {}
    for m in re.finditer(r"([\w:-]+)\s*=\s*(\"[^\"]*\"|'[^']*'|[^\s>]+)", blob):
        out[m.group(1).lower()] = m.group(2).strip("\"'")
    return out


def violations(html, path="<input>"):
    out = []
    clean = strip_noise(html)

    for m in TAG_RE.finditer(clean):
        tag = m.group(1).lower()
        a = attrs_of(m.group(2))
        line = clean.count("\n", 0, m.start()) + 1

        # R1 — a handler on something that is not a control
        if "onclick" in a and tag not in NATIVE:
            role_ok = a.get("role", "").lower() in INTERACTIVE_ROLES
            ti = a.get("tabindex")
            ti_ok = ti is not None and ti.lstrip("+-").isdigit() and int(ti) >= 0
            if not (role_ok and ti_ok):
                missing = []
                if not role_ok:
                    missing.append("role")
                if not ti_ok:
                    missing.append("tabindex")
                out.append(("R1", path, line, f"<{tag}> onclick={a['onclick'][:40]!r} missing {'+'.join(missing)}", R1))

        # R3 — the canonical portal pill must not be re-forked by an inline style
        if a.get("id") == "context-flip" and "style" in a:
            out.append(("R3", path, line, "#context-flip carries an inline style=", R3))

    # R2 — role="button" without an activator on the page.
    # Scoped to whole DOCUMENTS: "does this page ship an activator" is a property
    # of a page, and asking it of a fragment gives a false FAIL for a snippet
    # whose activator simply lives in the file that will contain it.
    is_document = re.search(r"<html\b|</body\s*>", html, re.I) is not None
    if is_document and 'role="button"' in clean and not any(mk in html for mk in ACTIVATOR_MARKERS):
        out.append(("R2", path, 1, 'role="button" present but no keyboard activator on this page', R2))

    return out


def main(paths):
    bad = []
    for p in paths:
        bad += violations(pathlib.Path(p).read_text(encoding="utf-8"), p)
    for rule, path, line, what, why in bad:
        print(f"[FAIL] {rule} {pathlib.Path(path).name}:{line} — {what}")
        print(f"       RULE: {why}")
    print(f"\n{len(paths)} file(s) checked — {len(bad)} violation(s)")
    return 1 if bad else 0


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--selftest":
        cases = [
            ('<div onclick="f()">x</div>', 1,
             "the CS-027 shape: handler, no role, no tab stop"),
            ('<div onclick="f()" role="button" tabindex="0">x</div>', 0,
             "role + tab stop — the fixed form"),
            ('<div onclick="f()" role="button">x</div>', 1,
             "role without a tab stop is still unreachable"),
            ('<div onclick="f()" tabindex="0">x</div>', 1,
             "tab stop without a role tells AT nothing"),
            ('<button onclick="f()">x</button>', 0,
             "a real button needs neither — the browser provides both"),
            ('<a href="/x" onclick="f()">x</a>', 0,
             "an anchor with href is already a control"),
            ('<!-- <div onclick="f()">x</div> -->', 0,
             "the rule quoted in a comment is not a violation"),
            ('<script>el.innerHTML = \'<div onclick="f()">x</div>\';</script>', 0,
             "markup inside a script body is out of static scope, not a hit"),
            ('<div onclick="f()" role="button" tabindex="-1">x</div>', 1,
             "tabindex=-1 is focusable by script only, not by Tab"),
            ('<a id="context-flip" style="position:static" href="/">x</a>', 1,
             "the exact fork the de-fork removed: inline style outranks app.css"),
            ('<a id="context-flip" href="/">x</a>', 0,
             "the pill with geometry left to the stylesheet"),
            ('<html><body><div role="button" tabindex="0" onclick="f()">x</div></body></html>', 1,
             "a PAGE using role=button with no activator anywhere on it"),
            ('<html><body><script src="/assets/app.min.js"></script>'
             '<div role="button" tabindex="0" onclick="f()">x</div></body></html>', 0,
             "same page, but it loads the bundle carrying the activator"),
            ('<div role="button" tabindex="0" onclick="f()">x</div>', 0,
             "a FRAGMENT is not a page — R2 must not judge where its activator lives"),
        ]
        ok = 0
        for html, want, why in cases:
            got = len(violations(html))
            flag = "PASS" if got == want else "FAIL"
            ok += got == want
            print(f"  [{flag}] want {want} got {got} — {why}")
        print(f"\nself-test: {ok}/{len(cases)} passed")
        sys.exit(0 if ok == len(cases) else 1)
    if not args:
        args = [str(p) for p in sorted(pathlib.Path(".").glob("assets/*.html"))] + \
               [str(p) for p in sorted(pathlib.Path(".").glob("site/*.html"))]
    sys.exit(main(args))
