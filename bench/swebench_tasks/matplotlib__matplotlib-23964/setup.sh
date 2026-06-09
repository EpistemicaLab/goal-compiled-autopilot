#!/usr/bin/env bash
# Clone matplotlib/matplotlib at 269c0b94b4fcf8b1135011c1556eac29dc09de15 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/matplotlib/matplotlib.git 2>/dev/null || true
  git fetch --depth=1 origin 269c0b94b4fcf8b1135011c1556eac29dc09de15 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: matplotlib/matplotlib @ 269c0b94b4fcf8b1135011c1556eac29dc09de15"
