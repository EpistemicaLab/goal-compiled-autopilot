#!/usr/bin/env bash
# Clone astropy/astropy at a5917978be39d13cd90b517e1de4e7a539ffaa48 into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/astropy/astropy.git 2>/dev/null || true
  git fetch --depth=1 origin a5917978be39d13cd90b517e1de4e7a539ffaa48 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: astropy/astropy @ a5917978be39d13cd90b517e1de4e7a539ffaa48"
