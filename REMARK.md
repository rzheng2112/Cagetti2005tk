---
# REMARK-style metadata (Econ-ARK ecosystem). This does not assert
# official listing on econ-ark.org -- this is a REMARK-in-progress at
# the baseline (standard) tier.
tier: 2
github_repo_url: https://github.com/rzheng2112/Cagetti2005tk
remark-name: Cagetti2005tk
notebooks:
  # Primary reproduction artifact: theory-model reproduction
  # (Bellman system eqs. 2-14, calibrated parameters, fixed price
  # environment). Executed by ./reproduce_min.sh; also invoked from
  # bare ./reproduce.sh.
  - Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
  # Narrative companions to the paper (NOT reproduction artifacts):
  - Cagetti2005tk_material/Cagetti2005-tk_intro.ipynb
  - Cagetti2005tk_material/Cagetti2005-tk_prior-literature.ipynb
  - Cagetti2005tk_material/Cagetti2005-tk_summary.ipynb
  - Cagetti2005tk_material/Cagetti2005-tk_subsequent-literature.ipynb
  - Cagetti2005tk_material/Cagetti2005-tk_bellman-stages.ipynb
tags:
  - REMARK
  - Notebook
  - Reproduction
keywords:
  - Entrepreneurship
  - Wealth
  - Occupational choice
  - Heterogeneous agents
---

# Cagetti2005tk

This is a **REMARK-in-progress** (baseline / standard tier) that
partially reproduces the theoretical model of

> Cagetti, M. and De Nardi, M. (2006),
> *Entrepreneurship, Frictions, and Wealth*,
> **Journal of Political Economy**, 114(5), 835--870.
> [doi:10.1086/508032](https://doi.org/10.1086/508032)

## What a reviewer should read first

1. This file --- scope and expected outputs (below).
2. `README.md` --- one-command quick start.
3. `ARCHITECTURE.md` --- file-by-file map of the repository.
4. `Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb`
   --- the reproduction notebook itself, cell-level commentary.
5. `NOTICES.md` --- vendored code provenance (SolvingMicroDSOPs).

## How to reproduce

```bash
git clone https://github.com/rzheng2112/Cagetti2005tk.git
cd Cagetti2005tk
./reproduce.sh
```

Bare `./reproduce.sh` runs the minimal reproduction
(`./reproduce_min.sh`) and, if a TeX Live installation is present,
rebuilds `Cagetti2005tk.pdf` from the artifacts produced by the
notebook. The minimal reproduction alone takes roughly 8--12 minutes on
a recent laptop.

To run only the minimal reproduction:

```bash
./reproduce_min.sh
```

If `uv` (<https://docs.astral.sh/uv/>) is installed, `reproduce_min.sh`
will create `.venv` from the pinned `pyproject.toml` / `uv.lock` and
activate it automatically; otherwise activate an existing environment
beforehand.

## What IS reproduced

The notebook
`Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb` solves
the household-side partial-equilibrium Bellman system of the paper:

- **Occupational choice** between worker (status W) and entrepreneur
  (status E) for the "young" population, with endogenous bankruptcy
  and collateral enforcement (eq. 5).
- **Value functions** $V$ (young worker), $W$ (old retiree / old
  entrepreneur), and $W^r$ (continuation for old retirees), solved by
  damped Jacobi value-function iteration using the `SolvingMicroDSOPs`
  Endogenous-Grid-Method stage (`Code/Python/`).
- **Calibrated structural parameters** (Table 5 of the paper):
  $\beta = 0.865$, $\sigma = 1.5$, $\delta = 0.06$, $\nu = 0.88$,
  $f = 0.75$, $\pi_y = 0.978$, $\pi_o = 0.911$, $\eta = 1.0$.
- **Income process** from paper Appendix A (5-state discretization
  of the labour-productivity chain) and the entrepreneurial-ability
  process $\theta \in \{0, 0.514\}$ (Table 5).
- **Persisted artifacts** under `Figures/Cagetti2005tk/` and
  `Tables/Cagetti2005tk/`:
  - `values_policies_kstar.{pdf,png}` --- value functions and
    $k^\star(a, \theta)$ policy.
  - `convergence.{pdf,png}` --- VFI sup-norm history.
  - `mu_marginal_assets.{pdf,png}` --- stationary asset distribution.
  - `wealth_lorenz.{pdf,png}` + `wealth_moments.csv`.
  - `summary.csv` --- headline scalars checked by
    `scripts/check_reproduction.py`.
  - `counterfactuals.csv` --- $\eta = 0$ and $(\eta = 0, \beta =
    0.88)$ branches (Section V of the paper, informal).

## What IS NOT reproduced

This is a baseline-tier REMARK-in-progress and explicitly does not
claim to match the paper's full general-equilibrium stationary
distribution. The following simplifications are intentional and are
flagged in-notebook so a reviewer can assess exactly what has and
has not been done:

- **Partial equilibrium.** Prices $(r, w)$ are fixed to the paper's
  Table 7 baseline; the representative-firm capital-market clearing
  condition of Appendix B is not iterated. See the "Appendix-B
  derivation of fixed-price inputs" markdown cell in the notebook
  for the derivation that *would* close the loop.
- **Young-only stationary kernel.** `iterate_mu_young_kernel` carries
  mass over the $(\theta, y, a)$ grid with fixed survival probability
  $\pi_y$; it does not yet carry an explicit four-status dimension
  $s \in \{YW, YE, OE, OR\}$ with demographic replacement, estate-tax
  bequest transmission, or old-age asset run-down. Wealth
  concentration numbers reported in `wealth_concentration.csv` are
  therefore **lower bounds** on the paper's Table 6 values, and the
  entrepreneur-share target in `scripts/check_reproduction.py`
  uses a deliberately wide band.
- **Estate tax counterfactual.** `estate_tax` is declared in
  `PaperStructuralParams` but the young-only kernel cannot
  meaningfully simulate its effect; the Section V "20% estate tax"
  exercise is not reproduced.
- **Payroll balance.** $\tau = 0.10$ is set illustratively. The
  Appendix-B social-security budget
  $\tau \, w \, L = p \, N_{\text{retirees}}$ is not imposed as a
  fixed point; a reviewer can recompute the implied $\tau^\star$
  from `mu_star` once the full-demographic kernel is added.

## Numerical checks

After the notebook runs, `reproduce_min.sh` invokes
`scripts/check_reproduction.py`, which parses
`Tables/Cagetti2005tk/summary.csv` and asserts:

| metric                        | expected band           |
|-------------------------------|-------------------------|
| `ent_share_mu_young_only`     | $[0.02, 0.15]$          |
| `E_y_under_mu`                | $[0.90, 1.10]$          |
| `converged`                   | `True`                  |

The bands are intentionally wide --- they catch silent regressions
(e.g. accidentally disabling the occupational-choice branch) without
claiming an exact match to the paper.

## Code provenance

The three files under `Code/Python/` (`solution.py`, `resources.py`,
`stages/cons_noshocks.py`) are vendored verbatim from
<https://github.com/llorracc/SolvingMicroDSOPs> at a pinned revision.
See `NOTICES.md` and `scripts/revendor_smd.sh` for the refresh
workflow.
