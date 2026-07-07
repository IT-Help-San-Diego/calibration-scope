use reqwest::Client;
use serde::{Deserialize, Serialize};
use crate::error::AppResult;
use std::time::Instant;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct LsModelInfo {
    pub id: String,
    #[serde(rename = "type")]
    pub model_type: String,
    pub publisher: String,
    pub arch: String,
    pub quantization: String,
    #[serde(rename = "state")]
    pub load_state: String,
    #[serde(rename = "max_context_length")]
    pub context_length: i64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LsModelsResponse {
    pub data: Vec<LsModelInfo>,
}

/// Query LM Studio for all available models (loaded and unloaded).
pub async fn list_ls_models(client: &Client, base_url: &str) -> AppResult<Vec<LsModelInfo>> {
    let resp = client
        .get(format!("{}/api/v0/models", base_url))
        .send()
        .await?
        .error_for_status()?;
    let json: LsModelsResponse = resp.json().await?;
    Ok(json.data)
}

/// Poll LM Studio model list until the target model is confirmed resident in RAM.
/// LM Studio v0 API: state = "loaded" | "not-loaded".
pub async fn wait_for_resident(
    client: &Client,
    base_url: &str,
    model_key: &str,
    max_wait_secs: u64,
) -> AppResult<bool> {
    let start = Instant::now();
    loop {
        let models = list_ls_models(client, base_url).await?;
        for m in &models {
            if m.id == model_key {
                if m.load_state == "loaded" {
                    return Ok(true);
                }
                // Not resident yet — nudge LM Studio's JIT loader (1-token request).
                let _ = trigger_load(client, base_url, model_key).await;
            }
        }
        if start.elapsed().as_secs() >= max_wait_secs {
            return Ok(false);
        }
        tokio::time::sleep(std::time::Duration::from_secs(2)).await;
    }
}

async fn trigger_load(client: &Client, base_url: &str, model_key: &str) -> AppResult<()> {
    let body = serde_json::json!({
        "model": model_key,
        "messages": [{"role": "user", "content": "hi"}],
        "max_tokens": 1
    });
    let _ = client
        .post(format!("{}/api/v0/chat/completions", base_url))
        .json(&body)
        .timeout(std::time::Duration::from_secs(60))
        .send()
        .await;
    // Fire-and-forget: the response body is irrelevant, we only want the load side-effect.
    Ok(())
}

/// Execute a chat completion against a local LM Studio model.
pub async fn chat_local(
    client: &Client,
    base_url: &str,
    model_key: &str,
    messages: &[(&str, &str)],
    max_tokens: u32,
    temperature: f32,
) -> AppResult<(String, u64, LsModelInfo)> {
    // Verify resident first
    let resident = wait_for_resident(client, base_url, model_key, 120).await?;
    if !resident {
        return Err(crate::error::AppError::Executor(format!(
            "Model {} did not become resident within timeout",
            model_key
        )));
    }

    let models = list_ls_models(client, base_url).await?;
    let model_info = models
        .iter()
        .find(|m| m.id == model_key)
        .ok_or_else(|| {
            crate::error::AppError::Executor(format!("Model {} not found in LM Studio", model_key))
        })?
        .clone();

    let body = serde_json::json!({
        "model": model_key,
        "messages": messages.iter().map(|(r,c)| {
            serde_json::json!({"role": r, "content": c})
        }).collect::<Vec<_>>(),
        "max_tokens": max_tokens,
        "temperature": temperature,
    });

    let start = Instant::now();
    let resp = client
        .post(format!("{}/api/v0/chat/completions", base_url))
        .json(&body)
        .timeout(std::time::Duration::from_secs(300))
        .send()
        .await?
        .error_for_status()?;

    let elapsed = start.elapsed().as_millis() as u64;
    let json: serde_json::Value = resp.json().await?;

    let content = json
        .get("choices")
        .and_then(|c| c.as_array())
        .and_then(|a| a.first())
        .and_then(|c| c.get("message"))
        .and_then(|m| m.get("content"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    Ok((content, elapsed, model_info))
}
