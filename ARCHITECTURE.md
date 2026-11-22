# Cagetti2005tk Code Architecture

**Purpose**: One-screen map of where each piece of the REMARK lives, what
calls what, and where outputs land.

**Scope**: This document is normative *only* for the supported REMARK
reproduction path (the theory-model notebook + the LaTeX write-up).
Computational sub-trees inherited from the upstream HAFiscal template
(`legacy/Code-HA-Models/`, `legacy/Code-Empirical/`, `reproduce/reproduce_data_moments*`)
are still on disk for legacy reasons but are not part of any reproduction
this REMARK claims; see `NOTICES.md` and `legacy/`.

---

## High-level data flow

```
./reproduce.sh
        |
        v
reproduce_min.sh
        |
        +--> Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
        |       (imports vendored solution.py + stages/cons_noshocks.py
        |        from Code/Python/, solves the household Bellman system)
        |               |
        |               v
        |       Figures/Cagetti2005tk/*.{pdf,png}
        |       Tables/Cagetti2005tk/*.csv
        |
        +--> scripts/check_reproduction.py
                (checks nine outputs and reads the three generated tables)
```

The optional LaTeX build (invoked separately via `./reproduce.sh --docs main`)
consumes those artifacts and produces `Cagetti2005tk.pdf`.

---

## Directory layout (reproduction-relevant only)

```
Cagetti2005tk/
├── reproduce_min.sh                      # canonical computational entry point
├── reproduce.sh                          # thin wrapper: bare = reproduce_min;
│                                         # --docs main = LaTeX build
├── REMARK.md                             # standard-tier metadata + scope
├── README.md                             # quick start
├── CITATION.cff                          # author + paper citation
├── NOTICES.md                            # third-party / vendored code
├── LICENSE                               # Apache-2.0
├── pyproject.toml + uv.lock              # Python deps (pinned)
├── environment.yml                       # same uv bootstrap as binder/environment.yml
├── binder/                               # Binder bootstrap (uv-based)
├── Dockerfile                            # repo2docker-compatible image
├── Cagetti2005tk.tex                     # main LaTeX document
├── Subfiles/                             # LaTeX section subfiles
├── Cagetti2005tk_material/
│   └── cagetti2005_theory_reproduction.ipynb   # *the* reproduction notebook
├── Code/Python/                          # vendored SolvingMicroDSOPs stage
│   ├── solution.py                       #   (see NOTICES.md)
│   ├── resources.py
│   └── stages/cons_noshocks.py
├── scripts/
│   ├── check_reproduction.py             # post-run numerical assertions
│   └── revendor_smd.sh                   # refresh vendored upstream
├── Figures/Cagetti2005tk/                # persisted plots (tracked)
├── Tables/Cagetti2005tk/                 # persisted scalars (tracked)
└── legacy/                               # HAFiscal-inherited; not used by REMARK
```

---

## Notebook structure

`Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb` is the only
file that produces persisted reproduction artifacts. Cells are numbered
to match the README of the notebook itself:

| Part | Cells | Role |
|------|-------|------|
| I    | 0–1   | Restate the paper's Bellman system (eqs. 2–14) |
| II   | 2     | Map paper notation to the SolvingMicroDSOPs stage API |
| III  | 3–13  | Setup, imports, parameter blocks (`PaperStructuralParams`, `FixedPriceInputs`, `SolverSettings`), income process, EGM wrappers, damped sequential VFI |
| IV   | 14–21 | Convergence diagnostics, value/policy plots, comparative-statics sweep, young-only stationary distribution, wealth concentration, persisted CSV writes |
| V    | 22    | Scope, what is and is not reproduced, next steps |

Three things are worth knowing before reading the code:

1. **`REPO_ROOT` discovery** (cell 4) honors the `CAGETTI_REPO_ROOT`
   environment variable when set (this is how `reproduce_min.sh` pins it).
   It falls back to walking `Path.cwd().parents` looking for `Code/Python/`.
2. **Matplotlib backend** (cell 4) selects `Agg` only when no `DISPLAY` is
   set and `MPLBACKEND` has not been pinned, so interactive Jupyter
   sessions still get a usable backend.
3. **Vendored code** (`Code/Python/solution.py`, `stages/cons_noshocks.py`)
   is byte-for-byte from `llorracc/SolvingMicroDSOPs` at the revision
   recorded in `scripts/revendor_smd.sh`. Do not edit it in place;
   re-vendor instead.

