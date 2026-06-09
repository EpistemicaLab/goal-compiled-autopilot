#!/usr/bin/env bash
# react.sh <goal_dir> — ReAct-style baseline: ONE kiro-cli call, free-form, no FSM, no firewall.
# Used by run_bench.sh --system react. Held-out oracle (independent of agent) does the scoring.
set -uo pipefail
DIR="${1:?usage: react.sh <goal_dir>}"
TIMEOUT="${REACT_TIMEOUT:-900}"
GOAL="$(jq -r '.goal' "$DIR/state.json")"
mkdir -p "$DIR/work"
PROMPT="You are a ReAct coding agent. Goal:
$GOAL

Working directory: $DIR/work — put all artifacts there. Use only the python standard library.
Do NOT install packages, do NOT bind ports, do NOT touch anything outside that directory.
Reason and act iteratively (think, run, observe) until you believe the goal is met. When you
believe you are done, stop. Your own self-check is the only gate."
af=(); [[ -n "${AUTOPILOT_AGENT:-}" ]] && af=(--agent "$AUTOPILOT_AGENT")
mf=(); [[ -n "${KIRO_MODEL:-}" ]] && mf=(--model "$KIRO_MODEL")
timeout "$TIMEOUT" kiro-cli chat ${af[@]+"${af[@]}"} ${mf[@]+"${mf[@]}"} --no-interactive --trust-all-tools "$PROMPT" \
  > "$DIR/react.log" 2>&1
ec=$?
# ReAct does not write a state machine; we record a flat "claimed_done" if it exited cleanly.
jq --arg ec "$ec" '. + {react_exit: ($ec|tonumber), status:(if ($ec|tonumber)==0 then "done" else "failed" end)}' \
   "$DIR/state.json" > "$DIR/state.json.tmp" && mv "$DIR/state.json.tmp" "$DIR/state.json"
exit 0
