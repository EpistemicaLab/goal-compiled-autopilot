#!/usr/bin/env bash
# Clone matplotlib/matplotlib at 430fb1db88843300fb4baae3edc499bbfe073b0c into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/matplotlib/matplotlib.git 2>/dev/null || true
  git fetch --depth=1 origin 430fb1db88843300fb4baae3edc499bbfe073b0c 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: matplotlib/matplotlib @ 430fb1db88843300fb4baae3edc499bbfe073b0c"
