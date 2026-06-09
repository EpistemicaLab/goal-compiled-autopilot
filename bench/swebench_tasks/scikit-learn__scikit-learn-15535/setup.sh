#!/usr/bin/env bash
# Clone scikit-learn/scikit-learn at 70b0ddea992c01df1a41588fa9e2d130fb6b13f8 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/scikit-learn/scikit-learn.git 2>/dev/null || true
  git fetch --depth=1 origin 70b0ddea992c01df1a41588fa9e2d130fb6b13f8 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: scikit-learn/scikit-learn @ 70b0ddea992c01df1a41588fa9e2d130fb6b13f8"
