#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f reservoirsample.py ] || { echo FAIL; exit 1; }
[ -f test_reservoirsample.py ] || { echo FAIL test; exit 1; }
python -c "
from reservoirsample import reservoir_sample
out = reservoir_sample(range(10), 5)
assert len(out) == 5 and set(out) <= set(range(10)), out
out = reservoir_sample(range(3), 5)
assert sorted(out) == [0,1,2], out
# Light uniformity check
from collections import Counter
counts = Counter()
import random; random.seed(42)
for _ in range(2000):
    counts.update(reservoir_sample(range(5), 2))
# each item should appear ~ 2000*2/5 = 800 times +/- 100
for v in counts.values():
    assert 600 < v < 1000, counts
" || { echo FAIL; exit 1; }
echo PASS
