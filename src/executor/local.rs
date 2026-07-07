// Placeholder: LM Studio clean-room executor
// eject-all → load target → verify resident → execute N trials → score → SHA-3
use crate::executor::lmstudio;

pub async fn execute_local_test(
    model_key: &str,
    test: &crate::models::tests::TestDef,
    n_trials: u32,
) -> crate::error::AppResult<crate::executor::provenance::RunEvidence> {
    // TODO: implement eject/load/verify/trial/score pipeline
    todo!("Local executor — implement after cloud path is green")
}
