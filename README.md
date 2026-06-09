# Goal-Compiled Autopilot

A verifiable anti-fabrication firewall for unattended long-horizon LLM agents.

This repository accompanies the paper:

> **Goal-Autopilot: A Verifiable Anti-Fabrication Firewall for Unattended Long-Horizon Agents**
> Youwang Deng, *EpistemicaLab — Independent Research*, 2026.
> [arXiv preprint] (link added after submission)

## What's inside

```
paper/    LaTeX source, compiled PDF, ICLR style files, and figures.
          See paper/submission.pdf for the latest compiled version.

bench/    Full reproducer code:
            run_bench.sh         driver script (Autopilot vs Reflexion vs StateFlow)
            tasks/               20 trap tasks
            swebench_tasks/      50 SWE-bench Lite tasks across 11 OSS repos
            baselines/           Reflexion + StateFlow harnesses
            p1_corpus/           per-cell artifact summaries (3,150 cells)
            rescore.sh           re-runs the audit ensemble on existing reports
            a3_audit.sh          static A3 plan-coverage auditor (60 lines)
            a3_audit_llm.sh      LLM-judge A3 auditor (67 lines)
```

The 11 GB raw per-cell run logs (`goals/`) are not included; only the
SHA-1-indexed summary manifest is shipped. Per-cell logs available on request.

## Reproducing the headline numbers

```bash
# Re-run the audit on existing per-cell reports:
bench/rescore.sh

# Re-bootstrap the headline 3,150-cell paired CIs:
python3 bench/scaled_corpus/bootstrap.py    # B=5000, seed=42, ~33 s on CPU
```

This recomputes Autopilot 0.95% [0.38--1.62] vs StateFlow 25.05% [22.48--27.62]
exactly, and the SWE-bench Lite paired difference of $-33.07$ pp.

## Re-running from scratch

The full re-run uses fresh LLM API calls (~600 GPU-hours plus ~$300 in closed-API
inference for the headline corpus). See `bench/README.md` for the full pipeline:
goal $\to$ goal compiler $\to$ FSM + auditor $\to$ stateless tick scheduler.

## Code license

Source under [MIT License](LICENSE). Paper text and figures under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Contact

`dengyouwang@gmail.com` &middot; [epistemicalab.github.io](https://epistemicalab.github.io/)
