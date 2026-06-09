#!/usr/bin/env bash
# Clone mwaskom/seaborn at 4a9e54962a29c12a8b103d75f838e0e795a6974d into work/
set -uo pipefail
WORKDIR="${1:?work dir required}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ".git" ]; then
  git init -q
  git remote add origin https://github.com/mwaskom/seaborn.git 2>/dev/null || true
  git fetch --depth=1 origin 4a9e54962a29c12a8b103d75f838e0e795a6974d 2>&1 | tail -2
  git checkout -q FETCH_HEAD
fi
echo "ready: mwaskom/seaborn @ 4a9e54962a29c12a8b103d75f838e0e795a6974d"
