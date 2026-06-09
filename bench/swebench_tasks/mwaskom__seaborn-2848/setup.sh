#!/usr/bin/env bash
# Clone mwaskom/seaborn at 94621cef29f80282436d73e8d2c0aa76dab81273 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/mwaskom/seaborn.git 2>/dev/null || true
  git fetch --depth=1 origin 94621cef29f80282436d73e8d2c0aa76dab81273 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: mwaskom/seaborn @ 94621cef29f80282436d73e8d2c0aa76dab81273"
