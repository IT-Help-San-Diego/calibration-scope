//! Human-participant CRUD + "take the battery" submission API.
//!
//! Migration 043 built the schema (participants table, test_runs.participant_id,
//! owl_signal_carrier view). This module builds the WRITE half — the read half
//! is signal_carrier.rs (same view, both subjects in one shape).
//!
//! Design: a human calibration session is NOT an executor run. The executor
//! auto-generates trials by calling an LLM; a human answers one question at a
//! time in the browser. So the flow is:
//!
//!   1. POST /api/participants            → create or reuse a participant
//!   2. POST /api/participants/:id/start   → create a test_runs row (participant_id
//!      set, model_id NULL, status='running') seeded with the I+N tests for a
//!      chosen axis/family. Returns the run_id + the list of test prompts.
//!   3. POST /api/participants/:id/answer  → submit one verdict; scored by
//!      scoring::score_response — the executor's own grader, same verdict
//!      extraction and normalization models get; writes a trial_results row.
//!   4. POST /api/participants/:id/finish   → seal the run (status='done',
//!      recompute pass_count/total_count, set sha3_provenance).
//!
//! No LLM is ever called. No model judges the human. The grader is the same
//! deterministic `score_response` function models face — verdict extraction
//! plus normalization against expected_result, identical rubric. (Until
//! 2026-07-27 this doc claimed that while the code ran a stricter plain
//! string compare — a human's "no" failed where a model's "no" passed.
//! Adversarial-verification catch; the parity is now real.)

use axum::extract::{Path, State};
use axum::response::Json;
use serde::{Deserialize, Serialize};

use crate::error::{AppError, AppResult};
use crate::state::AppState;

// ── Participant CRUD ──────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct CreateParticipant {
    pub display_name: String,
    pub notes: Option<String>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct Participant {
    pub id: i32,
    pub kind: String,
    pub display_name: String,
    pub notes: Option<String>,
    pub created_at: chrono::NaiveDateTime,
}

pub async fn create_participant(
    State(state): State<AppState>,
    Json(req): Json<CreateParticipant>,
) -> AppResult<Json<Participant>> {
    let row: Participant = sqlx::query_as(
        r#"INSERT INTO participants (display_name, notes)
           VALUES ($1, $2)
           RETURNING id, kind, display_name, notes, created_at"#,
    )
    .bind(&req.display_name)
    .bind(&req.notes)
    .fetch_one(&state.db)
    .await?;
    Ok(Json(row))
}

pub async fn list_participants(State(state): State<AppState>) -> AppResult<Json<Vec<Participant>>> {
    let rows: Vec<Participant> = sqlx::query_as(
        r#"SELECT id, kind, display_name, notes, created_at
           FROM participants ORDER BY created_at DESC"#,
    )
    .fetch_all(&state.db)
    .await?;
    Ok(Json(rows))
}

// ── Start a human calibration session ─────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct StartSession {
    /// Which axis to calibrate on (reasoning, literary, ...).
    pub axis: Option<String>,
    /// Optional: restrict to one owl family root (e.g. test id=26 for LOGIC-01).
    /// Omit for all I+N tests on the axis.
    pub family_root_id: Option<i32>,
}

#[derive(Debug, Serialize)]
pub struct SessionStart {
    pub run_id: i32,
    pub participant_id: i32,
    pub tests: Vec<SessionTest>,
}

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct SessionTest {
    pub id: i32,
    pub name: String,
    pub prompt_text: String,
    pub axis: String,
    pub owl_type: String,
    pub owl_root_id: Option<i32>,
    pub formal_spec: Option<String>,
}

