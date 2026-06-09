#!/usr/bin/env bash
# Clone pydata/xarray at e56905889c836c736152b11a7e6117a229715975 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pydata/xarray.git 2>/dev/null || true
  git fetch --depth=1 origin e56905889c836c736152b11a7e6117a229715975 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pydata/xarray @ e56905889c836c736152b11a7e6117a229715975"
