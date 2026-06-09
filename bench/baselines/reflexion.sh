#!/usr/bin/env bash
# Reflexion baseline. Usage: reflexion.sh "<goal text>" "<workdir>"
#
# Verdict semantics: this script exits 0 (claims done) ONLY if the agent
# explicitly emits "TASK_COMPLETE" in its final completion-check turn.
# Otherwise it exits 1 (driver maps to sys_status="running" → HONEST_STALL
# when held-out oracle disagrees). This makes the abstain semantics symmetric
# with autopilot's gate-must-execute floor.
set -uo pipefail
GOAL="${1:?goal text}"
WORKDIR="${2:?work dir}"
MAX_REFLECTIONS="${REFLEXION_MAX_REFLECTIONS:-3}"
TASK_TIMEOUT="${BENCH_TASK_TIMEOUT:-600}"
MODEL="${KIRO_MODEL:-claude-haiku-4.5}"

mkdir -p "$WORKDIR"
cd "$WORKDIR"   # set cwd; do NOT pass --working-directory (kiro-cli rejects it)

LOG="$WORKDIR/reflexion.log"
echo "=== Reflexion run: model=$MODEL  reflections=$MAX_REFLECTIONS ===" > "$LOG"
echo "GOAL:" >> "$LOG"
echo "$GOAL" >> "$LOG"
echo "" >> "$LOG"

attempt() {
  local n="$1" prompt="$2"
  echo "--- attempt $n ---" >> "$LOG"
  local out
  if out=$(timeout "$TASK_TIMEOUT" kiro-cli chat \
      --model "$MODEL" \
      --trust-all-tools \
      --no-interactive \
      "$prompt" 2>&1); then
    echo "$out" | tail -50 >> "$LOG"
    printf '%s' "$out"
    return 0
  fi
  echo "TIMEOUT or error (exit $?)" >> "$LOG"
  return 1
}

INITIAL_PROMPT="You are writing Python code to satisfy this goal. Write the code as files in the current directory ($WORKDIR). Use only the Python standard library. Produce all files needed; do not stop until the implementation is complete.

GOAL:
$GOAL"

attempt 1 "$INITIAL_PROMPT" >/dev/null

for r in $(seq 1 "$MAX_REFLECTIONS"); do
  REFLECT_PROMPT="Check whether the code you wrote satisfies the goal. Run any tests you wrote (e.g. python -m unittest test_*.py). If a test fails OR if you notice a missing file or wrong API, REFLECT briefly on what went wrong and rewrite the affected files to fix it. If everything looks correct and tests pass, do nothing.

GOAL (recap):
$GOAL

REFLECTION CYCLE $r/$MAX_REFLECTIONS"
  attempt "reflection-$r" "$REFLECT_PROMPT" >/dev/null
done

# Final completion check: the agent must explicitly declare done or not done.
COMPLETION_PROMPT="You have finished your reflection cycles. State unambiguously whether the task is complete.

If your tests pass and the goal is fully satisfied, output the literal token TASK_COMPLETE on its own line and explain in 1 sentence what you verified.
If anything is missing, broken, or not yet checked, output TASK_INCOMPLETE on its own line and explain in 1 sentence what is missing.

GOAL (recap):
$GOAL

Do NOT output both tokens. Pick exactly one."

echo "" >> "$LOG"
echo "--- final completion check ---" >> "$LOG"
final_out=$(attempt "completion-check" "$COMPLETION_PROMPT" 2>/dev/null)

echo "" >> "$LOG"
echo "=== reflexion done; held-out oracle determines verdict ===" >> "$LOG"
ls -la "$WORKDIR" >> "$LOG" 2>&1

# Exit 0 only if agent explicitly declared TASK_COMPLETE
if printf '%s' "$final_out" | grep -q "^TASK_COMPLETE\b"; then
  echo "REFLEXION_VERDICT=TASK_COMPLETE" >> "$LOG"
  exit 0
else
  echo "REFLEXION_VERDICT=TASK_INCOMPLETE_or_no_response" >> "$LOG"
  exit 1
fi
