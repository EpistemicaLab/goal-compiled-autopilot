#!/usr/bin/env bash
# Clone pytest-dev/pytest at 4a2fdce62b73944030cff9b3e52862868ca9584d into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pytest-dev/pytest.git 2>/dev/null || true
  git fetch --depth=1 origin 4a2fdce62b73944030cff9b3e52862868ca9584d 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pytest-dev/pytest @ 4a2fdce62b73944030cff9b3e52862868ca9584d"
