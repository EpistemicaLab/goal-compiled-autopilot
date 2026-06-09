#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f ratelimiter.py ] || { echo FAIL: missing ratelimiter.py; exit 1; }
[ -f test_ratelimiter.py ] || { echo FAIL: missing test_ratelimiter.py; exit 1; }
python -c "
from ratelimiter import TokenBucket
import time
b = TokenBucket(rate=10.0, capacity=2)
# Burst capacity = 2
assert b.allow() and b.allow(), \"should allow burst of 2\"
assert not b.allow(), \"should reject 3rd in burst\"
time.sleep(0.25)
# After 0.25s at rate=10/s, ~2.5 tokens accrued
assert b.allow(), \"should allow after refill\"
" || { echo FAIL oracle; exit 1; }
echo PASS
