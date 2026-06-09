#!/usr/bin/env bash
# Clone sympy/sympy at b7c5ba2bf3ffd5cf453b25af7c8ddd9a639800cb into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/sympy/sympy.git 2>/dev/null || true
  git fetch --depth=1 origin b7c5ba2bf3ffd5cf453b25af7c8ddd9a639800cb 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: sympy/sympy @ b7c5ba2bf3ffd5cf453b25af7c8ddd9a639800cb"
