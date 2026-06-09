#!/usr/bin/env bash
# Clone sympy/sympy at d57aaf064041fe52c0fa357639b069100f8b28e1 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/sympy/sympy.git 2>/dev/null || true
  git fetch --depth=1 origin d57aaf064041fe52c0fa357639b069100f8b28e1 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: sympy/sympy @ d57aaf064041fe52c0fa357639b069100f8b28e1"
