#!/usr/bin/env python3
"""ollama-react.sh equivalent in python — gives the SLM a minimal ReAct loop with shell + write_file
tools so it can actually produce code in the work dir. No FSM, no firewall, no held-out gate; the
agent self-decides when 'done'. Held-out oracle (independent of the agent) scores the artifacts.

Usage: ollama_react.py <goal_dir>   (state.json is written by run_bench's drive_react)
"""
import os, sys, json, subprocess, time, urllib.request, urllib.error
from pathlib import Path

OLLAMA = os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434/api/chat")
MODEL  = os.environ.get("OLLAMA_MODEL", "qwen2.5-coder:7b")
TIMEOUT_S = int(os.environ.get("REACT_TIMEOUT", "900"))   # wall budget per task
MAX_STEPS = int(os.environ.get("REACT_MAX_STEPS", "20"))  # tool-loop cap

DIR = Path(sys.argv[1]).resolve()
WORK = DIR / "work"
WORK.mkdir(parents=True, exist_ok=True)
STATE = DIR / "state.json"
GOAL = json.loads(STATE.read_text())["goal"]
LOG = (DIR / "react.log").open("w")

def log(msg):
    LOG.write(msg + "\n"); LOG.flush()

SYSTEM = f"""You are a coding agent. Goal:
{GOAL}

Working directory: {WORK} — put all artifacts there. Use only the python standard library.
Do NOT install packages, do NOT bind ports, do NOT touch anything outside that directory.

You can call tools by emitting a single line starting with TOOL: followed by JSON, e.g.
  TOOL: {{"name":"write_file","path":"file.py","content":"..."}}
  TOOL: {{"name":"shell","cmd":"python3 -m unittest discover"}}
  TOOL: {{"name":"read_file","path":"file.py"}}
  TOOL: {{"name":"done"}}    when you believe the goal is complete

Reason step by step (think), then issue exactly ONE tool call per turn. After you receive the
tool output, decide the next action. When done, call the done tool."""

def chat(messages):
    body = json.dumps({"model": MODEL, "messages": messages, "stream": False,
                       "options": {"temperature": 0.2, "num_ctx": 8192}}).encode()
    req = urllib.request.Request(OLLAMA, data=body, headers={"Content-Type":"application/json"})
    with urllib.request.urlopen(req, timeout=180) as r:
        return json.loads(r.read())["message"]["content"]

def safe_path(p):
    p = (WORK / p).resolve()
    if not str(p).startswith(str(WORK)): raise ValueError(f"escape: {p}")
    return p

def run_tool(call):
    n = call.get("name")
    if n == "write_file":
        p = safe_path(call["path"]); p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(call.get("content",""))
        return f"wrote {len(call.get('content',''))} bytes to {p.name}"
    if n == "read_file":
        p = safe_path(call["path"])
        return p.read_text() if p.exists() else f"NOT_FOUND: {p.name}"
    if n == "shell":
        try:
            r = subprocess.run(call["cmd"], shell=True, cwd=WORK, capture_output=True,
                               text=True, timeout=60)
            out = (r.stdout + r.stderr)[-2000:]
            return f"exit={r.returncode}\n{out}"
        except subprocess.TimeoutExpired: return "TIMEOUT"
    if n == "done": return "DONE"
    return f"UNKNOWN_TOOL: {n}"

def update_status(status, **extra):
    s = json.loads(STATE.read_text())
    s.update({"status": status, **extra})
    STATE.write_text(json.dumps(s, indent=2))

start = time.time()
messages = [{"role":"system","content":SYSTEM}, {"role":"user","content": GOAL}]
status = "failed"
try:
    for step in range(MAX_STEPS):
        if time.time() - start > TIMEOUT_S:
            log(f"WALL_TIMEOUT after {step} steps"); break
        reply = chat(messages); log(f"--- step {step} reply ---\n{reply}")
        messages.append({"role":"assistant","content":reply})
        # extract first TOOL: line
        tool_line = next((ln for ln in reply.splitlines() if ln.strip().startswith("TOOL:")), None)
        if not tool_line:
            messages.append({"role":"user","content":"No tool call found. Emit one TOOL: JSON line."})
            continue
        try: call = json.loads(tool_line.split("TOOL:",1)[1].strip())
        except Exception as e:
            messages.append({"role":"user","content":f"Bad TOOL JSON: {e}. Try again."}); continue
        out = run_tool(call); log(f"tool out: {out[:300]}")
        if out == "DONE": status = "done"; break
        messages.append({"role":"user","content":f"Tool result:\n{out}"})
except Exception as e:
    log(f"EXCEPTION: {e}")

update_status(status, react_steps=step+1, react_wall_s=int(time.time()-start), react_model=MODEL)
LOG.close()
sys.exit(0)
