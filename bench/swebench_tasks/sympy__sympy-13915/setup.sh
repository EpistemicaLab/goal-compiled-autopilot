#!/usr/bin/env bash
# Clone sympy/sympy at 5c1644ff85e15752f9f8721bc142bfbf975e7805 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/sympy/sympy.git 2>/dev/null || true
  git fetch --depth=1 origin 5c1644ff85e15752f9f8721bc142bfbf975e7805 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: sympy/sympy @ 5c1644ff85e15752f9f8721bc142bfbf975e7805"
