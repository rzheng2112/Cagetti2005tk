#!/usr/bin/env bash
# reproduce_min.sh - Minimal reproduction for the Cagetti2005tk REMARK.
#
# Supported minimal reproduction path:
#   1. Bootstrap a local Python environment from pyproject.toml / uv.lock
#      (activates .venv if present; otherwise runs `uv sync --frozen`).
#   2. Execute the theory-model notebook
#        Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
#      which solves the Cagetti & De Nardi (2006) household Bellman
#      system (eqs. 2-14) at the paper's calibrated parameters and a
#      fixed price environment, using the SolvingMicroDSOPs stage
#      package vendored under Code/Python/.
#   3. Run scripts/check_reproduction.py to assert a small set of
#      numerical targets on the persisted summary table, so a silent
#      regression fails the pipeline.
#
# This script does NOT run the HAFiscal-inherited --comp pipelines;
# those are not Cagetti reproductions. For the main LaTeX document
# (Cagetti2005tk.tex), use `./reproduce.sh --docs main`.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

NOTEBOOK="Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb"
CODE_PY="Code/Python"
CHECK_SCRIPT="scripts/check_reproduction.py"

echo "================================================================="
echo "Cagetti2005tk minimal reproduction"
echo "================================================================="
echo ""
echo "Paper: Cagetti, M. and De Nardi, M. (2006),"
echo "       \"Entrepreneurship, Frictions, and Wealth,\""
echo "       Journal of Political Economy, 114(5), 835-870."
echo "       DOI: 10.1086/508032"
echo ""
echo "Artifact: $NOTEBOOK"
echo "Expected runtime: ~8-12 minutes on a recent laptop (VFI converges ~115 sweeps;"
echo "  most wall time is the young-only mu kernel + counterfactual notebook cells)."
echo "Persisted outputs: Figures/Cagetti2005tk/, Tables/Cagetti2005tk/"
echo ""
echo "For the LaTeX write-up, run: ./reproduce.sh --docs main"
echo "================================================================="
echo ""

if [[ ! -f "$NOTEBOOK" ]]; then
    echo "ERROR: Theory-reproduction notebook not found:"
    echo "       $NOTEBOOK"
    echo "Please run this script from the repository root."
    exit 1
fi

if [[ ! -f "$CODE_PY/solution.py" || ! -f "$CODE_PY/stages/cons_noshocks.py" ]]; then
    echo "ERROR: Required Python modules are missing."
    echo ""
    echo "The theory-reproduction notebook imports:"
    echo "    from solution import ModelParams, Stage"
    echo "    from stages.cons_noshocks import solve_cons_noshocks, build_a_grid"
    echo ""
    echo "and expects them to live under:"
    echo "    $CODE_PY/solution.py"
    echo "    $CODE_PY/stages/cons_noshocks.py"
    echo ""
    echo "These are the vendored SolvingMicroDSOPs stage modules. Refresh"
    echo "them by running: ./scripts/revendor_smd.sh"
    exit 2
fi

# --- Environment bootstrap -------------------------------------------------
# The REMARK standard expects `./reproduce_min.sh` to run from a clean
# clone on a reviewer's machine, so we must not assume `jupyter` is
# already on PATH. Preference order:
#   1. If a project-local .venv already exists, activate it.
#   2. Else, if `uv` is installed, sync the locked environment.
#   3. Else, fall back to any `jupyter` already on PATH and tell the
#      user what they need to install if there is none.
if ! command -v jupyter >/dev/null 2>&1; then
    if [[ -f .venv/bin/activate ]]; then
        echo "Activating existing .venv ..."
        # shellcheck disable=SC1091
        source .venv/bin/activate
    elif command -v uv >/dev/null 2>&1; then
        echo "No .venv found; running 'uv sync --frozen' to bootstrap ..."
        uv sync --frozen
        # shellcheck disable=SC1091
        source .venv/bin/activate
    fi
fi

if ! command -v jupyter >/dev/null 2>&1; then
    echo "ERROR: 'jupyter' is not on PATH and could not be bootstrapped."
    echo "Install 'uv' (https://docs.astral.sh/uv/) and re-run this script,"
    echo "or manually create the environment:"
    echo "    uv sync && source .venv/bin/activate"
    echo "or:"
    echo "    conda env create -f environment.yml && conda activate cagetti2005tk"
    exit 3
fi

echo "Executing notebook in place (this does not modify your source cells;"
echo "it only refreshes cached outputs)..."
echo ""
# Pin REPO_ROOT discovery for the notebook (cell 4 honors this env var as
# the highest-priority source of truth, instead of walking Path.cwd().parents).
export CAGETTI_REPO_ROOT="$REPO_ROOT"
# Per-cell timeout: 600s (10 minutes). The slowest cell on a recent laptop
# is the comparative-statics sweep (~5 minutes); 600s is comfortably above
# that while still failing loudly if a cell hangs (e.g. a regression that
# turns the Jacobi VFI into an infinite loop). The previous 1800s setting
# masked precisely the kind of regression the post-run check is meant to
# catch.
jupyter nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=600 \
    "$NOTEBOOK"

echo ""
echo "-----------------------------------------------------------------"
echo "Running numerical-target checks ..."
echo "-----------------------------------------------------------------"
if [[ -f "$CHECK_SCRIPT" ]]; then
    python3 "$CHECK_SCRIPT"
else
    echo "WARN: $CHECK_SCRIPT not found; skipping post-run assertions."
fi

echo ""
echo "================================================================="
echo "Minimal reproduction complete."
echo "================================================================="
echo "Refreshed: $NOTEBOOK"
echo ""
echo "Next steps:"
echo "  - Inspect the persisted artifacts:"
echo "      Figures/Cagetti2005tk/   (PDF + PNG plots)"
echo "      Tables/Cagetti2005tk/    (summary.csv, counterfactuals.csv, ...)"
echo "  - Open the notebook in Jupyter to explore value functions,"
echo "    occupational branches, and the entrepreneur-share comparison."
echo "  - Build the main document: ./reproduce.sh --docs main"
