#!/usr/bin/env bash
# Clone scikit-learn/scikit-learn at a5743ed36fbd3fbc8e351bdab16561fbfca7dfa1 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/scikit-learn/scikit-learn.git 2>/dev/null || true
  git fetch --depth=1 origin a5743ed36fbd3fbc8e351bdab16561fbfca7dfa1 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: scikit-learn/scikit-learn @ a5743ed36fbd3fbc8e351bdab16561fbfca7dfa1"
