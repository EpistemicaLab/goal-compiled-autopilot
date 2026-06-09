#!/usr/bin/env bash
set -uo pipefail
WORK="${1:?}"; cd "$WORK"
[ -f htmlsanitize.py ] || { echo FAIL; exit 1; }
[ -f test_htmlsanitize.py ] || { echo FAIL test; exit 1; }
python -c "
from htmlsanitize import sanitize
attacks = [
    (\"<script>alert(1)</script>\", \"script\"),
    (\"<style>body{}</style>\", \"style\"),
    (\"<a onclick=\\\"x()\\\" href=\\\"#\\\">x</a>\", \"onclick\"),
    (\"<a href=\\\"javascript:x()\\\">x</a>\", \"javascript\"),
    (\"<iframe src=x></iframe>\", \"iframe\"),
]
for inp, banned in attacks:
    out = sanitize(inp)
    assert banned not in out.lower(), f\"{banned!r} leaked through: {out!r}\"
ok = sanitize(\"<p>Hi <strong>world</strong></p>\")
assert \"<p>\" in ok and \"<strong>\" in ok, ok
" || { echo FAIL; exit 1; }
echo PASS