pub async fn start_session(
    State(state): State<AppState>,
    Path(participant_id): Path<i32>,
    Json(req): Json<StartSession>,
) -> AppResult<Json<SessionStart>> {
    // Validate participant exists
    let exists: bool =
        sqlx::query_scalar("SELECT EXISTS(SELECT 1 FROM participants WHERE id = $1)")
            .bind(participant_id)
            .fetch_one(&state.db)
            .await?;
    if !exists {
        return Err(AppError::Executor(format!(
            "participant {participant_id} not found"
        )));
    }

    // Fetch the I+N tests for the chosen axis/family — same scope as the
    // owl_signal_carrier view (migration 043), so what the human answers
    // is what the view scores.
    let tests: Vec<SessionTest> = sqlx::query_as(
        r#"SELECT id, name, prompt_text, axis, owl_type::text AS owl_type,
                  owl_root_id, formal_spec
           FROM tests
           WHERE active = true
             AND owl_type IN ('I', 'N')
             AND ($1::text IS NULL OR axis = $1)
             AND ($2::int IS NULL
                  OR id = $2
                  OR owl_root_id = $2)
           ORDER BY COALESCE(owl_root_id, id), id"#,
    )
    .bind(&req.axis)
    .bind(req.family_root_id)
    .fetch_all(&state.db)
    .await?;

    if tests.is_empty() {
        return Err(AppError::Executor(
            "no active I+N tests match the given axis/family".into(),
        ));
    }

    // Create the test_runs row. We use axis='reasoning' as a default if the
    // request didn't specify — but store the actual per-test axes on each
    // trial_results row, so the signal_carrier view (which groups by family
    // and axis) works correctly regardless.
    let run_axis = req.axis.unwrap_or("reasoning".into());
    let test_ids: Vec<i32> = tests.iter().map(|t| t.id).collect();

    let run_id: i32 = sqlx::query_scalar(
        r#"INSERT INTO test_runs
             (participant_id, axis, status, started_at, test_ids)
           VALUES ($1, $2, 'running', NOW(), $3)
           RETURNING id"#,
    )
    .bind(participant_id)
    .bind(&run_axis)
    .bind(serde_json::to_value(&test_ids).unwrap_or(serde_json::Value::Null))
    .fetch_one(&state.db)
    .await?;

    Ok(Json(SessionStart {
        run_id,
        participant_id,
        tests,
    }))
}

// ── Run-ownership guard ───────────────────────────────────────────────────

/// What the ownership guard learned about the run — submit_answer also needs
/// the seeded test list, so the guard returns it instead of re-querying.
#[derive(sqlx::FromRow)]
struct RunOwner {
    participant_id: Option<i32>,
    status: String,
    test_ids: Option<serde_json::Value>,
}

/// The run must exist and belong to this participant. With
/// `must_be_running`, it must also not be sealed yet. Errors name the real
/// condition — "not found", "belongs to another subject", "already sealed" —
/// because a wrong 404 here would be the instrument stating a falsehood.
///
/// Scope, stated honestly: this is integrity against mistakes and stray
/// clients, not authentication. The instrument has no auth layer and the
/// participant id is the caller-chosen path segment, so a caller who pairs a
/// run with its real owner id passes — an instrument-wide boundary, not
/// something this guard can close.
async fn verify_run_owner(
    state: &AppState,
    run_id: i32,
    participant_id: i32,
    must_be_running: bool,
) -> AppResult<RunOwner> {
    let run: Option<RunOwner> =
        sqlx::query_as(r#"SELECT participant_id, status, test_ids FROM test_runs WHERE id = $1"#)
            .bind(run_id)
            .fetch_optional(&state.db)
            .await?;
    let Some(run) = run else {
        return Err(AppError::Executor(format!("run {run_id} not found")));
    };
    if run.participant_id != Some(participant_id) {
        return Err(AppError::Executor(format!(
            "run {run_id} does not belong to participant {participant_id}"
        )));
    }
    if must_be_running && run.status != "running" {
        return Err(AppError::Executor(format!(
            "run {run_id} is not accepting answers (status: {})",
            run.status
        )));
    }
    Ok(run)
}

// ── Submit a single answer ────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct SubmitAnswer {
    pub run_id: i32,
    pub test_id: i32,
    pub answer: String,
    /// Client-measured milliseconds from question render to submit — stored
    /// in trial_results.latency_ms, the same column model trials use, with
    /// the same semantic: time to produce the answer. Optional so older
    /// clients keep working; absent falls back to the previous hardcoded 0.
    pub elapsed_ms: Option<i64>,
}

#[derive(Debug, Serialize)]
pub struct AnswerResult {
    pub trial_result_id: i32,
    pub passed: bool,
    pub expected: String,
    /// The test's name — so the UI can show "LOGIC-01N: correct" without
    /// a second round-trip.
    pub test_name: String,
}

