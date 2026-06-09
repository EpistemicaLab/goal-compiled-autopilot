#!/usr/bin/env bash
# Clone pytest-dev/pytest at 10ca84ffc56c2dd2d9dc4bd71b7b898e083500cd into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pytest-dev/pytest.git 2>/dev/null || true
  git fetch --depth=1 origin 10ca84ffc56c2dd2d9dc4bd71b7b898e083500cd 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pytest-dev/pytest @ 10ca84ffc56c2dd2d9dc4bd71b7b898e083500cd"
