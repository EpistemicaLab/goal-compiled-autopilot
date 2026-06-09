#!/usr/bin/env bash
# Clone matplotlib/matplotlib at 3eadeacc06c9f2ddcdac6ae39819faa9fbee9e39 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/matplotlib/matplotlib.git 2>/dev/null || true
  git fetch --depth=1 origin 3eadeacc06c9f2ddcdac6ae39819faa9fbee9e39 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: matplotlib/matplotlib @ 3eadeacc06c9f2ddcdac6ae39819faa9fbee9e39"
