#!/usr/bin/env python3
"""Paired bootstrap on the P1_7 corpus.

Reads runs/*/report.json. The independent unit is (tasktype, taskname, model, seed).
Each unit appears 3 times (one per system: autopilot/reflexion/stateflow). Pairing
across systems and resampling the unit gives a paired bootstrap CI on the system
contrast.

Usage: python3 bootstrap.py [B=5000] [seed=42]
Output: stdout text matching §5 draft.
"""
import json
import glob
import random
import sys
from collections import defaultdict

B = int(sys.argv[1]) if len(sys.argv) > 1 else 5000
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 42
SYSTEMS = ["autopilot", "reflexion", "stateflow"]


def fab(v): return 1 if v == "FABRICATION" else 0
def solve(v): return 1 if v == "TRUE_SUCCESS" else 0


def boot_quantile(values, lo=0.025, hi=0.975):
    s = sorted(values)
    n = len(s)
    return s[int(lo * n)], s[int(hi * n)]


def boot_rate(rows, system, predicate, B=B, seed=SEED):
    n = len(rows)
    rng = random.Random(seed)
    samples = []
    for _ in range(B):
        idx = [rng.randrange(n) for _ in range(n)]
        samples.append(sum(predicate(rows[i][system]) for i in idx) / n)
    point = sum(predicate(r[system]) for r in rows) / n
    return point, *boot_quantile(samples)


def boot_diff(rows, sys_a, sys_b, predicate, B=B, seed=SEED):
    n = len(rows)
    rng = random.Random(seed)
    samples = []
    for _ in range(B):
        idx = [rng.randrange(n) for _ in range(n)]
        a = sum(predicate(rows[i][sys_a]) for i in idx) / n
        b = sum(predicate(rows[i][sys_b]) for i in idx) / n
        samples.append(a - b)
    pa = sum(predicate(r[sys_a]) for r in rows) / n
    pb = sum(predicate(r[sys_b]) for r in rows) / n
    return pa - pb, *boot_quantile(samples)


def main():
    cells = []
    for p in glob.glob("runs/*/report.json"):
        try:
            cells.append(json.load(open(p)))
        except Exception:
            continue

    units = defaultdict(dict)
    for c in cells:
        key = (c["tasktype"], c["taskname"], c["model"], c["seed"])
        units[key][c["system"]] = c["verdict"]
    keys = sorted(units.keys())
    rows = [{s: units[k].get(s, "MISSING") for s in SYSTEMS} for k in keys]
    N = len(rows)

    print(f"# Paired bootstrap (B={B}, seed={SEED}, n_units={N})\n")
    print("## System fab rate (paired across (task, model, seed))")
    for s in SYSTEMS:
        p, lo, hi = boot_rate(rows, s, fab)
        print(f"  {s:<12} fab = {p*100:.2f}%  CI=[{lo*100:.2f}%, {hi*100:.2f}%]")

    print("\n## Paired difference (autopilot - baseline)")
    for s in SYSTEMS[1:]:
        d, lo, hi = boot_diff(rows, "autopilot", s, fab)
        print(f"  autopilot - {s:<10} = {d*100:.2f}pp  CI=[{lo*100:.2f}, {hi*100:.2f}]pp")

    print("\n## Per-tasktype paired CI")
    for tt in ["trap", "swe"]:
        sub = [r for k, r in zip(keys, rows) if k[0] == tt]
        print(f"\n### {tt} (n_units={len(sub)})")
        for s in SYSTEMS:
            p, lo, hi = boot_rate(sub, s, fab)
            print(f"  {s:<12} fab = {p*100:.2f}%  CI=[{lo*100:.2f}%, {hi*100:.2f}%]")
        for s in SYSTEMS[1:]:
            d, lo, hi = boot_diff(sub, "autopilot", s, fab)
            print(f"  autopilot - {s:<10} = {d*100:.2f}pp  CI=[{lo*100:.2f}, {hi*100:.2f}]pp")

    print("\n## Per-model fab rate")
    for model in sorted({k[2] for k in keys}):
        sub = [r for k, r in zip(keys, rows) if k[2] == model]
        for s in SYSTEMS:
            p, lo, hi = boot_rate(sub, s, fab)
            print(f"  {model:<22}{s:<12} {p*100:.2f}%  [{lo*100:.2f}, {hi*100:.2f}]%")

    print("\n## Autopilot solve rate per tasktype")
    for tt in ["trap", "swe"]:
        sub = [r for k, r in zip(keys, rows) if k[0] == tt]
        p, lo, hi = boot_rate(sub, "autopilot", solve)
        print(f"  {tt:<6} solve = {p*100:.2f}%  CI=[{lo*100:.2f}%, {hi*100:.2f}%]  n={len(sub)}")

    print("\n## All autopilot fabrications (task, model, seed)")
    for k, r in zip(keys, rows):
        if r["autopilot"] == "FABRICATION":
            tt, tn, m, sd = k
            print(f"  {tt}/{tn}/{m}/seed{sd}")


if __name__ == "__main__":
    main()
