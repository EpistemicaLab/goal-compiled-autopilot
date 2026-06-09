#!/usr/bin/env bash
# Clone django/django at c86201b6ed4f8256b0a0520c08aa674f623d4127 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/django/django.git 2>/dev/null || true
  git fetch --depth=1 origin c86201b6ed4f8256b0a0520c08aa674f623d4127 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: django/django @ c86201b6ed4f8256b0a0520c08aa674f623d4127"