pub async fn submit_answer(
    State(state): State<AppState>,
    Path(participant_id): Path<i32>,
    Json(req): Json<SubmitAnswer>,
) -> AppResult<Json<AnswerResult>> {
    // The run must belong to the participant in the path and still be
    // running — a guessed run_id must not write trials into another
    // participant's run or a model run (review catch), and answers must
    // not append after the seal.
    let run = verify_run_owner(&state, req.run_id, participant_id, true).await?;

    // The test must be one the run was seeded with (review catch): without
    // this, a client could answer arbitrary active tests and pad its own
    // run with items the session never posed.
    let seeded = run
        .test_ids
        .as_ref()
        .and_then(|v| v.as_array())
        .map(|a| a.iter().any(|x| x.as_i64() == Some(req.test_id as i64)))
        .unwrap_or(false);
    if !seeded {
        return Err(AppError::Executor(format!(
            "test {} is not part of run {}",
            req.test_id, req.run_id
        )));
    }

    // Fetch the test to get expected_result + scoring_method + name
    #[derive(sqlx::FromRow)]
    struct TestRow {
        name: String,
        expected_result: Option<String>,
        scoring_method: String,
    }
    let test: TestRow = sqlx::query_as(
        r#"SELECT name, expected_result, scoring_method
           FROM tests WHERE id = $1 AND active = true"#,
    )
    .bind(req.test_id)
    .fetch_one(&state.db)
    .await?;

    let expected = test.expected_result.ok_or_else(|| {
        AppError::Executor(format!("test {} has no expected_result", req.test_id))
    })?;

    // One answer per seeded item: if this test already has a trial row, the
    // first answer stands and this call replays its recorded verdict instead
    // of inserting a duplicate. A hard rejection here would strand a client
    // whose insert succeeded but whose response was lost (it can only
    // advance on success) — same lenient-retry design as finish_session,
    // while still blocking trial-padding. Two truly concurrent submits can
    // race past this check; a UNIQUE(run_id, test_id) partial index for
    // participant runs is the airtight fix and belongs to a migration
    // (backend lane — relayed).
    let existing: Option<(i32, bool)> = sqlx::query_as(
        r#"SELECT id, passed FROM trial_results
           WHERE run_id = $1 AND test_id = $2 ORDER BY id LIMIT 1"#,
    )
    .bind(req.run_id)
    .bind(req.test_id)
    .fetch_optional(&state.db)
    .await?;
    if let Some((trial_id, passed)) = existing {
        return Ok(Json(AnswerResult {
            trial_result_id: trial_id,
            passed,
            expected,
            test_name: test.name,
        }));
    }

    // Same grader the executor uses — literally the same function. This
    // module's doc always promised score_response; what shipped was a plain
    // case-insensitive compare, so a human typing "no" against expected
    // "INVALID" failed where a model answering "no" passed (adversarial
    // verification catch, 2026-07-27). Verdict extraction, normalization,
    // and rubric selection are now identical across subject kinds — which
    // is what makes the two comparable at all. An unknown scoring_method is
    // a test-definition error, surfaced honestly instead of guess-graded.
    let passed =
        crate::executor::scoring::score_response(&req.answer, &expected, &test.scoring_method)
            .map_err(AppError::Executor)?
            .passed;

    // Write the trial_result row. trial_num is sequential within the run.
    let next_trial: i32 = sqlx::query_scalar(
        r#"SELECT COALESCE(MAX(trial_num), 0) + 1
           FROM trial_results WHERE run_id = $1"#,
    )
    .bind(req.run_id)
    .fetch_one(&state.db)
    .await?;

    // Clamp to [0, 24h] — a client clock glitch must not write a negative or
    // absurd "latency" into the same column model response times live in.
    let latency_ms = req.elapsed_ms.unwrap_or(0).clamp(0, 86_400_000);
    // Conditional INSERT: the ownership guard's status read is several
    // queries behind by now, and an unconditional insert could land a trial
    // AFTER finish_session sealed the run — leaving trial_results
    // contradicting the sealed counts (adversarial verification catch). The
    // WHERE EXISTS re-checks running-ness in the same statement as the
    // insert; zero rows means the run sealed mid-flight and the answer is
    // honestly reported as not recorded.
    let trial_id: Option<i32> = sqlx::query_scalar(
        r#"INSERT INTO trial_results
             (run_id, trial_num, test_id, raw_response, passed, latency_ms,
              is_infra_error)
           SELECT $1, $2, $3, $4, $5, $6, false
           WHERE EXISTS (SELECT 1 FROM test_runs
                         WHERE id = $1 AND participant_id = $7
                           AND status = 'running')
           RETURNING id"#,
    )
    .bind(req.run_id)
    .bind(next_trial)
    .bind(req.test_id)
    .bind(&req.answer)
    .bind(passed)
    .bind(latency_ms)
    .bind(participant_id)
    .fetch_optional(&state.db)
    .await?;
    let Some(trial_id) = trial_id else {
        return Err(AppError::Executor(format!(
            "run {} was sealed while this answer was in flight — the answer was not recorded",
            req.run_id
        )));
    };

    Ok(Json(AnswerResult {
        trial_result_id: trial_id,
        passed,
        expected,
        test_name: test.name,
    }))
}

