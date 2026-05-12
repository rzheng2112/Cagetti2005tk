# Binder configuration

This directory configures [MyBinder.org](https://mybinder.org) for the
Cagetti2005tk REMARK.

## How the bootstrap works

1. `environment.yml` (in this directory) is intentionally minimal: it
   installs Python 3.9 and `uv` only. It is **not** the canonical
   dependency manifest. The repo-root `pyproject.toml` + `uv.lock` are
   the canonical pin, and we want Binder to install exactly those locked
   versions rather than letting conda re-solve to a different
   numpy/scipy/etc.
2. `apt.txt` lists the system packages (`latexmk` + a small TeX subset)
   that are needed only if a Binder user clicks the optional
   `./reproduce.sh --docs main` path. The supported minimal reproduction
   does not need them.
3. `postBuild` runs `uv sync --frozen` so the Binder session ends up with
   the same `.venv/` as a local `./reproduce_min.sh` run.

## Files

- `environment.yml` — minimal Python + uv bootstrap (separate file, **not**
  a symlink to the repo-root `environment.yml`). The two files have
  intentionally different scopes; see the comment headers in each.
- `apt.txt` — system packages installed via apt-get at build time.
- `postBuild` — installs the locked Python environment via `uv sync --frozen`.

## Testing locally

```bash
# In a fresh Python 3.9 environment with uv installed
uv sync --frozen
source .venv/bin/activate
./reproduce_min.sh
```

If that succeeds locally with the `uv.lock` committed at the same
revision, Binder should also succeed.
