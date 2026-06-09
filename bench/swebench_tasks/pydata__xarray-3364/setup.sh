#!/usr/bin/env bash
# Clone pydata/xarray at 863e49066ca4d61c9adfe62aca3bf21b90e1af8c into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pydata/xarray.git 2>/dev/null || true
  git fetch --depth=1 origin 863e49066ca4d61c9adfe62aca3bf21b90e1af8c 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pydata/xarray @ 863e49066ca4d61c9adfe62aca3bf21b90e1af8c"
