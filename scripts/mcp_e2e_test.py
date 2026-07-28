#!/usr/bin/env python3
"""End-to-end MCP client test against POST /mcp (JSON-RPC 2.0).

Acts as a real bot would: handshake, discover the tool surface, call the
read-only tools, validate response shapes, and probe the error paths. Nothing
is taken on faith — the expected tool set is parsed OUT OF src/routes/mcp.rs
at runtime, so a tool added to the registry but never wired into the
dispatcher (or vice versa) is caught as a mismatch instead of a green tick.

Run: python3 scripts/mcp_e2e_test.py [--base-url http://127.0.0.1:8768]

GPU SAFETY: run_benchmark starts a REAL clean-room run on a real GPU. By
default this script NEVER fires one. It validates run_benchmark's CONTRACT
only — presence, input schema, and the three server-side validation refusals
that are rejected before any test_runs row is created. Pass --fire-run
(plus --model-key and --axis) to actually start a run. Without --fire-run the
queued/running count is snapshotted before and after and asserted unchanged;
WITH --fire-run it is snapshotted only, because the queue is expected to move.

Outcomes printed per check:
  PASS  the server did what the code says it does
  FAIL  protocol or contract broken (exit 1)
  GAP   documented-vs-actual, in either of two kinds: a tool's own
        description promises a field or a filter the implementation does
        not deliver, OR the transport deviates from JSON-RPC 2.0 / MCP
        (some of those originate in the HTTP layer, before the MCP
        handler runs). Each GAP line names which kind it is. (exit 2)
An absent field is never a skip. It is a FAIL or a GAP, always printed with
the value actually observed.

Exit 0 = clean. Exit 1 = at least one FAIL. Exit 2 = GAPs only.
"""
import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MCP_SRC = os.path.join(REPO, "src", "routes", "mcp.rs")
CARGO_TOML = os.path.join(REPO, "Cargo.toml")

PASS, FAIL, GAP, INFO = "PASS", "FAIL", "GAP ", "INFO"
RESULTS = []
_next_id = [0]


def record(outcome, label, detail):
    RESULTS.append((outcome, label, detail))
    print(f"  [{outcome}] {label}\n         {detail}")


def check(label, condition, detail):
    record(PASS if condition else FAIL, label, detail)
    return condition


def gap(label, detail):
    record(GAP, label, detail)


def info(label, detail):
    record(INFO, label, detail)


def section(title):
    print(f"\n{title}\n{'-' * len(title)}")


# ── Source of truth: parse the Rust registry + dispatcher ──────────────────

def parse_source_registry():
    """Return (registry_names, dispatch_names) read from src/routes/mcp.rs."""
    with open(MCP_SRC, "r", encoding="utf-8") as fh:
        src = fh.read()
    reg_body = re.search(r"fn tool_registry\(\).*?\n\}\n", src, re.S)
    dis_body = re.search(r"async fn dispatch_tool\(.*?\n\}\n", src, re.S)
    if not reg_body or not dis_body:
        print("FATAL: could not locate tool_registry()/dispatch_tool() in " + MCP_SRC)
        sys.exit(1)
    registry = re.findall(r'name:\s*"([a-z_]+)"', reg_body.group(0))
    dispatch = re.findall(r'"([a-z_]+)"\s*=>\s*tool_', dis_body.group(0))
    return registry, dispatch


def cargo_version():
    with open(CARGO_TOML, "r", encoding="utf-8") as fh:
        for line in fh:
            m = re.match(r'^version\s*=\s*"([^"]+)"', line.strip())
            if m:
                return m.group(1)
    return None


# ── Transport ─────────────────────────────────────────────────────────────

