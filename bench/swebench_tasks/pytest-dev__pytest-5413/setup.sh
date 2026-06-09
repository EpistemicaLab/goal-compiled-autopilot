#!/usr/bin/env bash
# Clone pytest-dev/pytest at 450d2646233c670654744d3d24330b69895bb9d2 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pytest-dev/pytest.git 2>/dev/null || true
  git fetch --depth=1 origin 450d2646233c670654744d3d24330b69895bb9d2 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pytest-dev/pytest @ 450d2646233c670654744d3d24330b69895bb9d2"