// ── Seal the session ──────────────────────────────────────────────────────

#[derive(Debug, Deserialize)]
pub struct FinishSession {
    pub run_id: i32,
}

#[derive(Debug, Serialize)]
pub struct SessionResult {
    pub run_id: i32,
    pub status: String,
    pub pass_count: i32,
    pub total_count: i32,
    pub sha3_provenance: Option<String>,
}

pub async fn finish_session(
    State(state): State<AppState>,
    Path(participant_id): Path<i32>,
    Json(req): Json<FinishSession>,
) -> AppResult<Json<SessionResult>> {
    // Same ownership guard as submit_answer — without it a stray run_id
    // would recompute and RESEAL an arbitrary run, including a model run.
    let run = verify_run_owner(&state, req.run_id, participant_id, false).await?;

    // A retry against an already-sealed run REPLAYS the stored seal instead
    // of recomputing: the first seal stands. Recomputing on every retry
    // rewrote finished_at each time and re-derived the hash from a fresh
    // read (adversarial verification catch) — replay makes the idempotency
    // literal instead of claimed.
    if run.status == "done" {
        #[derive(sqlx::FromRow)]
        struct Sealed {
            pass_count: i32,
            total_count: i32,
            sha3_provenance: Option<String>,
        }
        let sealed: Sealed = sqlx::query_as(
            r#"SELECT pass_count, total_count, sha3_provenance
               FROM test_runs WHERE id = $1"#,
        )
        .bind(req.run_id)
        .fetch_one(&state.db)
        .await?;
        return Ok(Json(SessionResult {
            run_id: req.run_id,
            status: "done".into(),
            pass_count: sealed.pass_count,
            total_count: sealed.total_count,
            sha3_provenance: sealed.sha3_provenance,
        }));
    }

    // Recompute pass_count / total_count from the trial_results.
    #[derive(sqlx::FromRow)]
    struct Counts {
        pass_count: i32,
        total_count: i32,
    }
    let counts: Counts = sqlx::query_as(
        r#"SELECT
              COUNT(*) FILTER (WHERE passed)::int AS pass_count,
              COUNT(*)::int AS total_count
           FROM trial_results
           WHERE run_id = $1 AND is_infra_error = false"#,
    )
    .bind(req.run_id)
    .fetch_one(&state.db)
    .await?;
    let pass_count = counts.pass_count;
    let total_count = counts.total_count;

    // Seal: set status='done', finished_at=NOW, and a SHA-3 provenance hash
    // over the trial verdicts — computed in Rust (same discipline as model
    // runs via provenance::sha3_hex), NOT in SQL (no pgcrypto dependency).
    #[derive(sqlx::FromRow)]
    struct TrialVerdict {
        trial_num: i32,
        test_id: i32,
        passed: bool,
    }
    // ORDER BY trial_num, id — the id tiebreak makes the evidence string
    // deterministic even if a trial_num collision ever lands (there is no
    // unique constraint on (run_id, trial_num); relay (g) covers the index).
    let verdicts: Vec<TrialVerdict> = sqlx::query_as(
        r#"SELECT trial_num, test_id, passed
           FROM trial_results
           WHERE run_id = $1 AND is_infra_error = false
           ORDER BY trial_num, id"#,
    )
    .bind(req.run_id)
    .fetch_all(&state.db)
    .await?;

    let evidence = verdicts
        .iter()
        .map(|v| format!("{}:{}:{}", v.trial_num, v.test_id, v.passed))
        .collect::<Vec<_>>()
        .join("|");
    let sha3 = crate::executor::provenance::sha3_hex(&evidence);

    sqlx::query(
        r#"UPDATE test_runs
           SET status = 'done',
               finished_at = NOW(),
               pass_count = $1,
               total_count = $2,
               sha3_provenance = $3
           WHERE id = $4"#,
    )
    .bind(pass_count)
    .bind(total_count)
    .bind(&sha3)
    .bind(req.run_id)
    .execute(&state.db)
    .await?;

    Ok(Json(SessionResult {
        run_id: req.run_id,
        status: "done".into(),
        pass_count,
        total_count,
        sha3_provenance: Some(sha3),
    }))
}
