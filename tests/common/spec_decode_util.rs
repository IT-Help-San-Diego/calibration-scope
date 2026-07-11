pub fn make_temp_pair_dir() -> (tempfile::TempDir,Vec<(&'static str,&'static str)>) {
    let dir = tempfile::tempdir().unwrap();
    let nested = dir.path().join("org").join("model");
    std::fs::create_dir_all(&nested).unwrap();
    let files = vec![
        ("top.json",                      r#"{"load":{"fields":[{"key":"llm.load.llama.speculativeDecoding.draftModel","value":"draft-a"}]}}"#),
        ("nested.json",                   r#"{"load":{"fields":[{"key":"llm.load.llama.speculativeDecoding.draftModel","value":"nested/draft"}]}}"#),
        ("bak.json.bak",                  r#"{"load":{"fields":[{"key":"llm.load.llama.speculativeDecoding.draftModel","value":"ignore-me"}]}}"#),
        ("plain.json",                    r#"{"load":{"fields":[{"key":"other","value":"1"}]}}"#),
    ];
    for (name, body) in &files {
        if name == "nested.json" {
            std::fs::write(nested.join(name), body).unwrap();
        } else {
            std::fs::write(dir.path().join(name), body).unwrap();
        }
    }
    (dir, vec![("top".into(),"draft-a".into()),("nested".into(),"nested/draft".into())])
}
