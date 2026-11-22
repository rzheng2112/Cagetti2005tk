#!/usr/bin/env bash
# reproduce_min.sh - Minimal reproduction for the Cagetti2005tk REMARK.
#
# Supported minimal reproduction path:
#   1. Bootstrap a local Python environment from pyproject.toml / uv.lock
#      (runs `uv sync --locked --group jupyter`).
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

# Install the computational dependencies recorded in uv.lock.
command -v uv >/dev/null || { echo "ERROR: Install uv before reproducing." >&2; exit 3; }
[[ -f "$CHECK_SCRIPT" ]] || { echo "ERROR: Missing $CHECK_SCRIPT" >&2; exit 2; }
mkdir -p .reproduction
echo "Execution log: $REPO_ROOT/.reproduction/run.log"
exec > .reproduction/run.log 2>&1
uv sync --locked --group jupyter
PYTHON="$(uv run --no-sync python -c 'import sys; print(sys.executable)')"
export CAGETTI_REPO_ROOT="$REPO_ROOT"
export MPLBACKEND=Agg
# An isolated kernelspec prevents a user-installed python3 kernel taking precedence.
KERNEL_DIR="$(mktemp -d)"
trap 'rm -rf "$KERNEL_DIR"' EXIT
"$PYTHON" -m ipykernel install --prefix "$KERNEL_DIR" --name cagetti-locked
export JUPYTER_PATH="$KERNEL_DIR/share/jupyter${JUPYTER_PATH:+:$JUPYTER_PATH}"
"$PYTHON" - "$KERNEL_DIR" <<'PYTHON_CHECK'
import json, pathlib, sys
spec = json.loads((pathlib.Path(sys.argv[1]) / "share/jupyter/kernels/cagetti-locked/kernel.json").read_text())
assert pathlib.Path(spec["argv"][0]).resolve() == pathlib.Path(sys.executable).resolve()
print("Notebook kernel interpreter:", sys.executable)
PYTHON_CHECK
# Remove only outputs with verified generators. Historical Lorenz artifacts remain.
"$PYTHON" "$CHECK_SCRIPT" --clean
# The sweep took 394 seconds locally. Allow 3x that time on hosted runners.
"$PYTHON" -m nbconvert --to notebook --execute \
    --output-dir .reproduction --output executed.ipynb \
    --ExecutePreprocessor.kernel_name=cagetti-locked \
    --ExecutePreprocessor.timeout=1200 "$NOTEBOOK"
"$PYTHON" "$CHECK_SCRIPT"
echo "Reproduction complete. Logs and executed notebook: .reproduction/"
