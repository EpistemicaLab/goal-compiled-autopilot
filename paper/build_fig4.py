#!/usr/bin/env python3
"""Figure 4 -- Audit ablation on Autopilot x W1 (development corpus, 7 trap tasks).

Visualizes the static + LLM-judge defense in action: 3 raw FAB cases
caught (TP=3/3), at the cost of 2 over-conservative stalls (FP=2/2).

Output: paper/figs/fig4_audit_ablation.pdf
"""
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))

# Data from Appendix A.1 (Table 6 in current PDF) -- Autopilot x W1 x 7 tasks
# Each entry: (TRUE_SUCCESS, UNDERCLAIM, HONEST_STALL, FABRICATION)
configs = [
    ("No audit\n(raw Autopilot)",        2, 0, 2, 3),
    ("+ Static A3 audit\n(model-free)",  0, 0, 7, 0),
    ("+ LLM-judge audit\n(semantic)",    0, 0, 7, 0),
]

verdicts = ["TRUE_SUCCESS", "UNDERCLAIM", "HONEST_STALL", "FABRICATION"]
colors = ["#5A8F47", "#9DB7C9", "#CFCCC9", "#C84630"]
labels = [
    "TRUE_SUCCESS",
    "UNDERCLAIM",
    "HONEST_STALL",
    "FABRICATION",
]

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

fig, ax = plt.subplots(figsize=(6.5, 2.8))
fig.subplots_adjust(top=0.85, bottom=0.30)

n_per_row = 7  # tasks per row
y_pos = np.arange(len(configs))
y_labels = [c[0] for c in configs]

# Stack horizontally (counts, not percentages -- n=7 is small enough that counts read better)
left = np.zeros(len(configs))
counts_mat = np.array([list(c[1:]) for c in configs])  # shape (3, 4)

for j, v in enumerate(verdicts):
    bars = ax.barh(
        y_pos, counts_mat[:, j], left=left,
        color=colors[j], label=labels[j],
        edgecolor="white", linewidth=0.5, height=0.55,
    )
    for i, b in enumerate(bars):
        w = b.get_width()
        if w >= 1:
            x_center = b.get_x() + w / 2
            y_center = b.get_y() + b.get_height() / 2
            txt_color = "white" if v in ["TRUE_SUCCESS", "FABRICATION"] else "#333"
            label_text = f"{int(w)}"
            ax.text(
                x_center, y_center,
                label_text,
                ha="center", va="center",
                fontsize=10, color=txt_color,
                fontweight="bold" if v == "FABRICATION" else "normal",
            )
    left += counts_mat[:, j]

ax.set_yticks(y_pos)
ax.set_yticklabels(y_labels)
ax.invert_yaxis()
ax.set_xlim(0, n_per_row + 0.3)
ax.set_xlabel(f"Tasks (n={n_per_row} per row)", fontsize=10)
ax.set_xticks(np.arange(0, n_per_row + 1))

# Title
ax.set_title(
    "Audit ablation on Autopilot $\\times$ W1 (the only column with raw fabrications): \n"
    "static audit catches 3/3 fab cases at the cost of 2 over-conservative stalls",
    fontsize=10, pad=12,
)

# Legend below
ax.legend(
    loc="upper center",
    bbox_to_anchor=(0.5, -0.32),
    ncol=4,
    frameon=False,
    fontsize=8.5,
    handlelength=1.2,
    columnspacing=1.2,
    handletextpad=0.4,
)

# Inline catch annotation: arrow from no-audit FAB to static-audit STALL
ax.annotate(
    "",
    xy=(6, 1),                    # static-audit row, near the right edge
    xytext=(6, 0),                # no-audit row, near the right edge
    arrowprops=dict(arrowstyle="->", color="#666", lw=0.8,
                    connectionstyle="arc3,rad=0.3"),
)
ax.text(
    7.0, 0.5,
    "3 FAB caught\n(all 3 A3\nplan defects)",
    ha="left", va="center",
    fontsize=8, color="#222",
)

out = os.path.join(HERE, "figs", "fig4_audit_ablation.pdf")
os.makedirs(os.path.dirname(out), exist_ok=True)
plt.savefig(out, bbox_inches="tight", pad_inches=0.05)
plt.savefig(out.replace(".pdf", ".png"), dpi=150, bbox_inches="tight")
print(f"wrote {out}")
print(f"      {out.replace('.pdf', '.png')}")
