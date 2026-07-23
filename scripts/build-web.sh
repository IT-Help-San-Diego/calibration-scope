#!/usr/bin/env bash
# Build the dashboard's served assets from source — THE one way to minify.
#
# app.js / app.css are the SOURCE OF TRUTH; app.min.js / app.min.css are build
# artifacts. This exists because the two forked once (commit 20e2a7e edited
# app.min.js directly; the ⚡ picker fix lived only in app.js) and the drift
# was invisible until a foundations audit caught it. CI now rebuilds and fails
# if the committed min files don't match the source — so hand-editing a .min
# file can never ship silently again.
#
# esbuild is PINNED to 0.28.1: CI rebuilds and byte-compares the committed min
# files, so the version must be identical everywhere or equality breaks.
#
# No identifier mangling: inline onclick= handlers in dashboard.html need the
# global function names intact.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
node --check "$REPO/assets/app.js"
npx --yes esbuild@0.28.1 "$REPO/assets/app.js"  --minify-whitespace --minify-syntax --charset=utf8 --outfile="$REPO/assets/app.min.js"  --allow-overwrite
npx --yes esbuild@0.28.1 "$REPO/assets/app.css" --minify --charset=utf8 --outfile="$REPO/assets/app.min.css" --allow-overwrite
echo "built: app.min.js ($(wc -c < "$REPO/assets/app.min.js" | tr -d ' ') bytes), app.min.css ($(wc -c < "$REPO/assets/app.min.css" | tr -d ' ') bytes)"
