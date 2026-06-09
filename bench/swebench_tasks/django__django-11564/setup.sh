#!/usr/bin/env bash
# Clone django/django at 580e644f24f1c5ae5b94784fb73a9953a178fd26 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/django/django.git 2>/dev/null || true
  git fetch --depth=1 origin 580e644f24f1c5ae5b94784fb73a9953a178fd26 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: django/django @ 580e644f24f1c5ae5b94784fb73a9953a178fd26"
