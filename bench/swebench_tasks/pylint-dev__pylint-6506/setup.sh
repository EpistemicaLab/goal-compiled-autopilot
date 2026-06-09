#!/usr/bin/env bash
# Clone pylint-dev/pylint at 0a4204fd7555cfedd43f43017c94d24ef48244a5 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pylint-dev/pylint.git 2>/dev/null || true
  git fetch --depth=1 origin 0a4204fd7555cfedd43f43017c94d24ef48244a5 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pylint-dev/pylint @ 0a4204fd7555cfedd43f43017c94d24ef48244a5"
