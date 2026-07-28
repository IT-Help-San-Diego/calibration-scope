#!/usr/bin/env python3
"""Generate docs/architecture.excalidraw from a declarative spec, and render
the SAME geometry to SVG so the layout can be verified before committing.

The .excalidraw file stays the editable source anybody can open for free at
excalidraw.com. This script is the authoring tool; the SVG is the proof."""
import json, html, sys, os

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

W, H = 1680, 1000
MONO = 3   # excalidraw fontFamily: 1=hand, 2=normal, 3=code
HAND = 1

# ── palette (matches the instrument's own scotopic identity on light paper) ──
INK      = "#1e1e1e"
MUTED    = "#5c5c5c"
GOLD     = "#b8860b"
CYAN     = "#0b7285"
GREEN    = "#0ca678"
VIOLET   = "#6741d9"
GREY     = "#868e96"

zones = [
    # id, x, y, w, h, label, stroke, fill
    ("z_local",  50,  110,  790, 840, "LOCAL INSTRUMENT — your machine, port 8768", CYAN,  "#e3fafc"),
    ("z_subj",   880, 110,  330, 470, "SUBJECTS — one schema, both kinds",          GOLD,  "#fff9db"),
    ("z_out",    880, 620,  330, 330, "EVIDENCE OUT",                                VIOLET, "#f3f0ff"),
    ("z_ext",   1250, 110,  380, 840, "NOTES",                                       GREY,   "#f8f9fa"),
]

boxes = [
    # id, x, y, w, h, lines, stroke
    ("b_dash",  85, 175, 340, 165, [
        "DASHBOARD  ·  single file",
        "dashboard.html + app.min.js/css",
        "",
        "Focused shell (default): one viewport",
        "Deep: full tab flow · nav tabs are",
        "native buttons, keyboard + aria-current",
    ], CYAN),
    ("b_rungs", 85, 370, 340, 120, [
        "FIRST RUN — the ladder",
        "1 continuity test (zero credentials)",
        "2 Model Picker (server-graded)",
        "3 Subject/Channel wizard",
    ], CYAN),
    ("b_hcal",  85, 520, 340, 105, [
        "HUMAN CAL",
        "same items · same grader as models",
        "per-question timing · carrier swing",
    ], GOLD),
    ("b_api",  460, 175, 350, 200, [
        "axum BACKEND  (Rust)",
        "",
        "runs · models · events (SSE)",
        "participants · signal-carrier",
        "picker · witness · mcp",
        "",
        "SSE connects AFTER window load",
    ], CYAN),
    ("b_exec", 460, 405, 350, 155, [
        "EXECUTOR",
        "clean-room load · blind trials · N=3",
        "score_response grader",
        "SHA3-512 seal over ordered verdicts",
    ], CYAN),
    ("b_guard",460, 590, 350, 60, [
        "lm_guard semaphore",
        "serializes every LM Studio call",
    ], GREY),
    ("b_pg",    85, 700, 725, 130, [
        "PostgreSQL",
        "tests · test_runs (model_id XOR participant_id) · trial_results",
        "participants · owl_signal_carrier view",
    ], GREEN),
    ("b_lms",  910, 175, 270, 95, [
        "LM STUDIO",
        "local OpenAI-compatible API",
        "silicon · local channel",
    ], GOLD),
    ("b_cloud",910, 300, 270, 95, [
        "CLOUD PROVIDERS",
        "Nous · OpenRouter · OpenAI",
        "silicon · cloud channel",
    ], GOLD),
    ("b_human",910, 425, 270, 95, [
        "HUMAN PARTICIPANT",
        "dashboard quiz",
        "carbon · same battery",
    ], GOLD),
    ("b_wit",  910, 680, 270, 110, [
        "WITNESS CERTIFICATE",
        "GET /api/runs/{id}/witness",
        "zero-JS φ SVG + claim ledger",
        "no witness without a seal",
    ], VIOLET),
    ("b_site", 910, 820, 270, 105, [
        "PUBLIC SITE",
        "calibrationscope.com",
        "S3 + CloudFront · zero JS",
        "CSP style hashes pinned",
    ], VIOLET),
]

