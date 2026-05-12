#!/usr/bin/env bash
# reproduce.sh - thin orchestration wrapper for the Cagetti2005tk REMARK.
#
# Two supported invocations:
#
#   ./reproduce.sh
#       Run the canonical computational reproduction (delegates to
#       ./reproduce_min.sh: notebook + scripts/check_reproduction.py).
#
#   ./reproduce.sh --docs main
#       Build the LaTeX write-up (Cagetti2005tk.pdf) from
#       Cagetti2005tk.tex using the host TeX Live install.
#
# This wrapper deliberately does NOT expose the HAFiscal-inherited
# --comp / --data / --envt flags. Those pipelines belong to the
# HAFiscal REMARK and are not part of any Cagetti2005tk reproduction.
# The original 2528-line script is preserved unmodified for reference at
# legacy/reproduce.sh.hafiscal but is not invoked from here.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

usage() {
    cat <<'EOF'
Cagetti2005tk reproduction wrapper

Usage:
  ./reproduce.sh                Run the minimal computational reproduction.
                                Equivalent to ./reproduce_min.sh.
  ./reproduce.sh --docs main    Build Cagetti2005tk.pdf from
                                Cagetti2005tk.tex (requires host TeX Live).
  ./reproduce.sh --help         Show this help.

For details on what is reproduced (and what is intentionally not), see
REMARK.md and ARCHITECTURE.md. The optional LaTeX build is not part of
the supported minimal reproduction path; the REMARK catalog tooling
(cli.py execute) only invokes the bare ./reproduce.sh form.
EOF
}

build_docs_main() {
    local tex="Cagetti2005tk.tex"
    if [[ ! -f "$tex" ]]; then
        echo "ERROR: $tex not found in $REPO_ROOT" >&2
        exit 1
    fi
    if ! command -v pdflatex >/dev/null 2>&1; then
        echo "ERROR: pdflatex is not on PATH." >&2
        echo "Install a TeX Live distribution (with the econark class file" >&2
        echo "and texlive-{latex,fonts,bibtex}-extra) and re-run this command." >&2
        exit 1
    fi

    echo "Building Cagetti2005tk.pdf via pdflatex / bibtex / pdflatex x2 ..."
    if command -v latexmk >/dev/null 2>&1; then
        latexmk -pdf -interaction=nonstopmode "$tex"
    else
        pdflatex -interaction=nonstopmode "$tex"
        bibtex   Cagetti2005tk || true
        pdflatex -interaction=nonstopmode "$tex"
        pdflatex -interaction=nonstopmode "$tex"
    fi
    echo "Done. Output: Cagetti2005tk.pdf"
}

case "${1:-}" in
    "" )
        echo "================================================================="
        echo "Cagetti2005tk reproduction (delegating to ./reproduce_min.sh)"
        echo "================================================================="
        echo "For the LaTeX write-up, run separately: ./reproduce.sh --docs main"
        echo
        exec ./reproduce_min.sh
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    --docs)
        case "${2:-main}" in
            main)
                build_docs_main
                exit 0
                ;;
            *)
                echo "ERROR: --docs only supports 'main' (got '${2:-}')." >&2
                echo "       Other document targets from the HAFiscal template are not" >&2
                echo "       part of this REMARK." >&2
                exit 2
                ;;
        esac
        ;;
    *)
        echo "ERROR: unknown argument '$1'." >&2
        echo "       The HAFiscal-inherited --comp / --data / --envt flags are not" >&2
        echo "       supported by this REMARK; see legacy/reproduce.sh.hafiscal" >&2
        echo "       if you need that script for upstream cross-reference." >&2
        echo
        usage
        exit 2
        ;;
esac
