#!/usr/bin/env bash
# Clone pytest-dev/pytest at 56bf819c2f4eaf8b36bd8c42c06bb59d5a3bfc0f into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pytest-dev/pytest.git 2>/dev/null || true
  git fetch --depth=1 origin 56bf819c2f4eaf8b36bd8c42c06bb59d5a3bfc0f 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pytest-dev/pytest @ 56bf819c2f4eaf8b36bd8c42c06bb59d5a3bfc0f"
