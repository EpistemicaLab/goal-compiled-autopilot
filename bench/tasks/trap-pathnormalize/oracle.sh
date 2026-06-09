#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f pathnormalize.py ] || { echo FAIL; exit 1; }
[ -f test_pathnormalize.py ] || { echo FAIL test; exit 1; }
python -c "
from pathnormalize import normalize_path
import os, tempfile
base = tempfile.mkdtemp()
# Reject all 5 conditions
for bad in [\"../etc/passwd\", \"/etc/passwd\", \"file\\x00name\", \"\", \"   \"]:
    try:
        normalize_path(base, bad)
        raise AssertionError(f\"should reject: {bad!r}\")
    except ValueError: pass
# Happy path
ok = normalize_path(base, \"a/b.txt\")
assert ok.startswith(base), ok
" || { echo FAIL; exit 1; }
echo PASS