---

## Module dependency graph

```
numpy, scipy, matplotlib  (locked Python packages)
        ^
        |
Code/Python/solution.py            <-- vendored, do not edit
Code/Python/stages/cons_noshocks.py <-- vendored, do not edit
        ^
        |
Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
        |
        +--> Figures/Cagetti2005tk/*.{pdf,png}
        +--> Tables/Cagetti2005tk/*.csv
                ^
                |
        scripts/check_reproduction.py
```

The supported notebook uses the scientific packages and Jupyter dependencies installed by `reproduce_min.sh`.

---

## Entry points

### `./reproduce_min.sh` — canonical computational reproduction

1. Checks the notebook, vendored modules, and checker, then installs the locked environment with `uv sync --locked --group jupyter`.
2. Registers a temporary kernel and verifies its interpreter against the project Python.
3. Clears the nine declared outputs and executes the notebook with the project Python's nbconvert module. The executed copy and log are in `.reproduction/`.
4. Runs the checker with the same Python interpreter.

Expected wall time on a recent laptop: **8–12 minutes** (dominated by the
counterfactual sweep in notebook cell 19).

### `./reproduce.sh` — thin orchestration wrapper

| Invocation | What it does |
|------------|--------------|
| `./reproduce.sh`                    | Calls `./reproduce_min.sh` (no LaTeX). |
| `./reproduce.sh --docs main`        | Builds `Cagetti2005tk.pdf` from `Cagetti2005tk.tex`. |
| `./reproduce.sh --help`             | Usage. |

This wrapper is intentionally tiny. The HAFiscal-inherited
`reproduce/reproduce_*.sh` scripts are not invoked from it and are kept
only for the legacy sub-trees under `legacy/Code-HA-Models/` and
`legacy/Code-Empirical/`.

### `uv run --no-sync python scripts/check_reproduction.py` — standalone post-run check

Checks that all nine declared outputs exist and are nonempty. The baseline checks use inclusive bands:

| metric | expected band |
|---|---|
| `ent_share_mu_young_only` | `[0.05, 0.12]` |
| `E_y_under_mu`            | `[0.90, 1.10]` |
| `mean_assets_mu` | `[3.80, 4.60]` |
| `final_sum_norm` | `[0, 0.0005)` |
| `gini` (wealth table) | `[0.64, 0.72]` |
| `top1`, `top5` (wealth table) | `[0.14, 0.15]`, `[0.36, 0.38]` |
| `converged`               | `True` |

The baseline counterfactual row must converge. Residuals must be finite and nonnegative. A converged row must have a residual below 0.0005. Other rows can be retained as diagnostics. Exit codes are 0 for success, 1 for a failed numerical check, and 2 for a missing or empty required output.

---

## Persisted artifacts

After a successful `./reproduce_min.sh` the following files are
regenerated and (per `.gitignore` carve-outs) tracked in git so that a
reviewer can `git diff` against a fresh run:

```
Figures/Cagetti2005tk/
  convergence.{pdf,png}             # VFI sup-norm history
  values_policies_kstar.{pdf,png}   # value functions + k*(a, theta)
  mu_marginal_assets.{pdf,png}      # young-only stationary distribution

Tables/Cagetti2005tk/
  summary.csv                # headline scalars (consumed by check script)
  counterfactuals.csv        # comparative-statics sweep
  wealth_concentration.csv   # young-only Gini and top wealth shares
```

---

The two `wealth_lorenz` figures and `wealth_moments.csv` in the figure directory are historical artifacts with unverified generators. The young-only wealth statistics establish no formal bounds on the paper’s full-population moments.

## What is *not* covered by this architecture

- `legacy/Code-HA-Models/`, `legacy/Code-Empirical/`, `reproduce/reproduce_data_moments*`,
  the `--comp` and `--data` HAFiscal flags, `reproduce/docker/setup.sh`:
  these belong to the historical HAFiscal workflow. The original development notes are in `history/`. None of them are used by
  any reproduction this REMARK claims, and none of them will be invoked
  by the entry points listed above.
- The full general-equilibrium fixed-point of Cagetti & De Nardi (2006):
  see `REMARK.md` "What IS NOT reproduced" for the deliberate
  simplifications and their justification.

---

**For questions or to file an issue**: <https://github.com/rzheng2112/Cagetti2005tk/issues>
