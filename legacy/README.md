# `legacy/` — HAFiscal-inherited artifacts

Everything in this directory originates from the upstream HAFiscal
REMARK template that this Cagetti2005tk repository was cloned from.
None of these files are part of the Cagetti2005tk reproduction:

- `HAFiscal.{tex,pdf,bib,bbl,dep,md}`, `HAFiscal-Slides.*`,
  `HAFiscal-Abstract.txt` — the HAFiscal paper sources and compiled
  artifacts; kept here for reference but not compiled by
  `./reproduce.sh --docs main`.
- `HANK-and-SAM-tutorial.ipynb`, `HANK_and_SAM_tutorial_utils.py` —
  a HANK+SAM tutorial notebook unrelated to Cagetti & De Nardi (2006).
- `Code-HA-Models/`, `Code-Empirical/` — the HAFiscal computational
  pipelines invoked by `./reproduce.sh --comp full` / `--data`. They
  are deliberately preserved because the inherited `reproduce.sh` can
  still drive them (they are *not* Cagetti reproductions; see
  `README.md` and `REMARK.md`).
- `dashboard/`, `NOTEBOOK-CONSOLIDATION.md`,
  `README_IF_YOU_ARE_AN_AI/` — HAFiscal development aids.
- `Subfiles-HAFiscal-titlepage.tex` — titlepage subfile referenced
  only by `HAFiscal.tex`, never by `Cagetti2005tk.tex`.

Why keep them? Deleting outright would break
`./reproduce.sh --comp ...` and `./reproduce.sh --data`, which are
still exposed in the inherited CLI for users who specifically want
to run HAFiscal's pipelines. Moving them under `legacy/` makes it
unambiguous to a REMARK reviewer which files are in scope for this
REMARK and which are HAFiscal-inherited scaffolding.
