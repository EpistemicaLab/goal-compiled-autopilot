#!/usr/bin/env bash
# StateFlow baseline. Usage: stateflow.sh "<goal text>" "<workdir>"
#
# Verdict semantics: exits 0 (claims done) ONLY if the FSM reached
# current_state="DONE". Otherwise exits 1 (driver maps to sys_status="running"
# → HONEST_STALL when held-out oracle disagrees). Symmetric with autopilot's
# gate-must-execute floor.
set -uo pipefail
GOAL="${1:?goal text}"
WORKDIR="${2:?work dir}"
MAX_TICKS="${STATEFLOW_MAX_TICKS:-15}"
TASK_TIMEOUT="${BENCH_TASK_TIMEOUT:-600}"
MODEL="${KIRO_MODEL:-claude-haiku-4.5}"

mkdir -p "$WORKDIR"
cd "$WORKDIR"   # set cwd; do NOT pass --working-directory (kiro-cli rejects it)

LOG="$WORKDIR/stateflow.log"
HISTORY="$WORKDIR/stateflow_history.txt"
echo "=== StateFlow run: model=$MODEL  max_ticks=$MAX_TICKS ===" > "$LOG"
echo "GOAL:" >> "$LOG"
echo "$GOAL" >> "$LOG"
: > "$HISTORY"

current_state="PLAN"
last_obs=""

for tick in $(seq 1 "$MAX_TICKS"); do
  echo "" >> "$LOG"
  echo "--- tick $tick  current_state=$current_state ---" >> "$LOG"
  echo "$tick: $current_state" >> "$HISTORY"

  if [ "$current_state" = "DONE" ]; then
    echo "  reached DONE at tick $tick" >> "$LOG"
    break
  fi

  PROMPT="You are running inside a state-driven LLM agent (StateFlow). Pick the next state and execute its action.

GOAL:
$GOAL

STATE VOCABULARY:
  PLAN       — read goal, list files to create
  IMPLEMENT  — write/edit code files in the current directory ($WORKDIR)
  TEST       — run tests via 'python -m unittest test_*.py' or similar; observe the output
  FIX        — apply a patch to fix a test failure
  DONE       — declare task complete (only if you are confident tests pass)

CURRENT STATE: $current_state
TICK: $tick / $MAX_TICKS
HISTORY OF STATES: $(cat "$HISTORY" | tr '\n' ' ')

LAST OBSERVATION (truncated):
$(echo "$last_obs" | tail -50)

Now: (a) decide the next state by writing 'NEXT_STATE: <STATE>' on its own line, then (b) take that state's action. Stop when you've completed the action for this single tick. Use only the Python standard library."

  if obs=$(timeout "$TASK_TIMEOUT" kiro-cli chat \
      --model "$MODEL" \
      --trust-all-tools \
      --no-interactive \
      "$PROMPT" 2>&1); then
    echo "$obs" | tail -100 >> "$LOG"
    last_obs="$obs"
    next=$(echo "$obs" | grep -oE "NEXT_STATE: *(PLAN|IMPLEMENT|TEST|FIX|DONE)" | head -1 | awk '{print $2}')
    if [ -n "$next" ]; then
      current_state="$next"
    else
      case "$current_state" in
        PLAN)      current_state="IMPLEMENT" ;;
        IMPLEMENT) current_state="TEST" ;;
        TEST)      current_state="FIX" ;;
        FIX)       current_state="TEST" ;;
        *)         current_state="PLAN" ;;
      esac
    fi
  else
    echo "  tick $tick TIMEOUT (exit $?)" >> "$LOG"
    last_obs="(timeout in previous action)"
  fi
done

echo "" >> "$LOG"
echo "=== stateflow done; final state=$current_state ===" >> "$LOG"
ls -la "$WORKDIR" >> "$LOG" 2>&1

# Exit 0 only if FSM reached DONE
if [ "$current_state" = "DONE" ]; then
  echo "STATEFLOW_VERDICT=REACHED_DONE" >> "$LOG"
  exit 0
else
  echo "STATEFLOW_VERDICT=NOT_DONE_state=$current_state" >> "$LOG"
  exit 1
fi
