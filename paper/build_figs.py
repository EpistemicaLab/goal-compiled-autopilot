#!/usr/bin/env python3
"""Figure 1 -- Behavioral fork: fabrication rate per (system x model tier).

Visualizes the §6.5 headline: under the same paired inputs, Autopilot's
floor enforcement reduces fabrication from 64.57% (StateFlow on F2) to
2.86% (Autopilot on F2), with a 24.10pp aggregate gap that holds across
all three model tiers.

Output: paper/figs/fig1_behavioral_fork.pdf  (vector, for \\includegraphics)
"""
import json
import os
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

# ---- Load shipped reports.jsonl and aggregate per (system, model) ----
HERE = os.path.dirname(os.path.abspath(__file__))

# Try the rerun corpus first (has post-fix baseline numbers)
RERUN_REPORTS_DIR = "/home/dyouwang/.meshclaw/workspace/goal-autopilot-paper-v2/artifacts/p1_corpus/runs"

cells = []
if os.path.isdir(RERUN_REPORTS_DIR):
    import glob
    for p in sorted(glob.glob(f"{RERUN_REPORTS_DIR}/*/report.json")):
        try:
            cells.append(json.load(open(p)))
        except Exception:
            continue
    print(f"loaded {len(cells)} cells from rerun corpus")
else:
    REPORTS = os.path.join(HERE, "..", "bench", "p1_corpus", "reports.jsonl")
    with open(REPORTS) as f:
        cells = [json.loads(line) for line in f if line.strip()]
    print(f"loaded {len(cells)} cells from {REPORTS}")

# Anonymize model names
MODEL_MAP = {
    "claude-haiku-4.5": "F2",
    "deepseek-3.2": "M2",
    "qwen3-coder-next": "M1",
    "agi-nova-beta-1m": "W1",
}
for c in cells:
    c["model"] = MODEL_MAP.get(c["model"], c["model"])

counts = defaultdict(lambda: [0, 0])
for c in cells:
    key = (c["system"], c["model"])
    counts[key][1] += 1
    if c["verdict"] == "FABRICATION":
        counts[key][0] += 1

systems = ["autopilot", "reflexion", "stateflow"]
models = ["F2", "M1", "M2"]

fab_pct = np.zeros((len(models), len(systems)))
n_cells = np.zeros((len(models), len(systems)), dtype=int)
for i, m in enumerate(models):
    for j, s in enumerate(systems):
        fab, total = counts.get((s, m), [0, 0])
        fab_pct[i, j] = 100.0 * fab / total if total else 0.0
        n_cells[i, j] = total
        print(f"  {s:<10} x {m}: {fab:>3}/{total:<3} = {fab_pct[i,j]:>5.2f}%")

# ---- Plot ----
plt.rcParams.update({
    "font.family": "serif",
    "font.size": 10,
    "axes.labelsize": 10,
    "axes.titlesize": 10,
    "legend.fontsize": 9,
    "xtick.labelsize": 10,
    "ytick.labelsize": 9,
    "axes.spines.top": False,
    "axes.spines.right": False,
})

# Slightly taller to give room for legend at top OUTSIDE plot area
fig, ax = plt.subplots(figsize=(6.5, 3.2))
fig.subplots_adjust(top=0.85, bottom=0.30)

x = np.arange(len(models))
bar_width = 0.26

colors = {
    "autopilot": "#2E5EAA",
    "reflexion": "#E8A83A",
    "stateflow": "#C84630",
}
labels = {
    "autopilot": "Autopilot (ours, with floor)",
    "reflexion": "Reflexion (reflective-loop)",
    "stateflow": "StateFlow (FSM, no floor)",
}

for j, s in enumerate(systems):
    offset = (j - 1) * bar_width
    bars = ax.bar(
        x + offset, fab_pct[:, j],
        width=bar_width, color=colors[s], label=labels[s],
        edgecolor="white", linewidth=0.6,
    )
    for i, b in enumerate(bars):
        v = fab_pct[i, j]
        txt = f"{v:.2f}%"
        ax.text(
            b.get_x() + b.get_width() / 2,
            b.get_height() + 1.0,
            txt,
            ha="center", va="bottom",
            fontsize=8, color="#333",
        )

ax.set_xticks(x)
TIER_DESC = {
    "F2": "frontier-small",
    "M1": "mid-tier code-tuned",
    "M2": "mid-tier reasoning",
}
ax.set_xticklabels([
    f"{m}\n({TIER_DESC[m]})\nn={n_cells[i, 0]}"
    for i, m in enumerate(models)
])
ax.set_ylabel("Fabrication rate (%)", fontsize=10)
ax.set_ylim(0, 75)
ax.yaxis.set_major_locator(plt.MultipleLocator(10))
ax.grid(axis="y", linestyle=":", alpha=0.4, zorder=0)
ax.set_axisbelow(True)

# Title (plain text, no LaTeX commands matplotlib can't render)
ax.set_title(
    "Behavioral fork on the 3,150-cell scaled corpus:\n"
    "the floor cuts fabrication 22-65x on the same paired inputs",
    fontsize=10, pad=10,
)

# Legend ABOVE the bars, OUTSIDE the data area, in a single row
ax.legend(
    loc="upper center",
    bbox_to_anchor=(0.5, -0.30),  # below plot
    ncol=3,
    frameon=False,
    fontsize=8.5,
    handlelength=1.3,
    columnspacing=1.5,
    handletextpad=0.5,
)

# Centered annotation in empty M1/M2 area: explains the contrast and labels
# the aggregate paired difference (NOT a per-tier number — that would be larger).
# Δ info moved to LaTeX figure caption -- keep figure visually clean

plt.tight_layout()
out = os.path.join(HERE, "figs", "fig1_behavioral_fork.pdf")
os.makedirs(os.path.dirname(out), exist_ok=True)
plt.savefig(out, bbox_inches="tight", pad_inches=0.05)
plt.savefig(out.replace(".pdf", ".png"), dpi=150, bbox_inches="tight")
print(f"\nwrote {out}")
print(f"      {out.replace('.pdf', '.png')}")
