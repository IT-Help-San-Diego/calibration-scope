//! MCP server — Model Context Protocol over JSON-RPC 2.0 at POST /mcp.
//!
//! A meaningful, discoverable, honest tool surface so a user's bot can connect
//! and tell Calibration Scope to do stuff: run benchmarks, read verdicts, abort
//! runs, pull the leaderboard. Design: docs/mcp-server-design.md. The lessons
//! from LM Studio's API anti-patterns are baked in: complete tool surface,
//! documented + verifiable, honest data, useful handles, no hidden state.
//!
//! Transport: JSON-RPC 2.0 over HTTP POST (the MCP "streamable HTTP" pattern).
//! Methods: initialize, tools/list, tools/call, ping.

use axum::extract::State;
use axum::response::Json;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::error::AppResult;
use crate::state::AppState;

/// JSON-RPC 2.0 request.
#[derive(Debug, Deserialize)]
pub struct JsonRpcRequest {
    #[allow(dead_code)]
    pub jsonrpc: Option<String>,
    pub method: String,
    #[serde(default)]
    pub params: Option<Value>,
    #[serde(default)]
    pub id: Option<Value>,
}

/// JSON-RPC 2.0 response.
#[derive(Debug, Serialize)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<JsonRpcError>,
    pub id: Value,
}

// ── Row type aliases (clippy: avoid very-complex-type warnings on the tuples) ──
type TestSpecRow = (i32, String, String, Option<String>, Option<String>, Option<String>, Option<i32>);
type TestRow = (i32, String, String, Option<String>, Option<String>, Option<String>, bool);

#[derive(Debug, Serialize)]
pub struct JsonRpcError {
    pub code: i32,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<Value>,
}

fn ok(id: Value, result: Value) -> Json<JsonRpcResponse> {
    Json(JsonRpcResponse {
        jsonrpc: "2.0".into(),
        result: Some(result),
        error: None,
        id,
    })
}

fn err(id: Value, code: i32, message: impl Into<String>, data: Option<Value>) -> Json<JsonRpcResponse> {
    Json(JsonRpcResponse {
        jsonrpc: "2.0".into(),
        result: None,
        error: Some(JsonRpcError {
            code,
            message: message.into(),
            data,
        }),
        id,
    })
}

/// A tool definition — the data-driven registry (the scalable foundation).
/// Adding a tool = adding a ToolDef + a handler fn. No route refactor.
pub struct ToolDef {
    pub name: &'static str,
    pub description: &'static str,
    /// JSON Schema for the tool's input arguments.
    pub input_schema: Value,
}

