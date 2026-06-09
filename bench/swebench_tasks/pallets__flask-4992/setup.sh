#!/usr/bin/env bash
# Clone pallets/flask at 4c288bc97ea371817199908d0d9b12de9dae327e into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pallets/flask.git 2>/dev/null || true
  git fetch --depth=1 origin 4c288bc97ea371817199908d0d9b12de9dae327e 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pallets/flask @ 4c288bc97ea371817199908d0d9b12de9dae327e"
