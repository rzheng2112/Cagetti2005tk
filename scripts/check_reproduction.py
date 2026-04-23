#!/usr/bin/env python3
"""Post-run verification for the Cagetti2005tk minimal reproduction.

Invoked by ``reproduce_min.sh`` after the theory-reproduction notebook has
been executed. The notebook persists summary scalars to
``Tables/Cagetti2005tk/summary.csv``; this script reads that file and
asserts a small set of numerical targets so that a silent regression in
the reproduction fails the pipeline.

The targets are deliberately loose. They are not a claim that the
reproduction exactly matches the paper (the partial-equilibrium,
young-only-kernel caveats are documented in ``REMARK.md``). They only
guard against the reproduction producing obviously-wrong values, which
is what a REMARK reviewer cares about when running ``cli.py execute``.

Exit codes:
  0  all checks passed
  1  one or more checks failed
  2  summary.csv not found (notebook did not run or did not persist)
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
SUMMARY_CSV = REPO_ROOT / "Tables" / "Cagetti2005tk" / "summary.csv"

# metric -> (lower, upper, note) or (expected_bool, note) for boolean rows
TARGETS = {
    "ent_share_mu_young_only": (
        0.02, 0.15,
        "Young-only entrepreneur share; paper Table 6 baseline = 0.075. "
        "A wide band is intentional: this is a partial-equilibrium "
        "young-only kernel, not the paper's full stationary distribution.",
    ),
    "E_y_under_mu": (
        0.90, 1.10,
        "Invariant E[y] should be ~1 by Appendix-A normalization.",
    ),
    "converged": (
        True,
        "VFI sup-norm must fall below the SolverSettings.tol threshold.",
    ),
}


def _load_summary(path: Path) -> dict[str, str]:
    rows: dict[str, str] = {}
    with path.open() as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            metric = row.get("metric", "").strip()
            value = row.get("value", "").strip()
            if metric:
                rows[metric] = value
    return rows


def _check_float(metric: str, value_str: str, lo: float, hi: float, note: str) -> bool:
    try:
        value = float(value_str)
    except ValueError:
        print(f"  FAIL {metric}: could not parse '{value_str}' as float")
        return False
    ok = lo <= value <= hi
    status = "PASS" if ok else "FAIL"
    print(f"  {status} {metric} = {value:.6f} (expected {lo} <= value <= {hi})")
    if not ok:
        print(f"       note: {note}")
    return ok


def _check_bool(metric: str, value_str: str, expected: bool, note: str) -> bool:
    truthy = value_str.strip().lower() in {"true", "1", "yes"}
    ok = truthy is expected
    status = "PASS" if ok else "FAIL"
    print(f"  {status} {metric} = {value_str} (expected {expected})")
    if not ok:
        print(f"       note: {note}")
    return ok


def main() -> int:
    print("Cagetti2005tk reproduction check")
    print(f"  summary file: {SUMMARY_CSV}")
    if not SUMMARY_CSV.is_file():
        print("  ERROR: summary.csv not found. Did the notebook run to completion?")
        return 2

    rows = _load_summary(SUMMARY_CSV)
    all_ok = True
    for metric, spec in TARGETS.items():
        if metric not in rows:
            print(f"  FAIL {metric}: missing from summary.csv")
            all_ok = False
            continue
        if isinstance(spec[0], bool):
            expected, note = spec
            if not _check_bool(metric, rows[metric], expected, note):
                all_ok = False
        else:
            lo, hi, note = spec
            if not _check_float(metric, rows[metric], lo, hi, note):
                all_ok = False

    if all_ok:
        print("All reproduction checks passed.")
        return 0
    print("Reproduction check FAILED. See messages above.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
