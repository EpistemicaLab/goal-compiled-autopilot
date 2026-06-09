#!/usr/bin/env bash
# Clone scikit-learn/scikit-learn at fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/scikit-learn/scikit-learn.git 2>/dev/null || true
  git fetch --depth=1 origin fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: scikit-learn/scikit-learn @ fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6"
