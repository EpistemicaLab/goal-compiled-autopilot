#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f leastsquares.py ] || { echo FAIL: missing leastsquares.py; exit 1; }
[ -f test_leastsquares.py ] || { echo FAIL: missing test_leastsquares.py; exit 1; }
python -c "
from leastsquares import fit
xs = [0,1,2,3,4]; ys = [1,3,5,7,9]   # y = 2x + 1
m, b = fit(xs, ys)
assert abs(m - 2.0) < 1e-6, m
assert abs(b - 1.0) < 1e-6, b
" || { echo FAIL; exit 1; }
# Verify test file actually has tests
python -m unittest test_leastsquares.py 2>&1 | tail -3 | grep -q "OK" || { echo "FAIL: test file does not pass"; exit 1; }
echo PASS
