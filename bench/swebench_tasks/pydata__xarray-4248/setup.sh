#!/usr/bin/env bash
# Clone pydata/xarray at 98dc1f4ea18738492e074e9e51ddfed5cd30ab94 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pydata/xarray.git 2>/dev/null || true
  git fetch --depth=1 origin 98dc1f4ea18738492e074e9e51ddfed5cd30ab94 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pydata/xarray @ 98dc1f4ea18738492e074e9e51ddfed5cd30ab94"