notes = [
    ("n_1", 1275, 175, [
        "EVIDENCE DISCIPLINE",
        "",
        "· infra errors are flagged and excluded",
        "  from scoring — missing data, never",
        "  wrong answers",
        "· latency recorded for BOTH subject kinds",
        "· re-finishing a sealed run replays the",
        "  stored seal; it never re-derives it",
    ]),
    ("n_2", 1275, 415, [
        "KNOWN GAPS  (recorded, not hidden)",
        "",
        "· owl_signal_carrier view lacks the infra",
        "  filter and uses sample variance — the",
        "  endpoint inlines corrected SQL (relay h)",
        "· no channel column on runs yet (§14):",
        "  Witness labels channel as derived",
        "· no authentication anywhere — the",
        "  participant guards are integrity",
        "  against mistakes, not access control",
        "· Lighthouse CI gate is a single run on a",
        "  threshold-straddling page (relay f)",
    ]),
    ("n_3", 1275, 740, [
        "THREE AGENTS, ONE MEMORY",
        "",
        "Claude Code — GUI lane",
        "Hermes Desktop — backend / executor / CI",
        "Claude Science — independent validation",
        "",
        "The git repo is the only shared memory;",
        "DECISIONS.md carries cross-lane relays.",
    ]),
]

# Orthogonal routing: every segment is axis-aligned and runs through a
# deliberately empty corridor (x=845 between the local zone and the
# subjects zone), so no arrow crosses a box. Labels sit ON a corridor
# segment, never over a box. Both properties are asserted below — the
# first pass drew diagonals through the Executor and ran one arrow off
# the canvas, and a checker that only looked at box-vs-box missed it.
arrows = [
    # id, x, y, points, label, label_dx, label_dy, stroke, dashed
    ("a_dash_api", 425, 250, [[0,0],[35,0]], "", 0, 0, CYAN, False),
    ("a_rungs_api",425, 420, [[0,0],[18,0],[18,-125],[35,-125]], "", 0, 0, CYAN, False),
    ("a_api_exec", 635, 375, [[0,0],[0,30]], "", 0, 0, CYAN, False),
    ("a_exec_grd", 635, 560, [[0,0],[0,30]], "", 0, 0, CYAN, False),
    # Backend → Postgres runs down the 425–460 gutter, not through the
    # Executor and lm_guard (the checker now proves it does not).
    ("a_api_pg",   540, 375, [[0,0],[-98,0],[-98,325],[-55,325]], "", 0, 0, GREEN, False),
    ("a_exec_cld", 810, 440, [[0,0],[35,0],[35,-92],[100,-92]], "", 0, 0, GOLD, False),
    ("a_grd_lms",  810, 620, [[0,0],[25,0],[25,-398],[100,-398]], "", 0, 0, GOLD, False),
    ("a_human_hcal",910, 472, [[0,0],[-55,0],[-55,100],[-430,100]], "answers", -60, 21, GOLD, False),
    ("a_api_wit",  810, 330, [[0,0],[48,0],[48,405],[100,405]], "sealed runs", -43, 0, VIOLET, False),
    ("a_site_dash",905, 872, [[0,0],[-60,0],[-60,-45]], "LOCAL ⇄ WEB", -55, 0, GREY, False),
]

def text_el(eid, x, y, s, size=13, color=INK, family=MONO):
    return {"type":"text","id":eid,"x":x,"y":y,"text":s,"fontSize":size,
            "fontFamily":family,"strokeColor":color,"originalText":s,
            "autoResize":True,"textAlign":"left","verticalAlign":"top"}

