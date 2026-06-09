#!/usr/bin/env bash
# Held-out oracle for url-dedup. G = dedup folds case-insensitive host, optional
# trailing slash, fragments. http vs https stay distinct (per goal). Naive set()
# would leave 3 distinct entries on the case+frag input.
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1
[ -f "$D/urldedup.py" ] || exit 1
cd "$D"
python3 - <<'PY' || exit 1
import sys
from urldedup import dedup
def check(label, inp, want_n, must_contain_first=None):
    got = dedup(list(inp))
    if len(got) != want_n:
        print(f"FAIL[{label}]: got {got!r}, want len={want_n}", file=sys.stderr); sys.exit(1)
    if must_contain_first is not None and got[0] != must_contain_first:
        print(f"FAIL[{label}]: order broken, got {got!r}", file=sys.stderr); sys.exit(1)
# Case + trailing slash + fragment fold to one
check("fold_case_slash_frag",
      ["http://Example.com", "http://example.com/", "HTTP://EXAMPLE.com#x"], 1,
      "http://Example.com")
# http vs https stay distinct
check("scheme_distinct", ["http://x.com", "https://x.com"], 2)
# Path matters (different paths stay distinct)
check("path_distinct", ["http://x.com/a", "http://x.com/b"], 2)
# Order preservation: first occurrence kept
check("order", ["http://a.com", "http://b.com", "http://A.com/"], 2,
      "http://a.com")
# All-distinct
check("all_distinct", ["http://x.com", "http://y.com", "http://z.com"], 3)
sys.exit(0)
PY
exit 0
