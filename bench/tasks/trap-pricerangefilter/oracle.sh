#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f pricerangefilter.py ] || { echo FAIL; exit 1; }
[ -f test_pricerangefilter.py ] || { echo FAIL test; exit 1; }
python -c "
from pricerangefilter import filter_in_range
items = [{\"price\":5},{\"price\":10},{\"price\":15},{\"name\":\"no_price\"}]
out = filter_in_range(items, 5, 10)
assert len(out) == 2 and out[0][\"price\"] == 5 and out[1][\"price\"] == 10, out
out = filter_in_range(items, 100, 200)
assert out == []
out = filter_in_range(items, 20, 5)
assert out == []
" || { echo FAIL; exit 1; }
echo PASS
