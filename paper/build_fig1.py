#!/usr/bin/env python3
"""Generate Figure 1 for the goal-autopilot ICLR submission.

Side-by-side panels:
  (a) No auditor (baseline)        — autopilot × {5 cells} × 7 tasks
  (b) Production-config audit on   — same 5 cells, audit ensemble enabled

Stacked bars, one bar per cell, segments = {TRUE_SUCCESS, UNDERCLAIM,
HONEST_STALL, FABRICATION}. The visual point: in (a) only the agi-nova
cell shows a red FABRICATION segment; in (b) that segment vanishes
across all cells.

Output:
    paper/fig1_fabrication.pdf  (vector, embedded by LaTeX)
    paper/fig1_fabrication.png  (raster preview for Showcase)

Run from repo root:
    python paper/build_fig1.py
"""
import json
import pathlib
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

REPO = pathlib.Path(__file__).resolve().parent.parent
BENCH = REPO / "bench"
OUT_PDF = REPO / "paper" / "fig1_fabrication.pdf"
OUT_PNG = REPO / "paper" / "fig1_fabrication.png"

CELLS = [
    ("opus-4.7", "Opus-4.7"),
    ("haiku-4.5", "Haiku-4.5"),
    ("qwen3-coder-next", "Qwen3-coder"),
    ("deepseek-3.2", "DeepSeek-3.2"),
    ("agi-nova-beta-1m", "Agi-nova-1m"),
]

# Verdict colors — colorblind-safe: blue / orange / grey / red
COLORS = {
    "TRUE":   "#1f77b4",  # blue: actual success
    "UND":    "#ff7f0e",  # orange: underclaim (oracle pass, no DONE)
    "STALL":  "#7f7f7f",  # grey: honest stall
    "FAB":    "#d62728",  # red: real fabrication
}
ORDER = ["TRUE", "UND", "STALL", "FAB"]
LABEL = {
    "TRUE":  "TRUE_SUCCESS",
    "UND":   "UNDERCLAIM",
    "STALL": "HONEST_STALL",
    "FAB":   "FABRICATION",
}


def counts_for_report(report_path: pathlib.Path) -> dict[str, int]:
    """Read a bench/report*.json and return {TRUE, UND, STALL, FAB} counts."""
    data = json.loads(report_path.read_text())
    out = {k: 0 for k in ORDER}
    for t in data["tasks"]:
        v = t["verdict"]
        if v == "TRUE_SUCCESS":
            out["TRUE"] += 1
        elif v == "UNDERCLAIM":
            out["UND"] += 1
        elif v == "HONEST_STALL":
            out["STALL"] += 1
        elif v == "FABRICATION":
            out["FAB"] += 1
    return out


def baseline_report(model_slug: str) -> pathlib.Path:
    """Pre-audit baseline lives at bench/report-autopilot-{timestamp}-{model}.json
    OR the legacy locations from §5.4. Hard-code the known paths.
    """
    # Map cell to its no-audit baseline report
    mapping = {
        "opus-4.7":          BENCH / "report-autopilot-opus-4.7.json",
        "haiku-4.5":         BENCH / "report-autopilot-haiku-4.5.json",
        "deepseek-3.2":      BENCH / "report-autopilot-deepseek-3.2.json",
        "qwen3-coder-next":  BENCH / "report-autopilot-qwen3-coder-next.json",
        "agi-nova-beta-1m":  BENCH / "report-autopilot-agi-nova-beta-1m.json",
    }
    return mapping[model_slug]


def production_report(model_slug: str) -> pathlib.Path:
    return BENCH / f"report.prod-autopilot-{model_slug}.json"


def stacked_bar(ax, data: list[dict], xlabels: list[str], title: str):
    """data[i] = {TRUE,UND,STALL,FAB} for cell i."""
    x = list(range(len(data)))
    bottom = [0] * len(data)
    for k in ORDER:
        heights = [d[k] for d in data]
        ax.bar(x, heights, bottom=bottom, color=COLORS[k], label=LABEL[k],
               edgecolor="white", linewidth=0.5)
        # annotate FAB count above its segment if non-zero
        if k == "FAB":
            for i, h in enumerate(heights):
                if h > 0:
                    ax.text(i, bottom[i] + h + 0.15, str(h),
                            ha="center", va="bottom",
                            color=COLORS["FAB"], fontweight="bold", fontsize=9)
        bottom = [b + h for b, h in zip(bottom, heights)]
    ax.set_xticks(x)
    ax.set_xticklabels(xlabels, rotation=20, ha="right", fontsize=9)
    ax.set_ylim(0, 8.5)
    ax.set_ylabel("# tasks (n=7 per cell)", fontsize=9)
    ax.set_title(title, fontsize=10, pad=8)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_axisbelow(True)
    ax.yaxis.grid(True, color="#cccccc", linewidth=0.5)


def main():
    # Try to find baseline reports; fall back to known §5.4 numbers if missing
    KNOWN_BASELINE = {
        "opus-4.7":         {"TRUE": 7, "UND": 0, "STALL": 0, "FAB": 0},
        "haiku-4.5":        {"TRUE": 7, "UND": 0, "STALL": 0, "FAB": 0},
        "deepseek-3.2":     {"TRUE": 0, "UND": 3, "STALL": 4, "FAB": 0},
        "qwen3-coder-next": {"TRUE": 4, "UND": 2, "STALL": 1, "FAB": 0},
        "agi-nova-beta-1m": {"TRUE": 2, "UND": 0, "STALL": 2, "FAB": 3},
    }

    baseline_data = []
    production_data = []
    xlabels = []
    for slug, label in CELLS:
        # Baseline
        bp = baseline_report(slug)
        if bp.exists():
            baseline_data.append(counts_for_report(bp))
        else:
            baseline_data.append(KNOWN_BASELINE[slug])
        # Production
        pp = production_report(slug)
        if not pp.exists():
            raise SystemExit(f"missing prod report: {pp}")
        production_data.append(counts_for_report(pp))
        xlabels.append(label)

    fig, axes = plt.subplots(1, 2, figsize=(7.0, 3.0), sharey=True)
    stacked_bar(axes[0], baseline_data, xlabels,
                "(a) No auditor (baseline)")
    stacked_bar(axes[1], production_data, xlabels,
                "(b) Production-config (ensemble auditor on)")
    # Single legend below
    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower center", ncol=4,
               frameon=False, fontsize=8.5,
               bbox_to_anchor=(0.5, -0.02))
    fig.tight_layout(rect=[0, 0.06, 1, 1])
    fig.savefig(OUT_PDF, bbox_inches="tight")
    fig.savefig(OUT_PNG, bbox_inches="tight", dpi=150)
    print(f"wrote {OUT_PDF.relative_to(REPO)}")
    print(f"wrote {OUT_PNG.relative_to(REPO)}")
    print()
    print("baseline totals:")
    for s, d in zip(xlabels, baseline_data):
        print(f"  {s:14s}  T={d['TRUE']} U={d['UND']} H={d['STALL']} F={d['FAB']}")
    print("production totals:")
    for s, d in zip(xlabels, production_data):
        print(f"  {s:14s}  T={d['TRUE']} U={d['UND']} H={d['STALL']} F={d['FAB']}")


if __name__ == "__main__":
    main()
