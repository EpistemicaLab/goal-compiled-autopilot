#!/usr/bin/env bash
# Clone psf/requests at 091991be0da19de9108dbe5e3752917fea3d7fdc into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/psf/requests.git 2>/dev/null || true
  git fetch --depth=1 origin 091991be0da19de9108dbe5e3752917fea3d7fdc 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: psf/requests @ 091991be0da19de9108dbe5e3752917fea3d7fdc"
