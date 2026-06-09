#!/usr/bin/env bash
# Clone psf/requests at fe693c492242ae532211e0c173324f09ca8cf227 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/psf/requests.git 2>/dev/null || true
  git fetch --depth=1 origin fe693c492242ae532211e0c173324f09ca8cf227 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: psf/requests @ fe693c492242ae532211e0c173324f09ca8cf227"
