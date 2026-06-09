#!/usr/bin/env bash
# Clone mwaskom/seaborn at 515286e02be3e4c0ff2ef4addb34a53c4a676ee4 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/mwaskom/seaborn.git 2>/dev/null || true
  git fetch --depth=1 origin 515286e02be3e4c0ff2ef4addb34a53c4a676ee4 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: mwaskom/seaborn @ 515286e02be3e4c0ff2ef4addb34a53c4a676ee4"
