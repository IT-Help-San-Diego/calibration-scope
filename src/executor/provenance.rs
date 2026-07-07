use sha3::{Digest, Sha3_512};

pub fn sha3_hex(data: &str) -> String {
    let mut hasher = Sha3_512::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();
    format!("sha3-512:{}", hex::encode(result))
}

pub fn sha3_bytes(data: &[u8]) -> String {
    let mut hasher = Sha3_512::new();
    hasher.update(data);
    let result = hasher.finalize();
    format!("sha3-512:{}", hex::encode(result))
}
