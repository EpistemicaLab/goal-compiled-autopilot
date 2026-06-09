# P1_7 Corpus — 3,150-cell paired evaluation

The full empirical evaluation backing §5 of the ICLR 2026 submission.

## Files

| File | Purpose |
|------|---------|
| `manifest.json` | All 3150 cells: SHA-1 cell_id keyed by (tasktype, taskname, system, model, seed) |
| `reports.jsonl` | One JSON object per cell with verdict, elapsed_sec, sys_status, oracle |
| `status.json` | Final driver state (cells_done, errors, finished) |
| `bootstrap.py` | Reproducible paired bootstrap (pure Python, no numpy dep) |
| `section5_draft.md` | Markdown draft of §5 results integrated into the paper |

## Reproducing the headline

```bash
python3 bootstrap.py 5000 42  # B=5000 resamples, seed=42
```

Output: per-system fab rate with 95% CI, paired difference (autopilot - baseline),
per-tasktype breakdown, per-model breakdown, autopilot solve rate per tasktype,
list of all 10 autopilot fabrications.

## Corpus dimensions

```
70 tasks (20 trap + 50 SWE-bench Lite)
  × 3 systems (autopilot, reflexion, stateflow)
  × 3 models (claude-haiku-4.5, deepseek-3.2, qwen3-coder-next)
  × 5 seeds
= 3150 cells
```

Per-cell timeout: 600 s. Concurrency: 4. Audit mode: `ensemble` (static then LLM).
Driver: `bench/run_bench.sh` via JSON-manifest indexed driver. Wall time: 11h32m
on a single laptop. Errors: 0.

## Headline (paired bootstrap, B=5000, seed=42, n=1050 paired triples)

| System    | fab rate | 95% bootstrap CI |
|-----------|---------:|-----------------:|
| autopilot |   0.95%  | [0.38%, 1.62%]   |
| reflexion | 100.00%  | [100.00%, 100.00%] |
| stateflow | 100.00%  | [100.00%, 100.00%] |

Paired Δ(autopilot − baseline) = −99.05 pp [−99.62, −98.38].

## Note on raw run/ artifacts

The full per-cell `runs/*/report.json` + `run.log` + `work/` directories total ~78GB
(SWE-bench clones bloat the work dirs). They live outside this repo at:

  /home/dyouwang/.meshclaw/workspace/goal-autopilot-paper-v2/artifacts/p1_corpus/runs/

`reports.jsonl` is a strict subset suitable for re-analysis without the bulk.