def post_raw(base_url, body_bytes):
    """POST a raw body. Returns (http_status, text). Never raises on 4xx/5xx."""
    req = urllib.request.Request(
        base_url + "/mcp",
        data=body_bytes,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")


def rpc(base_url, method, params=None, req_id=None):
    """One JSON-RPC call. Returns (http_status, envelope_or_None, raw_text)."""
    if req_id is None:
        _next_id[0] += 1
        req_id = _next_id[0]
    payload = {"jsonrpc": "2.0", "id": req_id, "method": method}
    if params is not None:
        payload["params"] = params
    status, text = post_raw(base_url, json.dumps(payload).encode("utf-8"))
    try:
        env = json.loads(text)
    except json.JSONDecodeError:
        env = None
    return status, env, text, req_id


def call_tool(base_url, name, args):
    """tools/call. Returns (envelope, payload, is_error, text_blob)."""
    status, env, raw, req_id = rpc(
        base_url, "tools/call", {"name": name, "arguments": args}
    )
    if not isinstance(env, dict) or "result" not in env:
        return env, None, None, raw
    result = env["result"]
    blob = ""
    content = result.get("content")
    if isinstance(content, list) and content and isinstance(content[0], dict):
        blob = content[0].get("text", "")
    try:
        payload = json.loads(blob)
    except (json.JSONDecodeError, TypeError):
        payload = None
    return env, payload, result.get("isError"), blob


def fields_report(obj, keys):
    """Human-readable presence report. Absent != null — both are shown."""
    out = []
    for k in keys:
        if not isinstance(obj, dict) or k not in obj:
            out.append(f"{k}=ABSENT")
        elif obj[k] is None:
            out.append(f"{k}=null(explicit)")
        else:
            v = obj[k]
            v = v if not isinstance(v, (list, dict)) else f"<{type(v).__name__} len={len(v)}>"
            out.append(f"{k}={v}")
    return ", ".join(out)


def missing(obj, keys):
    return [k for k in keys if not isinstance(obj, dict) or k not in obj]


# ── Queue safety ──────────────────────────────────────────────────────────

def queue_snapshot(base_url):
    """(active_count, detail) of queued/running runs, via the REST API."""
    try:
        with urllib.request.urlopen(base_url + "/api/runs?limit=50", timeout=30) as r:
            data = json.loads(r.read().decode("utf-8"))
    except (urllib.error.URLError, json.JSONDecodeError) as e:
        return None, f"could not read /api/runs: {e}"
    runs = data.get("runs")
    if not isinstance(runs, list):
        return None, "GET /api/runs returned no 'runs' array"
    active = [r for r in runs if r.get("status") in ("queued", "running")]
    return len(active), (
        f"{len(runs)} recent runs, active={[ (r['id'], r['status']) for r in active ]}"
    )


# ── The test run ──────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-url", default="http://127.0.0.1:8768")
    ap.add_argument(
        "--fire-run",
        action="store_true",
        help="ACTUALLY start a GPU benchmark run via run_benchmark (off by default)",
    )
    ap.add_argument("--model-key", help="model_key for --fire-run")
    ap.add_argument("--axis", help="axis for --fire-run")
    args = ap.parse_args()
    base = args.base_url.rstrip("/")

    print(f"MCP e2e test -> {base}/mcp")
    print(f"registry source of truth: {MCP_SRC}")

    # ── 0. Queue must be idle before we touch anything ────────────────────
    section("0. Queue state BEFORE")
    active_before, detail = queue_snapshot(base)
    check("queue readable", active_before is not None, detail)
    if active_before is None:
        summarize()
        return
    check("queue idle before test", active_before == 0, detail)

    # ── 1. Registry parsed from the Rust source ───────────────────────────
    section("1. Tool registry parsed from source")
    registry, dispatch = parse_source_registry()
    check(
        "tool_registry() parsed",
        len(registry) > 0,
        f"{len(registry)} tools in source: {sorted(registry)}",
    )
    check(
        "registry names are unique",
        len(set(registry)) == len(registry),
        f"{len(set(registry))} unique of {len(registry)}",
    )
    check(
        "every registry tool has a dispatch_tool arm",
        set(registry) == set(dispatch),
        f"registry-only={sorted(set(registry) - set(dispatch))}, "
        f"dispatch-only={sorted(set(dispatch) - set(registry))}",
    )

    # ── 2. Handshake ──────────────────────────────────────────────────────
    section("2. Handshake")
    status, env, raw, req_id = rpc(
        base,
        "initialize",
        {"protocolVersion": "2025-06-18", "capabilities": {},
         "clientInfo": {"name": "mcp_e2e_test.py", "version": "1"}},
    )
    ok = check("initialize -> HTTP 200 + JSON-RPC envelope",
               status == 200 and isinstance(env, dict), f"HTTP {status}, body={raw[:160]}")
    if not ok:
        summarize()
        return
    check("initialize echoes request id",
          env.get("id") == req_id, f"sent id={req_id}, got id={env.get('id')!r}")
    check("initialize jsonrpc=2.0", env.get("jsonrpc") == "2.0", f"jsonrpc={env.get('jsonrpc')!r}")
    res = env.get("result", {})
    miss = missing(res, ["protocolVersion", "capabilities", "serverInfo"])
    check("initialize result has protocolVersion/capabilities/serverInfo",
          not miss, fields_report(res, ["protocolVersion", "capabilities", "serverInfo"]))
    caps = res.get("capabilities") or {}
    check("capabilities advertises tools",
          "tools" in caps, f"capabilities={json.dumps(caps)}")
    sinfo = res.get("serverInfo") or {}
    check("serverInfo has name + version",
          not missing(sinfo, ["name", "version"]), fields_report(sinfo, ["name", "version"]))
    cv = cargo_version()
    check("serverInfo.version matches Cargo.toml",
          cv is not None and sinfo.get("version") == cv,
          f"serverInfo.version={sinfo.get('version')!r}, Cargo.toml version={cv!r}")

    # A spec-conformant MCP client sends notifications/initialized (no id)
    # right after initialize, and expects NO response to a notification.
    n_status, n_text = post_raw(
        base, json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}).encode()
    )
    try:
        n_env = json.loads(n_text)
    except json.JSONDecodeError:
        n_env = None
    if isinstance(n_env, dict) and "error" in n_env:
        gap("notifications/initialized handled",
            f"HTTP {n_status}, server replies with an ERROR envelope to the standard "
            f"post-initialize notification: {json.dumps(n_env.get('error'))}. A strict MCP "
            f"client sends this; JSON-RPC also says a notification (no id) gets no response "
            f"at all. Not fatal — the server does not crash and tools still work.")
    else:
        record(PASS, "notifications/initialized handled", f"HTTP {n_status}, body={n_text[:160]!r}")

    status, env, raw, req_id = rpc(base, "ping")
    check("ping -> result",
          isinstance(env, dict) and isinstance(env.get("result"), dict),
          f"HTTP {status}, body={raw[:160]}")

    # ── 3. Discovery: tools/list must match the source registry EXACTLY ───
    section("3. Discovery (tools/list vs source registry)")
    status, env, raw, req_id = rpc(base, "tools/list")
    tools = (env or {}).get("result", {}).get("tools")
    if not check("tools/list returns a tools array",
                 isinstance(tools, list), f"HTTP {status}, body={raw[:200]}"):
        summarize()
        return
    live_names = [t.get("name") for t in tools]
    check("discovered tool COUNT matches source registry",
          len(live_names) == len(registry),
          f"discovered={len(live_names)}, source registry={len(registry)}")
    check("discovered tool NAMES match source registry exactly",
          set(live_names) == set(registry),
          f"discovered-only={sorted(set(live_names) - set(registry))}, "
          f"source-only={sorted(set(registry) - set(live_names))}; "
          f"discovered={sorted(n for n in live_names if n)}")
    bad_schema = [
        t.get("name") for t in tools
        if not t.get("description")
        or not isinstance(t.get("inputSchema"), dict)
        or t["inputSchema"].get("type") != "object"
    ]
    check("every tool has a non-empty description + object inputSchema",
          not bad_schema, f"offenders={bad_schema or 'none'} (checked {len(tools)} tools)")
    by_name = {t.get("name"): t for t in tools}

    # ── 4. Read-only tools + response shapes ─────────────────────────────
    section("4. Read-only tool calls")

    env, payload, is_err, blob = call_tool(base, "get_status", {})
    if check("get_status returns a JSON payload",
             isinstance(payload, dict) and is_err is False,
             f"isError={is_err}, payload={blob[:200]!r}"):
        keys = ["status", "db_connected", "running_runs", "models_in_registry"]
        check("get_status shape", not missing(payload, keys), fields_report(payload, keys))
        check("get_status.db_connected is True",
              payload.get("db_connected") is True,
              f"db_connected={payload.get('db_connected')!r}")
        check("get_status.running_runs agrees with /api/runs",
              payload.get("running_runs") == active_before,
              f"tool says {payload.get('running_runs')!r}, /api/runs active={active_before}")
        desc = by_name.get("get_status", {}).get("description", "")
        if "uptime" in desc.lower():
            if "uptime" in payload:
                record(PASS, "get_status delivers the uptime it advertises",
                       f"uptime={payload['uptime']!r}")
            else:
                gap("get_status advertises uptime it does not return",
                    f"description says {desc!r}; payload keys={sorted(payload)} — no uptime field. "
                    f"A client that reads the description will look for a field that is never sent.")
        else:
            info("get_status uptime promise", f"description no longer mentions uptime: {desc!r}")

    env, payload, is_err, blob = call_tool(base, "list_models", {})
    model_key = None
    if check("list_models returns a JSON payload",
             isinstance(payload, dict) and is_err is False,
             f"isError={is_err}, payload={blob[:160]!r}"):
        models = payload.get("models")
        check("list_models has models[] + count",
              isinstance(models, list) and isinstance(payload.get("count"), int),
              fields_report(payload, ["models", "count"]))
        if isinstance(models, list):
            check("list_models count == len(models)",
                  payload.get("count") == len(models),
                  f"count={payload.get('count')}, len(models)={len(models)}")
            check("list_models is non-empty",
                  len(models) > 0, f"{len(models)} models returned")
            if models:
                mkeys = ["key", "display_name", "provider", "location",
                         "context_length", "size_gb", "supports_vision", "verdicts"]
                bad = [m.get("key") for m in models if missing(m, mkeys)]
                check("every model row has the full advertised field set",
                      not bad,
                      f"rows missing fields: {bad[:5] or 'none'} "
                      f"(checked {len(models)} rows for {mkeys})")
                model_key = models[0].get("key")
                info("sample model row", fields_report(models[0], mkeys))
                # keyed on 'key', the primary handle — display names are NOT unique
                uniq_keys = len({m.get("key") for m in models})
                uniq_names = len({m.get("display_name") for m in models})
                info("model identity keyed on 'key' (not display_name)",
                     f"{len(models)} rows -> {uniq_keys} unique keys, {uniq_names} unique display_names")
                # advertised 'runnable' filter
                _, p_true, _, _ = call_tool(base, "list_models", {"runnable": True})
                _, p_false, _, _ = call_tool(base, "list_models", {"runnable": False})
                ct, cf = (p_true or {}).get("count"), (p_false or {}).get("count")
                # Observed, not assumed: does a row actually carry 'runnable'?
                row_has_runnable = sum(
                    1 for m in models if isinstance(m, dict) and "runnable" in m)
                if ct is None or cf is None:
                    check("list_models 'runnable' filter could be probed", False,
                          f"runnable=true count={ct!r}, runnable=false count={cf!r} — the filter "
                          f"probe did not return a usable payload, so the 'runnable' filter is "
                          f"NOT VALIDATED. Recorded as a failure, never as a pass.")
                elif ct == cf == payload.get("count"):
                    gap("list_models 'runnable' filter is advertised but inert",
                        f"inputSchema accepts runnable; count unfiltered={payload.get('count')}, "
                        f"runnable=true -> {ct}, runnable=false -> {cf}. Identical: the argument is "
                        f"accepted and changes nothing. Rows carrying a 'runnable' field: "
                        f"{row_has_runnable} of {len(models)}, though the description names one.")
                else:
                    record(PASS, "list_models 'runnable' filter changes the result set",
                           f"unfiltered={payload.get('count')}, true={ct}, false={cf}")

    env, payload, is_err, blob = call_tool(base, "list_tests", {})
    test_id = None
    if check("list_tests returns a JSON payload",
             isinstance(payload, dict) and is_err is False,
             f"isError={is_err}, payload={blob[:160]!r}"):
        tests = payload.get("tests")
        check("list_tests has tests[] + count",
              isinstance(tests, list) and isinstance(payload.get("count"), int),
              fields_report(payload, ["tests", "count"]))
        if isinstance(tests, list) and tests:
            check("list_tests count == len(tests)",
                  payload.get("count") == len(tests),
                  f"count={payload.get('count')}, len(tests)={len(tests)}")
            tkeys = ["id", "name", "axis", "formal_spec", "expected_result", "owl_type", "active"]
            bad = [t.get("id") for t in tests if missing(t, tkeys)]
            check("every test row has the full advertised field set",
                  not bad, f"rows missing fields: {bad[:5] or 'none'} (checked {len(tests)} rows)")
            uniq_ids = len({t.get("id") for t in tests})
            uniq_names = len({t.get("name") for t in tests})
            dupes = len(tests) - uniq_names
            check("test rows are uniquely keyed on test id",
                  uniq_ids == len(tests),
                  f"{len(tests)} rows -> {uniq_ids} unique ids, {uniq_names} unique names "
                  + (f"(names are demonstrably NOT the key: {dupes} duplicate-name collision(s))"
                     if dupes else
                     "(no duplicate name in THIS result set — names are still not the key, "
                     "the id is; this run simply shows no collision)"))
            test_id = tests[0].get("id")
            # Advertised 'active' filter semantics. Decided on the ROWS, not on
            # a count comparison: counts alone cannot tell "no filter" apart
            # from "a registry with more inactive tests than active ones". A
            # row whose own active field is true, returned under active=false,
            # is direct proof the filter does not mean "inactive only".
            _, p_true, _, _ = call_tool(base, "list_tests", {"active": True})
            _, p_false, _, _ = call_tool(base, "list_tests", {"active": False})
            ct, cf = (p_true or {}).get("count"), (p_false or {}).get("count")
            rows_false = (p_false or {}).get("tests")
            if ct is None or not isinstance(rows_false, list):
                check("list_tests active filter could be probed", False,
                      f"active=true count={ct!r}, active=false tests={rows_false!r} — the filter "
                      f"probe did not return a usable payload, so the 'active' filter semantics "
                      f"are NOT VALIDATED. Recorded as a failure, never as a pass.")
            else:
                still_active = [t.get("id") for t in rows_false if t.get("active") is True]
                if still_active:
                    gap("list_tests active=false does not select inactive tests",
                        f"active=true -> {ct}, active=false -> {cf}, "
                        f"no filter -> {payload.get('count')}. The active=false result still "
                        f"contains {len(still_active)} row(s) whose own active field is true "
                        f"(test_ids {still_active[:5]}), so active=false means 'no filter', not "
                        f"'inactive only'. A client asking for inactive tests gets active ones.")
                else:
                    record(PASS, "list_tests active=false selects only inactive tests",
                           f"active=true -> {ct}, active=false -> {cf}; no row in the "
                           f"active=false result has active=true")

    if test_id is not None:
        env, payload, is_err, blob = call_tool(base, "get_test_spec", {"test_id": test_id})
        keys = ["id", "name", "axis", "formal_spec", "expected_result", "owl_type", "owl_root_id"]
        check(f"get_test_spec(test_id={test_id}) returns the full spec",
              isinstance(payload, dict) and is_err is False and not missing(payload, keys),
              f"isError={is_err}, {fields_report(payload or {}, keys)}")
    else:
        check("get_test_spec could be exercised", False,
              "no test_id available from list_tests — get_test_spec NOT validated")

    if model_key:
        env, payload, is_err, blob = call_tool(base, "get_model_verdict", {"model_key": model_key})
        keys = ["key", "provider", "location", "context_length",
                "size_gb", "supports_vision", "verdicts"]
        check(f"get_model_verdict(model_key={model_key!r}) returns the verdict record",
              isinstance(payload, dict) and is_err is False and not missing(payload, keys),
              f"isError={is_err}, {fields_report(payload or {}, keys)}")
        desc = by_name.get("get_model_verdict", {}).get("description", "")
        if isinstance(payload, dict) and "score" in desc.lower():
            if "score" in payload:
                record(PASS, "get_model_verdict delivers the score it advertises",
                       f"score={payload['score']!r}")
            else:
                gap("get_model_verdict advertises 'score' it does not return",
                    f"description={desc!r}; payload keys={sorted(payload)} — no score field.")
    else:
        check("get_model_verdict could be exercised", False,
              "no model_key available from list_models — get_model_verdict NOT validated")

    env, payload, is_err, blob = call_tool(base, "get_leaderboard", {})
    if check("get_leaderboard returns a JSON payload",
             isinstance(payload, dict) and is_err is False,
             f"isError={is_err}, payload={blob[:160]!r}"):
        board = payload.get("leaderboard")
        check("get_leaderboard has axis + leaderboard[]",
              payload.get("axis") is not None and isinstance(board, list),
              fields_report(payload, ["axis", "leaderboard"]))
        if isinstance(board, list):
            if board:
                bkeys = ["model_key", "passed", "total", "pct"]
                bad = [r.get("model_key") for r in board if missing(r, bkeys)]
                check("leaderboard rows have model_key/passed/total/pct",
                      not bad, f"offenders={bad[:5] or 'none'} ({len(board)} rows)")
            else:
                info("get_leaderboard default axis returns zero rows",
                     f"axis={payload.get('axis')!r} -> 0 entries. Reported as empty, not as 0% — "
                     f"the shape is valid; there is simply no non-quarantined finished run on that "
                     f"axis. Stating it rather than asserting content.")

    env, payload, is_err, blob = call_tool(base, "get_owl_state", {})
    if check("get_owl_state returns a JSON payload",
             isinstance(payload, dict) and is_err is False,
             f"isError={is_err}, payload={blob[:200]!r}"):
        cov = payload.get("owl_semaphore_v4")
        check("get_owl_state has owl_semaphore_v4 coverage map",
              isinstance(cov, dict), fields_report(payload, ["owl_semaphore_v4", "note"]))
        desc = by_name.get("get_owl_state", {}).get("description", "")
        if isinstance(cov, dict):
            promised = [c for c in ("I", "N", "C", "M") if c in desc]
            absent = [c for c in promised if c not in cov]
            if absent:
                gap("get_owl_state omits advertised coverage classes",
                    f"description promises {promised}; payload has {sorted(cov)} "
                    f"(values: {json.dumps(cov)}). Missing {absent} is rendered as ABSENT, which a "
                    f"client cannot distinguish from 'not measured' — and must not read as 0.")
            else:
                record(PASS, "get_owl_state returns every advertised coverage class",
                       f"promised={promised}, payload={json.dumps(cov)}")

    env, payload, is_err, blob = call_tool(base, "get_carrier_color", {})
    check("get_carrier_color returns a structurally valid payload",
          isinstance(payload, dict) and is_err is False
          and not missing(payload, ["spectrum", "finding", "reference"]),
          f"isError={is_err}, {fields_report(payload or {}, ['spectrum', 'finding', 'reference'])}")
    info("get_carrier_color content deliberately NOT asserted",
         "this test checks transport and shape only; the carrier/variance claims themselves are "
         "under live scientific review and are not this script's to adjudicate.")

    # get_run against a real, already-finished run — no run is started here.
    section("5. get_run against an existing run")
    run_id = None
    try:
        with urllib.request.urlopen(base + "/api/runs?limit=1", timeout=30) as r:
            runs = json.loads(r.read().decode("utf-8")).get("runs") or []
        run_id = runs[0]["id"] if runs else None
    except (urllib.error.URLError, json.JSONDecodeError, KeyError, IndexError) as e:
        info("could not read a run id from /api/runs", str(e))
    if run_id is None:
        check("get_run could be exercised", False,
              "no existing run to poll — get_run NOT validated (this is a failure, not a skip)")
    else:
        env, payload, is_err, blob = call_tool(base, "get_run", {"run_id": run_id})
        keys = ["id", "status", "pass_count", "total_count", "model_key", "axis", "trials"]
        if check(f"get_run(run_id={run_id}) returns the run record",
                 isinstance(payload, dict) and is_err is False and not missing(payload, keys),
                 f"isError={is_err}, {fields_report(payload or {}, keys)}"):
            check("get_run.id echoes the requested run_id",
                  payload.get("id") == run_id,
                  f"requested {run_id}, got {payload.get('id')!r}")
            check("get_run.status is one of the documented states",
                  payload.get("status") in ("queued", "running", "done", "error", "aborted"),
                  f"status={payload.get('status')!r} "
                  f"(documented: queued|running|done|error|aborted)")
            desc = by_name.get("get_run", {}).get("description", "")
            promised = [f for f in ("verdict", "quarantine_reason") if f in desc]
            absent = [f for f in promised if f not in payload]
            if absent:
                gap("get_run omits fields its own description promises",
                    f"description={desc!r}; missing from payload: {absent}; "
                    f"payload keys={sorted(payload)}. A bot polling for 'verdict' or "
                    f"'quarantine_reason' will never find them.")
            else:
                record(PASS, "get_run delivers every field its description promises",
                       f"promised={promised}, all present")
        env, payload, is_err, blob = call_tool(base, "get_run", {"run_id": 2147483600})
        check("get_run(nonexistent id) returns a tool error, not a crash",
              is_err is True, f"isError={is_err}, text={blob[:160]!r}")

    # ── 6. Error paths ────────────────────────────────────────────────────
    section("6. Error paths")
    status, env, raw, req_id = rpc(base, "definitely_not_a_method")
    e = (env or {}).get("error") or {}
    check("unknown method -> JSON-RPC -32601 (method not found)",
          status == 200 and e.get("code") == -32601 and "result" not in (env or {}),
          f"HTTP {status}, error={json.dumps(e) if e else raw[:160]}")
    check("error response echoes the request id",
          (env or {}).get("id") == req_id,
          f"sent id={req_id}, got id={(env or {}).get('id')!r}")

    status, env, raw, _ = rpc(base, "tools/call",
                              {"name": "definitely_not_a_tool", "arguments": {}})
    e = (env or {}).get("error") or {}
    check("unknown tool -> JSON-RPC -32602 (invalid params)",
          status == 200 and e.get("code") == -32602,
          f"HTTP {status}, error={json.dumps(e) if e else raw[:160]}")

    status, env, raw, _ = rpc(base, "tools/call", {})
    e = (env or {}).get("error") or {}
    check("tools/call with no name -> JSON-RPC error, not a bare 200 result",
          status == 200 and e.get("code") == -32602 and "result" not in (env or {}),
          f"HTTP {status}, error={json.dumps(e) if e else raw[:160]}")

    status, text = post_raw(base, b'{"jsonrpc":"2.0","id":99,')
    try:
        env = json.loads(text)
    except json.JSONDecodeError:
        env = None
    if isinstance(env, dict) and (env.get("error") or {}).get("code") == -32700:
        record(PASS, "malformed JSON -> JSON-RPC -32700 (parse error)",
               f"HTTP {status}, body={text[:160]!r}")
    elif status == 200:
        record(FAIL, "malformed JSON -> must not be a bare 200",
               f"HTTP {status}, body={text[:160]!r}")
    else:
        gap("malformed JSON is rejected at the HTTP layer, not as JSON-RPC",
            f"HTTP {status}, body={text[:160]!r}. Server does not crash and does not return a "
            f"bare 200, but the body is plain text from the axum extractor rather than a "
            f"-32700 JSON-RPC error envelope; a strict MCP client cannot parse it as JSON-RPC.")

    status, text = post_raw(base, b'{"id":98}')
    try:
        env = json.loads(text)
    except json.JSONDecodeError:
        env = None
    if isinstance(env, dict) and (env.get("error") or {}).get("code") in (-32600, -32601):
        record(PASS, "missing 'method' -> JSON-RPC invalid-request error",
               f"HTTP {status}, body={text[:160]!r}")
    elif status == 200:
        record(FAIL, "missing 'method' -> must not be a bare 200",
               f"HTTP {status}, body={text[:160]!r}")
    else:
        gap("request with no 'method' is rejected at the HTTP layer, not as JSON-RPC",
            f"HTTP {status}, body={text[:160]!r}. Same class as the malformed-JSON case: "
            f"safe (no crash) but not a -32600 envelope.")

    # ── 7. run_benchmark: contract only, unless --fire-run ───────────────
    section("7. run_benchmark contract (NO GPU run fired by default)")
    rb = by_name.get("run_benchmark")
    if check("run_benchmark is present in the discovered tool set",
             rb is not None, f"present={rb is not None}"):
        schema = rb.get("inputSchema") or {}
        props = schema.get("properties") or {}
        check("run_benchmark requires model_key",
              schema.get("required") == ["model_key"],
              f"required={schema.get('required')!r}")
        want = {"model_key", "axes", "test_ids", "load_preset", "provider"}
        check("run_benchmark input schema exposes the documented arguments",
              want.issubset(set(props)),
              f"properties={sorted(props)}, missing={sorted(want - set(props))}")
        check("run_benchmark rejects unknown arguments (additionalProperties false)",
              schema.get("additionalProperties") is False,
              f"additionalProperties={schema.get('additionalProperties')!r}")
        check("run_benchmark.test_ids is an integer array (test_id is the key)",
              (props.get("test_ids") or {}).get("items", {}).get("type") == "integer",
              f"test_ids={json.dumps(props.get('test_ids'))}")

    # Three refusals, each rejected server-side BEFORE any test_runs row exists.
    env, payload, is_err, blob = call_tool(base, "run_benchmark", {})
    check("run_benchmark{} -> validation error, no run created",
          is_err is True and "model_key" in blob,
          f"isError={is_err}, text={blob[:160]!r}")
    env, payload, is_err, blob = call_tool(
        base, "run_benchmark", {"model_key": "__e2e_nonexistent_model__"})
    check("run_benchmark with no axes/test_ids -> validation error, no run created",
          is_err is True and "at least one axis" in blob,
          f"isError={is_err}, text={blob[:160]!r}")
    env, payload, is_err, blob = call_tool(
        base, "run_benchmark",
        {"model_key": "__e2e_nonexistent_model__", "axes": ["__e2e_not_an_axis__"]})
    check("run_benchmark with an invalid axis -> validation error, no run created",
          is_err is True and "Invalid axis" in blob,
          f"isError={is_err}, text={blob[:160]!r}")

    # abort_run against an id that cannot exist: the handler only signals a
    # cancellation token, so this touches no run and no DB row.
    env, payload, is_err, blob = call_tool(base, "abort_run", {"run_id": 2147483600})
    if check("abort_run(nonexistent id) returns a run_id/aborted record",
             isinstance(payload, dict) and is_err is False
             and not missing(payload, ["run_id", "aborted"]),
             f"isError={is_err}, {fields_report(payload or {}, ['run_id', 'aborted'])}"):
        check("abort_run reports aborted=false when there is nothing to abort",
              payload.get("aborted") is False,
              f"aborted={payload.get('aborted')!r} — a no-op is reported as false, not as success")
    info("abort_run against a LIVE run NOT tested",
         "there is no live run to cancel and this script will not start one. The real "
         "cancellation path (aborted=true, run transitions to 'aborted') is UNTESTED here.")

    if args.fire_run:
        if not (args.model_key and args.axis):
            check("--fire-run supplied a model_key and an axis", False,
                  "--fire-run requires --model-key and --axis; no run started")
        else:
            env, payload, is_err, blob = call_tool(
                base, "run_benchmark",
                {"model_key": args.model_key, "axes": [args.axis]})
            fired = check("run_benchmark started a real run",
                          is_err is False and isinstance(payload, dict),
                          f"isError={is_err}, response={blob[:240]!r}")
            if fired:
                ids = payload.get("run_ids") or ([payload["run_id"]] if "run_id" in payload else [])
                check("run_benchmark returned run id handle(s)",
                      bool(ids), f"payload keys={sorted(payload)}, ids={ids}")
                for rid in ids:
                    _, p, ierr, b = call_tool(base, "get_run", {"run_id": rid})
                    check(f"get_run({rid}) polls the run just started",
                          isinstance(p, dict) and ierr is False,
                          f"isError={ierr}, status={(p or {}).get('status')!r}, "
                          f"pass_count={(p or {}).get('pass_count')!r}")
                info("a GPU run is now live",
                     f"started via --fire-run: model_key={args.model_key!r} axis={args.axis!r}. "
                     f"The queue is NO LONGER idle — abort or let it finish deliberately.")
    else:
        info("run_benchmark execution path NOT tested end to end",
             "contract only: presence, input schema, and the three server-side refusals. No run "
             "was started, so run_benchmark's success path and the queued->running->done "
             "transition remain UNTESTED by this script. Use --fire-run to exercise them.")

    # ── 8. Queue must still be idle ──────────────────────────────────────
    section("8. Queue state AFTER")
    active_after, detail = queue_snapshot(base)
    check("queue readable after test", active_after is not None, detail)
    if not args.fire_run:
        check("queue unchanged by this test (still idle)",
              active_after == active_before == 0,
              f"before={active_before}, after={active_after} | {detail}")

    summarize()


def summarize():
    print("\n" + "=" * 72)
    counts = {}
    for outcome, _, _ in RESULTS:
        counts[outcome] = counts.get(outcome, 0) + 1
    print("SUMMARY: " + ", ".join(
        f"{k.strip()}={v}" for k, v in sorted(counts.items())) + f" ({len(RESULTS)} checks)")
    fails = [r for r in RESULTS if r[0] == FAIL]
    gaps = [r for r in RESULTS if r[0] == GAP]
    if fails:
        print("\nFAILURES:")
        for _, label, detail in fails:
            print(f"  - {label}: {detail}")
    if gaps:
        print("\nDOCUMENTED-VS-ACTUAL GAPS "
              f"({len(gaps)} — tool-description mismatches and/or "
              "JSON-RPC/MCP transport deviations; see each line):")
        for _, label, detail in gaps:
            print(f"  - {label}")
    print("=" * 72)
    sys.exit(1 if fails else (2 if gaps else 0))


if __name__ == "__main__":
    main()
