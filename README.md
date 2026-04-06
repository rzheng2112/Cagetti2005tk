# Cagetti2005tk — REMARK

[![Powered by Econ-ARK](./@resources/econ-ark/PoweredByEconARK.svg)](https://econ-ark.org)

**Paper**: *Entrepreneurship, Frictions, and Wealth*
**Authors**: Marco Cagetti and Mariacristina De Nardi
**Journal**: Journal of Political Economy, Vol. 114, No. 5, October 2006
**DOI**: [10.1086/508032](https://doi.org/10.1086/508032)

---

## Overview

This is a REMARK (Replications and Explorations Made using the ARK) for:

> Cagetti, Marco and Mariacristina De Nardi (2006). "Entrepreneurship, Frictions, and Wealth." *Journal of Political Economy*, 114(5), 835–870.

The paper constructs and calibrates a parsimonious model of occupational choice that allows for entrepreneurial entry, exit, and investment decisions in the presence of borrowing constraints. The model fits the observed wealth distribution for entrepreneurs and workers. More restrictive borrowing constraints generate less wealth concentration but also reduce average firm size, aggregate capital, and the fraction of entrepreneurs. Voluntary bequests allow some high-ability workers to establish or enlarge an entrepreneurial activity.

## Repository Structure

```
Cagetti2005tk.tex          Main LaTeX document
Cagetti2005tk.bib          Bibliography (self-reference)
Cagetti2005tk-Add-Refs.bib Additional references cited in the paper
Subfiles/                  Paper sections (Introduction, Model, etc.)
Figures/                   Figure LaTeX wrappers
Tables/                    Table LaTeX files
images/                    Figure image files
Equations/                 Equation definitions
Code/                      Computational code
@local/                    Local LaTeX configuration
@resources/                Shared LaTeX resources
Cagetti2005tk_material/    Source material and notebooks
```

## Key Model Features

- **Life cycle with altruism**: Households go through young and old age with intergenerational bequest motives
- **Occupational choice**: Agents choose between entrepreneurship and wage work each period
- **Endogenous borrowing constraints**: Entrepreneurs' assets act as collateral; borrowing limits arise from imperfect contract enforcement
- **Two sectors**: Entrepreneurial firms with decreasing returns and a competitive non-entrepreneurial sector

## Building the Paper

```bash
pdflatex Cagetti2005tk.tex
bibtex Cagetti2005tk
pdflatex Cagetti2005tk.tex
pdflatex Cagetti2005tk.tex
```

## References

- Cagetti, M. and M. De Nardi (2006). "Entrepreneurship, Frictions, and Wealth." *Journal of Political Economy*, 114(5), 835–870.
- Based on the [HAFiscal](https://github.com/llorracc/HAFiscal-Public) LaTeX template by Carroll et al.