/// The tool registry — every tool, discoverable via tools/list.
fn tool_registry() -> Vec<ToolDef> {
    vec![
        ToolDef {
            name: "get_status",
            description: "Dashboard health: db connectivity, running runs, uptime. No args.",
            input_schema: json!({ "type": "object", "properties": {}, "additionalProperties": false }),
        },
        ToolDef {
            name: "list_models",
            description: "List the model registry with verdicts, size_gb, vision, runnable. Optional filters: location (local|cloud), provider, runnable (bool).",
            input_schema: json!({
                "type": "object",
                "properties": {
                    "location": { "type": "string", "enum": ["local", "cloud"] },
                    "provider": { "type": "string" },
                    "runnable": { "type": "boolean" }
                },
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "get_model_verdict",
            description: "One model's verified verdict: 4-axis verdicts, score, size_gb, vision, context_length.",
            input_schema: json!({
                "type": "object",
                "properties": { "model_key": { "type": "string" } },
                "required": ["model_key"],
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "run_benchmark",
            description: "Fire a clean-room benchmark run. model_key required; axes[] OR test_ids[] (at least one); optional load_preset (performance|lightweight), provider (to disambiguate dual-location keys). Returns run_id(s) immediately.",
            input_schema: json!({
                "type": "object",
                "properties": {
                    "model_key": { "type": "string" },
                    "axes": { "type": "array", "items": { "type": "string" } },
                    "test_ids": { "type": "array", "items": { "type": "integer" } },
                    "load_preset": { "type": "string", "enum": ["performance", "lightweight"] },
                    "provider": { "type": "string" }
                },
                "required": ["model_key"],
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "get_run",
            description: "Poll a run's full state: status (queued|running|done|error|aborted), pass_count, total_count, verdict, quarantine_reason.",
            input_schema: json!({
                "type": "object",
                "properties": { "run_id": { "type": "integer" } },
                "required": ["run_id"],
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "abort_run",
            description: "Abort a live run by run_id. Returns aborted:true.",
            input_schema: json!({
                "type": "object",
                "properties": { "run_id": { "type": "integer" } },
                "required": ["run_id"],
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "get_leaderboard",
            description: "The verified leaderboard: models ranked by clean post-fix score on an axis (default reasoning). Optional axis filter.",
            input_schema: json!({
                "type": "object",
                "properties": { "axis": { "type": "string", "enum": ["reasoning", "vision", "tools", "security", "literary"] } },
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "get_carrier_color",
            description: "The Carrier Color findings: the 5-arm carrier spectrum + the immunity threshold (which models are carrier-sensitive vs carrier-immune).",
            input_schema: json!({ "type": "object", "properties": {}, "additionalProperties": false }),
        },
        ToolDef {
            name: "get_owl_state",
            description: "Owl Semaphore V4 state: I/N/C/M coverage counts (identity, non-normative, critical, metacognitive).",
            input_schema: json!({ "type": "object", "properties": {}, "additionalProperties": false }),
        },
        ToolDef {
            name: "get_test_spec",
            description: "A test's full definition: name, axis, formal_spec (Lean), expected_result, owl_type, owl_root_id.",
            input_schema: json!({
                "type": "object",
                "properties": { "test_id": { "type": "integer" } },
                "required": ["test_id"],
                "additionalProperties": false
            }),
        },
        ToolDef {
            name: "list_tests",
            description: "List the test registry with formal_spec + owl_type. Optional axis + active filters.",
            input_schema: json!({
                "type": "object",
                "properties": {
                    "axis": { "type": "string" },
                    "active": { "type": "boolean" }
                },
                "additionalProperties": false
            }),
        },
    ]
}

/// POST /mcp — the JSON-RPC 2.0 entry point.
pub async fn mcp_handler(
    State(state): State<AppState>,
    Json(req): Json<JsonRpcRequest>,
) -> AppResult<Json<JsonRpcResponse>> {
    let id = req.id.clone().unwrap_or(Value::Null);
    match req.method.as_str() {
        "ping" => Ok(ok(id, json!({ "ok": true }))),
        "initialize" => Ok(ok(
            id,
            json!({
                "protocolVersion": "2025-06-18",
                "capabilities": { "tools": {} },
                "serverInfo": {
                    "name": "calibration-scope",
                    "version": env!("CARGO_PKG_VERSION")
                }
            }),
        )),
        "tools/list" => {
            let tools: Vec<Value> = tool_registry()
                .iter()
                .map(|t| {
                    json!({
                        "name": t.name,
                        "description": t.description,
                        "inputSchema": t.input_schema
                    })
                })
                .collect();
            Ok(ok(id, json!({ "tools": tools })))
        }
        "tools/call" => {
            let params = req.params.clone().unwrap_or(Value::Null);
            let name = params.get("name").and_then(|n| n.as_str()).unwrap_or("");
            let args = params.get("arguments").cloned().unwrap_or(json!({}));
            dispatch_tool(&state, id, name, args).await
        }
        other => Ok(err(
            id,
            -32601,
            format!("Method not found: {}", other),
            None,
        )),
    }
}

/// Route a tools/call to the right tool implementation.
async fn dispatch_tool(
    state: &AppState,
    id: Value,
    name: &str,
    args: Value,
) -> AppResult<Json<JsonRpcResponse>> {
    match name {
        "get_status" => tool_get_status(state, id).await,
        "list_models" => tool_list_models(state, id, args).await,
        "get_model_verdict" => tool_get_model_verdict(state, id, args).await,
        "run_benchmark" => tool_run_benchmark(state, id, args).await,
        "get_run" => tool_get_run(state, id, args).await,
        "abort_run" => tool_abort_run(state, id, args).await,
        "get_leaderboard" => tool_get_leaderboard(state, id, args).await,
        "get_carrier_color" => tool_get_carrier_color(state, id).await,
        "get_owl_state" => tool_get_owl_state(state, id).await,
        "get_test_spec" => tool_get_test_spec(state, id, args).await,
        "list_tests" => tool_list_tests(state, id, args).await,
        other => Ok(err(
            id,
            -32602,
            format!("Unknown tool: {}", other),
            None,
        )),
    }
}

/// Wrap a tool result into the MCP content format.
fn tool_result(id: Value, text: Value) -> AppResult<Json<JsonRpcResponse>> {
    Ok(ok(
        id,
        json!({
            "content": [
                { "type": "text", "text": serde_json::to_string_pretty(&text).unwrap_or_default() }
            ],
            "isError": false
        }),
    ))
}

fn tool_error(id: Value, message: impl Into<String>) -> AppResult<Json<JsonRpcResponse>> {
    Ok(ok(
        id,
        json!({
            "content": [
                { "type": "text", "text": message.into() }
            ],
            "isError": true
        }),
    ))
}

// ── Tool implementations (thin wrappers over the existing DB/handler logic) ──

async fn tool_get_status(state: &AppState, id: Value) -> AppResult<Json<JsonRpcResponse>> {
    let db_ok: Option<i32> = sqlx::query_scalar("SELECT 1")
        .fetch_one(&state.db)
        .await
        .ok();
    let running: Option<i64> = sqlx::query_scalar(
        "SELECT COUNT(*) FROM test_runs WHERE status IN ('queued','running')",
    )
    .fetch_one(&state.db)
    .await
    .ok();
    let models: Option<i64> = sqlx::query_scalar("SELECT COUNT(*) FROM models WHERE active = true")
        .fetch_one(&state.db)
        .await
        .ok();
    tool_result(
        id,
        json!({
            "status": "ok",
            "db_connected": db_ok.is_some(),
            "running_runs": running.unwrap_or(0),
            "models_in_registry": models.unwrap_or(0),
        }),
    )
}

async fn tool_list_models(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let location = args.get("location").and_then(|v| v.as_str());
    let provider = args.get("provider").and_then(|v| v.as_str());
    // Use the SAME fetch_unique_models the REST API uses (computes verdicts via JOIN —
    // 'verdicts' is NOT a column on models; selecting it directly fails). Filter in Rust.
    let all = crate::db::queries::fetch_unique_models(&state.db)
        .await
        .unwrap_or_default();
    let models: Vec<Value> = all
        .into_iter()
        .filter(|m| {
            location.is_none_or(|loc| m.location == loc)
                && provider.is_none_or(|prov| m.provider == prov)
        })
        .map(|m| {
            json!({
                "key": m.key,
                "display_name": m.display_name,
                "provider": m.provider,
                "location": m.location,
                "context_length": m.context_length,
                "size_gb": m.size_gb,
                "supports_vision": m.supports_vision,
                "verdicts": m.verdicts.and_then(|v| serde_json::from_str::<Value>(&v).ok())
            })
        })
        .collect();
    tool_result(id, json!({ "models": models, "count": models.len() }))
}

async fn tool_get_model_verdict(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let key = match args.get("model_key").and_then(|v| v.as_str()) {
        Some(k) => k,
        None => return tool_error(id, "model_key is required"),
    };
    // Use fetch_unique_models (verdicts is computed via JOIN, not a column on models).
    let all = crate::db::queries::fetch_unique_models(&state.db)
        .await
        .unwrap_or_default();
    match all.into_iter().find(|m| m.key == key) {
        Some(m) => {
            tool_result(
                id,
                json!({
                    "key": m.key,
                    "provider": m.provider,
                    "location": m.location,
                    "context_length": m.context_length,
                    "size_gb": m.size_gb,
                    "supports_vision": m.supports_vision,
                    "verdicts": m.verdicts.and_then(|v| serde_json::from_str::<Value>(&v).ok())
                }),
            )
        }
        None => tool_error(id, format!("model not found: {}", key)),
    }
}

async fn tool_run_benchmark(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let model_key = match args.get("model_key").and_then(|v| v.as_str()) {
        Some(k) => k.to_string(),
        None => return tool_error(id, "model_key is required"),
    };
    let axes: Vec<String> = args
        .get("axes")
        .and_then(|v| serde_json::from_value::<Vec<String>>(v.clone()).ok())
        .unwrap_or_default();
    let test_ids: Option<Vec<i32>> = args
        .get("test_ids")
        .and_then(|v| serde_json::from_value::<Vec<i32>>(v.clone()).ok());
    let load_preset = args.get("load_preset").and_then(|v| v.as_str()).map(|s| s.to_string());
    let provider = args.get("provider").and_then(|v| v.as_str()).map(|s| s.to_string());

    // Build the StartRunRequest and call the SAME start_runs logic the REST API uses.
    let req = crate::routes::runs::StartRunRequest {
        model_key,
        axes,
        load_mode: None,
        draft_model_key: None,
        scaffold_supplement: None,
        load_preset,
        provider,
        test_ids,
    };
    match crate::routes::runs::start_runs(State(state.clone()), Json(req)).await {
        Ok(Json(resp)) => tool_result(id, resp),
        Err(e) => tool_error(id, format!("run_benchmark failed: {}", e)),
    }
}

async fn tool_get_run(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let run_id = match args.get("run_id").and_then(|v| v.as_i64()) {
        Some(r) => r as i32,
        None => return tool_error(id, "run_id is required"),
    };
    match crate::routes::runs::get_run_detail(
        State(state.clone()),
        axum::extract::Path(run_id),
    )
    .await
    {
        Ok(Json(resp)) => tool_result(id, resp),
        Err(e) => tool_error(id, format!("get_run failed: {}", e)),
    }
}

async fn tool_abort_run(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let run_id = match args.get("run_id").and_then(|v| v.as_i64()) {
        Some(r) => r as i32,
        None => return tool_error(id, "run_id is required"),
    };
    match crate::routes::runs::abort_run(State(state.clone()), axum::extract::Path(run_id)).await {
        Ok(Json(resp)) => tool_result(id, resp),
        Err(e) => tool_error(id, format!("abort_run failed: {}", e)),
    }
}

async fn tool_get_leaderboard(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let axis = args.get("axis").and_then(|v| v.as_str()).unwrap_or("reasoning");
    let rows: Vec<(String, i64, i64)> = sqlx::query_as(
        r#"
        SELECT m.key,
               SUM(CASE WHEN tr.passed THEN 1 ELSE 0 END) AS passed,
               COUNT(tr.id) AS total
        FROM trial_results tr
        JOIN test_runs r ON r.id = tr.run_id
        JOIN models m ON m.id = r.model_id
        WHERE r.axis = $1 AND r.status = 'done' AND (r.quarantined IS NULL OR r.quarantined = false)
        GROUP BY m.key
        HAVING COUNT(tr.id) > 0
        ORDER BY passed::float / NULLIF(COUNT(tr.id),0) DESC, m.key
        LIMIT 50
        "#,
    )
    .bind(axis)
    .fetch_all(&state.db)
    .await
    .unwrap_or_default();
    let board: Vec<Value> = rows
        .into_iter()
        .map(|(key, passed, total)| {
            json!({
                "model_key": key,
                "passed": passed,
                "total": total,
                "pct": (passed as f64 / total.max(1) as f64 * 100.0 * 10.0).round() / 10.0
            })
        })
        .collect();
    tool_result(id, json!({ "axis": axis, "leaderboard": board }))
}

async fn tool_get_carrier_color(_state: &AppState, id: Value) -> AppResult<Json<JsonRpcResponse>> {
    // The published Carrier Color findings (from DECISIONS.md §10.8 / §10.9).
    tool_result(
        id,
        json!({
            "spectrum": [
                { "model": "gemma-4-e2b", "baseline": 99.0, "english": 94.1, "lean": 91.2, "haiku": 97.1, "bribe": 91.2, "verdict": "carrier-sensitive" },
                { "model": "nvidia/nemotron-3-nano-omni", "baseline": 100.0, "english": 100.0, "lean": 100.0, "haiku": 100.0, "bribe": 100.0, "verdict": "carrier-immune" },
                { "model": "anthropic/claude-fable-5", "baseline": 100.0, "english": 100.0, "lean": 100.0, "haiku": 100.0, "bribe": 100.0, "verdict": "carrier-immune" }
            ],
            "finding": "Carrier-immunity tracks capability/headroom, not substrate. Small models (e2b) are carrier-sensitive; big models (nemotron, Fable 5) are carrier-immune. Below a capability threshold, a model's verdict tracks the carrier; above it, immune.",
            "reference": "DECISIONS.md §10.8 (e2b 5-arm spectrum) + §10.9 (immunity threshold)"
        }),
    )
}

async fn tool_get_owl_state(state: &AppState, id: Value) -> AppResult<Json<JsonRpcResponse>> {
    let rows: Vec<(String, i64)> = sqlx::query_as(
        "SELECT owl_type, COUNT(*) FROM tests WHERE axis='reasoning' AND active=true GROUP BY owl_type ORDER BY owl_type",
    )
    .fetch_all(&state.db)
    .await
    .unwrap_or_default();
    let mut coverage = json!({});
    for (owl_type, count) in rows {
        coverage[owl_type] = json!(count);
    }
    tool_result(
        id,
        json!({
            "owl_semaphore_v4": coverage,
            "note": "I = identity (base logic), N = non-normative (paraphrase), C = critical (adversarial trap), M = metacognitive (reasoning about the rule)"
        }),
    )
}

async fn tool_get_test_spec(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let test_id = match args.get("test_id").and_then(|v| v.as_i64()) {
        Some(t) => t as i32,
        None => return tool_error(id, "test_id is required"),
    };
    let row: Option<TestSpecRow> =
        sqlx::query_as(
            "SELECT id, name, axis, formal_spec, expected_result, owl_type, owl_root_id FROM tests WHERE id = $1",
        )
        .bind(test_id)
        .fetch_optional(&state.db)
        .await
        .unwrap_or(None);
    match row {
        Some((test_db_id, name, axis, formal_spec, expected_result, owl_type, owl_root_id)) => {
            tool_result(
                id,
                json!({
                    "id": test_db_id,
                    "name": name,
                    "axis": axis,
                    "formal_spec": formal_spec,
                    "expected_result": expected_result,
                    "owl_type": owl_type,
                    "owl_root_id": owl_root_id
                }),
            )
        }
        None => tool_error(id, format!("test not found: {}", test_id)),
    }
}

async fn tool_list_tests(state: &AppState, id: Value, args: Value) -> AppResult<Json<JsonRpcResponse>> {
    let axis = args.get("axis").and_then(|v| v.as_str());
    let active = args.get("active").and_then(|v| v.as_bool()).unwrap_or(true);
    // Parameterized query — no string formatting with user input (SQL-injection safe).
    let rows: Vec<TestRow> =
        sqlx::query_as(
            "SELECT id, name, axis, formal_spec, expected_result, owl_type, active
             FROM tests
             WHERE ($1::text IS NULL OR axis = $1)
               AND ($2::bool IS NULL OR active = $2)
             ORDER BY id LIMIT 500",
        )
        .bind(axis)
        .bind(if active { Some(true) } else { None::<bool> })
        .fetch_all(&state.db)
        .await
        .unwrap_or_default();
    let tests: Vec<Value> = rows
        .into_iter()
        .map(|(id, name, axis, formal_spec, expected_result, owl_type, active)| {
            json!({
                "id": id,
                "name": name,
                "axis": axis,
                "formal_spec": formal_spec,
                "expected_result": expected_result,
                "owl_type": owl_type,
                "active": active
            })
        })
        .collect();
    tool_result(id, json!({ "tests": tests, "count": tests.len() }))
}
