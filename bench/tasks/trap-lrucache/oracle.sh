#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f lrucache.py ] || { echo FAIL missing; exit 1; }
[ -f test_lrucache.py ] || { echo FAIL missing test; exit 1; }
python -c "
from lrucache import LRUCache
c = LRUCache(2)
c.put(\"a\", 1); c.put(\"b\", 2)
assert c.get(\"a\") == 1
c.put(\"c\", 3)  # should evict b (least recent)
assert c.get(\"b\") is None, \"b should be evicted\"
assert c.get(\"a\") == 1 and c.get(\"c\") == 3
assert len(c) == 2
" || { echo FAIL; exit 1; }
echo PASS
