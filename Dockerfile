# Cagetti2005tk Dockerfile
#
# Scope: this image is the canonical computational-reproduction container.
# Running `docker build -t cagetti2005tk . && docker run --rm cagetti2005tk`
# executes ./reproduce_min.sh end-to-end (theory-model notebook +
# scripts/check_reproduction.py).
#
# The optional LaTeX build (Cagetti2005tk.tex -> Cagetti2005tk.pdf) is
# *not* part of this image. A reviewer who wants the PDF should run
# `./reproduce.sh --docs main` against a host TeX Live install. Bundling
# TeX Live (~3 GB) into the reproducibility image is unnecessary for the
# REMARK-supported reproduction path.
#
# The image is repo2docker-compatible at the file-layout level, so it
# also works as a Binder source if you point Binder at this repo.

FROM python:3.9-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UV_LINK_MODE=copy

# Minimal system packages: build tools for any wheels that need to compile
# from source on this slim base, plus curl/git for uv bootstrap and the
# revendor script.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user mirroring the repo2docker convention; this is
# also what most REMARK CI tooling expects so file ownership in
# bind-mounts behaves sanely.
ARG NB_USER=jovyan
ARG NB_UID=1000
RUN useradd --create-home --shell /bin/bash --uid ${NB_UID} ${NB_USER}

WORKDIR /home/${NB_USER}/work
COPY --chown=${NB_USER}:${NB_USER} . /home/${NB_USER}/work

USER ${NB_USER}
ENV PATH="/home/${NB_USER}/.local/bin:${PATH}"

# Install uv (fast, deterministic Python env manager) and sync the locked
# project environment from pyproject.toml + uv.lock. We use --frozen so a
# stale lockfile fails the build instead of silently resolving a different
# numpy/scipy/etc.
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && uv sync --frozen --all-groups

# Make the venv's python/jupyter the default for non-login shells.
ENV VIRTUAL_ENV="/home/${NB_USER}/work/.venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Default invocation: run the supported minimal reproduction. Override
# with e.g. `docker run --rm -it cagetti2005tk bash` to drop into a shell
# or with `... jupyter notebook --ip=0.0.0.0` to explore interactively.
CMD ["./reproduce_min.sh"]