def build():
    els = []
    els.append(text_el("title", 50, 30, "Calibration Scope — architecture", 30, INK, HAND))
    els.append(text_el("subtitle", 50, 72,
        "Measures the gap between what a system STATES and what is ACTUALLY true — silicon and carbon, one schema, sealed evidence.",
        14, MUTED, MONO))
    els.append(text_el("stamp", 1275, 72, "updated 2026-07-28", 12, MUTED, MONO))

    for zid, x, y, w, h, label, stroke, fill in zones:
        els.append({"type":"rectangle","id":zid,"x":x,"y":y,"width":w,"height":h,
                    "backgroundColor":fill,"fillStyle":"solid","roundness":{"type":3},
                    "strokeColor":stroke,"strokeWidth":1,"opacity":40})
        els.append(text_el(zid+"_l", x+14, y+12, label, 13, stroke, MONO))

    for bid, x, y, w, h, lines, stroke in boxes:
        els.append({"type":"rectangle","id":bid,"x":x,"y":y,"width":w,"height":h,
                    "backgroundColor":"#ffffff","fillStyle":"solid","roundness":{"type":3},
                    "strokeColor":stroke,"strokeWidth":2,"opacity":100})
        ty = y + 12
        for i, ln in enumerate(lines):
            if ln:
                els.append(text_el(f"{bid}_t{i}", x+12, ty,
                                   ln, 14 if i == 0 else 12,
                                   stroke if i == 0 else INK, MONO))
            ty += 19 if i == 0 else 15

    for nid, x, y, lines in notes:
        ty = y
        for i, ln in enumerate(lines):
            if ln:
                els.append(text_el(f"{nid}_t{i}", x, ty, ln,
                                   13 if i == 0 else 11,
                                   GREY if i == 0 else INK, MONO))
            ty += 18 if i == 0 else 14

    for aid, x, y, pts, label, ldx, ldy, stroke, dashed in arrows:
        xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
        a = {"type":"arrow","id":aid,"x":x,"y":y,
             "width":max(xs)-min(xs),"height":max(ys)-min(ys),
             "points":pts,"strokeColor":stroke,"strokeWidth":2,
             "endArrowhead":"arrow"}
        if dashed:
            a["strokeStyle"] = "dashed"
            a["startArrowhead"] = "arrow"
        els.append(a)
        if label:
            # Anchored to the LONGEST segment's midpoint, nudged by ldx into
            # the empty corridor — never floated at the chord midpoint, which
            # is what put labels on top of boxes in the first pass.
            best, blen = None, -1
            for p0, p1 in zip(pts, pts[1:]):
                seg = abs(p1[0]-p0[0]) + abs(p1[1]-p0[1])
                if seg > blen:
                    blen, best = seg, ((p0[0]+p1[0])/2, (p0[1]+p1[1])/2)
            els.append(text_el(aid+"_l", x+best[0]+ldx, y+best[1]-15+ldy, label, 11, stroke, MONO))
    return els

def render_svg(els, path):
    """Project the same geometry to SVG — verification, not a substitute."""
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
         f'viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="#fff"/>',
         '<defs><marker id="ah" markerWidth="9" markerHeight="9" refX="8" refY="3" '
         'orient="auto"><path d="M0,0 L8,3 L0,6 Z" fill="context-stroke"/></marker></defs>']
    for e in els:
        if e["type"] == "rectangle":
            op = e.get("opacity", 100) / 100
            o.append(f'<rect x="{e["x"]}" y="{e["y"]}" width="{e["width"]}" '
                     f'height="{e["height"]}" rx="8" fill="{e["backgroundColor"]}" '
                     f'fill-opacity="{op}" stroke="{e["strokeColor"]}" '
                     f'stroke-width="{e["strokeWidth"]}"/>')
    for e in els:
        if e["type"] == "arrow":
            pts = " ".join(f'{e["x"]+p[0]},{e["y"]+p[1]}' for p in e["points"])
            dash = ' stroke-dasharray="6 4"' if e.get("strokeStyle") == "dashed" else ""
            o.append(f'<polyline points="{pts}" fill="none" stroke="{e["strokeColor"]}" '
                     f'stroke-width="{e["strokeWidth"]}"{dash} marker-end="url(#ah)"/>')
        elif e["type"] == "text":
            fam = "ui-monospace, Menlo, monospace" if e["fontFamily"] == MONO else "Segoe UI, sans-serif"
            o.append(f'<text x="{e["x"]}" y="{e["y"] + e["fontSize"]}" font-size="{e["fontSize"]}" '
                     f'font-family="{fam}" fill="{e["strokeColor"]}">{html.escape(e["text"])}</text>')
    o.append("</svg>")
    # encoding pinned: the diagram carries —, ·, ⇄, φ, so relying on the
    # platform default would raise UnicodeEncodeError on a cp1252 Windows
    # box (review catch).
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(o))

