#!/usr/bin/env bash
# Clone sympy/sympy at b17abcb09cbcee80a90f6750e0f9b53f0247656c into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/sympy/sympy.git 2>/dev/null || true
  git fetch --depth=1 origin b17abcb09cbcee80a90f6750e0f9b53f0247656c 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: sympy/sympy @ b17abcb09cbcee80a90f6750e0f9b53f0247656c"
