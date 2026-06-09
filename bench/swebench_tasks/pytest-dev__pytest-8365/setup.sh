#!/usr/bin/env bash
# Clone pytest-dev/pytest at 4964b468c83c06971eb743fbc57cc404f760c573 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/pytest-dev/pytest.git 2>/dev/null || true
  git fetch --depth=1 origin 4964b468c83c06971eb743fbc57cc404f760c573 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: pytest-dev/pytest @ 4964b468c83c06971eb743fbc57cc404f760c573"
