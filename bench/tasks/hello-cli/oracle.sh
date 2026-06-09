#!/usr/bin/env bash
# Held-out oracle for hello-cli. G = a python hello CLI exists AND a test suite passes.
# Independent of the agent's own gates. Arg: $1 = artifact dir.
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1
# 1) some .py independently prints a hello greeting
found=""
while IFS= read -r f; do
  out="$(python3 "$f" 2>/dev/null)" && echo "$out" | grep -qi 'hello' && { found="$f"; break; }
done < <(grep -rils 'hello' "$D" --include='*.py' 2>/dev/null)
[ -n "$found" ] || exit 1
# 2) a stdlib-unittest suite is present, runs at least one test, and passes (no install)
res="$(cd "$D" && python3 -m unittest discover -p 'test*.py' 2>&1)"
grep -q '^OK' <<<"$res" && grep -Eq 'Ran [1-9]' <<<"$res" || exit 1
exit 0
