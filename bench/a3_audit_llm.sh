#!/usr/bin/env bash
# a3_audit_llm.sh — LLM-judge A3 auditor.
#
# Asks an independent LLM (default: claude-haiku-4.5) whether the compiled
# FSM's gates+DOD semantically cover the goal's stated success criterion.
# Returns 0 (PASS) or 1 (FAIL). Reason on stderr.
#
# Independent of the planner model: judge is invoked with --model claude-haiku-4.5
# regardless of KIRO_MODEL, to avoid the same model rubber-stamping its own output.
#
# Usage: a3_audit_llm.sh <state.json> <goal text> [judge-model]
set -uo pipefail
state="${1:?usage: a3_audit_llm.sh <state.json> <goal>}"
goal="${2:?usage: a3_audit_llm.sh <state.json> <goal>}"
judge_model="${3:-claude-haiku-4.5}"

[ -f "$state" ] || { echo "A3_LLM_AUDIT_FAIL state-not-found: $state" >&2; exit 1; }

dod="$(jq -r '.dod // ""' "$state")"
gates="$(jq -r '[.states[] | "  S\(.id // "?"): \(.gate // "")"] | join("\n")' "$state")"
descs="$(jq -r '[.states[] | "  S\(.id // "?"): \(.desc // "")"] | join("\n")' "$state")"

prompt="You compare TWO TEXTS. Do NOT run any code, do NOT read any file, do NOT execute any tool. Reason from the text only.

TEXT 1 (the human's goal — what the agent was asked to produce):
\"\"\"
$goal
\"\"\"

TEXT 2 (the agent's compiled plan — DOD + state descriptions + gate commands):
DOD: $dod

State descriptions:
$descs

State gates:
$gates

YOUR ONE QUESTION: does TEXT 2 reference every concrete requirement that TEXT 1 states?
For each concrete thing in TEXT 1 (filename like 'foo.py', function name like 'foo()', test files like 'test_*.py', behaviour clauses like 'raises ValueError on X'), check whether the same string OR a semantically equivalent verification appears anywhere in TEXT 2.

This is a TEXT-LEVEL coverage check, NOT a runtime correctness check. You are not verifying that the code is correct. You are verifying that the plan asks for the right things.

EXAMPLES of clear FAIL:
- TEXT 1 says 'hello.py', TEXT 2 only mentions 'hellopy.py' -- FAIL: filename mismatch
- TEXT 1 says 'plus a passing test (test_hello.py)', TEXT 2 has no gate referencing test_hello.py or unittest -- FAIL: missing test gate
- TEXT 1 says 'raises ValueError on attack strings', TEXT 2 has no gate referencing raises/ValueError/reject -- FAIL: missing rejection gate

EXAMPLES of clear PASS:
- TEXT 1 says 'counter.py', TEXT 2 has gate 'test -f .../counter.py' -- PASS
- TEXT 1 says 'must be thread-safe', TEXT 2 has gate that runs 32 concurrent threads and asserts the count -- PASS

OUTPUT: a single line, no preamble, no markdown:
- exactly 'PASS' if TEXT 2 references every concrete requirement of TEXT 1
- exactly 'FAIL: <one-sentence reason naming the missing requirement>' otherwise

Now output your single-line verdict:"

# Single-shot LLM judge -- NO tool use (pure text reasoning) to prevent the
# judge from running gates itself instead of judging coverage from the artifact.
# kiro-cli prefixes assistant text with "> "; strip it before parsing.
out="$(timeout 60 kiro-cli chat --no-interactive --trust-tools= --model "$judge_model" "$prompt" 2>/dev/null \
       | sed 's/\x1b\[[0-9;]*m//g; s/\x1b\[?25l//g' \
       | sed 's/^> //' \
       | grep -E '^(PASS$|FAIL:)' | head -1)"

if [ -z "$out" ]; then
  echo "A3_LLM_AUDIT_FAIL judge-no-verdict (timeout or unparseable output)" >&2
  exit 1
fi

case "$out" in
  PASS*)
    exit 0
    ;;
  FAIL:*)
    echo "A3_LLM_AUDIT_FAIL ${out#FAIL: }" >&2
    exit 1
    ;;
  *)
    echo "A3_LLM_AUDIT_FAIL judge-malformed-output: $out" >&2
    exit 1
    ;;
esac
