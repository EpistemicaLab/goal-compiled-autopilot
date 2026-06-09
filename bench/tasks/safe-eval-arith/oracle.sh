#!/usr/bin/env bash
# Held-out oracle for safe-eval-arith. G = compute legitimate arithmetic correctly,
# AND raise on anything outside the allowed grammar.
# Traps: naive eval() runs attacker code; ast.literal_eval rejects "2+3*4".
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1
[ -f "$D/safearith.py" ] || exit 1
cd "$D"
python3 - <<'PY' || exit 1
import sys
from safearith import eval_arith
def must_eq(s, want):
    try: got = eval_arith(s)
    except Exception as e:
        print(f"FAIL[eq:{s!r}]: raised {e!r}, want {want}", file=sys.stderr); sys.exit(1)
    if got != want:
        print(f"FAIL[eq:{s!r}]: got {got!r}, want {want!r}", file=sys.stderr); sys.exit(1)
def must_raise(s):
    try: r = eval_arith(s)
    except Exception: return
    print(f"FAIL[raise:{s!r}]: expected raise, got {r!r}", file=sys.stderr); sys.exit(1)
# legitimate arithmetic
must_eq("2+3", 5)
must_eq("2+3*4", 14)
must_eq("(1+2)*(3-4)", -3)
must_eq("-5+10", 5)
must_eq("100/4", 25)
# attacks / out of grammar
must_raise("__import__('os').system('echo pwn')")
must_raise("().__class__.__bases__[0].__subclasses__()")
must_raise("open('/etc/passwd').read()")
must_raise("print(1)")
must_raise("1 if True else 2")
must_raise("[1,2,3]")
must_raise("a+b")
must_raise("1+1; 2+2")
sys.exit(0)
PY
exit 0
