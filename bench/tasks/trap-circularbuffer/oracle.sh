#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f circularbuffer.py ] || { echo FAIL: missing impl; exit 1; }
[ -f test_circularbuffer.py ] || { echo FAIL: missing test; exit 1; }
python -c "
from circularbuffer import CircularBuffer
cb = CircularBuffer(3)
for i in [1,2,3,4,5]: cb.push(i)
assert list(cb) == [3,4,5], list(cb)
assert len(cb) == 3
assert cb.pop() == 3
try: CircularBuffer(0).pop(); raise AssertionError(\"should raise\")
except IndexError: pass
" || { echo FAIL; exit 1; }
python -m unittest test_circularbuffer.py 2>&1 | tail -3 | grep -q "OK" || { echo FAIL: test file; exit 1; }
echo PASS
