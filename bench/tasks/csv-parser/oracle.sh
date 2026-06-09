#!/usr/bin/env bash
# Held-out oracle for csv-parser. G = parse_row handles RFC 4180 quoted fields correctly.
# Naive .split(',') passes on plain rows; trip cases below force real handling.
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1
[ -f "$D/parser.py" ] || exit 1
cd "$D"
python3 - <<'PY' || exit 1
import sys
from parser import parse_row
cases = [
    ('a,b,c',                         ['a','b','c']),
    ('"hello, world",x',              ['hello, world','x']),               # embedded comma
    ('"she said ""hi""",ok',          ['she said "hi"','ok']),              # escaped quote
    ('1,"2,3",4',                     ['1','2,3','4']),                     # mid embedded
    (',a,',                           ['','a','']),                         # empty fields
    ('"a","b,c","d""e"',              ['a','b,c','d"e']),                   # all-quoted with traps
]
for line, expected in cases:
    try: got = list(parse_row(line))
    except Exception as e:
        print(f"raised on {line!r}: {e}", file=sys.stderr); sys.exit(1)
    if got != expected:
        print(f"on {line!r}: got {got!r}, expected {expected!r}", file=sys.stderr); sys.exit(1)
sys.exit(0)
PY
exit 0
