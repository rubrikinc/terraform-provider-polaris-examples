#!/bin/sh

set -e

# Required tools
if ! command -v terraform-docs >/dev/null 2>&1; then
  echo "error: the terraform-docs command must be installed"
  exit 1
fi

function gen_docs() {
  find . -type f -name "README.md" | while read -r file; do
    if grep -q "<!-- BEGIN_TF_DOCS -->" "$file" && grep -q "<!-- END_TF_DOCS -->" "$file"; then
      terraform-docs markdown table --hide-empty --output-file README.md --sort "$(dirname "$file")"
    fi
  done
}

dir=$(dirname "$0")
(
  cd "$dir"
  gen_docs
)
