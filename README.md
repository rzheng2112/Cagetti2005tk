# Cagetti2005tk

Partial computational reproduction of **Cagetti and De Nardi (2006)**,
*Entrepreneurship, Frictions, and Wealth*, packaged as an Econ-ARK
**REMARK-in-progress** (target: Tier 2 documentation and local
reproducibility). This repository is a course project; it is **not** an
officially accepted Econ-ARK catalog entry.

[![Powered by Econ-ARK](./@resources/econ-ark/PoweredByEconARK.svg)](https://econ-ark.org)

---

## Research question and paper

Marco Cagetti and Mariacristina De Nardi (2006) ask how entrepreneurial
ability, borrowing constraints, and bequest motives shape occupational
choice and the wealth distribution. The published article is

> Cagetti, M. and De Nardi, M. (2006), “Entrepreneurship, Frictions, and
> Wealth,” *Journal of Political Economy*, 114(5), 835–870.
> [DOI: 10.1086/508032](https://doi.org/10.1086/508032).

The repository name uses the working-paper year (**2005**); the journal
version is **2006**. Cite the journal article for the economic model, and
this repository (see `CITATION.cff`) for the reproduction code.

---

## What this REMARK actually reproduces

Supported path: fixed-price household Bellman system (paper eqs. 2–14) at
the paper’s calibrated structural parameters (Table 5), solved by damped
value-function iteration with an Endogenous Grid Method (EGM)
consumption stage from SolvingMicroDSOPs (`Code/Python/`). Each sweep updates the retiree, worker, old entrepreneur, and young entrepreneur branches in that order before damping the outer values.

| Included | Not included |
|----------|--------------|
| Young worker / entrepreneur occupational choice | General-equilibrium price clearing (Appendix B) |
| Old entrepreneur / retiree continuation | Full demographic stationary distribution |
| Enforcement / collateral constraint on \(k\) | Budget-balanced payroll tax / pension fixed point |
| Young-only \(\mu\) diagnostic | Formal match to paper Table 6 / Table 7 GE moments |
| PE comparative-static re-solves | Estate taxation (unused extension parameter) |

We take the net interest rate (0.065) from the paper’s Table 7 baseline and normalize the wage to one.
\(\tau = 0.10\) is illustrative. Wealth Gini and top shares from the
young-only kernel are **PE diagnostics**, not paper Table 6 moments and
not formal lower bounds on the GE distribution.

---

## Baseline results

The baseline uses the stationary distribution of young households.

| Metric | Value |
|--------|------:|
| VFI iterations (converged) | 115 |
| Final sum-norm | \(4.75\times10^{-4}\) |
| Entrepreneur share (young-only \(\mu\)) | 0.083286 |
| Mean assets | 4.179171 |
| Wealth Gini (young-only PE) | 0.671421 |
| Top 1% wealth share (young-only PE) | 0.143569 |

Paper Table 6 (for comparison only): entrepreneur share \(\approx 0.075\),
wealth Gini \(\approx 0.80\). Differences reflect scope (PE, young-only,
numerical grids), not a single identified mechanism.

---

## Numerical methods and known limitations

- **EGM.** Shock-free consumption stages use `solve_cons_noshocks`. Marginal
  continuation value on the multi-exponential asset grid uses first-order
  one-sided endpoint differences and irregular-grid central differences
  (equivalent to `np.gradient(..., edge_order=1)`). Do not revert to
  `edge_order=2` on this grid.
- **Capital grid.** Entrepreneurial \(k\) is chosen on a discrete hybrid
  grid with ceiling `k_max = 18`. Enforcement and the numerical ceiling
  can both bind (about 14/56 young and 6/80 old entrepreneurial states at
  the ceiling in the baseline).
- **Residual EGM gaps.** Small objective gaps \(O(10^{-3})\) can remain on
  coarse upper-grid nodes; they are far smaller than the pre-fix
  upper-boundary failure.
- **Counterfactuals.** Some PE re-solves hit `max_iter` with large
  residuals (`converged=False` in `counterfactuals.csv`). Those rows are
  diagnostics only, not valid comparative statics. The 35-point \(k\)
  experiment is a **uniform** grid over \([10^{-5}, k_{\max}]\), not a
  denser version of the hybrid grid.

---

## How to reproduce

### Requirements

- [`uv`](https://docs.astral.sh/uv/) (installs the locked Python 3.9
  environment from `pyproject.toml` / `uv.lock`)
- Optional: TeX Live (only for `./reproduce.sh --docs main`)

### Minimal computational reproduction (~8–12 minutes)

```bash
git clone https://github.com/rzheng2112/Cagetti2005tk.git
cd Cagetti2005tk
./reproduce.sh
```

Bare `./reproduce.sh` delegates to `./reproduce_min.sh`, which:

1. Runs `uv sync --locked --group jupyter`
2. Installs an isolated Jupyter kernel bound to the project interpreter
3. Executes `Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb`
4. Runs `scripts/check_reproduction.py` on the persisted tables

The source notebook is stored without execution outputs. Running the
reproduction writes the executed notebook and log under `.reproduction/`.
The figures and tables listed below are also available in the repository.

Equivalent:

```bash
./reproduce_min.sh
```

### Optional LaTeX write-up

```bash
./reproduce.sh --docs main
```

This builds `Cagetti2005tk.pdf` and is **not** part of the minimal
computational path.

### Checks

`scripts/check_reproduction.py` asserts bands around the corrected
baseline (entrepreneur share, mean assets, \(E[y]\), VFI residual,
convergence, young-only Gini, and top 1% and 5% wealth shares) and checks that any counterfactual row
marked `converged=True` has a finite, nonnegative residual below 0.0005. It does **not** require
selected scenarios to stay nonconverged.

---

## Supported regenerated outputs

Nine artifacts are produced by the supported notebook and checked for
presence:

**Tables** (`Tables/Cagetti2005tk/`)

- `summary.csv`
- `counterfactuals.csv`
- `wealth_concentration.csv`

**Figures** (`Figures/Cagetti2005tk/`)

- `convergence.{pdf,png}`
- `values_policies_kstar.{pdf,png}`
- `mu_marginal_assets.{pdf,png}`

**Historical artifacts without a verified generator in this workflow**
(preserved, not checked as reproduction outputs):

- `Figures/Cagetti2005tk/wealth_lorenz.{pdf,png}`
- `Figures/Cagetti2005tk/wealth_moments.csv`

---

## Repository map

| Path | Role |
|------|------|
| `Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb` | Supported reproduction notebook |
| `Code/Python/` | Vendored SolvingMicroDSOPs EGM stage |
| `scripts/check_reproduction.py` | Post-run numerical / inventory checks |
| `reproduce_min.sh`, `reproduce.sh` | Minimal runner and thin wrapper |
| `REMARK.md` | Scope, tier metadata, limitations |
| `CITATION.cff`, `codemeta.json`, `pyproject.toml` | Citation and project metadata |
| `binder/`, `Dockerfile` | Binder / container adapters |
| `Cagetti2005tk.tex`, `Subfiles/` | Course write-up (optional build) |
| `legacy/` | HAFiscal template material (not this REMARK) |

Narrative notebooks under `Cagetti2005tk_material/` (intro, literature,
summary, Bellman stages) are companions, not reproduction artifacts.

---

## Environment notes

Primary environment: **`uv sync --locked --group jupyter`**.
`binder/environment.yml` is an adapter for Binder / REMARK tooling.
Conda users can run `conda env create -f binder/environment.yml`, then
`conda activate cagetti2005tk` and `./reproduce.sh`. LaTeX is optional and separate from the computational path.

Layout descends from the HAFiscal / Econ-ARK template; legacy HAFiscal
`--comp` / `--data` pipelines are **not** part of Cagetti2005tk
reproduction (see `legacy/README.md`).

---

## Citation

Software / reproduction repository: see `CITATION.cff` (author Rudan Zheng).

Preferred citation for the economic model: Cagetti and De Nardi (2006),
JPE, DOI [10.1086/508032](https://doi.org/10.1086/508032).

Repository: <https://github.com/rzheng2112/Cagetti2005tk>

---

## License

Apache-2.0 (see `LICENSE`). Vendored SolvingMicroDSOPs files retain their
upstream notices (`NOTICES.md`).
