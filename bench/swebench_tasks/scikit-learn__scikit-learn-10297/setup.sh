#!/usr/bin/env bash
# Clone scikit-learn/scikit-learn at b90661d6a46aa3619d3eec94d5281f5888add501 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/scikit-learn/scikit-learn.git 2>/dev/null || true
  git fetch --depth=1 origin b90661d6a46aa3619d3eec94d5281f5888add501 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: scikit-learn/scikit-learn @ b90661d6a46aa3619d3eec94d5281f5888add501"
