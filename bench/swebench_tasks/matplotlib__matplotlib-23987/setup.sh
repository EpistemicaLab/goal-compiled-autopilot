#!/usr/bin/env bash
# Clone matplotlib/matplotlib at e98d8d085e8f53ec0467422b326f7738a2dd695e into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/matplotlib/matplotlib.git 2>/dev/null || true
  git fetch --depth=1 origin e98d8d085e8f53ec0467422b326f7738a2dd695e 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: matplotlib/matplotlib @ e98d8d085e8f53ec0467422b326f7738a2dd695e"
