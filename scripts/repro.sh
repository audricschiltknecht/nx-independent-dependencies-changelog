#!/usr/bin/env bash
# Runs in a throwaway clone so this repo is left untouched.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
git clone -q "$SRC" "$WORK/repo"
cd "$WORK/repo"
git config user.name repro && git config user.email repro@example.com
npm install

# Only touches libs/shared, which app depends on. Nothing under apps/ changes.
echo 'module.exports = 2;' > libs/shared/index.js
git commit -qam "fix: handle edge case in shared lib"

npx nx release --skip-publish 2>&1 | grep -E "app (📄|🚫)|^\+ " || true
echo
echo "---- apps/app/CHANGELOG.md"
cat apps/app/CHANGELOG.md
echo
echo "(work dir: $WORK/repo)"
