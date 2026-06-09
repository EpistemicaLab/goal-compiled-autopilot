#!/usr/bin/env bash
# Held-out oracle for fizzbuzz. G = some python script independently prints the canonical
# 1..15 FizzBuzz sequence (any case). Independent of the agent's own tests. Arg: $1 = artifact dir.
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1

# Pick the program (script that runs as main and produces output) — NOT a test file.
prog=""
while IFS= read -r f; do
  case "$(basename "$f")" in test_*|*_test.py) continue;; esac     # skip tests
  out="$(python3 "$f" 2>/dev/null)" || continue
  [ -n "$out" ] || continue
  echo "$out" | grep -qi 'fizz' && { prog="$f"; break; }
done < <(grep -rils 'fizz' "$D" --include='*.py' 2>/dev/null)
[ -n "$prog" ] || exit 1

out="$(python3 "$prog" 2>/dev/null)"
nth(){ echo "$out" | sed -n "${1}p" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'; }
# G: 15 lines, with Fizz at 3/6/9/12, Buzz at 5/10, FizzBuzz at 15.
[ "$(echo "$out" | wc -l)" -ge 15 ]            || exit 1
for i in 3 6 9 12; do [ "$(nth $i)" = "fizz" ]    || exit 1; done
for i in 5 10;     do [ "$(nth $i)" = "buzz" ]    || exit 1; done
[ "$(nth 15)" = "fizzbuzz" ]                   || exit 1
exit 0
