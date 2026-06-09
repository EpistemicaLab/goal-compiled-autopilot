#!/usr/bin/env bash
# Clone psf/requests at 0be38a0c37c59c4b66ce908731da15b401655113 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/psf/requests.git 2>/dev/null || true
  git fetch --depth=1 origin 0be38a0c37c59c4b66ce908731da15b401655113 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: psf/requests @ 0be38a0c37c59c4b66ce908731da15b401655113"
