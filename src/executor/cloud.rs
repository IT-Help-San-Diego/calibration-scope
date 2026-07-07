use reqwest::Client;
use crate::error::AppResult;
use std::time::Duration;

pub async fn fire_cloud_request(
    client: &Client,
    provider: &str,
    api_key: &str,
    model: &str,
    messages: &[(&str, &str)],
) -> AppResult<(String, u64)> {
    let (endpoint, headers, body) = match provider {
        "openrouter" => {
            let mut h = std::collections::HashMap::new();
            h.insert("Authorization", format!("Bearer {}", api_key));
            h.insert("Content-Type", "application/json".to_string());
            let body = serde_json::json!({
                "model": model,
                "messages": messages.iter().map(|(r,c)| serde_json::json!({"role": r, "content": c})).collect::<Vec<_>>(),
                "max_tokens": 4096
            });
            ("https://openrouter.ai/api/v1/chat/completions", h, body)
        }
        "nous" => {
            let mut h = std::collections::HashMap::new();
            h.insert("Authorization", format!("Bearer {}", api_key));
            h.insert("Content-Type", "application/json".to_string());
            let body = serde_json::json!({
                "model": model,
                "messages": messages.iter().map(|(r,c)| serde_json::json!({"role": r, "content": c})).collect::<Vec<_>>(),
                "max_tokens": 4096
            });
            ("https://api.nousresearch.com/v1/chat/completions", h, body)
        }
        _ => return Err(crate::error::AppError::Executor(format!("Unknown provider: {}", provider))),
    };

    let start = std::time::Instant::now();
    let mut req = client.post(endpoint).json(&body).timeout(Duration::from_secs(120));

    for (k, v) in headers {
        req = req.header(k, v);
    }

    let resp = req.send().await?;
    let elapsed = start.elapsed().as_millis() as u64;
    let resp_json: serde_json::Value = resp.json().await?;

    let content = resp_json
        .get("choices")
        .and_then(|c| c.as_array())
        .and_then(|a| a.first())
        .and_then(|c| c.get("message"))
        .and_then(|m| m.get("content"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    Ok((content, elapsed))
}
