#!/usr/bin/env bash
# Clone astropy/astropy at d5bd3f68bb6d5ce3a61bdce9883ee750d1afade5 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/astropy/astropy.git 2>/dev/null || true
  git fetch --depth=1 origin d5bd3f68bb6d5ce3a61bdce9883ee750d1afade5 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: astropy/astropy @ d5bd3f68bb6d5ce3a61bdce9883ee750d1afade5"
