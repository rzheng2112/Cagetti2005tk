# GitHub Actions Workflows

This directory contains the CI workflows for Cagetti2005tk.

## Workflows

### `reproduce-min.yml` -- minimal computational reproduction

**Purpose:** Verify on every push/PR that a clean clone can run
`./reproduce_min.sh` end-to-end (notebook execution +
`scripts/check_reproduction.py` numerical assertions) under the locked
Python environment.

**Triggers:** push to `main`, pull requests.

**What it tests:**

- `uv sync --frozen` succeeds against the committed `uv.lock`.
- `Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb`
  executes from a clean clone within the configured timeout.
- `scripts/check_reproduction.py` exits 0 (numerical bands on
  `Tables/Cagetti2005tk/summary.csv` are satisfied).

This is intentionally the *only* test workflow. It catches the failure
modes that block a REMARK catalog submission (env build, notebook
execution, post-run check) without trying to also test the LaTeX side,
which is run from a host TeX Live and is not part of the supported
minimal reproduction path.

### `deploy-gh-pages.yml` -- gh-pages deploy

Standard GitHub Pages deploy from the `gh-pages` branch. Project-agnostic
and does not exercise any reproduction logic.
