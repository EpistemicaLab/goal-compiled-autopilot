#!/usr/bin/env bash
# Clone pylint-dev/pylint at d597f252915ddcaaa15ccdfcb35670152cb83587 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pylint-dev/pylint.git 2>/dev/null || true
  git fetch --depth=1 origin d597f252915ddcaaa15ccdfcb35670152cb83587 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pylint-dev/pylint @ d597f252915ddcaaa15ccdfcb35670152cb83587"
