#!/usr/bin/env bash
# reproduce_min.sh - Minimal reproduction for the Cagetti2005tk REMARK.
#
# Supported minimal reproduction path:
#   Execute the theory-model notebook
#     Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
#   which solves the Cagetti & De Nardi (2006) household Bellman system
#   (eqs. 2-14) at the paper's calibrated parameters and a fixed price
#   environment, using the SolvingMicroDSOPs stage package that lives
#   under Code/Python/.
#
# This script does NOT run the HAFiscal-inherited --comp pipelines;
# those are not Cagetti reproductions. For the main LaTeX document
# (Cagetti2005tk.tex), use `./reproduce.sh --docs main`.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

NOTEBOOK="Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb"
CODE_PY="Code/Python"

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
echo "Expected runtime: ~90 seconds on a recent laptop."
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
    echo "These are the SolvingMicroDSOPs stage modules. Restore them"
    echo "(e.g. by checking out the SolvingMicroDSOPs source into"
    echo "\"$CODE_PY\") before re-running this script."
    exit 2
fi

if ! command -v jupyter >/dev/null 2>&1; then
    echo "ERROR: 'jupyter' is not on PATH."
    echo "Activate the project environment first (see README.md), e.g.:"
    echo "    uv sync && source .venv/bin/activate"
    echo "or:"
    echo "    conda env create -f environment.yml && conda activate hafiscal"
    exit 3
fi

echo "Executing notebook in place (this does not modify your source cells;"
echo "it only refreshes cached outputs)..."
echo ""
jupyter nbconvert \
    --to notebook \
    --execute \
    --inplace \
    --ExecutePreprocessor.timeout=600 \
    "$NOTEBOOK"

echo ""
echo "================================================================="
echo "Minimal reproduction complete."
echo "================================================================="
echo "Refreshed: $NOTEBOOK"
echo ""
echo "Next steps:"
echo "  - Open the notebook in Jupyter to inspect solved value functions,"
echo "    occupational branches, and the entrepreneur-share comparison."
echo "  - Build the main document: ./reproduce.sh --docs main"
