#!/usr/bin/env bash
# a3_audit_ensemble.sh — static-then-LLM ensemble auditor.
#
# Stage 1: static check (cheap, ~1ms). If FAIL, block immediately and skip Stage 2.
# Stage 2: LLM-judge check (claude-haiku-4.5, ~3s). If FAIL, block. If PASS, allow tick.
#
# Verdicts equivalent to LLM-only (because LLM ⊇ static for A3 catches), but skips
# the LLM call when static already finds the issue — a cost optimisation.
#
# Logs LLM-call count to <state-dir>/a3_audit_llm_calls.flag (1 if invoked, absent if not).
# Usage: a3_audit_ensemble.sh <state.json> <goal>
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
state="${1:?usage: a3_audit_ensemble.sh <state.json> <goal>}"
goal="${2:?usage: a3_audit_ensemble.sh <state.json> <goal>}"
state_dir="$(dirname "$state")"

# Stage 1: static
if ! bash "$HERE/a3_audit.sh" "$state" "$goal" 2>>"$state_dir/a3_audit.log"; then
  echo "(ensemble: stage-1 static FAIL — skipped LLM call)" >>"$state_dir/a3_audit.log"
  exit 1
fi

# Stage 2: LLM (only reached when static passed)
touch "$state_dir/a3_audit_llm_calls.flag"
if ! bash "$HERE/a3_audit_llm.sh" "$state" "$goal" 2>>"$state_dir/a3_audit.log"; then
  echo "(ensemble: stage-2 LLM FAIL after static PASS)" >>"$state_dir/a3_audit.log"
  exit 1
fi

exit 0
