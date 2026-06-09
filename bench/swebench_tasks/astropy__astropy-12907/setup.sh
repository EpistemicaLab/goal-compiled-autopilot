#!/usr/bin/env bash
# Clone astropy/astropy at d16bfe05a744909de4b27f5875fe0d4ed41ce607 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/astropy/astropy.git 2>/dev/null || true
  git fetch --depth=1 origin d16bfe05a744909de4b27f5875fe0d4ed41ce607 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: astropy/astropy @ d16bfe05a744909de4b27f5875fe0d4ed41ce607"
