#!/usr/bin/env bash
# revendor_smd.sh -- refresh the vendored SolvingMicroDSOPs stage code.
#
# The theory-reproduction notebook
#   Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
# imports `solution`, `resources`, and `stages.cons_noshocks` from
#   Code/Python/
# These files are vendored verbatim from the upstream SolvingMicroDSOPs
# repository (https://github.com/llorracc/SolvingMicroDSOPs) at a pinned
# commit. Vendoring is used instead of a pip install because the upstream
# project is a LaTeX-plus-code lecture-notes template rather than a
# pip-installable package.
#
# Running this script re-fetches the pinned files from GitHub so a
# reviewer can confirm byte-for-byte that our copy matches upstream.
# To bump the pinned revision, edit `SMD_REV` below, run this script,
# re-execute `./reproduce_min.sh`, and commit the diff.
#
# Usage:
#   ./scripts/revendor_smd.sh            # refresh at the pinned commit
#   SMD_REV=abcdef1 ./scripts/revendor_smd.sh   # override revision

set -euo pipefail

SMD_REPO="llorracc/SolvingMicroDSOPs"
SMD_REV="${SMD_REV:-03884752c372}"
DEST="Code/Python"

FILES=(
    "solution.py"
    "resources.py"
    "stages/__init__.py"
    "stages/cons_noshocks.py"
)

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p "$DEST/stages"

for rel in "${FILES[@]}"; do
    url="https://raw.githubusercontent.com/${SMD_REPO}/${SMD_REV}/Code/Python/${rel}"
    out="${DEST}/${rel}"
    echo "Fetching ${rel} @ ${SMD_REV}"
    curl -fsSL "$url" -o "${out}.tmp"
    # Prepend the vendor provenance header so a reader browsing the file
    # inside this repo can trace it back to the upstream commit.
    header="# Vendored verbatim from ${SMD_REPO}@${SMD_REV} Code/Python/${rel} (refetched via scripts/revendor_smd.sh); do not edit here \u2014 update upstream and re-vendor."
    printf "%b\n" "$header" > "$out"
    cat "${out}.tmp" >> "$out"
    rm -f "${out}.tmp"
done

echo "Revendoring complete. Inspect the diff with 'git diff -- Code/Python/' and re-run ./reproduce_min.sh to verify."
