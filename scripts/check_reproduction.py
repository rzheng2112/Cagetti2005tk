#!/usr/bin/env python3
"""Check the generated tables and figures. Exit 0 on success, 1 on a failed
check, or 2 on a missing or empty output.
"""
from __future__ import annotations

import csv
import math
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
SUMMARY_CSV = REPO_ROOT / "Tables" / "Cagetti2005tk" / "summary.csv"
WEALTH_CSV = REPO_ROOT / "Tables" / "Cagetti2005tk" / "wealth_concentration.csv"
COUNTERFACTUALS_CSV = REPO_ROOT / "Tables" / "Cagetti2005tk" / "counterfactuals.csv"

# Only these files have verified generators in the supported notebook.
REQUIRED_OUTPUTS = [
    *(REPO_ROOT / "Tables/Cagetti2005tk" / name for name in
      ("summary.csv", "counterfactuals.csv", "wealth_concentration.csv")),
    *(REPO_ROOT / "Figures/Cagetti2005tk" / (name + suffix)
      for name in ("convergence", "values_policies_kstar", "mu_marginal_assets")
      for suffix in (".pdf", ".png")),
]

# metric -> (lower, upper, note) or (expected_bool, note) for boolean rows.
# Bands refer to the young-only reproduction baseline.
TARGETS = {
    "ent_share_mu_young_only": (
        0.05, 0.12,
        "Young-only entrepreneur share; paper Table 6 baseline = 0.075. "
        "Band is a PE / young-only diagnostic guard, not a paper match.",
    ),
    "mean_assets_mu": (
        3.80, 4.60,
        "Corrected post-EGM-fix mean assets ≈ 4.18. The pre-fix "
        "baseline ≈ 3.45 lies below this band.",
    ),
    "E_y_under_mu": (
        0.90, 1.10,
        "Invariant E[y] should be ~1 by Appendix-A normalization.",
    ),
    "final_sum_norm": (
        0.0, math.nextafter(5e-4, 0.0),
        "Baseline VFI residual at the SolverSettings.tol scale (~5e-4).",
    ),
    "converged": (
        True,
        "VFI sup-norm must fall below the SolverSettings.tol threshold.",
    ),
}

# Checked in wealth_concentration.csv (same float-band protocol).
WEALTH_TARGETS = {
    "top1": (0.14, 0.15, "Young-only top 1% wealth share."),
    "top5": (0.36, 0.38, "Young-only top 5% wealth share."),
    "gini": (
        0.64, 0.72,
        "Corrected young-only Gini ≈ 0.67. The pre-fix Gini ≈ 0.62 "
        "lies below this band. Not a formal bound on paper Table 6.",
    ),
}

# If a counterfactual row claims convergence, its residual must be small.
# Nonconvergence is allowed and is not treated as a success criterion.
VFI_TOL = 5.0e-4


def _load_metric_csv(path: Path, key_field: str = "metric") -> dict[str, str]:
    rows: dict[str, str] = {}
    with path.open() as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            key = row.get(key_field, "").strip()
            value = row.get("value", "").strip()
            if key:
                rows[key] = value
    return rows


def _check_float(metric: str, value_str: str, lo: float, hi: float, note: str) -> bool:
    try:
        value = float(value_str)
    except ValueError:
        print(f"  FAIL {metric}: could not parse '{value_str}' as float")
        return False
    ok = lo <= value <= hi
    status = "PASS" if ok else "FAIL"
    print(f"  {status} {metric} = {value:.6g} (expected {lo} <= value <= {hi})")
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


def _check_counterfactuals() -> bool:
    """Check counterfactual CSV consistency without rewarding nonconvergence.

    - The baseline row must exist and report converged=True.
    - Every row must have a parseable converged flag and sum_norm.
    - Rows marked converged=True must have a small residual (cannot label a
      large residual as a solution).
    - Rows marked converged=False are allowed diagnostics; they are counted
      but not required to stay nonconverged forever.
    """
    if not COUNTERFACTUALS_CSV.is_file():
        print("  FAIL counterfactuals.csv: missing")
        return False
    rows = list(csv.DictReader(COUNTERFACTUALS_CSV.open()))
    if not rows:
        print("  FAIL counterfactuals.csv: empty")
        return False

    ok = True
    n_false = 0
    baseline = next((r for r in rows if r.get("scenario", "").strip() == "baseline"), None)
    if baseline is None:
        print("  FAIL counterfactuals.csv: missing baseline row")
        ok = False
    else:
        flag = baseline.get("converged", "").strip()
        if flag.lower() not in {"true", "1", "yes"}:
            print(f"  FAIL counterfactual baseline: converged={flag} (expected True)")
            ok = False
        else:
            print("  PASS counterfactual baseline converged=True")

    for row in rows:
        name = row.get("scenario", "").strip() or "<unnamed>"
        flag = row.get("converged", "").strip()
        if flag.lower() not in {"true", "1", "yes", "false", "0", "no"}:
            print(f"  FAIL counterfactual '{name}': invalid converged={flag!r}")
            ok = False
            continue
        try:
            residual = float(row.get("sum_norm", ""))
        except ValueError:
            print(f"  FAIL counterfactual '{name}': could not parse sum_norm="
                  f"{row.get('sum_norm')!r}")
            ok = False
            continue
        if not math.isfinite(residual) or residual < 0:
            print(f"  FAIL counterfactual '{name}': invalid residual {residual}")
            ok = False
            continue
        truthy = flag.lower() in {"true", "1", "yes"}
        if truthy:
            if residual >= VFI_TOL:
                print(f"  FAIL counterfactual '{name}': converged=True but "
                      f"sum_norm={residual:.6g} >= {VFI_TOL:g} "
                      f"(large residual cannot be treated as a solution)")
                ok = False
            elif name != "baseline":
                print(f"  PASS counterfactual '{name}' converged with "
                      f"sum_norm={residual:.6g}")
        else:
            n_false += 1

    print(f"  INFO counterfactuals: {n_false} row(s) flagged converged=False "
          f"(diagnostics only; not required to remain nonconverged)")
    return ok


def main() -> int:
    if sys.argv[1:] == ["--clean"]:
        for path in REQUIRED_OUTPUTS:
            path.unlink(missing_ok=True)
        return 0
    missing = [str(path.relative_to(REPO_ROOT)) for path in REQUIRED_OUTPUTS
               if not path.is_file() or path.stat().st_size == 0]
    if missing:
        print("ERROR: Missing or empty generated outputs:", ", ".join(missing))
        return 2
    print("Cagetti2005tk reproduction check")
    print(f"  summary file: {SUMMARY_CSV}")
    if not SUMMARY_CSV.is_file():
        print("  ERROR: summary.csv not found. Did the notebook run to completion?")
        return 2

    rows = _load_metric_csv(SUMMARY_CSV)
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

    wealth = _load_metric_csv(WEALTH_CSV)
    print(f"  wealth file: {WEALTH_CSV}")
    for metric, spec in WEALTH_TARGETS.items():
        if metric not in wealth:
            print(f"  FAIL {metric}: missing from wealth_concentration.csv")
            all_ok = False
            continue
        lo, hi, note = spec
        if not _check_float(metric, wealth[metric], lo, hi, note):
            all_ok = False

    if not _check_counterfactuals():
        all_ok = False

    if all_ok:
        print("All reproduction checks passed.")
        return 0
    print("Reproduction check FAILED. See messages above.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
