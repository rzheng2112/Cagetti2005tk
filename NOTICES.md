# Third-party notices

This REMARK contains code vendored from other open-source projects. This
file enumerates the vendored artifacts, their upstream source, and the
terms under which they are redistributed here.

## SolvingMicroDSOPs (Carroll)

- **Upstream repository:** https://github.com/llorracc/SolvingMicroDSOPs
- **Pinned revision:** `03884752c372`
- **Vendored files:**
  - `Code/Python/solution.py`
  - `Code/Python/resources.py`
  - `Code/Python/stages/__init__.py`
  - `Code/Python/stages/cons_noshocks.py`
- **Refresh script:** `scripts/revendor_smd.sh`
- **Why vendored (not pip-installed):** SolvingMicroDSOPs is a LaTeX +
  code lecture-notes template rather than a distributable Python package,
  so there is no PyPI artifact to pin; vendoring at a specific git revision
  is the lowest-friction way to keep the reproduction reproducible.
- **License:** SolvingMicroDSOPs is distributed under the Apache License
  2.0 (see the upstream `LICENSE`), which matches this repository's
  license. Attribution is provided both here and in the per-file
  provenance header at the top of each vendored file.

## Econ-ARK template artifacts

Parts of the repository layout and build tooling (the `@local/`,
`@resources/`, `reproduce/` directories and the HAFiscal-derived
`reproduce.sh`) originate from the Econ-ARK / HAFiscal REMARK template.
Those contents are governed by the Econ-ARK Apache-2.0 license; our
modifications are likewise Apache-2.0.
