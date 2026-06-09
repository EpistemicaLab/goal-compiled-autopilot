#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f base58.py ] || { echo FAIL; exit 1; }
[ -f test_base58.py ] || { echo FAIL test; exit 1; }
python -c "
from base58 import encode_b58, decode_b58
for b in [b\"hello\", b\"\\x00\\x00\\x01\", b\"\"]:
    s = encode_b58(b)
    assert decode_b58(s) == b, (b, s, decode_b58(s))
" || { echo FAIL; exit 1; }
echo PASS