def _hit(bx, by, bw, bh, x0, y0, x1, y1, pad=0):
    """Does the axis-aligned segment (x0,y0)-(x1,y1) enter the box interior?"""
    lo_x, hi_x = min(x0, x1), max(x0, x1)
    lo_y, hi_y = min(y0, y1), max(y0, y1)
    return (lo_x < bx + bw - pad and hi_x > bx + pad and
            lo_y < by + bh - pad and hi_y > by + pad)

def overlap_report(els):
    """Layout guard. v1 only compared box-to-box and passed a diagram whose
    arrows crossed the Executor and ran off the canvas — the eye caught what
    the check did not, so the check now covers what the eye had to."""
    rects = {e["id"]: e for e in els if e["type"] == "rectangle"}
    box_ids = [b[0] for b in boxes]
    problems = []
    for i, a in enumerate(box_ids):
        for b in box_ids[i+1:]:
            ra, rb = rects[a], rects[b]
            if _hit(ra["x"], ra["y"], ra["width"], ra["height"],
                    rb["x"], rb["y"], rb["x"]+rb["width"], rb["y"]+rb["height"]):
                problems.append(f"box overlap: {a} / {b}")

    for e in els:
        if e["type"] == "text" and "_t" in e["id"]:
            bid = e["id"].split("_t")[0]
            if bid in rects:
                r = rects[bid]
                if not (r["x"] <= e["x"] and e["y"] + e["fontSize"] <= r["y"] + r["height"]):
                    problems.append(f"text outside box: {e['id']} ({e['text'][:30]})")
                if e["x"] + len(e["text"]) * e["fontSize"] * 0.62 > r["x"] + r["width"]:
                    problems.append(f"text overflows box width: {e['id']} ({e['text'][:34]})")

    # Everything must live on the canvas.
    for e in els:
        if e["type"] == "arrow":
            for p in e["points"]:
                px, py = e["x"] + p[0], e["y"] + p[1]
                if not (0 <= px <= W and 0 <= py <= H):
                    problems.append(f"arrow off canvas: {e['id']} at ({px},{py})")
        elif e["type"] == "rectangle":
            if e["x"] + e["width"] > W or e["y"] + e["height"] > H:
                problems.append(f"box off canvas: {e['id']}")
        elif e["type"] == "text":
            if e["x"] + len(e["text"]) * e["fontSize"] * 0.62 > W:
                problems.append(f"text off canvas: {e['id']}")

    # No arrow segment may pass through a content box (zones are containers,
    # so they are exempt); 2px pad tolerates touching an edge to dock.
    for e in els:
        if e["type"] != "arrow":
            continue
        for p0, p1 in zip(e["points"], e["points"][1:]):
            x0, y0 = e["x"]+p0[0], e["y"]+p0[1]
            x1, y1 = e["x"]+p1[0], e["y"]+p1[1]
            for bid in box_ids:
                r = rects[bid]
                if _hit(r["x"], r["y"], r["width"], r["height"], x0, y0, x1, y1, pad=2):
                    problems.append(f"arrow {e['id']} crosses box {bid}")

    # Arrow labels must not sit on a box either.
    for e in els:
        if e["type"] == "text" and e["id"].endswith("_l") and e["id"].startswith("a_"):
            w = len(e["text"]) * e["fontSize"] * 0.62
            for bid in box_ids:
                r = rects[bid]
                if _hit(r["x"], r["y"], r["width"], r["height"],
                        e["x"], e["y"], e["x"]+w, e["y"]+e["fontSize"], pad=2):
                    problems.append(f"label {e['id']} sits on box {bid}")
    return problems

if __name__ == "__main__":
    els = build()
    probs = overlap_report(els)
    doc = {"type":"excalidraw","version":2,
           "source":"scripts/gen_architecture_diagram.py",
           "elements":els,"appState":{"gridSize":None,"viewBackgroundColor":"#ffffff"},
           "files":{}}
    with open(os.path.join(REPO, "docs", "architecture.excalidraw"),
              "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1, ensure_ascii=False)
    os.makedirs(os.path.join(REPO, "target"), exist_ok=True)
    render_svg(els, sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, "target", "architecture-preview.svg"))
    print(f"elements: {len(els)}  ·  layout problems: {len(probs)}")
    for p in probs:
        print("  !", p)
    sys.exit(1 if probs else 0)
