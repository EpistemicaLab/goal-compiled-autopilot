#!/usr/bin/env bash
# Clone sympy/sympy at eb926a1d0c1158bf43f01eaf673dc84416b5ebb1 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/sympy/sympy.git 2>/dev/null || true
  git fetch --depth=1 origin eb926a1d0c1158bf43f01eaf673dc84416b5ebb1 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: sympy/sympy @ eb926a1d0c1158bf43f01eaf673dc84416b5ebb1"
