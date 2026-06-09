#!/usr/bin/env bash
# Clone mwaskom/seaborn at 0f5a013e2cf43562deec3b879458e59a73853813 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/mwaskom/seaborn.git 2>/dev/null || true
  git fetch --depth=1 origin 0f5a013e2cf43562deec3b879458e59a73853813 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: mwaskom/seaborn @ 0f5a013e2cf43562deec3b879458e59a73853813"
