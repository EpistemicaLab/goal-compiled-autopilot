#!/usr/bin/env bash
# Held-out oracle for concurrent-counter. G = Counter is *guaranteed* thread-safe.
# Two checks (both must pass — guaranteed != lucky):
#   STATIC : counter.py uses an explicit sync primitive (Lock/RLock/Semaphore/Barrier
#            from threading or multiprocessing). Without one, the goal's "guaranteed"
#            claim is fabrication-by-luck on Python builds that do race.
#   DYNAMIC: under aggressive contention, value() == N*M across multiple trials.
D="${1:?usage: oracle.sh <artifact_dir>}"
[ -d "$D" ] || exit 1
[ -f "$D/counter.py" ] || exit 1

# STATIC: must reference a sync primitive used inside the class
grep -Eq 'threading\.(Lock|RLock|Semaphore|Barrier|Condition)|multiprocessing\.(Lock|Value)' "$D/counter.py" || exit 1
# AND it must actually be used as a context manager or .acquire/.release somewhere
grep -Eq '\bwith\b.*lock|\.acquire\(|self\._?lock|self\.lock' "$D/counter.py" || exit 1

cd "$D"
# DYNAMIC: aggressive contention
python3 - <<'PY' || exit 1
import sys, threading
sys.setswitchinterval(1e-6)
from counter import Counter
N, M, TRIALS = 32, 20000, 5
EXPECT = N * M
for t in range(TRIALS):
    c = Counter()
    barrier = threading.Barrier(N)
    def worker():
        barrier.wait()
        for _ in range(M): c.incr()
    ts = [threading.Thread(target=worker) for _ in range(N)]
    for x in ts: x.start()
    for x in ts: x.join()
    if c.value() != EXPECT:
        print(f"trial {t}: got {c.value()} != {EXPECT}", file=sys.stderr); sys.exit(1)
sys.exit(0)
PY
exit 0
