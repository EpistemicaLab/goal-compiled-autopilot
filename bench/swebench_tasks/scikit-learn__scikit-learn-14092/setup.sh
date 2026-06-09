#!/usr/bin/env bash
# Clone scikit-learn/scikit-learn at df7dd8391148a873d157328a4f0328528a0c4ed9 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/scikit-learn/scikit-learn.git 2>/dev/null || true
  git fetch --depth=1 origin df7dd8391148a873d157328a4f0328528a0c4ed9 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: scikit-learn/scikit-learn @ df7dd8391148a873d157328a4f0328528a0c4ed9"
