#!/usr/bin/env bash
# Clone pallets/flask at d8c37f43724cd9fb0870f77877b7c4c7e38a19e0 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pallets/flask.git 2>/dev/null || true
  git fetch --depth=1 origin d8c37f43724cd9fb0870f77877b7c4c7e38a19e0 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pallets/flask @ d8c37f43724cd9fb0870f77877b7c4c7e38a19e0"
