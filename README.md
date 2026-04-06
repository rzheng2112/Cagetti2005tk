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

**Build the main PDF** from the repository root:

```bash
pdflatex Cagetti2005tk.tex
bibtex Cagetti2005tk
pdflatex Cagetti2005tk.tex
pdflatex Cagetti2005tk.tex
```

If you use `latexmk` (for example via a `.latexmkrc`), you can compile with that instead.

**Automation:** `./reproduce.sh --docs main` calls `reproduce/reproduce_documents.sh` to build the main document (`Cagetti2005tk.tex`) and optional scopes. See `reproduce/README.md` for flags. The script bundle inherits optional pipelines from the upstream HAFiscal workflow (for example, `--comp` and `--data`); use only what your course requires.

**Notebooks:** Open the notebooks under `Cagetti2005tk_material/` in Jupyter after activating your Python environment.

---

## Reproducibility notes

PDFs and auxiliary outputs can be regenerated from the LaTeX and notebook sources. What is tracked in git follows this repository’s `.gitignore` and publishing choices. Large computational trees under `Code/` are separate from compiling `Cagetti2005tk.tex`.

---

## Current project status

Course project **Cagetti2005tk**, focused on Cagetti and De Nardi (2006). The write-up is built from `Cagetti2005tk.tex`; notebooks and materials under `Cagetti2005tk_material/` support the analysis.

---

## Legacy / attribution

The directory layout and `reproduce/` tooling descend from the **HAFiscal / Econ-ARK** template. That explains shared script names and optional pipelines; this repository’s **content** centers on the Cagetti–De Nardi (2006) exercise, not the HAFiscal paper.
