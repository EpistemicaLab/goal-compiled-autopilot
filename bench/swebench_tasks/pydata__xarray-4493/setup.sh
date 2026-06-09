#!/usr/bin/env bash
# Clone pydata/xarray at a5f53e203c52a7605d5db799864046471115d04f into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pydata/xarray.git 2>/dev/null || true
  git fetch --depth=1 origin a5f53e203c52a7605d5db799864046471115d04f 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pydata/xarray @ a5f53e203c52a7605d5db799864046471115d04f"
