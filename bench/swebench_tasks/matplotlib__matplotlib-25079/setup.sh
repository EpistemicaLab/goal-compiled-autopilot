#!/usr/bin/env bash
# Clone matplotlib/matplotlib at 66f7956984cbfc3647e867c6e5fde889a89c64ef into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/matplotlib/matplotlib.git 2>/dev/null || true
  git fetch --depth=1 origin 66f7956984cbfc3647e867c6e5fde889a89c64ef 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: matplotlib/matplotlib @ 66f7956984cbfc3647e867c6e5fde889a89c64ef"
