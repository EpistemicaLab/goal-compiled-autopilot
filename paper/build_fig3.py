#!/usr/bin/env python3
"""Figure 3 -- Verdict mix per system: where do agent exits actually go?

Visualizes Corollary 1 (safe-side asymmetry).
"""
import glob
import json
import os
from collections import Counter, defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
RERUN_DIR = "/home/dyouwang/.meshclaw/workspace/goal-autopilot-paper-v2/artifacts/p1_corpus/runs"

cells = []
for p in sorted(glob.glob(f"{RERUN_DIR}/*/report.json")):
    try:
        cells.append(json.load(open(p)))
    except Exception:
        continue
print(f"loaded {len(cells)} cells")

verdict_by_sys = defaultdict(Counter)
for c in cells:
    verdict_by_sys[c["system"]][c["verdict"]] += 1

systems = ["autopilot", "reflexion", "stateflow"]
verdicts = ["TRUE_SUCCESS", "UNDERCLAIM", "HONEST_STALL", "FABRICATION"]

mat = np.zeros((len(systems), len(verdicts)))
totals = []
for i, s in enumerate(systems):
    total = sum(verdict_by_sys[s].values())
    totals.append(total)
    for j, v in enumerate(verdicts):
        mat[i, j] = 100.0 * verdict_by_sys[s].get(v, 0) / total

# ---- Plot ----
plt.rcParams.update({
    "font.family": "serif",
    "font.size": 10,
    "axes.labelsize": 10,
    "axes.titlesize": 10,
    "legend.fontsize": 8.5,
    "xtick.labelsize": 9,
    "ytick.labelsize": 10,
    "axes.spines.top": False,
    "axes.spines.right": False,
})

fig, ax = plt.subplots(figsize=(7.0, 2.4))
# Explicit top/bottom margins to give room for title (top) and legend (bottom)
fig.subplots_adjust(top=0.85, bottom=0.30)

colors = ["#5A8F47", "#9DB7C9", "#CFCCC9", "#C84630"]
labels = [
    "TRUE_SUCCESS (honest win)",
    "UNDERCLAIM (honest near-win)",
    "HONEST_STALL (honest no-win)",
    "FABRICATION (the failure mode)",
]

y_pos = np.arange(len(systems))
display_names = {
    "autopilot":  "Autopilot\n(ours, with floor)",
    "reflexion":  "Reflexion\n(reflective-loop)",
    "stateflow":  "StateFlow\n(FSM, no floor)",
}
y_labels = [display_names[s] for s in systems]

left = np.zeros(len(systems))
for j, v in enumerate(verdicts):
    bars = ax.barh(
        y_pos, mat[:, j], left=left,
        color=colors[j], label=labels[j],
        edgecolor="white", linewidth=0.5, height=0.55,
    )
    for i, b in enumerate(bars):
        w = b.get_width()
        if w >= 4.0:
            x_center = b.get_x() + w / 2
            y_center = b.get_y() + b.get_height() / 2
            txt_color = "white" if v in ["TRUE_SUCCESS", "FABRICATION"] else "#333"
            ax.text(
                x_center, y_center,
                f"{w:.1f}%",
                ha="center", va="center",
                fontsize=8, color=txt_color,
                fontweight="bold" if v == "FABRICATION" else "normal",
            )
        elif w > 0:
            ax.text(
                b.get_x() + w + 0.5, b.get_y() + b.get_height() / 2,
                f"{w:.2f}%",
                ha="left", va="center",
                fontsize=7.5, color="#222",
            )
    left += mat[:, j]

ax.set_yticks(y_pos)
ax.set_yticklabels(y_labels)
ax.invert_yaxis()
ax.set_xlim(0, 102)
ax.set_xlabel("Share of paired-input outcomes (%)", fontsize=10)
ax.xaxis.set_major_locator(plt.MultipleLocator(20))

# Title at the top of the figure (above axes), single line
ax.set_title(
    "Where do agent exits go? (1,050 paired inputs per system, 3,150 cells total)",
    fontsize=10, pad=10,
)

# Legend BELOW the plot (standard placement, no overlap risk)
ax.legend(
    loc="upper center",
    bbox_to_anchor=(0.5, -0.28),
    ncol=2,
    frameon=False,
    fontsize=8.5,
    handlelength=1.3,
    columnspacing=1.5,
    handletextpad=0.5,
)

out = os.path.join(HERE, "figs", "fig3_verdict_mix.pdf")
os.makedirs(os.path.dirname(out), exist_ok=True)
plt.savefig(out, bbox_inches="tight", pad_inches=0.05)
plt.savefig(out.replace(".pdf", ".png"), dpi=150, bbox_inches="tight")
print(f"\nwrote {out}")
print(f"      {out.replace('.pdf', '.png')}")
