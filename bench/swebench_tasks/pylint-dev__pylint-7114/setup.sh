#!/usr/bin/env bash
# Clone pylint-dev/pylint at 397c1703e8ae6349d33f7b99f45b2ccaf581e666 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pylint-dev/pylint.git 2>/dev/null || true
  git fetch --depth=1 origin 397c1703e8ae6349d33f7b99f45b2ccaf581e666 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pylint-dev/pylint @ 397c1703e8ae6349d33f7b99f45b2ccaf581e666"
