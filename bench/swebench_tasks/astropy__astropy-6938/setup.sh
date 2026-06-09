#!/usr/bin/env bash
# Clone astropy/astropy at c76af9ed6bb89bfba45b9f5bc1e635188278e2fa into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/astropy/astropy.git 2>/dev/null || true
  git fetch --depth=1 origin c76af9ed6bb89bfba45b9f5bc1e635188278e2fa 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: astropy/astropy @ c76af9ed6bb89bfba45b9f5bc1e635188278e2fa"
