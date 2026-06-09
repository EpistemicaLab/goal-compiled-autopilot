#!/usr/bin/env bash
# Clone django/django at a59de6e89e8dc1f3e71c9a5a5bbceb373ea5247e into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/django/django.git 2>/dev/null || true
  git fetch --depth=1 origin a59de6e89e8dc1f3e71c9a5a5bbceb373ea5247e 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: django/django @ a59de6e89e8dc1f3e71c9a5a5bbceb373ea5247e"
