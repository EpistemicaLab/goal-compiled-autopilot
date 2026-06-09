#!/usr/bin/env bash
# Clone pylint-dev/pylint at 3c5eca2ded3dd2b59ebaf23eb289453b5d2930f0 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pylint-dev/pylint.git 2>/dev/null || true
  git fetch --depth=1 origin 3c5eca2ded3dd2b59ebaf23eb289453b5d2930f0 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pylint-dev/pylint @ 3c5eca2ded3dd2b59ebaf23eb289453b5d2930f0"
