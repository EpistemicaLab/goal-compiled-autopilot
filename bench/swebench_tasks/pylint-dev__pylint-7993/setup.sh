#!/usr/bin/env bash
# Clone pylint-dev/pylint at e90702074e68e20dc8e5df5013ee3ecf22139c3e into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pylint-dev/pylint.git 2>/dev/null || true
  git fetch --depth=1 origin e90702074e68e20dc8e5df5013ee3ecf22139c3e 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pylint-dev/pylint @ e90702074e68e20dc8e5df5013ee3ecf22139c3e"
