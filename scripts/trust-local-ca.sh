#!/usr/bin/env bash
# Trust the Calibration Scope local CA (macOS) — one command, idempotent.
#
# The instrument self-provisions a local certificate authority on first start
# (~/.calibration-scope/ca/ca.cert.pem) and serves HTTPS with a leaf signed by
# it. Trusting the CA once makes https://local.calibrationscope.com:8768 load
# clean in Safari/Chrome/Firefox. Plain http keeps working either way — trust
# is an upgrade, never a prerequisite.
#
# GUI alternative: double-click ca.cert.pem, then in Keychain Access open the
# "Calibration Scope Local CA" certificate and set Trust → Always Trust.
set -euo pipefail
CA="$HOME/.calibration-scope/ca/ca.cert.pem"
if [ ! -f "$CA" ]; then
  echo "CA not found at $CA — start the dashboard once to generate it." >&2
  exit 1
fi
echo "Adding the local CA to your login keychain as a trusted root."
echo "macOS will ask for your login password (this is the one-time trust step)."
security add-trusted-cert -r trustRoot -k "$HOME/Library/Keychains/login.keychain-db" "$CA"
echo "Done — https://local.calibrationscope.com:8768 is now trusted."
