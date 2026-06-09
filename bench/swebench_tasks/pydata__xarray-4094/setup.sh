#!/usr/bin/env bash
# Clone pydata/xarray at a64cf2d5476e7bbda099b34c40b7be1880dbd39a into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pydata/xarray.git 2>/dev/null || true
  git fetch --depth=1 origin a64cf2d5476e7bbda099b34c40b7be1880dbd39a 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pydata/xarray @ a64cf2d5476e7bbda099b34c40b7be1880dbd39a"
