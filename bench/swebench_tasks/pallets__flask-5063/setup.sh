#!/usr/bin/env bash
# Clone pallets/flask at 182ce3dd15dfa3537391c3efaf9c3ff407d134d4 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pallets/flask.git 2>/dev/null || true
  git fetch --depth=1 origin 182ce3dd15dfa3537391c3efaf9c3ff407d134d4 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pallets/flask @ 182ce3dd15dfa3537391c3efaf9c3ff407d134d4"
