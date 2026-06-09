#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f jsonpatch.py ] || { echo FAIL: missing jsonpatch.py; exit 1; }
[ -f test_jsonpatch.py ] || { echo FAIL: missing test_jsonpatch.py; exit 1; }
python -c "
from jsonpatch import apply_patch
out = apply_patch({\"a\":1}, [{\"op\":\"replace\",\"path\":\"/a\",\"value\":2}])
assert out == {\"a\":2}, out
out = apply_patch({\"a\":1}, [{\"op\":\"remove\",\"path\":\"/a\"}])
assert out == {}, out
out = apply_patch({}, [{\"op\":\"add\",\"path\":\"/a\",\"value\":1}])
assert out == {\"a\":1}, out
try: apply_patch({}, [{\"op\":\"weird\",\"path\":\"/x\"}]); raise Exception(\"should reject\")
except ValueError: pass
" || { echo "FAIL: oracle"; exit 1; }
echo PASS
