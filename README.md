# Cagetti2005tk

Public course-project repository on **Cagetti and De Nardi (2006)**, *Entrepreneurship, Frictions, and Wealth*. It contains the LaTeX write-up, supporting material, and notebooks used in the assignment.

[![Powered by Econ-ARK](./@resources/econ-ark/PoweredByEconARK.svg)](https://econ-ark.org)

---

## Reference paper

Marco Cagetti and Mariacristina De Nardi (2006), “Entrepreneurship, Frictions, and Wealth,” *Journal of Political Economy*, 114(5), 835–870. [DOI: 10.1086/508032](https://doi.org/10.1086/508032).

The repository name follows the working-paper year, while the published article appeared in **2006**.

---

## Repository structure

| Path | Role |
|------|------|
| `Cagetti2005tk.tex`, `Cagetti2005tk.bib`, `Cagetti2005tk-Add-Refs.bib` | Main document and bibliographies |
| `Subfiles/` | Sections of the write-up |
| `Figures/`, `Tables/`, `images/` | Figures and tables |
| `Cagetti2005tk_material/` | Jupyter notebooks and MyST config (`myst.yml`) |
| `reproduce/` | Scripts used by `reproduce.sh` |
| `Code/` | Computational code (large tree; optional for the write-up) |
| `@local/`, `@resources/` | LaTeX paths and shared resources |
| `pyproject.toml`, `environment.yml`, `binder/` | Python / Binder / conda configuration |

---

## Environment / installation

**Python and notebooks:** Use **`uv`** with `pyproject.toml` as described in the header of `environment.yml` (for example, `uv sync` and then activate the project environment), or use **Conda** with `conda env create -f environment.yml` and activate the environment defined there.

**LaTeX:** Install a current TeX distribution (for example, TeX Live) with standard packages for `pdflatex`, `bibtex`, and the Econ-ARK-style class files used by this project.

**Binder:** Configuration is provided under `binder/` for an optional cloud environment.

---

## How to run

### Minimal computational reproduction (~8–12 minutes on a recent laptop)

From the repository root:

```bash
./reproduce.sh
```

This is a thin wrapper that delegates to `./reproduce_min.sh`, which executes the theory-model reproduction notebook

```
Cagetti2005tk_material/cagetti2005_theory_reproduction.ipynb
```

and then runs `scripts/check_reproduction.py` to assert numerical bands on `Tables/Cagetti2005tk/summary.csv`.

The notebook re-states the Cagetti and De Nardi (2006) household Bellman system (equations 2–14) and solves it at the paper's calibrated structural parameters in a fixed-price environment, using the SolvingMicroDSOPs stage package. It is the supported minimal computational reproduction for this REMARK.

The notebook imports `solution` and `stages.cons_noshocks` from `Code/Python/`. `reproduce_min.sh` checks that those files are present and exits with an explanatory error if they are not, so that a failed minimal reproduction is never silent. Most of the wall time is spent on the comparative-statics sweep in notebook cell 19; the baseline VFI itself converges in ~115 sweeps.

### Main LaTeX document (optional)

To build `Cagetti2005tk.pdf`:

```bash
./reproduce.sh --docs main
```

Or, directly with a TeX toolchain from the repository root:

```bash
pdflatex Cagetti2005tk.tex
bibtex   Cagetti2005tk
pdflatex Cagetti2005tk.tex
pdflatex Cagetti2005tk.tex
```

If you use `latexmk` (for example via the bundled `.latexmkrc`), you can compile with that instead.

The LaTeX build is **not** part of the supported minimal reproduction path; the bare `./reproduce.sh` does not invoke it (the REMARK catalog tooling does not assume a TeX Live install in the reviewer's environment).

### Legacy HAFiscal scripts

The directory layout descends from the upstream HAFiscal REMARK template. The original 2528-line HAFiscal `reproduce.sh` (with its `--comp` / `--data` / `--envt` pipelines) is preserved unmodified at `legacy/reproduce.sh.hafiscal` for cross-reference, but it is **not** invoked from the current `reproduce.sh` and produces no Cagetti2005tk results.

### Other notebooks

The remaining notebooks under `Cagetti2005tk_material/` (intro, prior literature, summary, subsequent literature, Bellman-stages write-up) are narrative companions to the paper, not reproduction artifacts; they can be opened directly in Jupyter after activating your Python environment.

---

## Reproducibility notes

The REMARK-supported reproduction path is `./reproduce_min.sh` (theory-model notebook) plus `./reproduce.sh --docs main` (LaTeX write-up). PDFs and auxiliary outputs can be regenerated from these sources. What is tracked in git follows this repository's `.gitignore` and publishing choices. Large computational trees under `Code/HA-Models/` and `Code/Empirical/` are HAFiscal-inherited and separate from the Cagetti2005tk reproduction path.

---

## Current project status

Course project **Cagetti2005tk**, focused on Cagetti and De Nardi (2006). The write-up is built from `Cagetti2005tk.tex`; notebooks and materials under `Cagetti2005tk_material/` support the analysis.

---

## Legacy / attribution

The directory layout and `reproduce/` tooling descend from the **HAFiscal / Econ-ARK** template. That explains shared script names and optional pipelines; this repository’s **content** centers on the Cagetti–De Nardi (2006) exercise, not the HAFiscal paper.
