#!/usr/bin/env bash
# Run a single SWE-bench task through the named system. Used by the empirical
# corpus driver to grid (task x system x model x seed).
#
# Usage: run_swebench.sh <instance_id> <system: autopilot|react> [seed]
set -uo pipefail
IID="${1:?instance_id required}"
SYS="${2:?system required}"
SEED="${3:-42}"
REPO="/home/dyouwang/.meshclaw/workspace/goal-autopilot"
TASK_DIR="$REPO/bench/swebench_tasks/$IID"
[ -d "$TASK_DIR" ] || { echo "no such task: $IID"; exit 2; }

# Per-run sandbox under bench/runs/swebench-<sys>/<iid>/<seed>/
RUN_DIR="$REPO/bench/runs/swebench-$SYS/$IID/seed-$SEED"
mkdir -p "$RUN_DIR/work"
bash "$TASK_DIR/setup.sh" "$RUN_DIR/work"

# Goal text from goal.md
GOAL=$(cat "$TASK_DIR/goal.md")

case "$SYS" in
  autopilot)
    cd "$REPO" && BENCH_LABEL="swe-$IID-seed$SEED" \
      KIRO_MODEL="${KIRO_MODEL:-claude-haiku-4.5}" \
      RANDOM_SEED="$SEED" \
      bash autopilot.sh run "$GOAL" "$RUN_DIR/work" 2>&1 | tail -20
    ;;
  react)
    cd "$REPO" && BENCH_LABEL="swe-$IID-seed$SEED" \
      KIRO_MODEL="${KIRO_MODEL:-claude-haiku-4.5}" \
      RANDOM_SEED="$SEED" \
      bash bench/baselines/react.sh "$GOAL" "$RUN_DIR/work" 2>&1 | tail -20
    ;;
  *)
    echo "unknown system: $SYS"; exit 2 ;;
esac

# Run held-out oracle
ORACLE_OUT=$(bash "$TASK_DIR/oracle.sh" "$RUN_DIR/work" 2>&1 | tail -1)
echo "oracle: $ORACLE_OUT"

# Emit per-cell verdict to a JSON line
python3 - <<PY
import json, pathlib, os
v = "TRUE_SUCCESS" if "$ORACLE_OUT" == "PASS" else "HONEST_STALL"
out = {"task": "$IID", "system": "$SYS", "seed": $SEED, "verdict": v, "oracle": "$ORACLE_OUT"}
pathlib.Path("$RUN_DIR/verdict.json").write_text(json.dumps(out))
print(json.dumps(out))
PY
