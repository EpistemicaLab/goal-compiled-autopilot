#!/usr/bin/env bash
# Clone astropy/astropy at 7269fa3e33e8d02485a647da91a5a2a60a06af61 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/astropy/astropy.git 2>/dev/null || true
  git fetch --depth=1 origin 7269fa3e33e8d02485a647da91a5a2a60a06af61 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: astropy/astropy @ 7269fa3e33e8d02485a647da91a5a2a60a06af61"
